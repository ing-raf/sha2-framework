--! Standard library
library ieee;
--! Standard 9-values logic library
use ieee.std_logic_1164.all;
--! Standard math library, required for the log function
use ieee.math_real.all;
--! Arithmetic library, included for the unsigned type conversion
use ieee.numeric_std.all;

--! Package containing some generalisation functions
use work.utils.all;

--! @brief Constants ROM
--! @details All possible ROMs are hard-coded within the implementation of this entity. The
--! proper ROM is selected by the generic parameters
entity K_ROM is
	generic (
		--! @brief Word width of the circuit
		--! @details The width of the ROM depends also on the UNROLLING_FACTOR
		WORD_WIDTH : natural := 32;
		--! @brief Clock cycles required to complete a pipeline stage
		--! @details This is required to set the depth of the ROM
		CYCLES_PER_STAGE  : natural := 16;
		--! @brief Number of SHA-256 steps performed by a single round
		--! @details This is required to set the width of the ROM
		UNROLLING_FACTOR : natural := 1;
		--! @brief Specific pipeline stage for which the ROM must be instantiated
		--! @details This is required to select the ROM content
		STAGE : natural;
		--! Number of steps of the word prefetched from the Constants Unit and the Expander pipeline
		PREFETCH_STEPS : natural := 0
	);
	port (
		clk     : in  std_logic; --! Clock of this component
		en      : in  std_logic; --! Enable signal
		address : in  std_logic_vector(bits_to_encode(CYCLES_PER_STAGE) downto 0); --! Word selection signal
		data    : out std_logic_vector((UNROLLING_FACTOR * WORD_WIDTH) - 1 downto 0) --! Selected word
	);
end entity K_ROM;

architecture Behavioural of K_ROM is 
	
	--! @brief Type used to represent the content of the ROM
	--! @details The shape of the ROM contents changes according to the provided parameters
	constant ROM_CONTENT : CONFIGURABLE_ROM(CYCLES_PER_STAGE - 1 downto 0)((UNROLLING_FACTOR * WORD_WIDTH) - 1 downto 0) := rom_content(WORD_WIDTH, CYCLES_PER_STAGE, UNROLLING_FACTOR, STAGE, PREFETCH_STEPS);
	
	--! Temporary signal for the selected word
	signal read : std_logic_vector((UNROLLING_FACTOR * WORD_WIDTH) - 1 downto 0) := (others => '0');
begin
	--! In a fully pipelined architecture, the ROM actually boils down to an hard-coded value
	data_selection : if (CYCLES_PER_STAGE = 1) generate
		read <= ROM_CONTENT(0);
		data <= read;
	else generate
		read <= ROM_CONTENT(to_integer(unsigned(address)));
		
	--! @brief Output update process
	--! @details This process ensures that the output of the ROM is updated only on the rising edge of the clock
	--! signal, and only if the component is enabled
		process(clk) is
		begin
			if (rising_edge(clk)) then
				if (en = '1') then
					data <= read;
				end if;
			end if;
		end process;
	end generate;
		
end architecture Behavioural;
	