library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg is
	generic(
		width : natural := 32
	);
	port(
		clk     : in  std_logic;
		not_rst : in  std_logic;
		en      : in  std_logic;
		d       : in  std_logic_vector(width - 1 downto 0);
		q       : out std_logic_vector(width - 1 downto 0)
	);
end entity reg;

architecture RTL of reg is

begin

	ff_array : for i in width - 1 downto 0 generate
		ff : entity work.D_ff
			port map(
				clk     => clk,
				not_rst => not_rst,
				en      => en,
				d       => d(i),
				q       => q(i)
			);
	end generate;

end architecture RTL;
