--! Standard library
library ieee;
--! Standard 9-values logic library
use ieee.std_logic_1164.all;
--! Arithmetic library, included for the unsigned type conversion
use ieee.numeric_std.all;

--! Test bench 5A for the SHA-256 hash core
entity test_SHA256_power_5A is
	generic (
		FULLY_PIPELINED : boolean := false
	);
end entity test_SHA256_power_5A;

--! Detail of the test bench
architecture Testbed of test_SHA256_power_5A is

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

		-- SHA256ShortMsg.rsp, Len = 442
		M_blk     <= (511 downto 64 => x"9ebf93643854ea5c97a4f38f50bd18103fde2abdd77f5266b6914a317c07cc3cde954b85f6b8e207ddf68a267c678f4d9f7445d64bdff700",
		              63 downto 0   => std_logic_vector(to_unsigned(442, 64))
		             );
		M_blk(69) <= '1';

		if FULLY_PIPELINED then
			start <= '1';
			wait for clock_period;
		else
			start <= '1';
			wait until falling_edge(ready);
			start <= '0';
			wait until rising_edge(ready);
		end if;

		-- SHA256ShortMsg.rsp, Len = 445
		M_blk     <= (511 downto 64 => x"7da5f5153548eae21034efb7276e0a52d13c72df1ad2a2bf712dac87a140d04c034e4d1ef19777d27d360a05634abe5d3d541b12f6e08fa8",
		              63 downto 0   => std_logic_vector(to_unsigned(445, 64))
		             );
		M_blk(66) <= '1';
		
		if FULLY_PIPELINED then
			wait for clock_period;
		else
			start <= '1';
			wait until falling_edge(ready);
			start <= '0';
			wait until rising_edge(ready);
		end if;

		-- SHA256ShortMsg.rsp, Len = 443
		M_blk     <= (511 downto 64 => x"18537da0bf81cf55e38b8fbcfaa07ea36923c59e485cdc56656dab248c87efdf065de0f260d911b16e0e97ed8e6f6dc5313e17c098478600",
		              63 downto 0   => std_logic_vector(to_unsigned(443, 64))
		             );
		M_blk(68) <= '1';

		if FULLY_PIPELINED then
			wait for clock_period;
		else
			start <= '1';
			wait until falling_edge(ready);
			start <= '0';
			wait until rising_edge(ready);
		end if;

		-- SHA256ShortMsg.rsp, Len = 446
		M_blk     <= (511 downto 64 => x"cc29f1eb3b0237e815424c6c853ad0e16232768304f57009579127872d583093d92a7ba7f9f7cec6937f7262645c2d7e74437010ee87d0a8",
		              63 downto 0   => std_logic_vector(to_unsigned(446, 64))
		             );
		M_blk(65) <= '1';

		if FULLY_PIPELINED then
			wait for clock_period;
		else
			start <= '1';
			wait until falling_edge(ready);
			start <= '0';
			wait until rising_edge(ready);
		end if;

		-- SHA256ShortMsg.rsp, Len = 444
		M_blk     <= (511 downto 64 => x"294dee95f2146fc67870cd987d2e6e673ea320579b435d8d7870cc9f63900a487762ab6180927c0c608b0b33b18c6a31abfe2fce4805bf70",
		              63 downto 0   => std_logic_vector(to_unsigned(444, 64))
		             );
		M_blk(67) <= '1';

		if FULLY_PIPELINED then
			wait for clock_period;
		else
			start <= '1';
			wait until falling_edge(ready);
			start <= '0';
			wait until rising_edge(ready);
		end if;

	end process;

end architecture Testbed;
