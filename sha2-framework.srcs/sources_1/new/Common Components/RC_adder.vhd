--! @file RC_adder.vhd
--! @brief Ripple-carry adder entity definition and implementation

--! Standard library
library ieee;
--! Standard 9-values logic library
use ieee.std_logic_1164.all;

--! @brief Ripple-Carry adder
entity RC_adder is
	generic (
		width : integer := 8 --! Width of the adder
	);
	port(
		x     : in  std_logic_vector(width-1 downto 0); --! First input operand of the adder
		y     : in  std_logic_vector(width-1 downto 0); --! Second input operand of the adder
		c_in  : in  std_logic; --! Carry input of the adder
		s     : out std_logic_vector(width-1 downto 0); --! Sum output of the adder
		c_out : out std_logic --! Carry output of the adder
	);
end entity RC_adder;

--! @brief Architecture of the RC adder
architecture RTL of RC_adder is
	
	--! Carry signal vector, used for chaining
	signal c_internal : std_logic_vector(width downto 0) := (others => '0');
	
begin
	
	ripple_carry : for i in width-1 downto 0 generate
		--! Each one of the full adder of the RC adder
		full_adder_i : entity work.full_adder
			port map(
				x     => x(i),
				y     => y(i),
				c_in  => c_internal(i),
				s     => s(i),
				c_out => c_internal(i+1)
			);
	end generate;
	
	c_internal(0) <= c_in;
	c_out <= c_internal(width);

end architecture RTL;
