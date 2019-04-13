library ieee;
use ieee.std_logic_1164.all;

entity full_adder is
	port(
		x     : in  std_logic;
		y     : in  std_logic;
		c_in  : in  std_logic;
		s     : out std_logic;
		c_out : out std_logic
	);
end entity full_adder;

architecture RTL of full_adder is

begin

	s     <= x xor y xor c_in;
	c_out <= (x and y) or (y and c_in) or (x and c_in);

end architecture RTL;
