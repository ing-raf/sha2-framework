--! Standard library 
library ieee;
--! Standard 9-values logic library 
use ieee.std_logic_1164.all;

entity Transf_round is
	generic(
		WORD_WIDTH : natural := 32; --! Width of the words of the Compressor
		WORDS : natural := 8;  --! Number of words required as input by the Compressor
		UNROLLING_FACTOR : natural := 1 --! Number of SHA-256 steps performed by a single round
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
end entity Transf_round;
