library ieee;
use ieee.std_logic_1164.all;

entity Sigma_0 is
	generic (
		WORD_WIDTH : natural := 32
	);
	port(
		x : in  std_logic_vector(WORD_WIDTH - 1 downto 0);
		o : out std_logic_vector(WORD_WIDTH - 1 downto 0)
	);
end entity Sigma_0;

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
