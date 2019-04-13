library ieee;
use ieee.std_logic_1164.all;

entity D_ff is
	port(
		clk     : in  std_logic;
		not_rst : in  std_logic;
		en      : in  std_logic;
		d       : in  std_logic;
		q       : out std_logic
	);
end entity D_ff;

architecture Behavioural of D_ff is

begin

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
