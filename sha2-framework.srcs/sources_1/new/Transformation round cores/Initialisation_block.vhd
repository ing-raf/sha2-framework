--! Standard library
library ieee;
--! Standard 9-values logic library
use ieee.std_logic_1164.all;

entity Initialisation_block is
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
end entity Initialisation_block;
