--! @file test_SHA256_power_1A.vhd
--! @brief Iterated test case for SHA-256

--! Standard library
library ieee;
--! Standard 9-values logic library
use ieee.std_logic_1164.all;
--! Arithmetic library, included for the unsigned type conversion
use ieee.numeric_std.all;

--! @test Repeated hashing of a sequence of messages using SHA-256
--! \n NIST-provided test vectors: https://csrc.nist.gov/Projects/cryptographic-algorithm-validation-program/Secure-Hashing#shavs
--! \n
--! - <b>Input sequence 1A:</b> 
--! 	-# x"11ae0cbfee7bb3df"
--! - <b>Expected output:</b>
--!		-# x"a46d5f010e9664f21378c7588924682338888b2680d9b34506010610066dab59"

--! Test bench 1A for the SHA-256 hash core
entity test_SHA256_power_1A is
	generic (
		FULLY_PIPELINED : boolean := true --! Whether the Uniy Under Test is a fully pipelined architecture
	);
end entity test_SHA256_power_1A;

--! Detail of the test bench
architecture Testbed of test_SHA256_power_1A is

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
		port map(
			clk       => clk,
			not_rst   => not_rst,
			en        => en,
			start     => start,
			M_blk     => M_blk,
			iv        => iv,
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

		-- SHA256ShortMsg.rsp, Len = 64
		M_blk <= (511 downto 448 => x"11ae0cbfee7bb3df",
		          447            => '1',
		          63 downto 0    => std_logic_vector(to_unsigned(64, 64)),
		          others         => '0'
		         );

		if FULLY_PIPELINED then
			start <= '1';
			wait for clock_period;
		else
			start <= '1';
			wait until falling_edge(ready);
			start <= '0';
			wait until rising_edge(ready);
		end if;

	end process;

end architecture Testbed;

