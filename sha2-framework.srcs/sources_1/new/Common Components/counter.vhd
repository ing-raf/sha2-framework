--! @file counter.vhd
--! @brief Upward counter entity definition and implementation

--! Standard library
library ieee;
--! Standard 9-values logic library
use ieee.std_logic_1164.all;
--! Arithmetic library, included for the unsigned to integer conversion function
use ieee.numeric_std.all;
--! Standard math library, required for the @c log2 function
use ieee.math_real.all;

--! @brief Upward counter
--! @details Upward counter with overflow and current value output
--! @details The counter value ranges from 0 to @link counter.top top@endlink-1
entity counter is
	generic(
		top : natural := 64 --! Maximum counter value
	);
	port(
		clk     : in  std_logic; --! Clock of this component
		not_rst : in  std_logic; --! Active-low asynchronous reset signal
		en      : in  std_logic; --! Enable signal
		q       : out std_logic; --! Overflow output, asserted when the counter reaches the value @link counter.top top@endlink
		value   : out std_logic_vector(integer(log2(real(top-1))) downto 0) --! Current counter value
	);
end entity counter;

--! @brief Architecture of the counter
--! @details When the counter reach the top value, its value is set to 0 and the overflow output is asserted. This way,
--!	the value @link counter.top top@endlink needs not to be encoded in the counting value
--! @details The counter value is updated outside of th @c process
architecture Behavioural of counter is

begin
	--! Process for updating the internal counting variable
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

		value <= std_logic_vector(to_unsigned(count, value'length));
	end process;

end architecture Behavioural;
