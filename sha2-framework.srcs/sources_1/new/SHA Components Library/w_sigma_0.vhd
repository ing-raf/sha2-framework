--! @file w_sigma_0.vhd
--! @brief \f$\sigma_0\f$ entity definition and implementation

--! Standard library
library ieee;
--! Standard 9-values logic library
use ieee.std_logic_1164.all;


--! @brief \f$\sigma_0\f$ function block
--! @details This component computes the function
--! \f[ \sigma_0\left(x\right) = x \ggg_r 7 \oplus x \ggg_r 18 \oplus x \ggg 3 \f]
--! for SHA-256 and
--! \f[ \sigma_0\left(x\right) = x \ggg_r 1 \oplus x \ggg_r 8 \oplus x \ggg 7 \f]
--! for SHA-512.
entity w_sigma_0 is
	generic (
		WORD_WIDTH : natural := 32 --! Width of the words of the Expander 
	);
	port(
		x : in  std_logic_vector(WORD_WIDTH - 1 downto 0); --! Input word
		o : out std_logic_vector(WORD_WIDTH - 1 downto 0) --! Output word
	);
end entity w_sigma_0;

--! @brief Architecture of the \f$\sigma_0\f$ function block
--! @details The distinction between the SHA-256 and the SHA-512 variant is performed thanks to the 
--! @link w_sigma_0.WORD_WIDTH WORD_WIDTH@endlink generic.
architecture RTL of w_sigma_0 is	
begin
	
	sigma0 : if WORD_WIDTH = 32 generate
		o <= (x ror 7) xor (x ror 18) xor (x srl 3);
	elsif WORD_WIDTH = 64 generate
		o <= (x ror 1) xor (x ror 8) xor (x srl 7);
	else generate
		assert(false) report "Mismatched word width assignment" severity failure;
	end generate;

end architecture RTL;
