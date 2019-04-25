--! @file CS_adder.vhd
--! @brief Carry-Save adder entity definition and implementation

--! Standard library
library ieee;
--! Standard 9-values logic library
use ieee.std_logic_1164.all;

--! @brief Carry-Save adder
--! @details Three-operands adder with delay comparable to a two-operands adder
entity CS_adder is
	generic (
		width : integer := 8 --! Width of the adder
	);
	port(
		x     : in  std_logic_vector(width-1 downto 0); --! First input operand of the adder
		y     : in  std_logic_vector(width-1 downto 0); --! Second input operand of the adder
		z     : in  std_logic_vector(width-1 downto 0); --! Third input operand of the adder
		c_in  : in  std_logic; --! Carry input of the adder
		s     : out std_logic_vector(width-1 downto 0); --! Sum output of the adder
		c_out : out std_logic --! Carry output of the adder
	);
end entity CS_adder;

--! @brief Architecture of the Carry Save Adder
--! @details The Carry-Save adder first computes, for each bit of the imputs, the sum of the three input bits, and their
--! carry bit. Therefore, the carry vector is added to the partial sum vector
architecture RTL of CS_adder is
	--! Partial sums vector
	signal t : std_logic_vector(width-1 downto 0) := (others => '0');
	--! Carry vector
	signal c : std_logic_vector(width-1 downto 0) := (others => '0');
	
begin
	
	--! Full adder array to precompute the carry bits
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
	
	--! Final addition between the partial sum and the carry bits
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
