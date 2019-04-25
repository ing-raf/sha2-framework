--! @file ExpandeR_stage.vhd
--! @brief Expander stage entity definition and implementation

--! Standard library
library ieee;
--! Standard 9-values logic library
use ieee.std_logic_1164.all;
--! Arithmetic library, included for the unsigned addition
use ieee.numeric_std.all;

--! Basic integrated circuits components library
library components;

--! Basic SHA components library
library shacomps;

--! @brief Stage of the Expander pipeline
entity Expander_stage is
	generic(
		WORD_WIDTH : natural := 32; --! Width of the words of the Expander 
		UNROLLING_FACTOR : natural := 1 --! Number of SHA-2 steps performed by a single round
	);
	port(
		clk             : in  std_logic; --! Clock of this component
		not_rst         : in  std_logic; --! Active-low asynchronous reset signal
		en              : in  std_logic; --! Enable signal
		end_major_cycle : in  std_logic; --! Derived pipeline clock
		W_in            : in  std_logic_vector(16*WORD_WIDTH - 1 downto 0); --! Input of the expander pipeline stage
		W               : out std_logic_vector((UNROLLING_FACTOR * WORD_WIDTH) - 1 downto 0); --! Expanded words for the current clock cycle
		W_out           : out std_logic_vector(16*WORD_WIDTH - 1 downto 0) --! Output of the expander pipeline stage 	
	);
end entity Expander_stage;

--! @brief Architecture of the Expander pipeline stage
--! @details The standard shift registers chain is splitted into a number of chains equals to the unrolling factor
--! @details According to the SHA-256 specification, the 16 initial words which the input message is splitted into
--! are in big-endian order, causing a reverse sorting of the input message, which must be taken in little-endian
--! order. This makes it necessary to reverse the input of the expander, and this reversal must in turn be taken 
--! into account when splitting the expander into stages. Namely, the right shift becomes a @b left shift when 
--! reversed
architecture RTL of Expander_stage is
	
	--! @brief Type used to represent the set of expanded words 
	--! @details There are 16 expanded words, one per each shift register position, plus a newly expanded word
	--! per splitted chain
	type EXPANDED_WORDS is array ((UNROLLING_FACTOR + 15) downto 0) of std_logic_vector(WORD_WIDTH - 1 downto 0);
	--! Type used to break the input message into its constituting 32-bit words
	type MSG_CONNECTION is array (15 downto 0) of std_logic_vector(WORD_WIDTH - 1 downto 0);
	--! Type representing the output of \f$sigma_x\f$ functions
	type SIGMA is array (UNROLLING_FACTOR - 1 downto 0) of std_logic_vector(WORD_WIDTH - 1 downto 0);
	--! Array of expanded words
	signal word : EXPANDED_WORDS;
	--! Inputs of the registers in the shift registers
	signal shift_register_in : MSG_CONNECTION;
	--! Words of the input message
	signal Mj      : MSG_CONNECTION;
	--! Array of outputs of the \f$sigma_0\f$ function blocks
	signal sigma0 : SIGMA;
		--! Array of outputs of the \f$sigma_1\f$ function blocks
	signal sigma1 : SIGMA;
	
begin
	assert UNROLLING_FACTOR <= 16 report "The unrolling factor must be less than or equal to 16" severity failure;

	mux : for i in 15 downto 0 generate
		Mj(i) <= W_in(16*WORD_WIDTH - 1 - WORD_WIDTH * i downto 15*WORD_WIDTH - WORD_WIDTH * i);

		with end_major_cycle select shift_register_in(i) <=
			word(i + UNROLLING_FACTOR) when '0',
			Mj(i) when '1', (others => 'X') when others;
	end generate;

	unrolled_expander : for i in UNROLLING_FACTOR - 1 downto 0 generate
		--! Number of positions of each shift register
		constant SHIFT_LENGTH : natural := 16 / UNROLLING_FACTOR;
		--! Alias to identify the \f$i^{th}\f$ expanded word
		alias output is W((WORD_WIDTH * (i+1)) - 1 downto WORD_WIDTH * i);
	begin
		splitted_chain : for j in SHIFT_LENGTH - 1 downto 0 generate
			w_reg : entity components.reg
				generic map(
					width => WORD_WIDTH
				)
				port map(
					clk     => clk,
					not_rst => not_rst,
					en      => en,
					d       => shift_register_in((UNROLLING_FACTOR * j) + i),
					q       => word((UNROLLING_FACTOR * j) + i)
				);
		end generate;
		
		--! \f$\sigma_0\f$ component for the \f$i^{th}\f$ new expanded word
		sigma_0 : entity shacomps.w_sigma_0
			generic map(
				WORD_WIDTH => WORD_WIDTH
			)
			port map(
				x => word(1 + i),
				o => sigma0(i)
			);
			
		--! \f$\sigma_1\f$ component for the \f$i^{th}\f$ new expanded word
		sigma_1 : entity shacomps.w_sigma_1
		generic map (
			WORD_WIDTH => WORD_WIDTH
		)
		port map(
			x => word(14 + i),
			o => sigma1(i)
		);
			
		word(16 + i) <= std_logic_vector(unsigned(word(0 + i)) + unsigned(sigma0(i)) + unsigned(word(9 + i)) + unsigned(sigma1(i)));	
		
		output <= word(i);
		
		W_out( (WORD_WIDTH * (UNROLLING_FACTOR-i)) - 1 downto WORD_WIDTH * (UNROLLING_FACTOR-1-i) ) <= word(16 + i);
	end generate;
	
	last_shift : for i in 15-UNROLLING_FACTOR downto 0 generate
		W_out(16*WORD_WIDTH - 1 - (WORD_WIDTH * (15-UNROLLING_FACTOR - i))  downto 15*WORD_WIDTH - (WORD_WIDTH * (15-UNROLLING_FACTOR - i))) <= word (15 - i);
	end generate;

end architecture RTL;
	