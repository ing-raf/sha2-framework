--! @file Unrolled.vhd
--! @brief Implementation of the combinatorial part of the transformation round block with unrolling

--! Basic SHA components library
library shacomps;

--! @brief %Unrolled architecture of the combinatorial part of the transformation round
--! @details This architecture performs 4 steps within a single clock cycle.
--! @details To perform the unrolling, start from a single step, which is given by:
--! \f{align*}
--!		T^1_{t-1} & \propto E_{t-1}, F_{t-1}, G_{t-1}, H_{t-1}, K_{t-1}, W_{t-1} \\
--!		T^2_{t-1} & \propto A_{t-1}, B_{t-1}, C_{t-1} \\
--!		A_t & = T^1_{t-1} + T^2_{t-1} \\
--!		B_t & = A_{t-1} \\
--!		C_t & = B_{t-1} \\
--!		D_t & = C_{t-1} \\
--! 	E_t & = D_{t-1} + T^1_{t-1} \\
--!		F_t & = E_{t-1} \\
--!		G_t & = F_{t-1} \\
--!		H_t & = G_{t-1}
--! \f}
--! It is not necessary to specify exactly the structure of the step function, but only 
--! the @b positional dependency from the inputs.
--! @details Now it is needed to express outputs of the step \f$t\f$ as functions of the
--! inputs of the stage \f$t-2\f$. The easy part is related to the step function of the
--! step \f$t-1\f$:
--! \f{align*}
--!		T^1_{t-2} & \propto E_{t-2}, F_{t-2}, G_{t-2}, H_{t-2}, K_{t-2}, W_{t-2} \\
--!		T^2_{t-2} & \propto A_{t-2}, B_{t-2}, C_{t-2}
--! \f}
--! Now, applying the step expression for the step \f$t-1\f$ and substituting in the 
--! expression for the step \f$t\f$ one can obtain:
--! \f{align*}
--!		T^1_{t-1} & \propto D_{t-2} + T^1_{t-2}, E_{t-2}, F_{t-2}, G_{t-2}, K_{t-1}, W_{t-1} \\
--!		T^2_{t-1} & \propto T^1_{t-2} + T^2_{t-2}, A_{t-2}, B_{t-2} \\
--!		A_t & = T^1_{t-1} + T^2_{t-1} \\
--!		B_t & = T^1_{t-2} + T^2_{t-2} \\
--!		C_t & = A_{t-2} \\
--!		D_t & = B_{t-2} \\
--! 	E_t & = C_{t-2} + T^1_{t-1} \\
--!		F_t & = D_{t-2} + T^1_{t-2} \\
--!		G_t & = E_{t-2} \\
--!		H_t & = F_{t-2}
--! \f}
--! The same methodology can be applied to the step \f$t-3\f$:
--! \f{align*}
--!		T^1_{t-3} & \propto E_{t-3}, F_{t-3}, G_{t-3}, H_{t-3}, K_{t-3}, W_{t-3} \\
--!		T^2_{t-3} & \propto A_{t-3}, B_{t-3}, C_{t-3} \\
--!		T^1_{t-2} & \propto D_{t-3} + T^1_{t-3}, E_{t-3}, F_{t-3}, G_{t-3}, K_{t-2}, W_{t-2} \\
--!		T^2_{t-2} & \propto T^1_{t-3} + T^2_{t-3}, A_{t-3}, B_{t-3} \\
--!		T^1_{t-1} & \propto C_{t-3} + T^1_{t-2}, D_{t-3} + T^2_{t-3}, E_{t-3}, F_{t-3}, K_{t-1}, W_{t-1} \\
--!		T^2_{t-1} & \propto T^1_{t-2} + T^2_{t-2}, T^1_{t-3} + T^2_{t-3}, A_{t-3} \\
--!		A_t & = T^1_{t-1} + T^2_{t-1} \\
--!		B_t & = T^1_{t-2} + T^2_{t-2} \\
--!		C_t & = T^1_{t-3} + T^2_{t-3} \\
--!		D_t & = A_{t-2} \\
--! 	E_t & = B_{t-3} + T^1_{t-1} \\
--! 	F_t & = C_{t-3} + T^1_{t-2} \\
--!		G_t & = D_{t-3} + T^1_{t-3} \\
--!		H_t & = E_{t-3}
--! \f}
--! Another application yields the outputs of the step \f$t\f$ as functions of the inputs
--! of the stage \f$t-4\f$:
--! \f{align*}
--!		T^1_{t-4} & \propto E_{t-4}, F_{t-4}, G_{t-4}, H_{t-4}, K_{t-4}, W_{t-4} \\
--!		T^2_{t-4} & \propto A_{t-4}, B_{t-4}, C_{t-4} \\
--!		T^1_{t-3} & \propto D_{t-4} + T^1_{t-4}, E_{t-4}, F_{t-4}, G_{t-4}, K_{t-3}, W_{t-3} \\
--!		T^2_{t-3} & \propto T^1_{t-4} + T^2_{t-4}, A_{t-4}, B_{t-4} \\
--!		T^1_{t-2} & \propto C_{t-4} + T^1_{t-3}, D_{t-4} + T^1_{t-4}, E_{t-4}, F_{t-4}, K_{t-2}, W_{t-2} \\
--!		T^2_{t-2} & \propto T^1_{t-3} + T^2_{t-3}, T^1_{t-4} + T^2_{t-4}, A_{t-4}  \\
--!		T^1_{t-1} & \propto B_{t-4} + T^1_{t-2}, C_{t-4} + T^1_{t-3}, D_{t-4} + T^1_{t-4}, E_{t-4}, K_{t-1}, W_{t-1} \\
--!		T^2_{t-1} & \propto T^1_{t-2} + T^2_{t-2}, T^1_{t-3} + T^2_{t-3}, T^1_{t-4} + T^2_{t-4} \\
--!		A_t & = T^1_{t-1} + T^2_{t-1} \\
--!		B_t & = T^1_{t-2} + T^2_{t-2} \\
--!		C_t & = T^1_{t-3} + T^2_{t-3} \\
--!		D_t & = T^1_{t-4} + T^2_{t-4} \\
--! 	E_t & = A_{t-4} + T^1_{t-1} \\
--! 	F_t & = B_{t-4} + T^1_{t-2} \\
--!		G_t & = C_{t-4} + T^1_{t-3} \\
--!		H_t & = D_{t-4} + T^1_{t-4}
--! \f}
--! Assuming to employ internal signals for the compute outputs, this expression can be 
--! rewritten as follows:
--! \f{align*}
--!		T^1_{t-4} & \propto E_{t-4}, F_{t-4}, G_{t-4}, H_{t-4}, K_{t-4}, W_{t-4} \\
--!		T^2_{t-4} & \propto A_{t-4}, B_{t-4}, C_{t-4} \\
--!		T^1_{t-3} & \propto H_t, E_{t-4}, F_{t-4}, G_{t-4}, K_{t-3}, W_{t-3} \\
--!		T^2_{t-3} & \propto D_t, A_{t-4}, B_{t-4} \\
--!		T^1_{t-2} & \propto G_t, H_t, E_{t-4}, F_{t-4}, K_{t-2}, W_{t-2} \\
--!		T^2_{t-2} & \propto C_t, D_t, A_{t-4}  \\
--!		T^1_{t-1} & \propto F_t, G_t, H_t, E_{t-4}, K_{t-1}, W_{t-1} \\
--!		T^2_{t-1} & \propto B_t, G_t, D_t \\
--!		A_t & = T^1_{t-1} + T^2_{t-1} \\
--!		B_t & = T^1_{t-2} + T^2_{t-2} \\
--!		C_t & = T^1_{t-3} + T^2_{t-3} \\
--!		D_t & = T^1_{t-4} + T^2_{t-4} \\
--! 	E_t & = A_{t-4} + T^1_{t-1} \\
--! 	F_t & = B_{t-4} + T^1_{t-2} \\
--!		G_t & = C_{t-4} + T^1_{t-3} \\
--!		H_t & = D_{t-4} + T^1_{t-4}
--! \f}
architecture Unrolled of Transf_round_comb is

	--! Output of the \f$T_1\f$ step function of the step \f$t-4\f$
	signal t1_tm4   : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
	--! Output of the \f$T_2\f$ step function of the step \f$t-4\f$
	signal t2_tm4   : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
	--! Output of the \f$T_1\f$ step function of the step \f$t-3\f$
	signal t1_tm3   : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
	--! Output of the \f$T_2\f$ step function of the step \f$t-3\f$
	signal t2_tm3   : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
	--! Output of the \f$T_1\f$ step function of the step \f$t-2\f$
	signal t1_tm2  : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
	--! Output of the \f$T_2\f$ step function of the step \f$t-2\f$
	signal t2_tm2   : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
	--! Output of the \f$T_1\f$ step function of the step \f$t-1\f$
	signal t1_tm1   : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
	--! Output of the \f$T_2\f$ step function of the step \f$t-1\f$
	signal t2_tm1   : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
	--! Constant \f$K\f$ for the round \f$t-4\f$
	alias K_tm4 is K(WORD_WIDTH - 1 downto 0);
	--! Constant \f$K\f$ for the round \f$t-3\f$
	alias K_tm3 is K(2*WORD_WIDTH - 1 downto WORD_WIDTH);
	--! Constant \f$K\f$ for the round \f$t-2\f$
	alias K_tm2 is K(3*WORD_WIDTH - 1 downto 2*WORD_WIDTH);
	--! Constant \f$K\f$ for the round \f$t-1\f$
	alias K_tm1 is K(4*WORD_WIDTH - 1 downto 3*WORD_WIDTH);
	--! Expanded word for the round \f$t-4\f$
	alias W_tm4 is W(WORD_WIDTH - 1 downto 0);
	--! Expanded word for the round \f$t-3\f$
	alias W_tm3 is W(2*WORD_WIDTH - 1 downto WORD_WIDTH);
	--! Expanded word for the round \f$t-2\f$
	alias W_tm2 is W(3*WORD_WIDTH - 1 downto 2*WORD_WIDTH);
	--! Expanded word for the round \f$t-1\f$
	alias W_tm1 is W(4*WORD_WIDTH - 1 downto 3*WORD_WIDTH);
	--! @brief Value of the accumulator \f$B\f$ at the step \f$t\f$
	--! @details This value is computed early in the stage, and is employed later 
	--! to compute other values
	signal b : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
	--! @brief Value of the accumulator \f$C\f$ at the step \f$t\f$
	--! @details This value is computed early in the stage, and is employed later 
	--! to compute other values
	signal c : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
	--! @brief Value of the accumulator \f$D\f$ at the step \f$t\f$
	--! @details This value is computed early in the stage, and is employed later 
	--! to compute other values
	signal d : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
	--! @brief Value of the accumulator \f$F\f$ at the step \f$t\f$
	--! @details This value is computed early in the stage, and is employed later 
	--! to compute other values
	signal f : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
	--! @brief Value of the accumulator \f$G\f$ at the step \f$t\f$
	--! @details This value is computed early in the stage, and is employed later 
	--! to compute other values
	signal g : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
	--! @brief Value of the accumulator \f$H\f$ at the step \f$t\f$
	--! @details This value is computed early in the stage, and is employed later 
	--! to compute other values
	signal h : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');

begin
	
	assert (UNROLLING_FACTOR = 4) report "This core is developed for a 4-unrolled architecture" severity failure;

	--! \f$T_1\f$ step function of the step \f$t-4\f$ 
	T1_M4 : entity shacomps.T1
		generic map (
			WORD_WIDTH => WORD_WIDTH
		)
		port map(
			e => e_in,
			f => f_in,
			g => g_in,
			h => h_in,
			K => K_tm4,
			W => W_tm4,
			o => t1_tm4
		);

	--! \f$T_2\f$ step function of the step \f$t-4\f$ 
	T2_M4 : entity shacomps.T2
		generic map (
			WORD_WIDTH => WORD_WIDTH
		)
		port map(
			a => a_in,
			b => b_in,
			c => c_in,
			o => t2_tm4
		);

	--! \f$T_1\f$ step function of the step \f$t-3\f$ 
	T1_M3 : entity shacomps.T1
		generic map (
			WORD_WIDTH => WORD_WIDTH
		)
		port map(
			e => h,
			f => e_in,
			g => f_in,
			h => g_in,
			K => K_tm3,
			W => W_tm3,
			o => t1_tm3
		);

	--! \f$T_2\f$ step function of the step \f$t-3\f$ 
	T2_M3 : entity shacomps.T2
		generic map (
			WORD_WIDTH => WORD_WIDTH
		)
		port map(
			a => d,
			b => a_in,
			c => b_in,
			o => t2_tm3
		);

	--! \f$T_1\f$ step function of the step \f$t-2\f$ 
	T1_M2 : entity shacomps.T1
		generic map (
			WORD_WIDTH => WORD_WIDTH
		)
		port map(
			e => g,
			f => h,
			g => e_in,
			h => f_in,
			K => K_tm2,
			W => W_tm2,
			o => t1_tm2
		);

	--! \f$T_2\f$ step function of the step \f$t-2\f$ 
	T2_M2 : entity shacomps.T2
		generic map (
			WORD_WIDTH => WORD_WIDTH
		)
		port map(
			a => c,
			b => d,
			c => a_in,
			o => t2_tm2
		);

	--! \f$T_1\f$ step function of the step \f$t-1\f$ 
	T1_M1 : entity shacomps.T1
		generic map (
			WORD_WIDTH => WORD_WIDTH
		)
		port map(
			e => f,
			f => g,
			g => h,
			h => e_in,
			K => K_tm1,
			W => W_tm1,
			o => t1_tm1
		);

	--! \f$T_2\f$ step function of the step \f$t-1\f$ 
	T2_M1 : entity shacomps.T2
		generic map (
			WORD_WIDTH => WORD_WIDTH
		)
		port map(
			a => b,
			b => c,
			c => d,
			o => t2_tm1
		);

	a_out <= std_logic_vector(unsigned(t1_tm1) + unsigned(t2_tm1));
	b   <= std_logic_vector(unsigned(t1_tm2) + unsigned(t2_tm2));
	c   <= std_logic_vector(unsigned(t1_tm3) + unsigned(t2_tm3));
	d   <= std_logic_vector(unsigned(t1_tm4) + unsigned(t2_tm4));
	e_out <= std_logic_vector(unsigned(a_in) + unsigned(t1_tm1));
	f   <= std_logic_vector(unsigned(b_in) + unsigned(t1_tm2));
	g   <= std_logic_vector(unsigned(c_in) + unsigned(t1_tm3));
	h   <= std_logic_vector(unsigned(d_in) + unsigned(t1_tm4));

	b_out <= b;
	c_out <= c;
	d_out <= d;
	f_out <= f;
	g_out <= g;
	h_out <= h;

end architecture Unrolled;
