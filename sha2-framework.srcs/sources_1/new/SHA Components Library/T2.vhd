library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity T2 is
	generic (
		WORD_WIDTH : natural := 32
	);
	port(
		a : in std_logic_vector(WORD_WIDTH - 1 downto 0);
		b : in std_logic_vector(WORD_WIDTH - 1 downto 0);
		c : in std_logic_vector(WORD_WIDTH - 1 downto 0);
		o : out std_logic_vector(WORD_WIDTH - 1 downto 0)
	);
end entity T2;

architecture RTL of T2 is

	signal Sigma_0_o, Maj_o : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');

begin
	
	sigma : entity work.Sigma_0
		generic map (
			WORD_WIDTH => WORD_WIDTH
		)
		port map(
			x => a,
			o => Sigma_0_o
		);
		
	maj : entity work.Majority
		generic map(
			width => WORD_WIDTH
		)
		port map(
			x => a,
			y => b,
			z => c,
			o => Maj_o
		);
	
	o <= std_logic_vector(unsigned(Sigma_0_o) + unsigned(Maj_o));

end architecture RTL;
