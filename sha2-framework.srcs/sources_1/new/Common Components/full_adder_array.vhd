library ieee;
use ieee.std_logic_1164.all;

entity full_adder_array is
	generic(
		width : integer := 32
	);
	port(
		x : in  std_logic_vector(width - 1 downto 0);
		y : in  std_logic_vector(width - 1 downto 0);
		z : in  std_logic_vector(width - 1 downto 0);
		s : out std_logic_vector(width - 1 downto 0);
		c : out std_logic_vector(width - 1 downto 0)
	);
end entity full_adder_array;

architecture RTL of full_adder_array is

	signal c_temp : std_logic_vector(width - 1 downto 0) := (others => '0');

begin

	faa : for i in width - 1 downto 0 generate
		fa : entity work.full_adder
			port map(
				x     => x(i),
				y     => y(i),
				c_in  => z(i),
				s     => s(i),
				c_out => c_temp(i)
			);
	end generate;

	c <= c_temp sll 1;

end architecture RTL;
