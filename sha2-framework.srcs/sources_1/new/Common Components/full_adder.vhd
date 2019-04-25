--! @file full_adder.vhd
--! @brief Full adder entity definition and implementation

--! Standard library
library ieee;
--! Standard 9-values logic library
use ieee.std_logic_1164.all;

--! @brief Full adder
entity full_adder is
	port(
		x     : in  std_logic;  --! First input of the full adder
		y     : in  std_logic;  --! Second input of the full adder
		c_in  : in  std_logic;	--! Carry input of the full adder
		s     : out std_logic;	--! Sum output of the full adder
		c_out : out std_logic	--! Carry output of the full adder
	);
end entity full_adder;

--! @brief Architecture of the full adder
architecture RTL of full_adder is

begin

	s     <= x xor y xor c_in;
	c_out <= (x and y) or (y and c_in) or (x and c_in);

end architecture RTL;
