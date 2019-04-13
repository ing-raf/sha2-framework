library ieee;
use ieee.std_logic_1164.all;

entity Majority is
	generic(
		width : natural := 32
	);
	port(
		x : in  std_logic_vector(width - 1 downto 0);
		y : in  std_logic_vector(width - 1 downto 0);
		z : in  std_logic_vector(width - 1 downto 0);
		o : out std_logic_vector(width - 1 downto 0)
	);
end entity Majority;

architecture RTL of Majority is
	
begin
	
	o <= (x and y) xor (x and z) xor (y and z);

end architecture RTL;
