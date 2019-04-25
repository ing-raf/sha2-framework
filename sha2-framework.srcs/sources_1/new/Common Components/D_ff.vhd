--! @file D_ff.vhd
--! @brief D flip-flop entity definition and implementation

--! Standard library
library ieee;
--! Standard 9-values logic library
use ieee.std_logic_1164.all;

--! @brief Enabled D flip-flop with asynchronous reset
--! @details Reads its input signal and propagates it at the rising edge of the clock signal, if enables
--! @details If not enabled, retains the last sampled value
entity D_ff is
	port(
		clk     : in  std_logic; --! Clock of this component
		not_rst : in  std_logic; --! Active-low asynchronous reset signal
		en      : in  std_logic; --! Enable signal
		d       : in  std_logic; --! Input signal for the flip-flop
		q       : out std_logic --! Current value of the flip-flop
	);
end entity D_ff;

--! Architecture of the D flip-flop
architecture Behavioural of D_ff is

begin

	--! Process for updating the internal state of the flip-flop
	ff : process(clk, en, not_rst) is
	begin
		if (not_rst = '0') then
			q <= '0';
		elsif (en = '1') then
			if (rising_edge(clk)) then
				q <= d;
			end if;
		end if;

	end process;

end architecture Behavioural;
