--! Standard library
library ieee;
--! Standard 9-values logic library
use ieee.std_logic_1164.all;
--! Arithmetic library, included for the unsigned type conversion
use ieee.numeric_std.all;

--! Test bench for the non-unrolled expander
entity tExpander_stage_UF1 is
end entity tExpander_stage_UF1;

--! Detail of the test bench
architecture Testbench of tExpander_stage_UF1 is
	
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
	signal W : std_logic_vector(31 downto 0) := (others => '0');
	
begin
	
	--! Unit Under Test
	uut : entity work.Expander_stage
		generic map(
			UNROLLING_FACTOR => 1
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
		assert (W = x"61626380") report "Test failed at step 0" severity failure; 
		wait until W'event;
		assert (W = x"00000000") report "Test failed at step 1" severity failure; 
		wait for 15*clock_period;
		assert (W = x"00000018") report "Test failed at step 15" severity failure; 
		wait until W'event;
		assert (W = x"61626380") report "Test failed at step 16" severity failure;
		wait until W'event;
		assert (W = x"000F0000") report "Test failed at step 17" severity failure;
		wait until W'event;
		assert (W = x"7da86405") report "Test failed at step 18" severity failure;
		wait until W'event;
		assert (W = x"600003c6") report "Test failed at step 19" severity failure;
		wait until W'event;
		assert (W = x"3e9d7b78") report "Test failed at step 20" severity failure;
		wait until W'event;
		assert (W = x"0183fc00") report "Test failed at step 21" severity failure;
		wait until W'event;
		assert (W = x"12dcbfdb") report "Test failed at step 22" severity failure;
		wait until W'event;
		assert (W = x"e2e2c38e") report "Test failed at step 23" severity failure;
		wait until W'event;
		assert (W = x"c8215c1a") report "Test failed at step 24" severity failure;
		wait until W'event;
		assert (W = x"b73679a2") report "Test failed at step 25" severity failure;
		wait until W'event;
		assert (W = x"e5bc3909") report "Test failed at step 26" severity failure;
		wait until W'event;
		assert (W = x"32663c5b") report "Test failed at step 27" severity failure;
		wait until W'event;
		assert (W = x"9d209d67") report "Test failed at step 28" severity failure;
		wait until W'event;
		assert (W = x"ec8726cb") report "Test failed at step 29" severity failure;
		wait until W'event;
		assert (W = x"702138a4") report "Test failed at step 30" severity failure;
		wait until W'event;
		assert (W = x"d3b7973b") report "Test failed at step 31" severity failure;
		wait until W'event;
		assert (W = x"93f5997f") report "Test failed at step 32" severity failure;
		wait until W'event;
		assert (W = x"3b68ba73") report "Test failed at step 33" severity failure;
		wait until W'event;
		assert (W = x"aff4ffc1") report "Test failed at step 34" severity failure;
		wait until W'event;
		assert (W = x"f10a5c62") report "Test failed at step 35" severity failure;
		wait until W'event;
		assert (W = x"0a8b3996") report "Test failed at step 36" severity failure;
		wait until W'event;
		assert (W = x"72af830a") report "Test failed at step 37" severity failure;
		wait until W'event;
		assert (W = x"9409e33e") report "Test failed at step 38" severity failure;
		wait until W'event;
		assert (W = x"24641522") report "Test failed at step 39" severity failure;
		wait until W'event;
		assert (W = x"9f47bf94") report "Test failed at step 40" severity failure;
		wait until W'event;
		assert (W = x"f0a64f5a") report "Test failed at step 41" severity failure;
		wait until W'event;
		assert (W = x"3e246a79") report "Test failed at step 42" severity failure;
		wait until W'event;
		assert (W = x"27333ba3") report "Test failed at step 43" severity failure;
		wait until W'event;
		assert (W = x"0c4763f2") report "Test failed at step 44" severity failure;
		wait until W'event;
		assert (W = x"840abf27") report "Test failed at step 45" severity failure;
		wait until W'event;
		assert (W = x"7a290d5d") report "Test failed at step 46" severity failure;
		wait until W'event;
		assert (W = x"065c43da") report "Test failed at step 47" severity failure;
		wait until W'event;
		assert (W = x"fb3e89cb") report "Test failed at step 48" severity failure;
		wait until W'event;
		assert (W = x"cc7617db") report "Test failed at step 49" severity failure;
		wait until W'event;
		assert (W = x"b9e66c34") report "Test failed at step 50" severity failure;
		wait until W'event;
		assert (W = x"a9993667") report "Test failed at step 51" severity failure;
		wait until W'event;
		assert (W = x"84badedd") report "Test failed at step 52" severity failure;
		wait until W'event;
		assert (W = x"c21462bc") report "Test failed at step 53" severity failure;
		wait until W'event;
		assert (W = x"1487472c") report "Test failed at step 54" severity failure;
		wait until W'event;
		assert (W = x"b20f7a99") report "Test failed at step 55" severity failure;
		wait until W'event;
		assert (W = x"ef57b9cd") report "Test failed at step 56" severity failure;
		wait until W'event;
		assert (W = x"ebe6b238") report "Test failed at step 57" severity failure;
		wait until W'event;
		assert (W = x"9fe3095e") report "Test failed at step 58" severity failure;
		wait until W'event;
		assert (W = x"78bc8d4b") report "Test failed at step 59" severity failure;
		wait until W'event;
		assert (W = x"a43fcf15") report "Test failed at step 60" severity failure;
		wait until W'event;
		assert (W = x"668b2ff8") report "Test failed at step 61" severity failure;
		wait until W'event;
		assert (W = x"eeaba2cc") report "Test failed at step 62" severity failure;
		wait until W'event;
		assert (W = x"12b1edeb") report "Test failed at step 63" severity failure;
		wait;
	end process;
	
end architecture Testbench;