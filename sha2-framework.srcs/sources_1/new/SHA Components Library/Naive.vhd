--! @file "SHA Components Library/Naive.vhd"
--! @brief Implementation of the combinatorial part of the transformation round block without any optimisation

--! @brief Straightforward architecture of the combinatorial part of the transformation round block
--! @details Direct implementation of the compression function of SHA-2:
--! \f{aligned}
--!	A_{t+1} & = {T_1}_t + {T_2}_t & \quad \forall t\in\left[0,R-1\right] \\
--!	B_{t+1} & = A_t & \quad \forall t\in\left[0,R-1\right] \\
--!	C_{t+1} & = B_t & \quad \forall t\in\left[0,R-1\right] \\
--!	D_{t+1} & = C_t & \quad \forall t\in\left[0,R-1\right] \\
--!	E_{t+1} & = D_t + {T_1}_t & \quad \forall t\in\left[0,R-1\right] \\
--!	F_{t+1} & = E_t & \quad \forall t\in\left[0,R-1\right] \\
--!	G_{t+1} & = F_t & \quad \forall t\in\left[0,R-1\right] \\
--!	H_{t+1} & = G_t & \quad \forall t\in\left[0,R-1\right]
--! \f}
architecture Naive of Transf_round_comb is

	--! Output of the \f$T_1\f$ step function
	signal t1_o : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
	--! Output of the \f$T_2\f$ step function
	signal t2_o : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');

begin
	
	assert (UNROLLING_FACTOR = 1) report "This core is developed for a non-unrolled architecture" severity failure;

	--! \f$T1\f$ step function
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

	--! \f$T2\f$ step function
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
