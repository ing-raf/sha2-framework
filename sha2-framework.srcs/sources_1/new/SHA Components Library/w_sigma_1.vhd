library ieee;
use ieee.std_logic_1164.all;

entity w_sigma_1 is
	generic (
		WORD_WIDTH : natural := 32
	);
	port(
		x : in  std_logic_vector(WORD_WIDTH - 1 downto 0);
		o : out std_logic_vector(WORD_WIDTH - 1 downto 0)
	);
end entity w_sigma_1;

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
