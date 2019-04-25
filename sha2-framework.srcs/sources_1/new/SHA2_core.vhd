--! @mainpage A Flexible Framework for Exploring, Evaluating, and Comparing SHA-2 Designs
--! @tableofcontents
--! @section config Configuring the framework
--! To configure the framework for employing a specific transformation round block:
--! -# %Choose an implementation for the transformation round block \n 
--! This is done by specifying an @c architecture for the @link Transf_round Compressor_pipeline_stage@endlink component.
--!		<ul>
--!		<li> If the @link Transf_round.Naive Naive@endlink architecture is chosen, it is necessary to specify also 
--!			 an @c architecture for the Transf_round_comb component within the @link Transf_round.Naive Naive@endlink architecture.
--! 	<li> If an architecture requiring system-level data prefetching is chosen (requiring @link SHA2_core.PREFETCH_ROUNDS PREFETCH_ROUNDS@endlink > 1),
--!			it is necessary to specify also an @c architecture for the Initialisation_block component.
--!		</ul>
--! -# Configure the generic parameters of the top level entity \n
--! The following parameters needs to be adjusted according to the requirements of the selected transformation round block:
--!		<ul>
--! 	<li> @link SHA2_core.PIPELINE_WORDS PIPELINE_WORDS@endlink: Number of words in the pipeline register
--! 	<li> @link SHA2_core.PREFETCH_ROUNDS PREFETCH_ROUNDS@endlink: Number of prefetch steps
--! 	<li> @link SHA2_core.FIX_TIME FIX_TIME@endlink: Whether is required to delay the Compressor pipeline
--! 	<li> @link SHA2_core.UNROLLING_FACTOR UNROLLING_FACTORS@endlink: Unrolling factor (unless the transformation round block is itself generic on the unrolling factor) 
--!		</ul>
--! The following parameters are instead independent on the selected transformation round block:
--! 	- @link SHA2_core.WIDTH WIDTH@endlink: Hash size
--! 	- @link SHA2_core.PIPELINE_STAGES PIPELINE_STAGES@endlink: Number of pipeline stages
--! 	- @link SHA2_core.FINAL_SUM_AS_STAGE FINAL_SUM_AS_STAGE@endlink: Whether or not to implement the chaining sum as a separate stage
--! @section extend Add a different transformation round block
--! A new transformation round block is added by defining an @c architecture for the @link Transf_round@endlink or the 
--! @link Transf_round_comb@endlink entity. The latter can be used if the design focuses only on the combinatorial part.
--! However, if the transformation round block needs to move the pipeline registers, as is the case when optimisations
--! like <em>spatial reordering</em> or <em>variables precomputation</em>, an architecture for the @link Transf_round@endlink
--! entity must be defined.
--! @section architecture Architecture Details
--! For more details on the implementation, @link SHA2_core.RTL see the architecture of the top level entity@endlink.

--! @file SHA2_core.vhd 
--! @brief Top level entity definition and implementation
--! @details This file contains the definition of the top-level SHA-2 hash circuit and its implementation.
--! @details Notably, this file contains the architectural parameters which needs to be changed in order to obtain a different
--! SHA-2 circuit. More details are provided in @link SHA2_core.RTL the architecture description@endlink.

--! Standard library
library ieee;
--! Standard 9-values logic library
use ieee.std_logic_1164.all;

--! Package containing some generalisation functions
use work.utils.all;

--! SHA-2 transformation cores library
library rounds;

--! Basic integrated circuits components library
library components;

--! @brief SHA-2 hash core
--! @details Core for applying SHA-2 on a single block message (a.k.a. Padded Data Block)
entity SHA2_core is
	generic(
		--! @brief Hash size
		--! @details This parameter chooses the hash function
		WIDTH              : natural := 512;
		--! Number of pipeline stages
		PIPELINE_STAGES    : natural := 4;
		--! Number of SHA-2 steps performed by a single round
		UNROLLING_FACTOR   : natural := 2;
		--!@brief Number of words in  the pipeline registers
		--!@details If greater than 8, an initialisation block must be defined for providing the additional initial values
		PIPELINE_WORDS     : natural := 14;
		--! Number of round of the word prefetched from the Constants Unit and the Expander pipeline
		PREFETCH_ROUNDS    : natural := 4;
		--! @brief Whether or not it is necessary to fix the timing issue
		--! @details This flag @b must be set to @c true if the compressor stage employs the \f$K\f$ constant(s) and
		--! the \f$W\f$ expanded word(s) @b prior of the pipeline registers, since this causes a tempification issue which
		--! must be fixed; otherwise it must be set to @c false
		FIX_TIME           : boolean := true;
		--! @brief Whether or not to perform the final sum in a separate stage
		--! @details If the pipeline registers are placed before any adder in the transformation round, the adders of
		--! the final sum are on the critical path, hence it is beneficial to place the final sum in a separate stage.
		--! On the other hand, if the pipeline registers are placed at least after one adder, the adders of the final
		--! sum are in parallel with a portion of the transformation round, hence no longer on the critical path.
		FINAL_SUM_AS_STAGE : boolean := true
	);
	port(
		clk       : in  std_logic;      --! Clock of this component
		not_rst   : in  std_logic;      --! Active-low asynchronous reset signal
		en        : in  std_logic;      --! Enable signal
		start     : in  std_logic;      --! When asserted, a new Padded Data Block to be hashed is present at input
		M_blk     : in  std_logic_vector(2 * WIDTH - 1 downto 0); --! Padded Data Block
		iv        : in  std_logic_vector(WIDTH - 1 downto 0); --! Accumulators value for the provided padded data block
		ready     : out std_logic;      --! When asserted, the circuit is able to process a new input block
		completed : out std_logic;      --! When asserted, the hash output is meaningful
		hash      : out std_logic_vector(WIDTH - 1 downto 0) --! Value of the hash of the input
	);
end entity SHA2_core;

--! @brief Architecture of the hash core
--! @details The core is composed by two parallel and distinct pipelines, the Expander pipeline and the Compressor
--! pipeline. Each stage of the Compressor pipeline is paired with a ROM containing the \f$K\f$ constant values
--! needed for that stage. The pipeline depth can be configured by the generic parameter @link SHA2_core.PIPELINE_STAGES PIPELINE_STAGES@endlink,
--! which disables pipelining if set to 1.
--! @imageSize{sha2configurabledatapath.png,width:700px;}
--! @image html sha2configurabledatapath.png "Overall data path. Operative part in blue, Control part in red"
--! @section clocking Pipeline clocking
--! The pipeline registers are employed also as round registers, hence are clocked by the external base clock. 
--! The two working modes are selected by a multiplexer placed in front of each pipeline register, which switches 
--! between the feedback of the output from the current stage and the output from the previous stage. This 
--! multiplexer is driven by the carry output of the rounds counter, which consequently works as a stage clock and 
--! is hence called @link SHA2_core.RTL.end_major_cycle end_major_cycle@endlink.
--! @section pipelineLoading Pipeline loading
--! Since the signal @link SHA2_core.RTL.end_major_cycle end_major_cycle@endlink drives the input to the pipeline 
--! registers, and in particular to the first stage, the architecture is sensitive to its primary input 
--! @link SHA2_core.M_blk M_blk@endlink only when @link SHA2_core.RTL.end_major_cycle end_major_cycle@endlink 
--! is asserted. For this reason, the signal @link SHA2_core.RTL.end_major_cycle end_major_cycle@endlink must 
--! be propagated to the primary output @link SHA2_core.ready ready@endlink.
--! @details Upon reset, the signal @link SHA2_core.RTL.end_major_cycle end_major_cycle@endlink is cleared, 
--! hence the pipeline is not loaded during the first major cycle of operations. To avoid losing this major cycle, 
--! an additional signal @link SHA2_core.RTL.first_major_cycle first_major_cycle@endlink is introduced and `or`-ed 
--! with @link SHA2_core.RTL.end_major_cycle end_major_cycle@endlink in the first stage. It is not necessary in the 
--! subsequent stages, which are in indifference condition during the first major cycle, and during all subsequent 
--! major cycles the signal @link SHA2_core.RTL.end_major_cycle end_major_cycle@endlink is properly asserted and 
--! drives the data exchange as designed. Moreover, since the padded data block can be removed from the primary input,
--! it must be stored in an input register only for the very first major cycle. A multiplexer, driven by the signal
--! @link SHA2_core.RTL.first_major_cycle first_major_cycle@endlink, commutes between the primary input and the buffered
--! version, which is excluded during the subsequent major cycles in order not to lose an additional clock cycle.
--! @details It is worth noting that, during each major cycles, the output is captured by the pipeline register of 
--! the stage during all but the last step, whereas the output of the last step is captured by the pipeline register 
--! of the following stage. The last step is the one with @link SHA2_core.RTL.end_major_cycle end_major_cycle@endlink
--! asserted, hence the one with the @link SHA2_core.RTL.t counting value@endlink equals to 0. This means also 
--! that the first computation executed within the stage is the one with the @link SHA2_core.RTL.t counting value@endlink
--! equals to 1, since the computation with the previous value. is discarded by the multiplexer. This allows for 
--! compensating the one-cycle delay introduced by the ROM. The signal @link SHA2_core.RTL.init init@endlink 
--! ensures this behaviour also for the very first major cycle.
--! @section fixTime Tempification issue with reordering
--! @details The signals @link SHA2_core.RTL.end_major_cycle end_major_cycle@endlink and @link SHA2_core.RTL.init init@endlink
--! are both generated by the @link SHA2_Control_Unit Control Unit@endlink and are actually the same signal if 
--! @link SHA2_core.FIX_TIME FIX_TIME@endlink is set to @c false. On the other end, if the value of the \f$K\f$ constants is
--! consumed in the compressor pipeline stage ahead of the pipeline registers, the @link SHA2_Control_Unit.Reordering Control Unit@endlink
--! instantiated by defining @link SHA2_core.FIX_TIME FIX_TIME@endlink to @c true adds a latency state for the compressor pipeline
--! only, hence differentiating these two signals.
--! @details Moreover, when @link SHA2_core.FIX_TIME FIX_TIME@endlink is set to @c true, the Expander pipeline works with a major cycle
--! delayed of one clock cycle w.r.t. the major cycle of the Compressor pipeline, in order to take into account the additional latency
--! of the Compressor pipeline.
--! @section pipelineRegister Pipeline register
--! @details Apart from the hash variables, the register stores the flag @link Transf_round.Naive.valid_reg valid@endlink 
--! which is asserted if the register contains valid data. This flag is used to produce the output signal @link SHA2_core.completed completed@endlink,
--! since the content of the output register is valid, representing the output of a previously provided input, if 
--! and only if the @link Transf_round.Naive.valid_reg valid@endlink flag is asserted in the output register.
--! @details The @link Transf_round.Naive.valid_reg valid@endlink flag is initialised in the first stage by the 
--! @link SHA2_core.start start@endlink primary input. To ensure the proper setting of the flag also for the very first
--! major cycle, this primary input is buffered with the same logic of the input message.
--! @section finalStage The final stage
--! Differently from the other stages, the final sum stage requires only one clock cycle. This final sum can 
--! optionally been performed in a separate stage. When this is the case, the output register of this stage, 
--! which is also the output register for the whole circuit, is delayed of one clock cycle by means of a flip-flop.
--! @details If there is at least one adder before the pipeline register in the Compressor pipeline stage, however, the
--! separate stage is not profitable and can hence be disabled.
--! @section stagesCounter Supporting a variable number of stages
--! @details In order to be capable of supporting a configurable number of pipeline stages, a counter for pipeline stages
--! is added. This counter is modulo @link SHA2_core.PIPELINE_STAGES PIPELINE_STAGES@endlink and is used by the 
--! @link SHA2_Control_Unit Control Unit@endlink to determine when the pipeline has been fully flushed. The clock signal 
--! of this counter is the major cycle clock, i.e. @link SHA2_core.RTL.end_major_cycle end_major_cycle@endlink.
--! @details Another issue in supporting a configurable number of stages is the K_ROM, the content of which must be defined 
--! for each stage, for every supported configuration. @link SHA2_core.PIPELINE_STAGES PIPELINE_STAGES@endlink determines
--! the number of ROMs in which to partition the SHA-2 ROM, whereas @link SHA2_core.UNROLLING_FACTOR UNROLLING_FACTOR@endlink
--! determines the width of the ROMs.
--! @section expanderPipeline Pipelining and the Expander
--! In the implementation of SHA-2 with pipelining, it must be taken into account that the word required at each step 
--! depends up on word values of up to 16 cycles ahead.
--! @details One option is to precalculate all words, keeping into account that the computation is entirely combinatorial. 
--! However, in this case this computation  must be done within the first major cycle, in order not to increment 
--! the latency of the circuit.
--! @details The other way is to split the expander into stages. The parallel output of the shift register of the expander
--! becomes the parallel input for the shift register of the expander of the next stage. The combinatorial operations on 
--! the feedback line becomes the @link Expander_stage stage@endlink of the expander pipeline.
--! @imageSize{pipelinedExpanderStageConceptual.png,width:700px;}
--! @image html pipelinedExpanderStageConceptual.png "Conceptual view of the Expander pipeline stage"
architecture RTL of SHA2_core is

	--! Word width of the chosen SHA-2 variant
	constant WORD_WIDTH       : natural := WIDTH / 8;
	--! Number of clock cycles required to complete a pipeline stage
	constant CYCLES_PER_STAGE : natural := cycles_per_stage(WIDTH, PIPELINE_STAGES, UNROLLING_FACTOR);
	--! Number of steps of the word prefetched from the Constants Unit and the Expander pipeline
	constant PREFETCH_STEPS   : natural := PREFETCH_ROUNDS / UNROLLING_FACTOR;

	--! @brief Type used to represent compressor pipeline connections
	--! @details One pipeline input and one pipeline output is required per pipeline stage. The stages are
	--! PIPELINE_STAGES + 1 due to the additional last stage which performs the final sum
	type COMPRESSOR_PIPELINE_CONNECTION is array (PIPELINE_STAGES downto 0) of std_logic_vector(PIPELINE_WORDS * WORD_WIDTH downto 0);
	--! Array of signals representing the inputs to each stage of the compressor pipeline
	signal compressor_pipeline_input  : COMPRESSOR_PIPELINE_CONNECTION;
	--! Array of signals representing the outputs to each stage of the compressor pipeline
	signal compressor_pipeline_output : COMPRESSOR_PIPELINE_CONNECTION;
	--! Output of the hash output register
	signal output                     : std_logic_vector(WIDTH downto 0) := (others => '0');
	--! @brief Type used to represent expander pipeline connections
	--! @details One pipeline input and one pipeline output is required per pipeline stage.
	type EXPANDER_PIPELINE_CONNECTION is array (PIPELINE_STAGES - 1 downto 0) of std_logic_vector(2 * WIDTH - 1 downto 0);
	--! Array of signals representing the inputs to each stage of the compressor pipeline
	signal expander_pipeline_input    : EXPANDER_PIPELINE_CONNECTION;
	--! Array of signals representing the outputs to each stage of the compressor pipeline
	signal expander_pipeline_output   : EXPANDER_PIPELINE_CONNECTION;
	--! @brief Type used to represent ROM to compressor stage connections
	--! @details The ROM width is function of the unrolling factor
	type K_CONNECTION is array (PIPELINE_STAGES - 1 downto 0) of std_logic_vector((UNROLLING_FACTOR * WORD_WIDTH) - 1 downto 0);
	--! Array of signals representing the \f$K\f$ constant words input to each stage
	signal rom_output                 : K_CONNECTION;

	--! Enable signal for the hash register
	signal en_hash         : std_logic := '0';
	--! Enable signal for the step counter
	signal count           : std_logic := '0';
	--! Enable signal for the stage counter
	signal count_stages    : std_logic := '0';
	--! When asserted, the pipeline has been fully flushed 
	signal flush_completed : std_logic := '0';
	--! Active-low control signal to reset the step counter
	signal not_reset_count : std_logic := '0';
	--	signal end_major_cycle_temp : std_logic := '0';

	--! Control signal to drive the stage advance for the expander pipeline
	signal end_major_cycle_init : std_logic := '0';
	--! Clock of the compressor pipeline registers
	signal end_major_cycle      : std_logic := '0';
	--! Control signal to initialise the expansion pipeline
	signal init                 : std_logic := '0';
	--! @brief Control signal to allow starting the hash core
	--! @details This signal fixes @link SHA2_core.RTL.end_major_cycle end_major_cycle@endlink
	--! behaviour during the very first major cycle
	signal first_major_cycle    : std_logic := '0';
	--! @brief %Ready signal coming from the Control Unit
	--! @details This is used to fix the behaviour of the @link SHA2_core.ready ready@endlink signal for the fully-pipelined
	--! case
	signal ready_cu             : std_logic := '0';
	--! @brief Internal copy of the @link SHA2_core.ready ready@endlink output
	--! @details It is used to drive the synchronisation buffer for the @link SHA2_core.start start@endlink signal
	signal ready_internal : std_logic := '0';

	--! Validity flag for the Compressor pipeline
	signal valid_in       : std_logic                                := '0';
	--! Output of the message input buffer
	signal buffered_input : std_logic_vector(2 * WIDTH - 1 downto 0) := (others => '0');
	--! Message input to the Expander pipeline
	signal M_in           : std_logic_vector(2 * WIDTH - 1 downto 0) := (others => '0');

	--! Step counter value
	signal t     : std_logic_vector(bits_to_encode(CYCLES_PER_STAGE) downto 0) := (others => '0');
	--! Stage counter value
	signal stage : std_logic_vector(bits_to_encode(PIPELINE_STAGES) downto 0)  := (others => '0');

begin

	assert (WIDTH = 256 or WIDTH = 512) report "The chosen hash function has not been implemented yet" severity failure;

	check_params : if (WIDTH = 256) generate
		assert (PIPELINE_STAGES * UNROLLING_FACTOR * CYCLES_PER_STAGE = 64) report "The number of stages and the unrolling factor must exactly divide 64" severity failure;
	elsif (WIDTH = 512) generate
		assert (PIPELINE_STAGES * UNROLLING_FACTOR * CYCLES_PER_STAGE = 80) report "The number of stages and the unrolling factor must exactly divide 80" severity failure;
	end generate;

	--! @brief Buffer for the start signal
	--! @details It is required for capturing the start impulse only when the circuit is ready
	buffer_start : entity components.D_ff
		port map(
			clk     => clk,
			not_rst => not_rst,
			en      => en and ready_internal,
			d       => start,
			q       => valid_in
		);

	--! @brief Message buffer
	--! @details Required for synchronisation with the Expander pipeline when the @linkSHA2_control_Unit.Reordering Reordering@endlink 
	--! Control Unit is instantiated
	buffer_input : entity components.reg
		generic map(
			width => 2 * WIDTH
		)
		port map(
			clk     => clk,
			not_rst => not_rst,
			en      => en and ready_cu,
			d       => M_blk,
			q       => buffered_input
		);

	with first_major_cycle select M_in <=
		buffered_input when '1',
		M_blk when '0',(others => 'X') when others;

	pipeline : for stage in PIPELINE_STAGES - 1 downto 0 generate
		--! @brief Expanded words for the current steps
		--! @details The combinatorial block requires one expanded word for each step it performs within
		--! a single cycle, hence it requires a number of expanded words equals to the unrolling factor
		signal W : std_logic_vector((UNROLLING_FACTOR * WORD_WIDTH) - 1 downto 0) := (others => '0');

		signal K : std_logic_vector((UNROLLING_FACTOR * WORD_WIDTH) - 1 downto 0) := (others => '0');

		--! @brief Derived clock for the compressor pipeline stages
		--! @details This temporary signal is included to allow correction from the Control Unit for
		--! the first stage 
		signal major_cycle      : std_logic := '0';
		signal major_cycle_temp : std_logic := '0';

		--! @brief Derived clock for the expander pipeline stages
		--! @details This temporary signal is included to allow correction from the Control Unit for
		--! the first stage 
		signal expander_init      : std_logic := '0';
		signal expander_init_temp : std_logic := '0';

		--! Stage of the compressor pipeline
		component Compressor_pipeline_stage is
			generic(
				WORD_WIDTH       : natural := 32; --! Width of the words of the Compressor
				WORDS            : natural := 8; --! Number of words required as input by the Compressor
				UNROLLING_FACTOR : natural := 1 --! Number of SHA-2 steps performed by a single round
			);
			port(
				--! Clock of this component
				clk             : in  std_logic;
				--! Active-low asynchronous reset signal
				not_rst         : in  std_logic;
				--! Enable signal
				en              : in  std_logic;
				--! Derived pipeline clock
				end_major_cycle : in  std_logic;
				--! @brief Constant \f$K\f$ words
				--! @details The combinatorial block requires one constant for each step it performs within
				--! a single cycle, hence it requires a number of constants equals to the unrolling factor
				K               : in  std_logic_vector((UNROLLING_FACTOR * WORD_WIDTH) - 1 downto 0);
				--! @brief Expanded words for the current steps
				--! @details The combinatorial block requires one expanded word for each step it performs within
				--! a single cycle, hence it requires a number of expanded words equals to the unrolling factor
				W               : in  std_logic_vector((UNROLLING_FACTOR * WORD_WIDTH) - 1 downto 0);
				--! Input of the compressor pipeline stage
				input           : in  std_logic_vector(WORDS * WORD_WIDTH downto 0);
				--! Output of the compressor pipeline stage
				output          : out std_logic_vector(WORDS * WORD_WIDTH downto 0)
			);
		end component Compressor_pipeline_stage;

		for all : Compressor_pipeline_stage use entity rounds.Transf_round(Reordered_UF2);

	begin
		stages_interconnect : if (stage > 0) generate
			compressor_pipeline_input(stage) <= compressor_pipeline_output(stage - 1);
			expander_pipeline_input(stage)   <= expander_pipeline_output(stage - 1);
			major_cycle_temp                 <= end_major_cycle;
			expander_init_temp               <= end_major_cycle_init;
		else generate                   -- first stage

			init_block_check : if PIPELINE_WORDS > 8 generate
				constant ADDITIONAL_WORDS : natural := PIPELINE_WORDS - 8;

				signal additional_init : std_logic_vector(ADDITIONAL_WORDS * WORD_WIDTH - 1 downto 0) := (others => '0');

				component Initialisation_unit is
					generic(
						WORD_WIDTH       : natural := 32; --! Width of the words of the Compressor
						WORDS            : natural := 1; --! Number of words for which to provide initialisation values
						UNROLLING_FACTOR : natural := 1; --! Number of SHA-256 steps performed by a single round
						PREFETCH_STEPS   : natural := 2 --! Number of steps of the word prefetched from the Constants Unit and the Expander pipeline

					);
					port(
						--! Standard initialisation vector
						iv            : in  std_logic_vector(8 * WORD_WIDTH - 1 downto 0);
						--! Constant \f$K\f$ words
						K             : in  std_logic_vector((PREFETCH_STEPS * UNROLLING_FACTOR * WORD_WIDTH) - 1 downto 0);
						--! Expanded words for the current steps
						W             : in  std_logic_vector((PREFETCH_STEPS * UNROLLING_FACTOR * WORD_WIDTH) - 1 downto 0);
						--! Additional initialisation values
						additional_iv : out std_logic_vector(WORDS * WORD_WIDTH - 1 downto 0)
					);
				end component;

				constant K_INIT : std_logic_vector := rom_content(WORD_WIDTH, 1, PREFETCH_STEPS * UNROLLING_FACTOR, 0)(0);

				for all : Initialisation_unit use entity rounds.Initialisation_block(Reordered_UF2);
			begin

				iv_register : entity components.reg
					generic map(
						width => PIPELINE_WORDS * WORD_WIDTH + 1
					)
					port map(
						clk     => clk,
						not_rst => not_rst,
						en      => en and (end_major_cycle or init),
						d       => valid_in & additional_init & iv,
						q       => compressor_pipeline_input(0)
					);

				init_unit : component Initialisation_unit
					generic map(
						WORD_WIDTH       => WORD_WIDTH,
						WORDS            => ADDITIONAL_WORDS,
						UNROLLING_FACTOR => UNROLLING_FACTOR,
						PREFETCH_STEPS   => PREFETCH_STEPS
					)
					port map(
						iv            => iv,
						K             => K_INIT,
						W             => expander_pipeline_input(0)(2 * WIDTH - 1 downto 2 * WIDTH - PREFETCH_STEPS * UNROLLING_FACTOR * WORD_WIDTH),
						additional_iv => additional_init
					);

			elsif PIPELINE_WORDS = 8 generate
				compressor_pipeline_input(0) <= valid_in & iv;
			else generate
				assert false report "The pipeline width must be greater than or equal to the hash size" severity failure;
			end generate;

			expander_pipeline_input(0) <= M_in;
			major_cycle_temp           <= end_major_cycle or first_major_cycle;
			expander_init_temp         <= end_major_cycle_init or init;
			ready_signal : if CYCLES_PER_STAGE > 1 generate
				ready_internal <= end_major_cycle_init or ready_cu;
			end generate;

			ready_zero : if CYCLES_PER_STAGE = 1 generate
				ready_internal <= ready_cu;
			end generate;
		end generate;

		expander : if PREFETCH_STEPS > 0 generate
			--! Expander pipeline stage
			expander_stage : entity work.Expander_stage
				generic map(
					WORD_WIDTH       => WORD_WIDTH,
					UNROLLING_FACTOR => UNROLLING_FACTOR
				)
				port map(
					clk             => clk,
					not_rst         => not_rst,
					en              => en,
					end_major_cycle => expander_init,
					W_in            => expander_pipeline_input(stage),
					W               => open,
					W_out           => expander_pipeline_output(stage)
				);

			W <= expander_pipeline_output(stage)(2 * WIDTH - 1 - (PREFETCH_STEPS - 1) * UNROLLING_FACTOR * WORD_WIDTH downto 2 * WIDTH - PREFETCH_STEPS * UNROLLING_FACTOR * WORD_WIDTH);
		else generate
			expander_stage : entity work.Expander_stage
				generic map(
					WORD_WIDTH       => WORD_WIDTH,
					UNROLLING_FACTOR => UNROLLING_FACTOR
				)
				port map(
					clk             => clk,
					not_rst         => not_rst,
					en              => en,
					end_major_cycle => expander_init,
					W_in            => expander_pipeline_input(stage),
					W               => W,
					W_out           => expander_pipeline_output(stage)
				);
		end generate;

		--! Compressor pipeline stage
		compressor_stage : component Compressor_pipeline_stage
			generic map(
				WORD_WIDTH       => WORD_WIDTH,
				WORDS            => PIPELINE_WORDS,
				UNROLLING_FACTOR => UNROLLING_FACTOR
			)
			port map(
				clk             => clk,
				not_rst         => not_rst,
				en              => en,
				end_major_cycle => major_cycle,
				K               => K,
				W               => W,
				input           => compressor_pipeline_input(stage),
				output          => compressor_pipeline_output(stage)
			);

		--! Constants ROM for the stage
		rom : entity work.K_ROM(Behavioural)
			generic map(
				WORD_WIDTH       => WORD_WIDTH,
				CYCLES_PER_STAGE => CYCLES_PER_STAGE,
				UNROLLING_FACTOR => UNROLLING_FACTOR,
				STAGE            => stage,
				PREFETCH_STEPS   => PREFETCH_STEPS
			)
			port map(
				clk     => clk,
				en      => en,
				address => t,
				data    => rom_output(stage)
			);

		init_comp_delay : if PIPELINE_WORDS > 8 generate
			mc_delay : entity components.D_ff
				port map(
					clk     => clk,
					not_rst => not_rst,
					en      => en,
					d       => major_cycle_temp,
					q       => major_cycle
				);

			init_delay : entity components.D_ff
				port map(
					clk     => clk,
					not_rst => not_rst,
					en      => en,
					d       => expander_init_temp,
					q       => expander_init
				);

			k_delay : entity components.reg
				generic map(
					width => UNROLLING_FACTOR * WORD_WIDTH
				)
				port map(
					clk     => clk,
					not_rst => not_rst,
					en      => en,
					d       => rom_output(stage),
					q       => K
				);
		else generate
			major_cycle   <= major_cycle_temp;
			expander_init <= expander_init_temp;
			K             <= rom_output(stage);
		end generate;
	end generate;

	register_sum : if (FINAL_SUM_AS_STAGE) generate
		--! Pipeline register for the final sum stage
		last_pipeline_reg : entity components.reg
			generic map(
				width => WIDTH + 1
			)
			port map(
				clk     => clk,
				not_rst => not_rst,
				en      => end_major_cycle,
				d       => compressor_pipeline_output(PIPELINE_STAGES - 1)(PIPELINE_WORDS * WORD_WIDTH) & compressor_pipeline_output(PIPELINE_STAGES - 1)(8 * WORD_WIDTH - 1 downto 0),
				q       => compressor_pipeline_input(PIPELINE_STAGES)(8 * WORD_WIDTH downto 0)
			);
	elsif (CYCLES_PER_STAGE = 1) generate
		compressor_pipeline_input(PIPELINE_STAGES)(WIDTH - 1 downto 0) <= compressor_pipeline_output(PIPELINE_STAGES - 1)(WIDTH - 1 downto 0);
		-- It is necessary to delay the validity flag, in order to allow the completion of the post-computation
		valid_reg_delay : entity components.D_ff
			port map(
				clk     => clk,
				not_rst => not_rst,
				en      => end_major_cycle,
				d       => compressor_pipeline_output(PIPELINE_STAGES - 1)(PIPELINE_WORDS * WORD_WIDTH),
				q       => compressor_pipeline_input(PIPELINE_STAGES)(WIDTH)
			);
	else generate
		compressor_pipeline_input(PIPELINE_STAGES)(8 * WORD_WIDTH downto 0) <= compressor_pipeline_output(PIPELINE_STAGES - 1)(PIPELINE_WORDS * WORD_WIDTH) & compressor_pipeline_output(PIPELINE_STAGES - 1)(8 * WORD_WIDTH - 1 downto 0);
	end generate;

	--! Final sum
	final_stage : entity work.Last_transformation
		generic map(
			WORD_WIDTH => WORD_WIDTH
		)
		port map(
			h_in  => compressor_pipeline_input(PIPELINE_STAGES)(8 * WORD_WIDTH downto 0),
			iv    => iv,
			h_out => compressor_pipeline_output(PIPELINE_STAGES)(8 * WORD_WIDTH downto 0)
		);

	fully_pipelined : if (CYCLES_PER_STAGE = 1) generate
		-- To allow communication between stages
		end_major_cycle_init <= '1';
		end_major_cycle      <= '1';
	else generate
		--! @brief Rounds counter
		--! @details Acts as a frequency divider producing the signal 
		--! @link SHA2_core.RTL.end_major_cycle end_major_cycle@endlink
		counter : entity components.counter
			generic map(
				top => CYCLES_PER_STAGE
			)
			port map(
				clk     => clk,
				not_rst => not_rst and not_reset_count,
				en      => en and count,
				q       => end_major_cycle_init,
				value   => t
			);

		--! If the tempification fix is in place, it is necessary to take it into account by delaying of one clock
		--! cycle the @link SHA2_core.RTL.end_major_cycle end_major_cycle@endlink signal @b only for the Compressor
		--! pipeline. Otherwise, the handshake signal for the Compressor and the Expander pipeline is the same
		define_major_cycle : if (FIX_TIME) generate
			emc_delay_ff : entity components.D_ff
				port map(
					clk     => clk,
					not_rst => not_rst,
					en      => en,
					d       => end_major_cycle_init,
					q       => end_major_cycle
				);
		else generate
			end_major_cycle <= end_major_cycle_init;
		end generate;
	end generate;

	--! Control Unit
	control_unit : if (FIX_TIME) generate
		cu : entity work.SHA2_Control_Unit(Reordering)
			generic map(
				CYCLES_PER_STAGE => CYCLES_PER_STAGE
			)
			port map(
				clk               => clk,
				not_rst           => not_rst,
				start             => start,
				count_top         => end_major_cycle_init,
				count_stages_top  => flush_completed,
				not_reset_count   => not_reset_count,
				count             => count,
				count_stages      => count_stages,
				first_major_cycle => first_major_cycle,
				expander_init     => init,
				ready_cu          => ready_cu
			);
	else generate
		cu : entity work.SHA2_Control_Unit(FSM)
			generic map(
				CYCLES_PER_STAGE => CYCLES_PER_STAGE
			)
			port map(
				clk               => clk,
				not_rst           => not_rst,
				start             => start,
				count_top         => end_major_cycle_init,
				count_stages_top  => flush_completed,
				not_reset_count   => not_reset_count,
				count             => count,
				count_stages      => count_stages,
				first_major_cycle => first_major_cycle,
				expander_init     => init,
				ready_cu          => ready_cu
			);
	end generate;

	--! @brief Stages counter, part of the Control Unit
	--! @details This counter adds support for a configurable number of stages
	--! @details The final sum is taken into account by `and`-ing the counting 
	--! value instead of using the carry output of the counter
	stages_counter : entity components.counter
		generic map(
			top => PIPELINE_STAGES
		)
		port map(
			clk     => end_major_cycle,
			not_rst => not_rst and not_reset_count,
			en      => en and count_stages,
			q       => open,
			value   => stage
		);

	flush_completed <= and stage;

	output_delay : if (FINAL_SUM_AS_STAGE or (PIPELINE_WORDS > 8)) generate
		--! One cycle delay for the output hash registers loading
		en_hash_ff : entity components.D_ff
			port map(
				clk     => clk,
				not_rst => not_rst,
				en      => en,
				d       => end_major_cycle,
				q       => en_hash
			);
	else generate
		en_hash <= end_major_cycle;
	end generate;

	--! Output register of the circuit
	output_reg : entity components.reg
		generic map(
			width => WIDTH + 1
		)
		port map(
			clk     => clk,
			not_rst => not_rst,
			en      => en and en_hash,
			d       => compressor_pipeline_output(PIPELINE_STAGES)(8 * WORD_WIDTH downto 0),
			q       => output
		);

	hash      <= output(WIDTH - 1 downto 0);
	ready <= ready_internal;
	completed <= output(WIDTH);

end architecture RTL;
