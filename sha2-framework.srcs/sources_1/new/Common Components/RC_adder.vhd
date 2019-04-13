library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RC_adder is
	generic (
		width : integer := 8
	);
	port(
		x     : in  std_logic_vector(width-1 downto 0);
		y     : in  std_logic_vector(width-1 downto 0);
		c_in  : in  std_logic;
		s     : out std_logic_vector(width-1 downto 0);
		c_out : out std_logic
	);
end entity RC_adder;

architecture RTL of RC_adder is
	
	signal c_internal : std_logic_vector(width downto 0) := (others => '0');
	
begin
	
	ripple_carry : for i in width-1 downto 0 generate
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
