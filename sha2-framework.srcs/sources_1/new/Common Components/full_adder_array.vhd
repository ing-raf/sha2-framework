--! @file full_adder_array.vhd
--! @brief Full adder array entity definition and implementation

--! Standard library
library ieee;
--! Standard 9-values logic library
use ieee.std_logic_1164.all;

--! @brief Full adder array
--! @details A bench of full adders. The carry output features one carry output bit per full adder, therefore is not
--! aligned with the sum. Instead, each carry bit is aligned with the full adder which generates it. This particular
--! alignment allows for the addition of the carry bit with the output sum, as performed in the @link CS_adder Carry-Save adder@endlink
entity full_adder_array is
	generic(
		width : integer := 32
	);
	port(
		x : in  std_logic_vector(width - 1 downto 0); --! First input operand of the full adder array
		y : in  std_logic_vector(width - 1 downto 0); --! Second input operand of the full adder
		z : in  std_logic_vector(width - 1 downto 0); --! Third input operand of the full adder
		s : out std_logic_vector(width - 1 downto 0); --! Sum output of the full adder array
		c : out std_logic_vector(width - 1 downto 0) --! Carry output vector of the full adder
	);
end entity full_adder_array;

--! @brief Architectuere of the full adder array
architecture RTL of full_adder_array is

	--! Temporary array of carry outputs
	signal c_temp : std_logic_vector(width - 1 downto 0) := (others => '0');

begin

	faa : for i in width - 1 downto 0 generate
		--! Each one of the full adder of the array
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
