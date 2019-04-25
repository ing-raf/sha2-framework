--! @file w_sigma_1.vhd
--! @brief \f$\sigma_1\f$ entity definition and implementation

--! Standard library
library ieee;
--! Standard 9-values logic library
use ieee.std_logic_1164.all;

--! @brief \f$\sigma_1\f$ function block
--! @details This component computes the function
--! \f[ \sigma_1\left(x\right) = x \ggg_r 7 \oplus x \ggg_r 19 \oplus x \ggg 10 \f]
--! for SHA-256 and
--! \f[ \sigma_1\left(x\right) = x \ggg_r 19 \oplus x \ggg_r 61 \oplus x \ggg 6 \f]
--! for SHA-512.
entity w_sigma_1 is
	generic (
		WORD_WIDTH : natural := 32 --! Width of the words of the Expander 
	);
	port(
		x : in  std_logic_vector(WORD_WIDTH - 1 downto 0); --! Input word
		o : out std_logic_vector(WORD_WIDTH - 1 downto 0) --! Output word
	);
end entity w_sigma_1;

--! @brief Architecture of the \f$\sigma_1\f$ function block
--! @details The distinction between the SHA-256 and the SHA-512 variant is performed thanks to the 
--! @link w_sigma_1.WORD_WIDTH WORD_WIDTH@endlink generic.
architecture RTL of w_sigma_1 is
begin

	sigma1 : if WORD_WIDTH = 32 generate
		o <= (x ror 17) xor (x ror 19) xor (x srl 10);
	elsif WORD_WIDTH = 64 generate
		o <= (x ror 19) xor (x ror 61) xor (x srl 6);
	else generate
		assert(false) report "Mismatched word width assignment" severity failure;
	end generate;

end architecture RTL;
