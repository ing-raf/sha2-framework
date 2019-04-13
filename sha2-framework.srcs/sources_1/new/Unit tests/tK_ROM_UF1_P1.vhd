--! Standard library
library ieee;
--! Standard 9-values logic library
use ieee.std_logic_1164.all;

--! @brief Test bench for the K_ROM
--! @details Parameters of the test:
--! * @c UNROLLING_FACTOR equals to 1
--! * @c PIPELINE_STAGES equals to 1
entity tK_ROM_UF1_P1 is
end entity tK_ROM_UF1_P1;

--! Detail of the test bench
architecture Testbench of tK_ROM_UF1_P1 is
	
	--! Clock period
	constant clock_period : time := 10 ns;
	
	--! Clock signal
	signal clk : std_logic := '0';
	--! Enable signal
	signal en : std_logic := '0';
	--! Address signal for the ROM
	signal address : std_logic_vector(5 downto 0) := (others => '0');
	--! Output of the ROM
	signal data : std_logic_vector(31 downto 0) := (others => '0');
	
begin
	
	--! ROM with the test parameters
	uut : entity work.K_ROM
		generic map(
			CYCLES_PER_STAGE => 64,
			UNROLLING_FACTOR => 1,
			STAGE            => 0
		)
		port map(
			clk     => clk,
			en      => en,
			address => address,
			data    => data
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
		wait for clock_period;
		en <= '1';
		wait until data'event;
		assert (data = x"428a2f98") report "Test failed upon initialisation" severity failure;
		address <= 6d"1";
		wait until data'event;
		assert (data = x"71374491") report "Test failed for K[1]" severity failure;
		address <= 6d"2";
		wait until data'event;
		assert (data = x"b5c0fbcf") report "Test failed for K[2]" severity failure;
		address <= 6d"3";
		wait until data'event;
		assert (data = x"e9b5dba5") report "Test failed for K[3]" severity failure;
		address <= 6d"4";
		wait until data'event;
		assert (data = x"3956c25b") report "Test failed for K[4]" severity failure;
		address <= 6d"5";
		wait until data'event;
		assert (data = x"59f111f1") report "Test failed for K[5]" severity failure;
		address <= 6d"6";
		wait until data'event;
		assert (data = x"923f82a4") report "Test failed for K[6]" severity failure;
		address <= 6d"7";
		wait until data'event;
		assert (data = x"ab1c5ed5") report "Test failed for K[7]" severity failure;
		address <= 6d"8";
		wait until data'event;
		assert (data = x"d807aa98") report "Test failed for K[8]" severity failure;
		address <= 6d"9";
		wait until data'event;
		assert (data = x"12835b01") report "Test failed for K[9]" severity failure;
		address <= 6d"10";
		wait until data'event;
		assert (data = x"243185be") report "Test failed for K[10]" severity failure;
		address <= 6d"11";
		wait until data'event;
		assert (data = x"550c7dc3") report "Test failed for K[11]" severity failure;
		address <= 6d"12";
		wait until data'event;
		assert (data = x"72be5d74") report "Test failed for K[12]" severity failure;
		address <= 6d"13";
		wait until data'event;
		assert (data = x"80deb1fe") report "Test failed for K[13]" severity failure;
		address <= 6d"14";
		wait until data'event;
		assert (data = x"9bdc06a7") report "Test failed for K[14]" severity failure;
		address <= 6d"15";
		wait until data'event;
		assert (data = x"c19bf174") report "Test failed for K[15]" severity failure;
		address <= 6d"16";
		wait until data'event;
		assert (data = x"e49b69c1") report "Test failed for K[16]" severity failure;
		address <= 6d"17";
		wait until data'event;
		assert (data = x"efbe4786") report "Test failed for K[17]" severity failure;
		address <= 6d"18";
		wait until data'event;
		assert (data = x"0fc19dc6") report "Test failed for K[18]" severity failure;
		address <= 6d"19";
		wait until data'event;
		assert (data = x"240ca1cc") report "Test failed for K[19]" severity failure;
		address <= 6d"20";
		wait until data'event;
		assert (data = x"2de92c6f") report "Test failed for K[20]" severity failure;
		address <= 6d"21";
		wait until data'event;
		assert (data = x"4a7484aa") report "Test failed for K[21]" severity failure;
		address <= 6d"22";
		wait until data'event;
		assert (data = x"5cb0a9dc") report "Test failed for K[22]" severity failure;
		address <= 6d"23";
		wait until data'event;
		assert (data = x"76f988da") report "Test failed for K[23]" severity failure;
		address <= 6d"24";
		wait until data'event;
		assert (data = x"983e5152") report "Test failed for K[24]" severity failure;
		address <= 6d"25";
		wait until data'event;
		assert (data = x"a831c66d") report "Test failed for K[25]" severity failure;
		address <= 6d"26";
		wait until data'event;
		assert (data = x"b00327c8") report "Test failed for K[26]" severity failure;
		address <= 6d"27";
		wait until data'event;
		assert (data = x"bf597fc7") report "Test failed for K[27]" severity failure;
		address <= 6d"28";
		wait until data'event;
		assert (data = x"c6e00bf3") report "Test failed for K[28]" severity failure;
		address <= 6d"29";
		wait until data'event;
		assert (data = x"d5a79147") report "Test failed for K[29]" severity failure;
		address <= 6d"30";
		wait until data'event;
		assert (data = x"06ca6351") report "Test failed for K[30]" severity failure;
		address <= 6d"31";
		wait until data'event;
		assert (data = x"14292967") report "Test failed for K[31]" severity failure;
		address <= 6d"32";
		wait until data'event;
		assert (data = x"27b70a85") report "Test failed for K[32]" severity failure; 
		address <= 6d"33";
		wait until data'event;
		assert (data = x"2e1b2138") report "Test failed for K[33]" severity failure;
		address <= 6d"34";
		wait until data'event;
		assert (data = x"4d2c6dfc") report "Test failed for K[34]" severity failure;
		address <= 6d"35";
		wait until data'event;
		assert (data = x"53380d13") report "Test failed for K[35]" severity failure;
		address <= 6d"36";
		wait until data'event;
		assert (data = x"650a7354") report "Test failed for K[36]" severity failure;
		address <= 6d"37";
		wait until data'event;
		assert (data = x"766a0abb") report "Test failed for K[37]" severity failure;
		address <= 6d"38";
		wait until data'event;
		assert (data = x"81c2c92e") report "Test failed for K[38]" severity failure;
		address <= 6d"39";
		wait until data'event;
		assert (data = x"92722c85") report "Test failed for K[39]" severity failure;
		address <= 6d"40";
		wait until data'event;
		assert (data = x"a2bfe8a1") report "Test failed for K[40]" severity failure;
		address <= 6d"41";
		wait until data'event;
		assert (data = x"a81a664b") report "Test failed for K[41]" severity failure;
		address <= 6d"42";
		wait until data'event;
		assert (data = x"c24b8b70") report "Test failed for K[42]" severity failure;
		address <= 6d"43";
		wait until data'event;
		assert (data = x"c76c51a3") report "Test failed for K[43]" severity failure;
		address <= 6d"44";
		wait until data'event;
		assert (data = x"d192e819") report "Test failed for K[44]" severity failure;
		address <= 6d"45";
		wait until data'event;
		assert (data = x"d6990624") report "Test failed for K[45]" severity failure;
		address <= 6d"46";
		wait until data'event;
		assert (data = x"f40e3585") report "Test failed for K[46]" severity failure;
		address <= 6d"47";
		wait until data'event;
		assert (data = x"106aa070") report "Test failed for K[47]" severity failure;
		address <= 6d"48";
		wait until data'event;
		assert (data = x"19a4c116") report "Test failed for K[48]" severity failure;
		address <= 6d"49";
		wait until data'event;
		assert (data = x"1e376c08") report "Test failed for K[49]" severity failure;
		address <= 6d"50";
		wait until data'event;
		assert (data = x"2748774c") report "Test failed for K[50]" severity failure;
		address <= 6d"51";
		wait until data'event;
		assert (data = x"34b0bcb5") report "Test failed for K[51]" severity failure;
		address <= 6d"52";
		wait until data'event;
		assert (data = x"391c0cb3") report "Test failed for K[52]" severity failure;
		address <= 6d"53";
		wait until data'event;
		assert (data = x"4ed8aa4a") report "Test failed for K[53]" severity failure;
		address <= 6d"54";
		wait until data'event;
		assert (data = x"5b9cca4f") report "Test failed for K[54]" severity failure;
		address <= 6d"55";
		wait until data'event;
		assert (data = x"682e6ff3") report "Test failed for K[55]" severity failure;
		address <= 6d"56";
		wait until data'event;
		assert (data = x"748f82ee") report "Test failed for K[56]" severity failure;
		address <= 6d"57";
		wait until data'event;
		assert (data = x"78a5636f") report "Test failed for K[57]" severity failure;
		address <= 6d"58";
		wait until data'event;
		assert (data = x"84c87814") report "Test failed for K[58]" severity failure;
		address <= 6d"59";
		wait until data'event;
		assert (data = x"8cc70208") report "Test failed for K[59]" severity failure;
		address <= 6d"60";
		wait until data'event;
		assert (data = x"90befffa") report "Test failed for K[60]" severity failure;
		address <= 6d"61";
		wait until data'event;
		assert (data = x"a4506ceb") report "Test failed for K[61]" severity failure;
		address <= 6d"62";
		wait until data'event;
		assert (data = x"bef9a3f7") report "Test failed for K[62]" severity failure;
		address <= 6d"63";
		wait until data'event;
		assert (data = x"c67178f2") report "Test failed for K[63]" severity failure;
		address <= 6d"0";
		wait until data'event;
		assert (data = x"428a2f98") report "Test failed for K[0]" severity failure; 
	end process;
	
end architecture Testbench;