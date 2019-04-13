library ieee;
use ieee.std_logic_1164.all;

entity Choose is
	generic(
		width : natural := 32
	);
	port(
		x : in  std_logic_vector(width - 1 downto 0);
		y : in  std_logic_vector(width - 1 downto 0);
		z : in  std_logic_vector(width - 1 downto 0);
		o : out std_logic_vector(width - 1 downto 0)
	);
end entity Choose;

architecture RTL of Choose is

begin

	o <= (x and y) xor (not x and z);

end architecture RTL;
