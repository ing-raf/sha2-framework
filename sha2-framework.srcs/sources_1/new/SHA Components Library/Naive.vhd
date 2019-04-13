architecture Naive of Transf_round_comb is

	signal t1_o, t2_o : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');

begin
	
	assert (UNROLLING_FACTOR = 1) report "This core is developed for a non-unrolled architecture" severity failure;

	T1 : entity work.T1
		generic map (
			WORD_WIDTH => WORD_WIDTH
		)
		port map(
			e => e_in,
			f => f_in,
			g => g_in,
			h => h_in,
			K => K,
			W => W,
			o => t1_o
		);

	T2 : entity work.T2
		generic map (
			WORD_WIDTH => WORD_WIDTH
		)
		port map(
			a => a_in,
			b => b_in,
			c => c_in,
			o => t2_o
		);

	a_out <= std_logic_vector(unsigned(t1_o) + unsigned(t2_o));
	b_out <= a_in;
	c_out <= b_in;
	d_out <= c_in;
	e_out <= std_logic_vector(unsigned(d_in) + unsigned(t1_o));
	f_out <= e_in;
	g_out <= f_in;
	h_out <= g_in;

end architecture Naive;
