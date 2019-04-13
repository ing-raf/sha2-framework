--! Standard library 
library ieee;
--! Arithmetic library, included for the unsigned modulo addition  
use ieee.numeric_std.all;

--! Basic SHA components library
library shacomps;

--! Basic integrated circuits components library
library components;

architecture Reordered_UF2 of Transf_round is
	--! Internal output signal, to be used as feedback input
	signal feedback   : std_logic_vector(14*WORD_WIDTH downto 0) := (others => '0');
	--! Output of the multiplexer, and input of the precomputation stage
	signal mux_output : std_logic_vector(14*WORD_WIDTH downto 0) := (others => '0');
		--! Input of the compressor pipeline register
	signal reg_input  : std_logic_vector(11*WORD_WIDTH downto 0) := (others => '0');
	--! Output of the compressor pipeline register
	signal reg_output : std_logic_vector(11*WORD_WIDTH downto 0) := (others => '0');
	
	--! Value of the parameter \f$X^*\f$ input for the stage
	alias x_mux_out is mux_output(14*WORD_WIDTH - 1 downto 13*WORD_WIDTH);
	--! Value of the parameter \f$H^*\f$ input for the stage
	alias bigh_mux_out is mux_output(13*WORD_WIDTH - 1 downto 12*WORD_WIDTH);
	--! Value of the parameter \f$P_4\f$ input for the stage
	alias p4_mux_out is mux_output(12*WORD_WIDTH - 1 downto 11*WORD_WIDTH);
	--! Value of the parameter \f$X^*\f$ input for the stage
	alias x_star_mux_out is mux_output(11*WORD_WIDTH - 1 downto 10*WORD_WIDTH);
	--! Value of the parameter \f$H^*\f$ input for the stage
	alias bigh_star_mux_out is mux_output(10*WORD_WIDTH - 1 downto 9*WORD_WIDTH);
	--! Value of the parameter \f$P^*_4\f$ input for the stage
	alias p4_star_mux_out is mux_output(9*WORD_WIDTH - 1 downto 8*WORD_WIDTH);
	--! Value of the accumulator \f$A\f$ input for the stage
	alias a_mux_out is mux_output(8*WORD_WIDTH - 1 downto 7*WORD_WIDTH);
	--! Value of the accumulator \f$B\f$ input for the stage
	alias b_mux_out is mux_output(7*WORD_WIDTH - 1 downto 6*WORD_WIDTH);
	--! Value of the accumulator \f$C\f$ input for the stage
	alias c_mux_out is mux_output(6*WORD_WIDTH - 1 downto 5*WORD_WIDTH);
	--! Value of the accumulator \f$E\f$ input for the stage
	alias e_mux_out is mux_output(4*WORD_WIDTH - 1 downto 3*WORD_WIDTH);
	--! Value of the accumulator \f$F\f$ input for the stage
	alias f_mux_out is mux_output(3*WORD_WIDTH - 1 downto 2*WORD_WIDTH);
	--! Value of the accumulator \f$G\f$ input for the stage
	alias g_mux_out is mux_output(2*WORD_WIDTH - 1 downto WORD_WIDTH);
	
	--! Precomputed value of the parameter \f$H^*\f$ input to the pipeline register
	alias bigH_star_reg_in is reg_input(11*WORD_WIDTH - 1 downto 10*WORD_WIDTH);		
	--! Precomputed value of the parameter \f$X^*\f$ input to the pipeline register
	alias x_star_reg_in is reg_input(10*WORD_WIDTH - 1 downto 9*WORD_WIDTH);	
	--! Precomputed value of the intermediate parameter \f$A\f$ input to the pipeline register
	alias bigA_reg_in is reg_input(9*WORD_WIDTH - 1 downto 8*WORD_WIDTH);
	--! Precomputed value of the parameter \f$P^*_4\f$ input to the pipeline register
	alias p4_star_reg_in is reg_input(8*WORD_WIDTH - 1 downto 7*WORD_WIDTH);
	--! Precomputed value of the parameter \f$p_2\f$ input to the pipeline register
	alias p2_reg_in is reg_input(7*WORD_WIDTH - 1 downto 6*WORD_WIDTH);
	--! Precomputed value of the parameter \f$p_1_+p_3\f$ input to the pipeline register
	alias p1_plus_p3_reg_in is reg_input(6*WORD_WIDTH - 1 downto 5*WORD_WIDTH);
	--! Precomputed next value of the accumulator \f$E\f$ input to the pipeline register
	alias e_plus1_reg_in is reg_input(5*WORD_WIDTH - 1 downto 4*WORD_WIDTH);
	--! Precomputed value of the accumulator \f$F\f$ input to the pipeline register
	alias f_reg_in is reg_input(4*WORD_WIDTH - 1 downto 3*WORD_WIDTH);
	--! Precomputed value of the accumulator \f$E\f$ input to the pipeline register
	alias e_reg_in is reg_input(3*WORD_WIDTH - 1 downto 2*WORD_WIDTH);
	--! Precomputed value of the accumulator \f$B\f$ input to the pipeline register
	alias b_reg_in is reg_input(2*WORD_WIDTH - 1 downto WORD_WIDTH);
	--! Precomputed value of the accumulator \f$A\f$ input to the pipeline register
	alias a_reg_in is reg_input(WORD_WIDTH - 1 downto 0);
	
	--! Flag of validity for the register
	alias valid_reg is reg_output(11*WORD_WIDTH);
	--! Value of the parameter \f$H^*\f$ input to the final calculation phase
	alias bigH_star_reg_out is reg_output(11*WORD_WIDTH - 1 downto 10*WORD_WIDTH);
	--! Value of the parameter \f$X^*\f$ input to the final calculation phase
	alias x_star_reg_out is reg_output(10*WORD_WIDTH - 1 downto 9*WORD_WIDTH);
	--! Value of the intermediate parameter \f$A\f$ input to the final calculation phase
	alias bigA_reg_out is reg_output(9*WORD_WIDTH - 1 downto 8*WORD_WIDTH);
	--! Value of the parameter \f$p_2\f$ input to the final calculation phase
	alias p4_star_reg_out is reg_output(8*WORD_WIDTH - 1 downto 7*WORD_WIDTH);
	--! Value of the parameter \f$p_2\f$ input to the final calculation phase
	alias p2_reg_out is reg_output(7*WORD_WIDTH - 1 downto 6*WORD_WIDTH);
	--! Value of the parameter \f$p_1+p_3\f$ input to the final calculation phase
	alias p1_plus_p3_reg_out is reg_output(6*WORD_WIDTH - 1 downto 5*WORD_WIDTH);
	--! Next value of the accumulator \f$E\f$ input to the final calculation phase
	alias e_plus1_reg_out is reg_output(5*WORD_WIDTH - 1 downto 4*WORD_WIDTH);
	--! Value of the accumulator \f$F\f$ input to the final calculation phase
	alias f_reg_out is reg_output(4*WORD_WIDTH - 1 downto 3*WORD_WIDTH);
	--! Value of the accumulator \f$E\f$ input to the final calculation phase
	alias e_reg_out is reg_output(3*WORD_WIDTH - 1 downto 2*WORD_WIDTH);
	--! Value of the accumulator \f$B\f$ input to the final calculation phase
	alias b_reg_out is reg_output(2*WORD_WIDTH - 1 downto WORD_WIDTH);
	--! Value of the accumulator \f$A\f$ input to the final calculation phase
	alias a_reg_out is reg_output(WORD_WIDTH - 1 downto 0);

	
	--! @brief Value of the parameter \f$X^*\f$ output from the compressor round
	--! @details This temporary signal is employed to perform the feedback
	alias x_feedback is feedback(14*WORD_WIDTH - 1 downto 13*WORD_WIDTH);
	--! @brief Value of the parameter \f$h^*\f$ output from the compressor round
	--! @details This temporary signal is employed to perform the feedback
	alias bigh_feedback is feedback(13*WORD_WIDTH - 1 downto 12*WORD_WIDTH);
	--! @brief Value of the parameter \f$P_4\f$ output from the compressor round
	--! @details This temporary signal is employed to perform the feedback
	alias p4_feedback is feedback(12*WORD_WIDTH - 1 downto 11*WORD_WIDTH);
	--! @brief Value of the parameter \f$X^*\f$ output from the compressor round
	--! @details This temporary signal is employed to perform the feedback
	alias x_star_feedback is feedback(11*WORD_WIDTH - 1 downto 10*WORD_WIDTH);
	--! @brief Value of the parameter \f$H^*\f$ output from the compressor round
	--! @details This temporary signal is employed to perform the feedback
	alias bigh_star_feedback is feedback(10*WORD_WIDTH - 1 downto 9*WORD_WIDTH);
	--! @brief Value of the parameter \f$P^*_4\f$ output from the compressor round
	--! @details This temporary signal is employed to perform the feedback
	alias p4_star_feedback is feedback(9*WORD_WIDTH - 1 downto 8*WORD_WIDTH);
	--! @brief Value of the accumulator \f$A\f$ output from the compressor round
	--! @details This temporary signal is employed to perform the feedback
	alias a_feedback is feedback(8*WORD_WIDTH - 1 downto 7*WORD_WIDTH);
	--! @brief Value of the accumulator \f$B\f$ output from the compressor round
	--! @details This temporary signal is employed to perform the feedback
	alias b_feedback is feedback(7*WORD_WIDTH - 1 downto 6*WORD_WIDTH);
	--! @brief Value of the accumulator \f$C\f$ output from the compressor round
	--! @details This temporary signal is employed to perform the feedback
	alias c_feedback is feedback(6*WORD_WIDTH - 1 downto 5*WORD_WIDTH);
	--! @brief Value of the accumulator \f$D\f$ output from the compressor round
	--! @details This temporary signal is employed to perform the feedback
	alias d_feedback is feedback(5*WORD_WIDTH - 1 downto 4*WORD_WIDTH);
	--! @brief Value of the accumulator \f$E\f$ output from the compressor round
	--! @details This temporary signal is employed to perform the feedback
	alias e_feedback is feedback(4*WORD_WIDTH - 1 downto 3*WORD_WIDTH);
	--! @brief Value of the accumulator \f$F\f$ output from the compressor round
	--! @details This temporary signal is employed to perform the feedback
	alias f_feedback is feedback(3*WORD_WIDTH - 1 downto 2*WORD_WIDTH);
	--! @brief Value of the accumulator \f$G\f$ output from the compressor round
	--! @details This temporary signal is employed to perform the feedback
	alias g_feedback is feedback(2*WORD_WIDTH - 1 downto WORD_WIDTH);
	--! @brief Value of the accumulator \f$H\f$ output from the compressor round
	--! @details This temporary signal is employed to perform the feedback
	alias h_feedback is feedback(WORD_WIDTH - 1 downto 0);
	
	--! Flag of validity for the output register
	alias valid_out is output(14*WORD_WIDTH);
	--! Value of the parameter \f$X^*\f$ output from the stage
	alias x_out is output(14*WORD_WIDTH - 1 downto 13*WORD_WIDTH);
	--! Value of the parameter \f$H^*\f$ output from the stage
	alias bigh_out is output(13*WORD_WIDTH - 1 downto 12*WORD_WIDTH);
	--! Value of the parameter \f$P_4\f$ output from the stage
	alias p4_out is output(12*WORD_WIDTH - 1 downto 11*WORD_WIDTH);
	--! Value of the parameter \f$X^*\f$ output from the stage
	alias x_star_out is output(11*WORD_WIDTH - 1 downto 10*WORD_WIDTH);
	--! Value of the parameter \f$H^*\f$ output from the stage
	alias bigh_star_out is output(10*WORD_WIDTH - 1 downto 9*WORD_WIDTH);
	--! Value of the parameter \f$P^*_4\f$ output from the stage
	alias p4_star_out is output(9*WORD_WIDTH - 1 downto 8*WORD_WIDTH);
	--! Value of the accumulator \f$A\f$ output from the stage
	alias a_out is output(8*WORD_WIDTH - 1 downto 7*WORD_WIDTH );
	--! Value of the accumulator \f$B\f$ output from the stage
	alias b_out is output(7*WORD_WIDTH - 1 downto 6*WORD_WIDTH );
	--! Value of the accumulator \f$C\f$ output from the stage
	alias c_out is output(6*WORD_WIDTH - 1 downto 5*WORD_WIDTH );
	--! Value of the accumulator \f$D\f$ output from the stage
	alias d_out is output(5*WORD_WIDTH - 1 downto 4*WORD_WIDTH );
	--! Value of the accumulator \f$E\f$ output from the stage
	alias e_out is output(4*WORD_WIDTH - 1 downto 3*WORD_WIDTH );
	--! Value of the accumulator \f$F\f$ output from the stage
	alias f_out is output(3*WORD_WIDTH - 1 downto 2*WORD_WIDTH );
	--! Value of the accumulator \f$G\f$ output from the stage
	alias g_out is output(2*WORD_WIDTH - 1 downto WORD_WIDTH );
	--! Value of the accumulator \f$H\f$ output from the stage
	alias h_out is output(WORD_WIDTH - 1 downto 0);
	
	--! Internal signal carrying the parameter \f$p_3\f$
	signal p3 : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
	--! Internal signal carrying the parameter \f$p_5\f$
	signal p5 : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
	--! Internal signal carrying the parameter \f$p_6\f$
	signal p6 : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
	--! Output of the \f$\Sigma_0\f$ functional block for the step \f$t\f$
	signal sigma_0_t : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
		--! Output of the \f$\Sigma_0\f$ functional block for the step \f$t+1\f$
	signal sigma_0_t1 : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
		--! Output of the \f$\Sigma_1\f$ functional block for the step \f$t\f$
	signal sigma_1_t : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
		--! Output of the \f$\Sigma_1\f$ functional block for the step \f$t+1\f$
	signal sigma_1_t1 : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
	--! Output of the \f$Majority\f$ functional block for the step \f$t\f$
	signal maj_o_t : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
	--! Output of the \f$Majority\f$ functional block for the step \f$t+1\f$
	signal maj_o_t1 : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
	--! Output of the \f$Choose\f$ functional block for the step \f$t\f$
	signal ch_o_t : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
	--! Internal value of the parameter \f$p_2\f$ to be used for other sums
	signal p2_int : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
	--! Internal value of the parameter \f$H^*\f$ to be used for other sums
	signal bigH_star_int : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
	
	--! Constant \f$K\f$ for the step \f$t+4\f$
	alias k4 is K(2*WORD_WIDTH - 1 downto WORD_WIDTH);
	--! Constant \f$K\f$ for the step \f$t-3\f$
	alias k3 is K(WORD_WIDTH - 1 downto 0);
	--! Constant \f$K\f$ for the step \f$t+4\f$
	alias w4 is W(WORD_WIDTH - 1 downto 0);
	--! Constant \f$K\f$ for the step \f$t-3\f$
	alias w3 is W(2*WORD_WIDTH - 1 downto WORD_WIDTH);
	--! Value of the sum \f$K_{t+4}+W_{t+4}\f$ input to the prefetch register
	signal kw4_pre : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
	--! Value of the sum \f$K_{t+3}+W_{t+3}\f$ input to the prefetch register
	signal kw3_pre : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
	--! Value of the sum \f$K_{t+4}+W_{t+4}\f$ for the stage
	signal kw4 : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
	--! Value of the sum \f$K_{t+3}+W_{t+3}\f$ for the stage
	signal kw3 : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
begin
	assert (WORDS = 14) report "Wrong pipeline width specification" severity failure;
	assert (UNROLLING_FACTOR = 2) report "This core is developed for a 2-unrolled architecture" severity failure;
	
	-- PRE-COMPUTATION
	
	reg_input(11*WORD_WIDTH) <= mux_output(14*WORD_WIDTH);
	feedback(14*WORD_WIDTH) <= valid_reg;
	
	with end_major_cycle select mux_output <=
		feedback when '0',
		input when '1',(others => 'X') when others;
		
	--! \f$\Sigma_0\f$ component for the computation of the step \f$t\f$	
	sigma0_t : entity shacomps.Sigma_0
		generic map(
			WORD_WIDTH => WORD_WIDTH
		)
		port map(
			x => a_mux_out,
			o => sigma_0_t
		);
		
	--! \f$\Majority\f$ component for the computation of the step \f$t\f$	
	Maj_t : entity shacomps.Majority
		generic map(
			width => WORD_WIDTH
		)
		port map(
			x => a_mux_out,
			y => b_mux_out,
			z => c_mux_out,
			o => maj_o_t
		);
	
	--! CSA 1
	csa_1 : entity components.CS_adder
		generic map(
			width => WORD_WIDTH
		)
		port map(
			x     => sigma_0_t,
			y     => maj_o_t,
			z     => p3,
			c_in  => '0',
			s     => p1_plus_p3_reg_in,
			c_out => open
		);
	
	--! \f$\Sigma_1\f$ component for the computation of the step \f$t\f$
	sigma1_t : entity shacomps.Sigma_1
		generic map(
			WORD_WIDTH => WORD_WIDTH
		)
		port map(
			x => e_mux_out,
			o => sigma_1_t
		);
		
	--! \f$\Choose\f$ component	for the computation of the step \f$t\f$
	Ch_t : entity shacomps.Choose
		generic map(
			width => WORD_WIDTH
		)
		port map(
			x => e_mux_out,
			y => f_mux_out,
			z => g_mux_out,
			o => ch_o_t
		);
		
	--! CSA 2
	csa_2 : entity components.CS_adder
		generic map(
			width => WORD_WIDTH
		)
		port map(
			x     => x_mux_out,
			y     => sigma_1_t,
			z     => ch_o_t,
			c_in  => '0',
			s     => p2_int,
			c_out => open
		);
	
	--! CSA 3
	csa_3 : entity components.CS_adder
		generic map(
			width => WORD_WIDTH
		)
		port map(
			x     => bigH_mux_out,
			y     => sigma_1_t,
			z     => ch_o_t,
			c_in  => '0',
			s     => p3,
			c_out => open
		);
	
	--! \f$\Choose\f$ component	for the computation of the step \f$t+1\f$
	Ch_t1 : entity shacomps.Choose
		generic map(
			width => WORD_WIDTH
		)
		port map(
			x => p2_int,
			y => e_mux_out,
			z => f_mux_out,
			o => p6
		);
		
	--! \f$\Sigma_1\f$ component for the computation of the step \f$t+1\f$
	sigma1_t1 : entity shacomps.Sigma_1
		generic map(
			WORD_WIDTH => WORD_WIDTH
		)
		port map(
			x => p2_int,
			o => sigma_1_t1
		);
	
	p5 <= std_logic_vector(unsigned(c_mux_out)+unsigned(p4_mux_out));
	
	--! CSA for computing the intermediate parameter \f$A\f$
	csa_A : entity components.CS_adder
		generic map(
			width => WORD_WIDTH
		)
		port map(
			x     => sigma_1_t1,
			y     => p6,
			z     => p4_mux_out,
			c_in  => '0',
			s     => bigA_reg_in,
			c_out => open
		);
	
	--! CSA for computing the intermediate parameter \f$e_{t+1}\f$
	csa_e : entity components.CS_adder
		generic map(
			width => WORD_WIDTH
		)
		port map(
			x     => p6,
			y     => sigma_1_t1,
			z     => p5,
			c_in  => '0',
			s     => e_plus1_reg_in,
			c_out => open
		);
	
	a_reg_in <= a_mux_out;
	b_reg_in <= b_mux_out;
	e_reg_in <= e_mux_out;
	f_reg_in <= f_mux_out;
	p2_reg_in <= p2_int;
	x_star_reg_in <= x_star_mux_out;
	p4_star_reg_in <= p4_star_mux_out;
	bigh_star_reg_in <= bigh_star_mux_out;
	
	
	--! @brief Pipeline register of the compressor pipeline
	--! @details It works also as working register 
	pipeline_reg : entity components.reg
		generic map(
			width => 11*WORD_WIDTH+1
		)
		port map(
			clk     => clk,
			not_rst => not_rst,
			en      => en,
			d       => reg_input,
			q       => reg_output
		);
	
	-- PREFETCHING
	kw3_pre <= std_logic_vector(unsigned(k3)+unsigned(w3));
	kw4_pre <= std_logic_vector(unsigned(k4)+unsigned(w4));
	
	kw3_reg : entity components.reg
		generic map(
			width => WORD_WIDTH
		)
		port map(
			clk     => clk,
			not_rst => not_rst,
			en      => en,
			d       => kw3_pre,
			q       => kw3
		);
		
	kw4_reg : entity components.reg
		generic map(
			width => WORD_WIDTH
		)
		port map(
			clk     => clk,
			not_rst => not_rst,
			en      => en,
			d       => kw4_pre,
			q       => kw4
		);	
	
	-- FINAL COMPUTATION
	
	--! \f$\Sigma_0\f$ component for the computation of the step \f$t+1\f$	
	sigma0_t1 : entity shacomps.Sigma_0
		generic map(
			WORD_WIDTH => WORD_WIDTH
		)
		port map(
			x => p1_plus_p3_reg_out,
			o => sigma_0_t1
		);
		
	--! \f$\Majority\f$ component for the computation of the step \f$t+1\f$	
	Maj_t1 : entity shacomps.Majority
		generic map(
			width => WORD_WIDTH
		)
		port map(
			x => p1_plus_p3_reg_out,
			y => a_reg_out,
			z => b_reg_out,
			o => maj_o_t1
		);
		
	--! CSA for computing the new value for the accumulator \f$A\f$
	csa_a_out : entity components.CS_adder
		generic map(
			width => WORD_WIDTH
		)
		port map(
			x     => sigma_0_t1,
			y     => maj_o_t1,
			z     => bigA_reg_out,
			c_in  => '0',
			s     => a_feedback,
			c_out => open
		);
	
	bigH_star_int <= std_logic_vector(unsigned(p2_reg_out)+unsigned(kw3));
	
	b_feedback <= p1_plus_p3_reg_out;
	c_feedback <= a_reg_out;
	d_feedback <= b_reg_out;
	e_feedback <= e_plus1_reg_out;
	f_feedback <= p2_reg_out;
	g_feedback <= e_reg_out;
	h_feedback <= f_reg_out;
	x_star_feedback <= std_logic_vector(unsigned(bigh_star_int)+unsigned(p1_plus_p3_reg_out));
	bigH_star_feedback <= bigH_star_int;
	p4_star_feedback <= std_logic_vector(unsigned(e_plus1_reg_out)+unsigned(kw4));
	x_feedback <= x_star_reg_out;
	p4_feedback <= p4_staR_reg_out;
	bigH_feedback <= bigH_star_reg_out;
	
	a_out <= a_feedback;
	b_out <= b_feedback;
	c_out <= c_feedback;
	d_out <= d_feedback;
	e_out <= e_feedback;
	f_out <= f_feedback;
	g_out <= g_feedback;
	h_out <= h_feedback;
	x_out <= x_feedback;
	bigh_out <= bigh_feedback;
	p4_out <= p4_feedback;
	x_star_out <= x_star_feedback;
	bigh_star_out <= bigh_star_feedback;
	p4_star_out <= p4_star_feedback;

	valid_out <= valid_reg;
end architecture;

--! Standard library 
library ieee;
--! Arithmetic library, included for the unsigned modulo addition  
use ieee.numeric_std.all;

architecture Reordered_UF2 of Initialisation_block is
	--! Initialisation value for the accumulator \f$B\f$
	alias b_iv is iv(7*WORD_WIDTH - 1 downto 6*WORD_WIDTH);
	--! Initialisation value for the accumulator \f$D\f$
	alias d_iv is iv(5*WORD_WIDTH - 1 downto 4*WORD_WIDTH);
	--! Initialisation value for the accumulator \f$E\f$
	alias e_iv is iv(4*WORD_WIDTH - 1 downto 3*WORD_WIDTH);
	--! Initialisation value for the accumulator \f$F\f$
	alias f_iv is iv(3*WORD_WIDTH - 1 downto 2*WORD_WIDTH);
	--! Initialisation value for the accumulator \f$G\f$
	alias g_iv is iv(2*WORD_WIDTH - 1 downto WORD_WIDTH);
	--! Initialisation value for the accumulator \f$H\f$
	alias h_iv is iv(WORD_WIDTH - 1 downto 0);
	
	--! Constant \f$K\f$ for the round 3
	alias k_3 is K(4*WORD_WIDTH - 1 downto 3*WORD_WIDTH);
	--! Constant \f$K\f$ for the round 2
	alias k_2 is K(3*WORD_WIDTH - 1 downto 2*WORD_WIDTH);
	--! Constant \f$K\f$ for the round 1
	alias k_1 is K(2*WORD_WIDTH - 1 downto WORD_WIDTH);
	--! Constant \f$K\f$ for the round 0
	alias k_0 is K(WORD_WIDTH - 1 downto 0);
	
	--! Expanded word for the round 3
	alias w_3 is W(WORD_WIDTH - 1 downto 0);
	--! Expanded word for the round 2
	alias w_2 is W(2*WORD_WIDTH - 1 downto WORD_WIDTH);
	--! Expanded word for the round 1
	alias w_1 is W(3*WORD_WIDTH - 1 downto 2*WORD_WIDTH);
	--! Expanded word for the round 0
	alias w_0 is W(4*WORD_WIDTH - 1 downto 3*WORD_WIDTH);
	
	--! Initialisation value for \f$X^*\f$
	alias x is additional_iv(6*WORD_WIDTH - 1 downto 5*WORD_WIDTH);
	--! Initialisation value for the word \f$h^*\f$
	alias h is additional_iv(5*WORD_WIDTH - 1 downto 4*WORD_WIDTH);
	--! Initialisation value for the word \f$P_4\f$
	alias p_4 is additional_iv(4*WORD_WIDTH - 1 downto 3*WORD_WIDTH);
	--! Initialisation value for the word \f$X^*\f$
	alias x_star is additional_iv(3*WORD_WIDTH - 1 downto 2*WORD_WIDTH);
	--! Initialisation value for the word \f$H^*\f$
	alias h_star is additional_iv(2*WORD_WIDTH - 1 downto WORD_WIDTH);
	--! Initialisation value for the word \f$P^*_4\f$
	alias p_4_star is additional_iv(WORD_WIDTH - 1 downto 0);
begin
	x <= std_logic_vector(unsigned(h_iv) + unsigned(k_0) + unsigned(w_0) + unsigned(d_iv));
	h <= std_logic_vector(unsigned(h_iv) + unsigned(k_0) + unsigned(w_0));
	p_4 <= std_logic_vector(unsigned(k_1) + unsigned(w_1) + unsigned(g_iv));
	x_star <= std_logic_vector(unsigned(b_iv) + unsigned(f_iv) + unsigned(k_2) + unsigned(w_2));
	h_star <= std_logic_vector(unsigned(f_iv) + unsigned(k_2) + unsigned(w_2));
	p_4_star <= std_logic_vector(unsigned(k_3) + unsigned(w_3) + unsigned(e_iv));
end architecture;
	