--! Basic SHA components library
library shacomps;

--! Basic integrated circuits components library
library components;

architecture Naive of Transf_round is

	--! Output of the multiplexer, and input of the compressor pipeline register
	signal reg_input  : std_logic_vector(8*WORD_WIDTH downto 0) := (others => '0');
	--! Output of the compressor pipeline register
	signal reg_output : std_logic_vector(8*WORD_WIDTH downto 0) := (others => '0');
	--! Internal output signal, to be used as feedback input
	signal feedback   : std_logic_vector(8*WORD_WIDTH downto 0) := (others => '0');

	--! Flag of validity for the register
	alias valid_reg is reg_output(8*WORD_WIDTH);
	--! Value of the accumulator \f$A\f$ input to the compressor round
	alias a_hash is reg_output(8*WORD_WIDTH - 1 downto 7*WORD_WIDTH);
	--! Value of the accumulator \f$B\f$ input to the compressor round
	alias b_hash is reg_output(7*WORD_WIDTH - 1 downto 6*WORD_WIDTH);
	--! Value of the accumulator \f$C\f$ input to the compressor round
	alias c_hash is reg_output(6*WORD_WIDTH - 1 downto 5*WORD_WIDTH);
	--! Value of the accumulator \f$D\f$ input to the compressor round
	alias d_hash is reg_output(5*WORD_WIDTH - 1 downto 4*WORD_WIDTH);
	--! Value of the accumulator \f$E\f$ input to the compressor round
	alias e_hash is reg_output(4*WORD_WIDTH - 1 downto 3*WORD_WIDTH);
	--! Value of the accumulator \f$F\f$ input to the compressor round
	alias f_hash is reg_output(3*WORD_WIDTH - 1 downto 2*WORD_WIDTH);
	--! Value of the accumulator \f$G\f$ input to the compressor round
	alias g_hash is reg_output(2*WORD_WIDTH - 1 downto WORD_WIDTH);
	--! Value of the accumulator \f$H\f$ input to the compressor round
	alias h_hash is reg_output(WORD_WIDTH - 1 downto 0);

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
	alias a_out is output(8*WORD_WIDTH - 1 downto 7*WORD_WIDTH);
	--! Value of the accumulator \f$B\f$ output from the stage
	alias b_out is output(7*WORD_WIDTH - 1 downto 6*WORD_WIDTH);
	--! Value of the accumulator \f$C\f$ output from the stage
	alias c_out is output(6*WORD_WIDTH - 1 downto 5*WORD_WIDTH);
	--! Value of the accumulator \f$D\f$ output from the stage
	alias d_out is output(5*WORD_WIDTH - 1 downto 4*WORD_WIDTH);
	--! Value of the accumulator \f$E\f$ output from the stage
	alias e_out is output(4*WORD_WIDTH - 1 downto 3*WORD_WIDTH);
	--! Value of the accumulator \f$F\f$ output from the stage
	alias f_out is output(3*WORD_WIDTH - 1 downto 2*WORD_WIDTH);
	--! Value of the accumulator \f$G\f$ output from the stage
	alias g_out is output(2*WORD_WIDTH - 1 downto WORD_WIDTH);
	--! Value of the accumulator \f$H\f$ output from the stage
	alias h_out is output(WORD_WIDTH - 1 downto 0);

	component Transf_round_comb is
		generic(
			WORD_WIDTH : natural := 32;
			UNROLLING_FACTOR : natural := 1 --! Number of SHA-256 steps performed by a single round
		);
		port(
			--! Input value of the accumulator \f$A\f$
			a_in  : in  std_logic_vector(WORD_WIDTH - 1 downto 0);
			--! Input value of the accumulator \f$B\f$
			b_in  : in  std_logic_vector(WORD_WIDTH - 1 downto 0);
			--! Input value of the accumulator \f$C\f$
			c_in  : in  std_logic_vector(WORD_WIDTH - 1 downto 0);
			--! Input value of the accumulator \f$D\f$
			d_in  : in  std_logic_vector(WORD_WIDTH - 1 downto 0);
			--! Input value of the accumulator \f$E\f$
			e_in  : in  std_logic_vector(WORD_WIDTH - 1 downto 0);
			--! Input value of the accumulator \f$F\f$
			f_in  : in  std_logic_vector(WORD_WIDTH - 1 downto 0);
			--! Input value of the accumulator \f$G\f$
			g_in  : in  std_logic_vector(WORD_WIDTH - 1 downto 0);
			--! Input value of the accumulator \f$H\f$
			h_in  : in  std_logic_vector(WORD_WIDTH - 1 downto 0);
			--! Constant \f$K\f$ words
			K     : in  std_logic_vector((UNROLLING_FACTOR * WORD_WIDTH) - 1 downto 0);
			--! Expanded message words
			W     : in  std_logic_vector((UNROLLING_FACTOR * WORD_WIDTH) - 1 downto 0);
			--! Output value of the accumulator \f$A\f$
			a_out : out std_logic_vector(WORD_WIDTH - 1 downto 0);
			--! Output value of the accumulator \f$B\f$
			b_out : out std_logic_vector(WORD_WIDTH - 1 downto 0);
			--! Output value of the accumulator \f$C\f$
			c_out : out std_logic_vector(WORD_WIDTH - 1 downto 0);
			--! Output value of the accumulator \f$D\f$
			d_out : out std_logic_vector(WORD_WIDTH - 1 downto 0);
			--! Output value of the accumulator \f$E\f$
			e_out : out std_logic_vector(WORD_WIDTH - 1 downto 0);
			--! Output value of the accumulator \f$F\f$
			f_out : out std_logic_vector(WORD_WIDTH - 1 downto 0);
			--! Output value of the accumulator \f$G\f$
			g_out : out std_logic_vector(WORD_WIDTH - 1 downto 0);
			--! Output value of the accumulator \f$H\f$
			h_out : out std_logic_vector(WORD_WIDTH - 1 downto 0)
		);
	end component Transf_round_comb;
	
	for all : Transf_round_comb use entity shacomps.Transf_round_comb(Unrolled);
	
begin
	assert (WORDS = 8) report "Wrong pipeline width specification" severity failure;

	feedback(8*WORD_WIDTH) <= valid_reg;

	with end_major_cycle select reg_input <=
		feedback when '0',
		input when '1',(others => 'X') when others;

	--! @brief Pipeline register of the compressor pipeline
	--! @details It works also as working register 
	pipeline_reg : entity components.reg
		generic map(
			width => 8*WORD_WIDTH + 1
		)
		port map(
			clk     => clk,
			not_rst => not_rst,
			en      => en,
			d       => reg_input,
			q       => reg_output
		);

	compression : component Transf_round_comb
		generic map(
			WORD_WIDTH => WORD_WIDTH,
			UNROLLING_FACTOR => UNROLLING_FACTOR
		)
		port map(
			a_in  => a_hash,
			b_in  => b_hash,
			c_in  => c_hash,
			d_in  => d_hash,
			e_in  => e_hash,
			f_in  => f_hash,
			g_in  => g_hash,
			h_in  => h_hash,
			K     => K,
			W     => W,
			a_out => a_feedback,
			b_out => b_feedback,
			c_out => c_feedback,
			d_out => d_feedback,
			e_out => e_feedback,
			f_out => f_feedback,
			g_out => g_feedback,
			h_out => h_feedback
		);
	
	a_out <= a_feedback;
	b_out <= b_feedback;
	c_out <= c_feedback;
	d_out <= d_feedback;
	e_out <= e_feedback;
	f_out <= f_feedback;
	g_out <= g_feedback;
	h_out <= h_feedback;

	valid_out <= valid_reg;

end architecture Naive;
