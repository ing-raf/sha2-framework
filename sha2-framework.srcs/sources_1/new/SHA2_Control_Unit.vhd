--! @file SHA2_Control_Unit.vhd
--! @brief Control Unit entity definition and its implementations
--! @details This file contains the entity definiton for the Control Unit, and two different implementations. The choose
--! between the two is transparent to the user, instead is driven by the architectural parameters set in the 
--! @link SHA2_core top level entity@endlink.
--! @details Namely, the @link SHA2_Control_Unit.FSM FSM@endlink architecture is instantiated when the 
--! @link SHA2_core.FIX_TIME FIX_TIME@endlink parameter is set to @c false, otherwise the 
--! @link SHA2_Control_Unit.Reordering Reordering@endlink architecture is instantiated.

--! Standard library
library ieee;
--! Standard 9-values logic library
use ieee.std_logic_1164.all;

--! @brief Control Unit for the hash core
--! @details It employs an external stage counter so as to be able to support a generic number
--! of pipeline stages
entity SHA2_Control_Unit is
	generic(
		CYCLES_PER_STAGE : natural := 1
	);
	port(
		--! Clock of this component
		clk               : in  std_logic;
		--! Active-low asynchronous reset signal
		not_rst           : in  std_logic;
		--! When asserted, a new Padded Data Block to be hashed is present at input      
		start             : in  std_logic;
		--! Asserted when a round is over
		count_top         : in  std_logic;
		--! Asserted when the pipeline has been flushed
		count_stages_top  : in  std_logic;
		--! Active-low signal to reset the step counter
		not_reset_count   : out std_logic;
		--! Asserted during hash computation to enable step counting
		count             : out std_logic;
		--! Asserted when no new Padded Data Block is available, in order to complete the ongoing hashes
		count_stages      : out std_logic;
		--! @brief Control signal to allow starting the hash core
		--! @details This signal fixes @link SHA2_core.RTL.end_major_cycle end_major_cycle@endlink
		--! behaviour during the very first major cycle
		first_major_cycle : out std_logic;
		--! Control signal to initialises the expansion pipeline
		expander_init     : out std_logic;
		--! @brief Control signal asserted when the circuit can accept new inputs
		--! @details This signal is used only in fully pipelined architectures. In other cases, it is always low
		ready_cu          : out std_logic
	);
end entity SHA2_Control_Unit;

--! @brief Finite State Machine to control the hash core
--! @details For this FSM, the signal @link SHA2_Control_Unit.expander_init expander_init@endlink is
--! the same signal as @link SHA2_Control_Unit.first_major_cycle first_major_cycle@endlink
--! @imageSize{SHA_CU.png,width:700px;}
--! @image html SHA_CU.png "Finite State Machine for the SHA-2 core"
--! @details During the @c compute stage, the signal @link SHA2_Control_Unit.count count@endlink
--! enables the step counter so as to keep track of the computing progresses. This counter produces
--! also the signal @link SHA2_Control_Unit.count_top count_top@endlink, which is the pipeline clock
--! signal @link SHA2_core.RTL.end_major_cycle end_major_cycle@endlink
--! @details During the @c last_stages stage, the stage counter is enabled by means of the 
--! the signal @link SHA2_Control_Unit.count_stages count_stages@endlink. The stage is exited when
--! the pipeline has been fully flushed. However, it is not necessary to entirely flush the pipeline 
--! in order to start a new computation, since it is possible to reach the @c compute stage from 
--! these stages. Both the step counter and the stage counter are reset during the @c idle stage 
--! in order to start from a known value
--! @details The @c first_load stage is an unstable stage needed to load the pipeline, by keeping 
--! asserted the signal @link SHA2_Control_Unit.first_major_cycle first_major_cycle@endlink. It 
--! is necessary because the first counting of the counter actually requires an additional clock
--! cycle to assert the signal @link SHA2_Control_Unit.count_top count_top@endlink, since this  
--! signal starts low, and is asserted when the counting value equals 0 during all but the very
--! first computation. It is therefore necessary to estabilish the same number of cycles for every 
--! computation stage, even though this increases the circuit latency by one clock cycle. In fact, 
--! without this state the first stage would perform one step more than designed, leading to an 
--! incorrect result.
architecture FSM of SHA2_Control_Unit is

	--! Type used to represent the various states of the FSM
	type STATE_TYPE is (reset, idle, first_load, compute, last_stages);
	--! Current state of the %FSM
	signal current : STATE_TYPE := reset;
	--! Next state of the %FSM
	signal prox    : STATE_TYPE := reset;

begin

	--! @brief Process implementing the feedback delay element
	--! @details This process allows for state updating
	delay_process : process(clk, not_rst) is
	begin
		if (not_rst = '0') then
			current <= reset;
		elsif (rising_edge(clk)) then
			current <= prox;
		end if;
	end process;

	--! @brief Process implementing the \f$\tau\f$ function
	--! @details This process implements the logic for state changing
	tau_process : process(current, start, count_top, count_stages_top) is
	begin
		case current is
			when reset =>
				prox <= idle;
			when idle =>
				if (start = '1') then
					prox <= first_load;
				else
					prox <= idle;
				end if;
			when first_load =>
				prox <= compute;
			when compute =>
				if (count_top = '1' and start = '0') then
					prox <= last_stages;
				else
					prox <= compute;
				end if;
			when last_stages =>
				if (count_stages_top = '1') then
					prox <= idle;
				elsif (count_top = '1' and start = '1') then
					prox <= compute;
				else
					prox <= last_stages;
				end if;
		end case;
	end process;

	--! @brief Process for the \f$\omega\f$ function
	--! @details This process allows for outputs updating
	--! @details Being this FSM a Moore machine, outputs depend only upon the current state
	omega_process : process(current) is
	begin
		not_reset_count   <= '1';
		count             <= '0';
		count_stages      <= '0';
		first_major_cycle <= '0';
		ready_cu          <= '0';

		case current is
			when reset =>
				not_reset_count <= '0';
			when idle =>
				first_major_cycle <= '1';
				not_reset_count   <= '0';
				ready_cu          <= '1';
			when first_load =>
				first_major_cycle <= '1';
				count             <= '1';
			when compute =>
				count <= '1';
				if (CYCLES_PER_STAGE = 1) then
					ready_cu <= '1';
				end if;
			when last_stages =>
				count        <= '1';
				count_stages <= '1';
				if (CYCLES_PER_STAGE = 1) then
					ready_cu <= '1';
				end if;
		end case;

	end process;

	expander_init <= first_major_cycle;

end architecture FSM;

--! @brief Finite State Machine with support for resource reordering
--! @imageSize{SHA_CU_reordered.png,width:700px;}
--! @image html SHA_CU_reordered.png "Finite State Machine for the SHA-2 core"
--! @details During the @c compute stage, the signal @link SHA2_Control_Unit.count count@endlink
--! enables the step counter so as to keep track of the computing progresses. This counter produces
--! also the signal @link SHA2_Control_Unit.count_top count_top@endlink, which is the pipeline clock
--! signal @link SHA2_core.RTL.end_major_cycle end_major_cycle@endlink
--! @details During the @c last_stages stage, the stage counter is enabled by means of the 
--! the signal @link SHA2_Control_Unit.count_stages count_stages@endlink. The stage is exited when
--! the pipeline has been fully flushed. However, it is not necessary to entirely flush the pipeline 
--! in order to start a new computation, since it is possible to reach the @c compute stage from 
--! these stages. Both the step counter and the stage counter are reset during the @c idle stage 
--! in order to start from a known value
--! @details The @c first_load stage is an unstable stage needed to load the pipeline, by keeping 
--! asserted the signal @link SHA2_Control_Unit.first_major_cycle first_major_cycle@endlink. It 
--! is necessary because the first counting of the counter actually requires an additional clock
--! cycle to assert the signal @link SHA2_Control_Unit.count_top count_top@endlink, since this  
--! signal starts low, and is asserted when the counting value equals 0 during all but the very
--! first computation. It is therefore necessary to estabilish the same number of cycles for every 
--! computation stage, even though this increases the circuit latency by one clock cycle. In fact, 
--! without this state the first stage would perform  one step more than designed, leading to an 
--! incorrect result. To avoid the deassertion of the @link SHA2_core.start start@endlink 
--! primary input during this stage, which would lead to the clearing of the first pipeline register 
--! validity flag, the @link SHA2_Control_Unit.ready_cu ready_cu@endlink signal is kept asserted
--! during this state.
--! @details The @c second_load stage is an additional unstable stage required to align the values
--! of the \f$K\f$ constant with the other operands within the Compressor pipeline, again by keeping 
--! asserted the signal @link SHA2_Control_Unit.first_major_cycle first_major_cycle@endlink. It 
--! is necessary because the ROM introduces a delay of one clock cycle between the update of its input
--! and the presentation of the corresponding output, and this delay is not compensated within the data
--! path when @link SHA2_core.FIX_TIME FIX_TIME@endlink is set to @c true. It is worth noting that this
--! problem affects only the Compressor pipeline, and the  @link SHA2_Control_Unit.expander_init expander_init@endlink
--! signal must be deasserted in order to have the \f$W\f$ operand aligned.
architecture Reordering of SHA2_Control_Unit is

	--! Type used to represent the various states of the FSM
	type STATE_TYPE is (reset, idle, first_load, second_load, compute, last_stages);
	--! Current state of the %FSM
	signal current : STATE_TYPE := reset;
	--! Next state of the %FSM
	signal prox    : STATE_TYPE := reset;

begin

	--! @brief Process implementing the feedback delay element
	--! @details This process allows for state updating
	delay_process : process(clk, not_rst) is
	begin
		if (not_rst = '0') then
			current <= reset;
		elsif (rising_edge(clk)) then
			current <= prox;
		end if;
	end process;

	--! @brief Process implementing the \f$\tau\f$ function
	--! @details This process implements the logic for state changing
	tau_process : process(current, start, count_top, count_stages_top) is
	begin
		case current is
			when reset =>
				prox <= idle;
			when idle =>
				if (start = '1') then
					prox <= first_load;
				else
					prox <= idle;
				end if;
			when first_load =>
				prox <= second_load;
			when second_load =>
				prox <= compute;
			when compute =>
				if (count_top = '1' and start = '0') then
					prox <= last_stages;
				else
					prox <= compute;
				end if;
			when last_stages =>
				if (count_stages_top = '1') then
					prox <= idle;
				elsif (count_top = '1' and start = '1') then
					prox <= compute;
				else
					prox <= last_stages;
				end if;
		end case;
	end process;

	--! @brief Process for the \f$\omega\f$ function
	--! @details This process allows for outputs updating
	--! @details Being this FSM a Moore machine, outputs depend only upon the current state
	omega_process : process(current) is
	begin
		not_reset_count   <= '1';
		count             <= '0';
		count_stages      <= '0';
		first_major_cycle <= '0';
		expander_init     <= '0';
		ready_cu          <= '0';

		case current is
			when reset =>
				not_reset_count <= '0';
			when idle =>
				first_major_cycle <= '1';
				expander_init     <= '1';
				not_reset_count   <= '0';
				ready_cu          <= '1';
			when first_load =>
				first_major_cycle <= '1';
				expander_init     <= '1';
				count             <= '1';
			when second_load =>
				first_major_cycle <= '1';
				count             <= '1';
			when compute =>
				count <= '1';
				if (CYCLES_PER_STAGE = 1) then
					ready_cu <= '1';
				end if;
			when last_stages =>
				count        <= '1';
				count_stages <= '1';
				if (CYCLES_PER_STAGE = 1) then
					ready_cu <= '1';
				end if;
		end case;
	end process;

end architecture Reordering;
