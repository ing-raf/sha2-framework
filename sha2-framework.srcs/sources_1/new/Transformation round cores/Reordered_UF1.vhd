--! Standard library 
library ieee;
--! Arithmetic library, included for the unsigned modulo addition  
use ieee.numeric_std.all;

--! Basic SHA components library
library shacomps;

--! Basic integrated circuits components library
library components;

architecture Reordered_UF1 of Transf_round is
	
	--! Internal output signal, to be used as feedback input
	signal feedback   : std_logic_vector(8*WORD_WIDTH downto 0) := (others => '0');
	--! Output of the multiplexer, and input of the precomputation stage
	signal mux_output : std_logic_vector(8*WORD_WIDTH downto 0) := (others => '0');
	--! Input of the compressor pipeline register
	signal reg_input  : std_logic_vector(10*WORD_WIDTH downto 0) := (others => '0');
	--! Output of the compressor pipeline register
	signal reg_output : std_logic_vector(10*WORD_WIDTH downto 0) := (others => '0');
	
	--! Value of the accumulator \f$A\f$ input for the stage
	alias a_mux_out is mux_output(8*WORD_WIDTH - 1 downto 7*WORD_WIDTH);
	--! Value of the accumulator \f$B\f$ input for the stage
	alias b_mux_out is mux_output(7*WORD_WIDTH - 1 downto 6*WORD_WIDTH);
	--! Value of the accumulator \f$C\f$ input for the stage
	alias c_mux_out is mux_output(6*WORD_WIDTH - 1 downto 5*WORD_WIDTH);
	--! Value of the accumulator \f$D\f$ input for the stage
	alias d_mux_out is mux_output(5*WORD_WIDTH - 1 downto 4*WORD_WIDTH);
	--! Value of the accumulator \f$E\f$ input for the stage
	alias e_mux_out is mux_output(4*WORD_WIDTH - 1 downto 3*WORD_WIDTH);
	--! Value of the accumulator \f$F\f$ input for the stage
	alias f_mux_out is mux_output(3*WORD_WIDTH - 1 downto 2*WORD_WIDTH);
	--! Value of the accumulator \f$G\f$ input for the stage
	alias g_mux_out is mux_output(2*WORD_WIDTH - 1 downto WORD_WIDTH);
	--! Value of the accumulator \f$H\f$ input for the stage
	alias h_mux_out is mux_output(WORD_WIDTH - 1 downto 0);
	
	--! Precomputed value of the accumulator \f$A\f$ input to the pipeline register
	alias a_reg_in is reg_input(10*WORD_WIDTH - 1 downto 9*WORD_WIDTH);
	--! Precomputed value of the parameter \f$P^*_1\f$ input to the pipeline register
	alias p1_reg_in is reg_input(9*WORD_WIDTH - 1 downto 8*WORD_WIDTH);
	--! Precomputed value of the accumulator \f$B\f$ input to the pipeline register
	alias b_reg_in is reg_input(8*WORD_WIDTH - 1 downto 7*WORD_WIDTH);
	--! Precomputed value of the accumulator \f$C\f$ input to the pipeline register
	alias c_reg_in is reg_input(7*WORD_WIDTH - 1 downto 6*WORD_WIDTH);
	--! Precomputed value of the accumulator \f$D\f$ input to the pipeline register
	alias d_reg_in is reg_input(6*WORD_WIDTH - 1 downto 5*WORD_WIDTH);
	--! Precomputed value of the parameter \f$P^*_2\f$ input to the pipeline register
	alias p2_reg_in is reg_input(5*WORD_WIDTH - 1 downto 4*WORD_WIDTH);
	--! Precomputed value of the accumulator \f$E\f$ input to the pipeline register
	alias e_reg_in is reg_input(4*WORD_WIDTH - 1 downto 3*WORD_WIDTH);
	--! Precomputed value of the accumulator \f$F\f$ input to the pipeline register
	alias f_reg_in is reg_input(3*WORD_WIDTH - 1 downto 2*WORD_WIDTH);
	--! Precomputed value of the accumulator \f$G\f$ input to the pipeline register
	alias g_reg_in is reg_input(2*WORD_WIDTH - 1 downto WORD_WIDTH);
	--! Precomputed value of the parameter \f$H^*\f$ input to the pipeline register
	alias h_reg_in is reg_input(WORD_WIDTH - 1 downto 0);
	
	--! Flag of validity for the register
	alias valid_reg is reg_output(10*WORD_WIDTH);
	--! Value of the accumulator \f$A\f$ input to the final calculation phase
	alias a_reg_out is reg_output(10*WORD_WIDTH - 1 downto 9*WORD_WIDTH);
	--! Value of the parameter \f$P^*_1\f$ input to the final calculation phase
	alias p1_reg_out is reg_output(9*WORD_WIDTH - 1 downto 8*WORD_WIDTH);
	--! Value of the accumulator \f$B\f$ input to the final calculation phase
	alias b_reg_out is reg_output(8*WORD_WIDTH - 1 downto 7*WORD_WIDTH);
	--! Value of the accumulator \f$C\f$ input to the final calculation phase
	alias c_reg_out is reg_output(7*WORD_WIDTH - 1 downto 6*WORD_WIDTH);
	--! Value of the accumulator \f$D\f$ input to the final calculation phase
	alias d_reg_out is reg_output(6*WORD_WIDTH - 1 downto 5*WORD_WIDTH);
	--! Value of the parameter \f$P^*_2\f$ input to the final calculation phase
	alias p2_reg_out is reg_output(5*WORD_WIDTH - 1 downto 4*WORD_WIDTH);
	--! Value of the accumulator \f$E\f$ input to the final calculation phase
	alias e_reg_out is reg_output(4*WORD_WIDTH - 1 downto 3*WORD_WIDTH);
	--! Value of the accumulator \f$F\f$ input to the final calculation phase
	alias f_reg_out is reg_output(3*WORD_WIDTH - 1 downto 2*WORD_WIDTH);
	--! Value of the accumulator \f$G\f$ input to the final calculation phase
	alias g_reg_out is reg_output(2*WORD_WIDTH - 1 downto WORD_WIDTH);
	--! Value of the parameter \f$H^*\f$ input to the final calculation phase
	alias h_reg_out is reg_output(WORD_WIDTH - 1 downto 0);
	
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
	alias valid_out is output(8*WORD_WIDTH);
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
	
	--! Output of the \f$\Sigma_0\f$ functional block
	signal sigma_0 : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
	--! Output of the \f$Majority\f$ functional block
	signal maj_output : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
	--! Output of the \f$\Sigma_1\f$ functional block
	signal sigma_1 : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
	--! Output of the \f$Choose\f$ functional block
	signal ch_output : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
	--! Value of the \f$T_1\f$ step function, computed during the final computation phase
	signal t1 : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');

begin
	assert (WORDS = 8) report "Wrong pipeline width specification" severity failure;
	assert (UNROLLING_FACTOR = 1) report "This core is developed for a non-unrolled architecture" severity failure;
	
	-- PRE-COMPUTATION
	
	reg_input(10*WORD_WIDTH) <= mux_output(8*WORD_WIDTH);
	feedback(8*WORD_WIDTH) <= valid_reg;
	
	with end_major_cycle select mux_output <=
		feedback when '0',
		input when '1',(others => 'X') when others;
		
	--! \f$\Sigma_0\f$ component	
	Sigma0 : entity shacomps.Sigma_0
		generic map(
			WORD_WIDTH => WORD_WIDTH
		)
		port map(
			x => a_mux_out,
			o => sigma_0
		);
	
	--! \f$\Majority\f$ component	
	Maj : entity shacomps.Majority
		generic map(
			width => WORD_WIDTH
		)
		port map(
			x => a_mux_out,
			y => b_mux_out,
			z => c_mux_out,
			o => maj_output
		);
	
	--! \f$\Sigma_1\f$ component	
	Sigma1: entity shacomps.Sigma_1
		generic map(
			WORD_WIDTH => WORD_WIDTH
		)
		port map(
			x => e_mux_out,
			o => sigma_1
		);
	
	--! \f$\Choose\f$ component	
	Ch : entity shacomps.Choose
		generic map(
			width => WORD_WIDTH
		)
		port map(
			x => e_mux_out,
			y => f_mux_out,
			z => g_mux_out,
			o => ch_output
		);
		
	a_reg_in <= a_mux_out;
	p1_reg_in <= std_logic_vector(unsigned(sigma_0)+unsigned(maj_output));
	b_reg_in <= b_mux_out;
	c_reg_in <= c_mux_out;
	d_reg_in <= d_mux_out;
	p2_reg_in <= std_logic_vector(unsigned(sigma_1)+unsigned(ch_output));
	e_reg_in <= e_mux_out;
	f_reg_in <= f_mux_out;
	g_reg_in <= g_mux_out;
	h_reg_in <= std_logic_vector(unsigned(h_mux_out)+(unsigned(K)+unsigned(W)));
	
	--! @brief Pipeline register of the compressor pipeline
	--! @details It works also as working register 
	pipeline_reg : entity components.reg
		generic map(
			width => 10*WORD_WIDTH+1
		)
		port map(
			clk     => clk,
			not_rst => not_rst,
			en      => en,
			d       => reg_input,
			q       => reg_output
		);
	
	-- FINAL COMPUTATION
	
	t1 <= std_logic_vector(unsigned(p2_reg_out)+unsigned(h_reg_out));
	a_feedback <= std_logic_vector(unsigned(p1_reg_out)+unsigned(t1));
	b_feedback <= a_reg_out;
	c_feedback <= b_reg_out;
	d_feedback <= c_reg_out;
	e_feedback <= std_logic_vector(unsigned(d_reg_out)+unsigned(t1));
	f_feedback <= e_reg_out;
	g_feedback <= f_reg_out;
	h_feedback <= g_reg_out;
	
	a_out <= a_feedback;
	b_out <= b_feedback;
	c_out <= c_feedback;
	d_out <= d_feedback;
	e_out <= e_feedback;
	f_out <= f_feedback;
	g_out <= g_feedback;
	h_out <= h_feedback;

	valid_out <= valid_reg;
	
end architecture Reordered_UF1;