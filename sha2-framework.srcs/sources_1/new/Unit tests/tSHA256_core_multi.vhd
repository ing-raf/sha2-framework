--! @file tSHA256_core_multi.vhd
--! @brief Multi-block test case for SHA-256

--! Standard library
library ieee;
--! Standard 9-values logic library
use ieee.std_logic_1164.all;
--! Arithmetic library, included for the unsigned type conversion
use ieee.numeric_std.all;

--! @test Hash multiple messages using SHA-256
--! \n NIST-provided test vectors:
--! - @a https://csrc.nist.gov/projects/cryptographic-standards-and-guidelines/example-values \n
--! - @a https://csrc.nist.gov/Projects/cryptographic-algorithm-validation-program/Secure-Hashing#shavs
--! \n\n
--! - <b>Input sequence:</b> 
--! 	-# x"11ae0cbfee7bb3df"
--! 	-# "abc"
--! 	-# x"9ebf93643854ea5c97a4f38f50bd18103fde2abdd77f5266b6914a317c07cc3cde954b85f6b8e207ddf68a267c678f4d9f7445d64bdff700"
--! 	-# x"18537da0bf81cf55e38b8fbcfaa07ea36923c59e485cdc56656dab248c87efdf065de0f260d911b16e0e97ed8e6f6dc5313e17c098478600"
--! 	-# x"294dee95f2146fc67870cd987d2e6e673ea320579b435d8d7870cc9f63900a487762ab6180927c0c608b0b33b18c6a31abfe2fce4805bf70"
--! 	-# x"7da5f5153548eae21034efb7276e0a52d13c72df1ad2a2bf712dac87a140d04c034e4d1ef19777d27d360a05634abe5d3d541b12f6e08fa8"
--! 	-# x"cc29f1eb3b0237e815424c6c853ad0e16232768304f57009579127872d583093d92a7ba7f9f7cec6937f7262645c2d7e74437010ee87d0a8"
--! 	-# x"86f15b8b677b7655f358a2c7fd5785bc84d31e079ed859b6af88e198debd36fccaf0ffbc785aa17a9158102aca14e6d0a362b28b54e892d2"
--! - <b>Expected output:</b>
--!		-# x"a46d5f010e9664f21378c7588924682338888b2680d9b34506010610066dab59"
--!		-# x"ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad"
--!		-# x"47ee6110b83273f2b966bdcd34727007ef4d20edfec7e30b8931669c6d1c05e7"
--!		-# x"56f10bcc16149f5d8bc86f4b9fe3eafbb5213ea1e4c209b0463c751c61650e04"
--!		-# x"edee1c1d003835c8f39be8a489cf7e50b70ed96fbbc41b36ae7e5dc937c74a13"
--!		-# x"9d6de887db0cd7a5ac51b0b4217ede80a3b83cb909824ebb0a90407e46906958"
--!		-# x"660cf7af3bce342d5ede084e3a6493747cf900583a5710f16e67bae8b5a95b74"
--!		-# x"eaec4af4f0632711ae6d78bcadb50eb53aee0d2e65c906cd903349750ea71c92"

--! @brief Multi-message test bench for the SHA-256 hash core
entity tSHA256_core_multi is
--	generic (
--		FULLY_PIPELINED : boolean := true
--	);
end entity tSHA256_core_multi;

--! Detail of the test bench
architecture Testbench of tSHA256_core_multi is

	--! Clock period
	constant clock_period : time    := 10 ns;
	--! Delay of the input waveforms
	constant wave_delay : time := 2 ns; -- required by the postponed logic

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
	stim_process : postponed process
	begin
		if (en = '0') then
			wait until en = '1';
		end if;

		-- SHA256ShortMsg.rsp, Len = 64
		M_blk <= (511 downto 448 => x"11ae0cbfee7bb3df",
          447            => '1',
          63 downto 0    => std_logic_vector(to_unsigned(64, 64)),
          others         => '0'
        ) after wave_delay;
        start <= '1' after wave_delay;
		wait for clock_period;
		if (ready = '0') then
			start <= '0' after wave_delay;
			wait until ready = '1';
		end if;
		
		-- Message "abc"
		M_blk   <= (511 downto 504 => x"61",
		            503 downto 496 => x"62",
		            495 downto 488 => x"63",
		            487            => '1',
		            63 downto 0    => std_logic_vector(to_unsigned(24, 64)),
		            others         => '0') after wave_delay;
		start   <= '1' after wave_delay;
		wait for clock_period;
		if (ready = '0') then
			start <= '0' after wave_delay;
			wait until ready = '1';
		end if;
	
		-- SHA256ShortMsg.rsp, Len = 442
		M_blk     <= (511 downto 64 => x"9ebf93643854ea5c97a4f38f50bd18103fde2abdd77f5266b6914a317c07cc3cde954b85f6b8e207ddf68a267c678f4d9f7445d64bdff700",
		              63 downto 0   => std_logic_vector(to_unsigned(442, 64))
		             ) after wave_delay;
		M_blk(69) <= '1' after wave_delay;
		start     <= '1' after wave_delay;
		wait for clock_period;
		if (ready = '0') then
			start <= '0' after wave_delay;
			wait until ready = '1';
		end if;

		-- SHA256ShortMsg.rsp, Len = 443
		M_blk     <= (511 downto 64 => x"18537da0bf81cf55e38b8fbcfaa07ea36923c59e485cdc56656dab248c87efdf065de0f260d911b16e0e97ed8e6f6dc5313e17c098478600",
		              63 downto 0   => std_logic_vector(to_unsigned(443, 64))
		             ) after wave_delay;
		M_blk(68) <= '1' after wave_delay;
		start     <= '1' after wave_delay;
		wait for clock_period;
		if (ready = '0') then
			start <= '0' after wave_delay;
			wait until ready = '1';
		end if;
		
		-- SHA256ShortMsg.rsp, Len = 444
		M_blk     <= (511 downto 64 => x"294dee95f2146fc67870cd987d2e6e673ea320579b435d8d7870cc9f63900a487762ab6180927c0c608b0b33b18c6a31abfe2fce4805bf70",
		              63 downto 0   => std_logic_vector(to_unsigned(444, 64))
		             ) after wave_delay;
		M_blk(67) <= '1' after wave_delay;
		start     <= '1' after wave_delay;
		wait for clock_period;
		if (ready = '0') then
			start <= '0' after wave_delay;
			wait until ready = '1';
		end if;	

		-- SHA256ShortMsg.rsp, Len = 445
		M_blk     <= (511 downto 64 => x"7da5f5153548eae21034efb7276e0a52d13c72df1ad2a2bf712dac87a140d04c034e4d1ef19777d27d360a05634abe5d3d541b12f6e08fa8",
		              63 downto 0   => std_logic_vector(to_unsigned(445, 64))
		             ) after wave_delay;
		M_blk(66) <= '1' after wave_delay;
		start     <= '1' after wave_delay;
		wait for clock_period;
		if (ready = '0') then
			start <= '0' after wave_delay;
			wait until ready = '1';
		end if;
		
		-- SHA256ShortMsg.rsp, Len = 446
		M_blk     <= (511 downto 64 => x"cc29f1eb3b0237e815424c6c853ad0e16232768304f57009579127872d583093d92a7ba7f9f7cec6937f7262645c2d7e74437010ee87d0a8",
		              63 downto 0   => std_logic_vector(to_unsigned(446, 64))
		             ) after wave_delay;
		M_blk(65) <= '1' after wave_delay;
		start <= '1' after wave_delay;
		wait for clock_period;
		if (ready = '0') then
			start <= '0' after wave_delay;
			wait until ready = '1';
		end if;	
		
		-- SHA256ShortMsg.rsp, Len = 447
		M_blk     <= (511 downto 64 => x"86f15b8b677b7655f358a2c7fd5785bc84d31e079ed859b6af88e198debd36fccaf0ffbc785aa17a9158102aca14e6d0a362b28b54e892d2",
		              63 downto 0   => std_logic_vector(to_unsigned(447, 64))
		             ) after wave_delay;
		M_blk(64) <= '1' after wave_delay;
		start     <= '1' after wave_delay;
		wait  for clock_period;
		if (ready = '0') then
			start <= '0' after wave_delay;
			wait until ready = '1';
		end if;

	end postponed process;
	
	oracle_process : process
	begin
		if (en = '0') then
			wait until rising_edge(en);
		end if;
		
		wait until hash'event or falling_edge(completed);
		if (completed = '0') then
			wait until rising_edge(completed);
		end if;	
		assert (hash = x"a46d5f010e9664f21378c7588924682338888b2680d9b34506010610066dab59") report "Test case 64 failed" severity failure;
		report "Test case 64 passed" severity note;
		
		wait until hash'event or falling_edge(completed);
		if (completed = '0') then
			wait until rising_edge(completed);
		end if;	
		assert (hash = x"ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad") report "Test case 'abc' failed" severity failure;
		report "Test case 'abc' passed" severity note;
		
		wait until hash'event or falling_edge(completed);
		if (completed = '0') then
			wait until rising_edge(completed);
		end if;	
		assert (hash = x"47ee6110b83273f2b966bdcd34727007ef4d20edfec7e30b8931669c6d1c05e7") report "Test case 442 failed" severity failure; 
		report "Test case 442 passed" severity note;
		
		wait until hash'event or falling_edge(completed);
		if (completed = '0') then
			wait until rising_edge(completed);
		end if;	
		assert (hash = x"56f10bcc16149f5d8bc86f4b9fe3eafbb5213ea1e4c209b0463c751c61650e04") report "Test case 443 failed" severity failure;
		report "Test case 443 passed" severity note;
		
		wait until hash'event or falling_edge(completed);
		if (completed = '0') then
			wait until rising_edge(completed);
		end if;	
		assert (hash = x"edee1c1d003835c8f39be8a489cf7e50b70ed96fbbc41b36ae7e5dc937c74a13") report "Test case 444 failed" severity failure;
		report "Test case 444 passed" severity note;
		
		wait until hash'event or falling_edge(completed);
		if (completed = '0') then
			wait until rising_edge(completed);
		end if;	
		assert (hash = x"9d6de887db0cd7a5ac51b0b4217ede80a3b83cb909824ebb0a90407e46906958") report "Test case 445 failed" severity failure;
		report "Test case 445 passed" severity note;
		
		wait until hash'event or falling_edge(completed);
		if (completed = '0') then
			wait until rising_edge(completed);
		end if;	
		assert (hash = x"660cf7af3bce342d5ede084e3a6493747cf900583a5710f16e67bae8b5a95b74") report "Test case 446 failed" severity failure;
		report "Test case 446 passed" severity note;
		
		wait until hash'event or falling_edge(completed);
		if (completed = '0') then
			wait until rising_edge(completed);
		end if;	
		assert (hash = x"eaec4af4f0632711ae6d78bcadb50eb53aee0d2e65c906cd903349750ea71c92") report "Test case 447 failed" severity failure;
		report "Test case 447 passed" severity note;
		
	end process;
		
end architecture Testbench;
