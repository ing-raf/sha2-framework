--! @file reg.vhd
--! @brief D register entity definition and implementation

--! Standard library
library ieee;
--! Standard 9-values logic library
use ieee.std_logic_1164.all;

--! @brief D register
entity reg is
	generic(
		width : natural := 32 --! Width of the register
	);
	port(
		clk     : in  std_logic; --! Clock of this component
		not_rst : in  std_logic; --! Active-low asynchronous reset signal
		en      : in  std_logic; --! Enable signal
		d       : in  std_logic_vector(width - 1 downto 0); --! Input word of the register
		q       : out std_logic_vector(width - 1 downto 0) --! Output word of the register
	);
end entity reg;

--! @brief Architecture of the D register
architecture RTL of reg is

begin

	ff_array : for i in width - 1 downto 0 generate
		--! Each one of the flip-flops of the register
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
