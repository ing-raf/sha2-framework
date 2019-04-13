--! Standard library
library ieee;
--! Standard 9-values logic library
use ieee.std_logic_1164.all;

--! @brief Test bench for the K_ROM
--! @details Parameters of the test:
--! * @c UNROLLING_FACTOR equals to 1
--! * @c PIPELINE_STAGES equals to 4
entity tK_ROM_UF1_P4 is
end entity tK_ROM_UF1_P4;

--! Detail of the test bench
architecture Testbench of tK_ROM_UF1_P4 is
	
	--! Clock period
	constant clock_period : time := 10 ns;
	
	--! Clock signal
	signal clk : std_logic := '0';
	--! Enable signal
	signal en : std_logic := '0';
	--! Address signal for the ROM
	signal address : std_logic_vector(3 downto 0) := (others => '0');
	--! Output of the ROM of the first stage
	signal K1 : std_logic_vector(31 downto 0) := (others => '0');
	--! Output of the ROM of the second stage
	signal K2 : std_logic_vector(31 downto 0) := (others => '0');
	--! Output of the ROM of the third stage
	signal K3 : std_logic_vector(31 downto 0) := (others => '0');
	--! Output of the ROM of the fourth stage
	signal K4 : std_logic_vector(31 downto 0) := (others => '0');
	
begin
	
	--! ROM for the first stage
	uut1 : entity work.K_ROM
		generic map(
			CYCLES_PER_STAGE => 16,
			UNROLLING_FACTOR => 1,
			STAGE            => 0
		)
		port map(
			clk     => clk,
			en      => en,
			address => address,
			data    => K1
		);
		
	--! ROM for the second stage
	uut2 : entity work.K_ROM
		generic map(
			CYCLES_PER_STAGE => 16,
			UNROLLING_FACTOR => 1,
			STAGE            => 1
		)
		port map(
			clk     => clk,
			en      => en,
			address => address,
			data    => K2
		);
		
	--! ROM for the third stage
	uut3 : entity work.K_ROM
		generic map(
			CYCLES_PER_STAGE => 16,
			UNROLLING_FACTOR => 1,
			STAGE            => 2
		)
		port map(
			clk     => clk,
			en      => en,
			address => address,
			data    => K3
		);
		
	--! ROM for the fourth stage
	uut4 : entity work.K_ROM
		generic map(
			CYCLES_PER_STAGE => 16,
			UNROLLING_FACTOR => 1,
			STAGE            => 3
		)
		port map(
			clk     => clk,
			en      => en,
			address => address,
			data    => K4
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
		wait until K1'event;
		assert (K1 = x"428a2f98") report "Test of K1 failed upon initialisation" severity failure;
		assert (K2 = x"e49b69c1") report "Test of K2 failed upon initialisation" severity failure;
		assert (K3 = x"27b70a85") report "Test of K3 failed upon initialisation" severity failure;
		assert (K4 = x"19a4c116") report "Test of K4 failed upon initialisation" severity failure; 
		address <= 4d"1";
		wait until K1'event;
		assert (K1 = x"71374491") report "Test failed for K1[1]" severity failure;
		assert (K2 = x"efbe4786") report "Test failed for K2[1]" severity failure;
		assert (K3 = x"2e1b2138") report "Test failed for K3[1]" severity failure;
		assert (K4 = x"1e376c08") report "Test failed for K4[1]" severity failure;
		address <= 4d"2";
		wait until K1'event;
		assert (K1 = x"b5c0fbcf") report "Test failed for K1[2]" severity failure;
		assert (K2 = x"0fc19dc6") report "Test failed for K2[2]" severity failure;
		assert (K3 = x"4d2c6dfc") report "Test failed for K3[2]" severity failure;
		assert (K4 = x"2748774c") report "Test failed for K4[2]" severity failure;
		address <= 4d"3";
		wait until K1'event;
		assert (K1 = x"e9b5dba5") report "Test failed for K1[3]" severity failure;
		assert (K2 = x"240ca1cc") report "Test failed for K2[3]" severity failure;
		assert (K3 = x"53380d13") report "Test failed for K3[3]" severity failure;
		assert (K4 = x"34b0bcb5") report "Test failed for K4[3]" severity failure;
		address <= 4d"4";
		wait until K1'event;
		assert (K1 = x"3956c25b") report "Test failed for K1[4]" severity failure;
		assert (K2 = x"2de92c6f") report "Test failed for K2[4]" severity failure;
		assert (K3 = x"650a7354") report "Test failed for K3[4]" severity failure;
		assert (K4 = x"391c0cb3") report "Test failed for K4[4]" severity failure;
		address <= 4d"5";
		wait until K1'event;
		assert (K1 = x"59f111f1") report "Test failed for K1[5]" severity failure;
		assert (K2 = x"4a7484aa") report "Test failed for K2[5]" severity failure;
		assert (K3 = x"766a0abb") report "Test failed for K3[5]" severity failure;
		assert (K4 = x"4ed8aa4a") report "Test failed for K4[5]" severity failure;
		address <= 4d"6";
		wait until K1'event;
		assert (K1 = x"923f82a4") report "Test failed for K1[6]" severity failure;
		assert (K2 = x"5cb0a9dc") report "Test failed for K2[6]" severity failure;
		assert (K3 = x"81c2c92e") report "Test failed for K3[6]" severity failure;
		assert (K4 = x"5b9cca4f") report "Test failed for K4[6]" severity failure;		
		address <= 4d"7";
		wait until K1'event;
		assert (K1 = x"ab1c5ed5") report "Test failed for K1[7]" severity failure;
		assert (K2 = x"76f988da") report "Test failed for K2[7]" severity failure;
		assert (K3 = x"92722c85") report "Test failed for K3[7]" severity failure;
		assert (K4 = x"682e6ff3") report "Test failed for K4[7]" severity failure;
		address <= 4d"8";
		wait until K1'event;
		assert (K1 = x"d807aa98") report "Test failed for K1[8]" severity failure;
		assert (K2 = x"983e5152") report "Test failed for K2[8]" severity failure;
		assert (K3 = x"a2bfe8a1") report "Test failed for K3[8]" severity failure;
		assert (K4 = x"748f82ee") report "Test failed for K4[8]" severity failure;
		address <= 4d"9";
		wait until K1'event;
		assert (K1 = x"12835b01") report "Test failed for K1[9]" severity failure;
		assert (K2 = x"a831c66d") report "Test failed for K2[9]" severity failure;
		assert (K3 = x"a81a664b") report "Test failed for K3[9]" severity failure;
		assert (K4 = x"78a5636f") report "Test failed for K4[9]" severity failure;
		address <= 4d"10";
		wait until K1'event;
		assert (K1 = x"243185be") report "Test failed for K1[10]" severity failure;
		assert (K2 = x"b00327c8") report "Test failed for K2[10]" severity failure;
		assert (K3 = x"c24b8b70") report "Test failed for K3[10]" severity failure;
		assert (K4 = x"84c87814") report "Test failed for K4[10]" severity failure;		
		address <= 4d"11";
		wait until K1'event;
		assert (K1 = x"550c7dc3") report "Test failed for K1[11]" severity failure;
		assert (K2 = x"bf597fc7") report "Test failed for K2[11]" severity failure;
		assert (K3 = x"c76c51a3") report "Test failed for K3[11]" severity failure;
		assert (K4 = x"8cc70208") report "Test failed for K4[11]" severity failure;	
		address <= 4d"12";
		wait until K1'event;
		assert (K1 = x"72be5d74") report "Test failed for K1[12]" severity failure;
		assert (K2 = x"c6e00bf3") report "Test failed for K2[12]" severity failure;
		assert (K3 = x"d192e819") report "Test failed for K3[12]" severity failure;
		assert (K4 = x"90befffa") report "Test failed for K4[12]" severity failure;		
		address <= 4d"13";
		wait until K1'event;
		assert (K1 = x"80deb1fe") report "Test failed for K1[13]" severity failure;
		assert (K2 = x"d5a79147") report "Test failed for K2[13]" severity failure;
		assert (K3 = x"d6990624") report "Test failed for K3[13]" severity failure;
		assert (K4 = x"a4506ceb") report "Test failed for K4[13]" severity failure;		
		address <= 4d"14";
		wait until K1'event;
		assert (K1 = x"9bdc06a7") report "Test failed for K1[14]" severity failure;
		assert (K2 = x"06ca6351") report "Test failed for K2[14]" severity failure;
		assert (K3 = x"f40e3585") report "Test failed for K3[14]" severity failure;
		assert (K4 = x"bef9a3f7") report "Test failed for K4[14]" severity failure;		
		address <= 4d"15";
		wait until K1'event;
		assert (K1 = x"c19bf174") report "Test failed for K1[15]" severity failure;
		assert (K2 = x"14292967") report "Test failed for K2[15]" severity failure;
		assert (K3 = x"106aa070") report "Test failed for K3[15]" severity failure;
		assert (K4 = x"c67178f2") report "Test failed for K4[15]" severity failure;
		address <= 4d"0";
		wait until K1'event;
		assert (K1 = x"428a2f98") report "Test failed for K1[0]" severity failure;
		assert (K2 = x"e49b69c1") report "Test failed for K2[0]" severity failure;
		assert (K3 = x"27b70a85") report "Test failed for K3[0]" severity failure;
		assert (K4 = x"19a4c116") report "Test failed for K4[0]" severity failure;
	end process;
	
end architecture Testbench;