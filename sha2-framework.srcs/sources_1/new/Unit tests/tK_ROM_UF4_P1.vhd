--! Standard library
library ieee;
--! Standard 9-values logic library
use ieee.std_logic_1164.all;

--! @brief Test bench for the K_ROM
--! @details Parameters of the test:
--! * @c UNROLLING_FACTOR equals to 4
--! * @c PIPELINE_STAGES equals to 1
entity tK_ROM_UF4_P1 is
end entity tK_ROM_UF4_P1;

--! Detail of the test bench
architecture Testbench of tK_ROM_UF4_P1 is
	
	--! Clock period
	constant clock_period : time := 10 ns;
	
	--! Clock signal
	signal clk : std_logic := '0';
	--! Enable signal
	signal en : std_logic := '0';
	--! Address signal for the ROM
	signal address : std_logic_vector(3 downto 0) := (others => '0');
	--! Output of the ROM
	signal data : std_logic_vector(127 downto 0) := (others => '0');
	
begin
	
	--! ROM with the test parameters
	uut : entity work.K_ROM
		generic map(
			CYCLES_PER_STAGE => 16,
			UNROLLING_FACTOR => 4,
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
		assert (data = x"e9b5dba5" & x"b5c0fbcf" & x"71374491" & x"428a2f98") report "Test failed upon initialisation" severity failure;
		address <= 4d"1";
		wait until data'event;
		assert (data = x"ab1c5ed5" & x"923f82a4" & x"59f111f1" & x"3956c25b") report "Test failed for K[1]" severity failure;
		address <= 4d"2";
		wait until data'event;
		assert (data = x"550c7dc3" & x"243185be" & x"12835b01" & x"d807aa98") report "Test failed for K[2]" severity failure;
		address <= 4d"3";
		wait until data'event;
		assert (data = x"c19bf174" & x"9bdc06a7" & x"80deb1fe" & x"72be5d74") report "Test failed for K[3]" severity failure;
		address <= 4d"4";
		wait until data'event;
		assert (data = x"240ca1cc" & x"0fc19dc6" & x"efbe4786" & x"e49b69c1") report "Test failed for K[4]" severity failure;
		address <= 4d"5";
		wait until data'event;
		assert (data = x"76f988da" & x"5cb0a9dc" & x"4a7484aa" & x"2de92c6f") report "Test failed for K[5]" severity failure;
		address <= 4d"6";
		wait until data'event;
		assert (data = x"bf597fc7" & x"b00327c8" & x"a831c66d" & x"983e5152") report "Test failed for K[6]" severity failure;
		address <= 4d"7";
		wait until data'event;
		assert (data = x"14292967" & x"06ca6351" & x"d5a79147" & x"c6e00bf3") report "Test failed for K[7]" severity failure;
		address <= 4d"8";
		wait until data'event;
		assert (data = x"53380d13" & x"4d2c6dfc" & x"2e1b2138" & x"27b70a85") report "Test failed for K[8]" severity failure;
		address <= 4d"9";
		wait until data'event;
		assert (data = x"92722c85" & x"81c2c92e" & x"766a0abb" & x"650a7354") report "Test failed for K[9]" severity failure;
		address <= 4d"10";
		wait until data'event;
		assert (data = x"c76c51a3" & x"c24b8b70" & x"a81a664b" & x"a2bfe8a1") report "Test failed for K[10]" severity failure;
		address <= 4d"11";
		wait until data'event;
		assert (data = x"106aa070" & x"f40e3585" & x"d6990624" & x"d192e819") report "Test failed for K[11]" severity failure;
		address <= 4d"12";
		wait until data'event;
		assert (data = x"34b0bcb5" & x"2748774c" & x"1e376c08" & x"19a4c116") report "Test failed for K[12]" severity failure;
		address <= 4d"13";
		wait until data'event;
		assert (data = x"682e6ff3" & x"5b9cca4f" & x"4ed8aa4a" & x"391c0cb3") report "Test failed for K[13]" severity failure;
		address <= 4d"14";
		wait until data'event;
		assert (data = x"8cc70208" & x"84c87814" & x"78a5636f" & x"748f82ee") report "Test failed for K[14]" severity failure;
		address <= 4d"15";
		wait until data'event;
		assert (data = x"c67178f2" & x"bef9a3f7" & x"a4506ceb" & x"90befffa") report "Test failed for K[15]" severity failure;
		address <= 4d"0";
		wait until data'event;
		assert (data = x"e9b5dba5" & x"b5c0fbcf" & x"71374491" & x"428a2f98") report "Test failed for K[0]" severity failure; 
	end process;
	
end architecture Testbench;