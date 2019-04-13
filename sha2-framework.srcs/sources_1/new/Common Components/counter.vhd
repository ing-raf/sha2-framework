library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity counter is
	generic(
		top : natural := 64
	);
	port(
		clk     : in  std_logic;
		not_rst : in  std_logic;
		en      : in  std_logic;
		q       : out std_logic;
		value   : out std_logic_vector(integer(log2(real(top-1))) downto 0)
	);
end entity counter;

architecture Behavioural of counter is

begin

	process(not_rst, clk) is
		variable count : integer := 0;
	begin
		if (not_rst = '0') then
			count := 0;
			q     <= '0';
		elsif (rising_edge(clk)) then
			if (en = '1') then
				count := count + 1;

				if count = top then
					q     <= '1';
					count := 0;
				else
					q <= '0';
				end if;
			end if;
		end if;
--		value <= std_logic_vector(to_unsigned(count, integer(log2(real(top)))));
		value <= std_logic_vector(to_unsigned(count, value'length));
	end process;

end architecture Behavioural;
