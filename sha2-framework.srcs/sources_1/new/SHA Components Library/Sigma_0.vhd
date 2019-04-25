--! @file Sigma_0.vhd
--! @brief \f$\Sigma_0\f$ entity definition and implementation

--! Standard library
library ieee;
--! Standard 9-values logic library
use ieee.std_logic_1164.all;

--! @brief \f$\Sigma_0\f$ function block
--! @details This component computes the function
--! \f[ \Sigma_0\left(x\right) = x \ggg_r 2 \oplus x \ggg_r 13 \oplus x \ggg_r 22 \f]
--! for SHA-256 and
--! \f[\Sigma_0\left(x\right) = x \ggg_r 28 \oplus x \ggg_r 34 \oplus x \ggg_r 39 \f]
--! for SHA-512.
entity Sigma_0 is
	generic (
		WORD_WIDTH : natural := 32 --! Width of the words of the Compressor
	);
	port(
		x : in  std_logic_vector(WORD_WIDTH - 1 downto 0); --! Input word
		o : out std_logic_vector(WORD_WIDTH - 1 downto 0) --! Output word
	);
end entity Sigma_0;

--! @brief Architecture of the \f$\Sigma_0\f$ function block
--! @details The distinction between the SHA-256 and the SHA-512 variant is performed thanks to the 
--! @link Sigma_0.WORD_WIDTH WORD_WIDTH@endlink generic.
architecture RTL of Sigma_0 is
begin

	Sigma0 : if WORD_WIDTH = 32 generate
		o <= (x ror 2) xor (x ror 13) xor (x ror 22);
	elsif WORD_WIDTH = 64 generate
		o <= (x ror 28) xor (x ror 34) xor (x ror 39);
	else generate
		assert(false) report "Mismatched word width assignment" severity failure;
	end generate;

end architecture RTL;
