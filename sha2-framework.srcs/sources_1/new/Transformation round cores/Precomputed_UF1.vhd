--! Standard library 
library ieee;
--! Arithmetic library, included for the unsigned modulo addition  
use ieee.numeric_std.all;

--! Basic SHA components library
library shacomps;

--! Basic integrated circuits components library
library components;

--!@brief Precomputed, non-unrolled architecture
architecture Precomputed_UF1 of Transf_round is
	
	alias d_in is input(5 * WORD_WIDTH - 1 downto 4 * WORD_WIDTH);
	alias h_in is input(WORD_WIDTH - 1 downto 0);
	
	--! Output of the multiplexer, and input of the compressor pipeline register
	signal reg_input  : std_logic_vector(8 * WORD_WIDTH downto 0) := (others => '0');
	--! Output of the compressor pipeline register
	signal reg_output : std_logic_vector(8 * WORD_WIDTH downto 0) := (others => '0');
	--! Internal output signal, to be used as feedback input
	signal feedback   : std_logic_vector(8 * WORD_WIDTH downto 0) := (others => '0');

	--! Flag of validity for the register
	alias valid_reg is reg_output(8 * WORD_WIDTH);
	--! Value of the accumulator \f$A\f$ input to the compressor round
	alias a_t is reg_output(8 * WORD_WIDTH - 1 downto 7 * WORD_WIDTH);
	--! Value of the accumulator \f$B\f$ input to the compressor round
	alias b_t is reg_output(7 * WORD_WIDTH - 1 downto 6 * WORD_WIDTH);
	--! Value of the accumulator \f$C\f$ input to the compressor round
	alias c_t is reg_output(6 * WORD_WIDTH - 1 downto 5 * WORD_WIDTH);
	--!@brief Value of the accumulator \f$D\f$ input to the compressor round
	--!@details This value is precomputed during the precomputation step, hence it is not read
	--! from the registers
	signal d_t : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
	--! Value of the accumulator \f$E\f$ input to the compressor round
	alias e_t is reg_output(4 * WORD_WIDTH - 1 downto 3 * WORD_WIDTH);
	--! Value of the accumulator \f$F\f$ input to the compressor round
	alias f_t is reg_output(3 * WORD_WIDTH - 1 downto 2 * WORD_WIDTH);
	--! Value of the accumulator \f$G\f$ input to the compressor round
	alias g_t is reg_output(2 * WORD_WIDTH - 1 downto WORD_WIDTH);
	--! Value of the accumulator \f$H\f$ input to the compressor round
	--!@details This value is precomputed during the precomputation step, hence it is not read
	--! from the registers
	signal h_t : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
	
	signal Maj_o: std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0'); 
	signal Ch_o : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
	signal Sigma_0_o : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
	signal Sigma_1_o : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
	signal delta_reg_in : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
	signal delta_reg_out : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
	signal delta_first_reg_in : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
	signal delta_first_reg_out : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
	signal intermediate_sum2 :  std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
	signal intermediate_sum3 :  std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');

	--! @brief Value of the accumulator \f$A\f$ output from the compressor round
	--! @details This temporary signal is employed to perform the feedback
	alias a_feedback is feedback(8 * WORD_WIDTH - 1 downto 7 * WORD_WIDTH);
	--! @brief Value of the accumulator \f$B\f$ output from the compressor round
	--! @details This temporary signal is employed to perform the feedback
	alias b_feedback is feedback(7 * WORD_WIDTH - 1 downto 6 * WORD_WIDTH);
	--! @brief Value of the accumulator \f$C\f$ output from the compressor round
	--! @details This temporary signal is employed to perform the feedback
	alias c_feedback is feedback(6 * WORD_WIDTH - 1 downto 5 * WORD_WIDTH);
	--! @brief Value of the accumulator \f$D\f$ output from the compressor round
	--! @details This temporary signal is employed to perform the feedback
	alias d_feedback is feedback(5 * WORD_WIDTH - 1 downto 4 * WORD_WIDTH);
	--! @brief Value of the accumulator \f$E\f$ output from the compressor round
	--! @details This temporary signal is employed to perform the feedback
	alias e_feedback is feedback(4 * WORD_WIDTH - 1 downto 3 * WORD_WIDTH);
	--! @brief Value of the accumulator \f$F\f$ output from the compressor round
	--! @details This temporary signal is employed to perform the feedback
	alias f_feedback is feedback(3 * WORD_WIDTH - 1 downto 2 * WORD_WIDTH);
	--! @brief Value of the accumulator \f$G\f$ output from the compressor round
	--! @details This temporary signal is employed to perform the feedback
	alias g_feedback is feedback(2 * WORD_WIDTH - 1 downto WORD_WIDTH);
	--! @brief Value of the accumulator \f$H\f$ output from the compressor round
	--! @details This temporary signal is employed to perform the feedback
	alias h_feedback is feedback(WORD_WIDTH - 1 downto 0);

	--! Flag of validity for the output register
	alias valid_out is output(8 * WORD_WIDTH);
	--! Value of the accumulator \f$A\f$ output from the stage
	alias a_out is output(8 * WORD_WIDTH - 1 downto 7 * WORD_WIDTH);
	--! Value of the accumulator \f$B\f$ output from the stage
	alias b_out is output(7 * WORD_WIDTH - 1 downto 6 * WORD_WIDTH);
	--! Value of the accumulator \f$C\f$ output from the stage
	alias c_out is output(6 * WORD_WIDTH - 1 downto 5 * WORD_WIDTH);
	--! Value of the accumulator \f$D\f$ output from the stage
	alias d_out is output(5 * WORD_WIDTH - 1 downto 4 * WORD_WIDTH);
	--! Value of the accumulator \f$E\f$ output from the stage
	alias e_out is output(4 * WORD_WIDTH - 1 downto 3 * WORD_WIDTH);
	--! Value of the accumulator \f$F\f$ output from the stage
	alias f_out is output(3 * WORD_WIDTH - 1 downto 2 * WORD_WIDTH);
	--! Value of the accumulator \f$G\f$ output from the stage
	alias g_out is output(2 * WORD_WIDTH - 1 downto WORD_WIDTH);
	--! Value of the accumulator \f$H\f$ output from the stage
	alias h_out is output(WORD_WIDTH - 1 downto 0);

begin
	assert (WORDS = 8) report "Wrong pipeline width specification" severity failure;
	assert (UNROLLING_FACTOR = 1) report "This core is developed for a non-unrolled architecture" severity failure;

	feedback(8 * WORD_WIDTH) <= valid_reg;

	with end_major_cycle select reg_input <=
		feedback when '0',
		input when '1',(others => 'X') when others;

	--! @brief Pipeline register of the compressor pipeline
	--! @details It works also as working register 
	pipeline_reg : entity components.reg
		generic map(
			width => 8 * WORD_WIDTH + 1
		)
		port map(
			clk     => clk,
			not_rst => not_rst,
			en      => en,
			d       => reg_input,
			q       => reg_output
		);

	with end_major_cycle select d_t <=
		c_t when '0',
		d_in when '1', (others => 'X') when others;	

	with end_major_cycle select h_t <=
		g_t when '0',
		h_in when '1', (others => 'X') when others;
		
	delta : entity components.CS_adder
		generic map(
			width => WORD_WIDTH
		)
		port map(
			x     => W,
			y     => K,
			z     => h_t,
			c_in  => '0',
			s     => delta_reG_in,
			c_out => open
		);
	
	delta_first_reg_in <= std_logic_vector(unsigned(delta_reg_in) + unsigned(d_t));
	
	delta_reg : entity components.reg
		generic map(
			width => WORD_WIDTH
		)
		port map(
			clk     => clk,
			not_rst => not_rst,
			en      => en,
			d       => delta_reg_in,
			q       => delta_reg_out
		);
		
	delta_first_reg : entity components.reg
		generic map(
			width => WORD_WIDTH
		)
		port map(
			clk     => clk,
			not_rst => not_rst,
			en      => en,
			d       => delta_first_reg_in,
			q       => delta_first_reg_out
		);
	
	maj : entity shacomps.Majority
		generic map(
			width => WORD_WIDTH
		)
		port map(
			x => a_t,
			y => b_t,
			z => c_t,
			o => Maj_o
		);
		
	sigma0 : entity shacomps.Sigma_0
		generic map(
			WORD_WIDTH => WORD_WIDTH
		)
		port map(
			x => a_t,
			o => Sigma_0_o
		);
		
	ch : entity shacomps.Choose
		generic map(
			width => WORD_WIDTH
		)
		port map(
			x => e_t,
			y => f_t,
			z => g_t,
			o => Ch_o
		);
		
	sigma1 : entity shacomps.Sigma_1
		generic map(
			WORD_WIDTH => WORD_WIDTH
		)
		port map(
			x => e_t,
			o => Sigma_1_o
		);
		
	intermediate_csa : entity components.CS_adder
		generic map(
			width => WORD_WIDTH
		)
		port map(
			x     => Maj_o,
			y     => Sigma_0_o,
			z     => delta_reg_out,
			c_in  => '0',
			s     => intermediate_sum3,
			c_out => open
		);
		
	intermediate_sum2 <= std_logic_vector(unsigned(Ch_o) + unsigned(Sigma_1_o));
		
	a_feedback <= std_logic_vector(unsigned(intermediate_sum3) + unsigned(intermediate_sum2));
	b_feedback <= a_t;
	c_feedback <= b_t;
	d_feedback <= c_t;
	e_feedback <= std_logic_vector(unsigned(delta_first_reg_out) + unsigned(intermediate_sum2));
	f_feedback <= e_t;
	g_feedback <= f_t;
	h_feedback <= g_t;

	a_out <= a_feedback;
	b_out <= b_feedback;
	c_out <= c_feedback;
	d_out <= d_feedback;
	e_out <= e_feedback;
	f_out <= f_feedback;
	g_out <= g_feedback;
	h_out <= h_feedback;

	valid_out <= valid_reg;

end architecture Precomputed_UF1;
