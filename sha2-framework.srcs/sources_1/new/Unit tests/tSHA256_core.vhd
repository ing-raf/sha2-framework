--! Standard library
library ieee;
--! Standard 9-values logic library
use ieee.std_logic_1164.all;
--! Arithmetic library, included for the unsigned type conversion
use ieee.numeric_std.all;

--! Test bench for the SHA-256 hash core
entity tSHA256_core is
end entity tSHA256_core;

--! Detail of the test bench
architecture Testbench of tSHA256_core is

	--! Clock period
	constant clock_period : time := 10 ns;
	--! Initialisation vector
	constant IV : std_logic_vector(255 downto 0) := x"6a09e667" & x"bb67ae85" & x"3c6ef372" & x"a54ff53a" & x"510e527f" & x"9b05688c" & x"1f83d9ab" & x"5be0cd19";

	--! Clock signal
	signal clk       : std_logic := '0';
	--! Asynchronous active-low reset signal
	signal not_rst   : std_logic := '0';
	--! Enable signal
	signal en        : std_logic := '0';
	--! Start signal
	signal start     : std_logic := '0';
	--! When asserted, a new input can be provided
	signal ready     : std_logic := '0';
	--! When asserted, a new hash output is available
	signal completed : std_logic := '0';

	--! Padded data block to test
	signal M_blk : std_logic_vector(511 downto 0) := (others => '0');
	--! Output hash value
	signal hash  : std_logic_vector(255 downto 0) := (others => '0');

begin

	--! Unit Under Test
	uut : entity work.SHA2_core
		generic map (
			WIDTH => 256
		)
		port map(
			clk       => clk,
			not_rst   => not_rst,
			en        => en,
			start     => start,
			M_blk     => M_blk,
			iv        => IV,
			ready     => ready,
			completed => completed,
			hash      => hash
		);

	--! Process for clock generation	
	clock_process : process
	begin
		clk <= '1';
		wait for clock_period / 2;
		clk <= '0';
		wait for clock_period / 2;
	end process;
	
	-- Process for initial reset
	transient_process : process
	begin
		not_rst <= '1' after clock_period;
		wait until rising_edge(ready);
		en      <= '1';
		wait;
	end process;

	--! Test process
	stim_process : process
	begin
		if (en = '0') then
			wait until rising_edge(en);
		end if;
		-- Message "abc"
		M_blk   <= (511 downto 504 => x"61",
		            503 downto 496 => x"62",
		            495 downto 488 => x"63",
		            487            => '1',
		            63 downto 0    => std_logic_vector(to_unsigned(24, 64)),
		            others         => '0');
		start   <= '1';

		wait until rising_edge(clk);
		M_blk <= (others => '0');
		start <= '0';
		wait;
	end process;
	
	--! Verification process
	oracle_process : process
	begin
		if (en = '0') then
			wait until rising_edge(en);
		end if;
		
		wait until rising_edge(completed);
		assert (hash = x"ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad") report "Test failed" severity failure;	
		report "Test passed" severity note;
		wait;
	end process;

end architecture Testbench;
