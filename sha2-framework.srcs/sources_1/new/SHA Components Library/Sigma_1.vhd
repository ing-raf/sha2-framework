--! @file Sigma_1.vhd
--! @brief \f$\Sigma_1\f$ entity definition and implementation

--! Standard library
library ieee;
--! Standard 9-values logic library
use ieee.std_logic_1164.all;

--! @brief \f$\Sigma_1\f$ function block
--! @details This function block computes the function
--! \f[ \Sigma_1\left(x\right) = x \ggg_r 6 \oplus x \ggg_r 11 \oplus x \ggg_r 25  \f]
--! for SHA-256 and
--! \f[ \Sigma_1\left(x\right) = x \ggg_r 14 \oplus x \ggg_r 18 \oplus x \ggg_r 41 \f]
--! for SHA-512.
entity Sigma_1 is
	generic (
		WORD_WIDTH : natural := 32 --! Width of the words of the Compressor 
	);
	port(
		x : in  std_logic_vector(WORD_WIDTH - 1 downto 0); --! Input word
		o : out std_logic_vector(WORD_WIDTH - 1 downto 0) --! Output word
	);
end entity Sigma_1;

--! @brief Architecture of the \f$\Sigma_1\f$ function block
--! @details The distinction between the SHA-256 and the SHA-512 variant is performed thanks to the 
--! @link Sigma_1.WORD_WIDTH WORD_WIDTH@endlink generic.
architecture RTL of Sigma_1 is
begin
 
	Sigma0 : if WORD_WIDTH = 32 generate	
		o <= (x ror 6) xor (x ror 11) xor (x ror 25);
	elsif WORD_WIDTH = 64 generate
		o <= (x ror 14) xor (x ror 18) xor (x ror 41);
	else generate
		assert(false) report "Mismatched word width assignment" severity failure;
	end generate;
    	
end architecture RTL;
