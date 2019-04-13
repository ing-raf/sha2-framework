library ieee;
use ieee.std_logic_1164.all;

entity Sigma_1 is
	generic (
		WORD_WIDTH : natural := 32
	);
	port(
		x : in  std_logic_vector(WORD_WIDTH - 1 downto 0);
		o : out std_logic_vector(WORD_WIDTH - 1 downto 0)
	);
end entity Sigma_1;

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
