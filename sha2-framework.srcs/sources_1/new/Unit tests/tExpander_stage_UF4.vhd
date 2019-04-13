--! Standard library
library ieee;
--! Standard 9-values logic library
use ieee.std_logic_1164.all;
--! Arithmetic library, included for the unsigned type conversion
use ieee.numeric_std.all;

--! Test bench for the 4-unrolled expander
entity tExpander_stage_UF4 is
end entity tExpander_stage_UF4;

--! Detail of the test bench
architecture Testbench of tExpander_stage_UF4 is
	
	--! Clock period
	constant clock_period : time := 10 ns;
	
	--! Clock signal
	signal clk : std_logic := '0';
	--! Asynchronous active-low reset signal
	signal not_rst : std_logic := '0';
	--! Enable signal
	signal en : std_logic := '0';
	--! Initialisation signal to load the Expander
	signal load_msg : std_logic := '0';
	--! Input to the Expander
	signal M_blk : std_logic_vector(511 downto 0) := (others => '0');
	--! Newly expanded word
	signal W : std_logic_vector(127 downto 0) := (others => '0');
	
begin
	
	--! Unit Under Test
	uut : entity work.Expander_stage
		generic map(
			UNROLLING_FACTOR => 4
		)
		port map(
			clk             => clk,
			not_rst         => not_rst,
			en              => en,
			end_major_cycle => load_msg,
			W_in            => M_blk,
			W               => W,
			W_out           => open
		);
	
	--! Process for clock generation	
	clock_process : process
	begin
		clk <= '1';
		wait for clock_period/2;
		clk <= '0';
		wait for clock_period/2;
	end process;
	
	--! Test process
	stim_process : process
	begin
		not_rst <= '1' after clock_period;
		wait for 2*clock_period;
		en <= '1';
		wait for clock_period;
		load_msg <= '1', '0' after 2*clock_period;
		M_blk <= (	511 downto 504 => x"61", 
					503 downto 496 => x"62", 
					495 downto 488 => x"63", 
					487 => '1',
					63 downto 0 => std_logic_vector(to_unsigned(24, 64)),
					others => '0');
		wait until W'event;
		assert (W = x"00000000" & x"00000000" & x"00000000" & x"61626380") report "Test failed at step 0" severity failure;
		wait until W'event;
		assert (W = x"00000000" & x"00000000" & x"00000000" & x"00000000") report "Test failed at step 1" severity failure;
		wait for clock_period;
		assert (W = x"00000000" & x"00000000" & x"00000000" & x"00000000") report "Test failed at step 2" severity failure;
		wait until W'event;
		assert (W = x"00000018" & x"00000000" & x"00000000" & x"00000000") report "Test failed at step 3" severity failure;
		wait until W'event;
		assert (W = x"600003c6" & x"7da86405" & x"000F0000" & x"61626380") report "Test failed at step 4" severity failure;
		wait until W'event;
		assert (W = x"e2e2c38e" & x"12dcbfdb" & x"0183fc00" & x"3e9d7b78") report "Test failed at step 5" severity failure;
		wait until W'event;
		assert (W = x"32663c5b" & x"e5bc3909" & x"b73679a2" & x"c8215c1a") report "Test failed at step 6" severity failure;
		wait until W'event;
		assert (W = x"d3b7973b" & x"702138a4" & x"ec8726cb" & x"9d209d67") report "Test failed at step 7" severity failure;
		wait until W'event;
		assert (W = x"f10a5c62" & x"aff4ffc1" & x"3b68ba73" & x"93f5997f") report "Test failed at step 8" severity failure;
		wait until W'event;
		assert (W = x"24641522" & x"9409e33e" & x"72af830a" & x"0a8b3996") report "Test failed at step 9" severity failure;
		wait until W'event;
		assert (W = x"27333ba3" & x"3e246a79" & x"f0a64f5a" & x"9f47bf94") report "Test failed at step 10" severity failure;
		wait until W'event;
		assert (W = x"065c43da" & x"7a290d5d" & x"840abf27" & x"0c4763f2") report "Test failed at step 11" severity failure;
		wait until W'event;
		assert (W = x"a9993667" & x"b9e66c34" & x"cc7617db" & x"fb3e89cb") report "Test failed at step 12" severity failure;
		wait until W'event;
		assert (W = x"b20f7a99" & x"1487472c" & x"c21462bc" & x"84badedd") report "Test failed at step 13" severity failure;
		wait until W'event;
		assert (W = x"78bc8d4b" & x"9fe3095e" & x"ebe6b238" & x"ef57b9cd") report "Test failed at step 14" severity failure;
		wait until W'event;
		assert (W = x"12b1edeb" & x"eeaba2cc" & x"668b2ff8" & x"a43fcf15") report "Test failed at step 15" severity failure;
		wait;
	end process;
	
end architecture Testbench;