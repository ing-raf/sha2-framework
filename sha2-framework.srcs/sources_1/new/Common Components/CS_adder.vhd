library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity CS_adder is
	generic (
		width : integer := 8
	);
	port(
		x     : in  std_logic_vector(width-1 downto 0);
		y     : in  std_logic_vector(width-1 downto 0);
		z     : in  std_logic_vector(width-1 downto 0);
		c_in  : in  std_logic;
		s     : out std_logic_vector(width-1 downto 0);
		c_out : out std_logic
	);
end entity CS_adder;

architecture RTL of CS_adder is
	
	signal t, c : std_logic_vector(width-1 downto 0) := (others => '0');
	
begin
	
	carry_save_logic : entity work.full_adder_array
		generic map(
			width => width
		)
		port map(
			x => x,
			y => y,
			z => z,
			s => t,
			c => c
		);
		
	rca : entity work.RC_adder
		generic map(
			width => width
		)
		port map(
			x     => t,
			y     => c,
			c_in  => c_in,
			s     => s,
			c_out => c_out
		);

end architecture RTL;
