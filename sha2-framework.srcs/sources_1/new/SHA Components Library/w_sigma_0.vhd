library ieee;
use ieee.std_logic_1164.all;

entity w_sigma_0 is
	generic (
		WORD_WIDTH : natural := 32
	);
	port(
		x : in  std_logic_vector(WORD_WIDTH - 1 downto 0);
		o : out std_logic_vector(WORD_WIDTH - 1 downto 0)
	);
end entity w_sigma_0;

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
