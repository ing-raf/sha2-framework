library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity T1 is
	generic (
		WORD_WIDTH : natural := 32
	);
	port(
		e : in  std_logic_vector(WORD_WIDTH - 1 downto 0);
		f : in  std_logic_vector(WORD_WIDTH - 1 downto 0);
		g : in  std_logic_vector(WORD_WIDTH - 1 downto 0);
		h : in  std_logic_vector(WORD_WIDTH - 1 downto 0);
		K : in  std_logic_vector(WORD_WIDTH - 1 downto 0);
		W : in  std_logic_vector(WORD_WIDTH - 1 downto 0);
		o : out std_logic_vector(WORD_WIDTH - 1 downto 0)
	);
end entity T1;

architecture RTL of T1 is
	
	signal Sigma_1_o, Ch_o : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');

begin

	sigma : entity work.Sigma_1
		generic map(
			WORD_WIDTH => WORD_WIDTH
		)
		port map(
			x => e,
			o => Sigma_1_o
		);

	choose : entity work.Choose
		generic map(
			width => WORD_WIDTH
		)
		port map(
			x => e,
			y => f,
			z => g,
			o => Ch_o
		);

	o <= std_logic_vector(unsigned(h) + unsigned(Sigma_1_o) + unsigned(Ch_o) + unsigned(K) + unsigned(W));

end architecture RTL;
