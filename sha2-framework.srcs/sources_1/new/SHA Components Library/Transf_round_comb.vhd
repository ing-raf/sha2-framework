--! Standard library 
library ieee; 
--! Standard 9-values logic library 
use ieee.std_logic_1164.all; 
--! Arithmetic library, included for the unsigned modulo addition  
use ieee.numeric_std.all; 

--! Combinatorial part of the transformation round
entity Transf_round_comb is
	generic(
		WORD_WIDTH : natural := 32;
		UNROLLING_FACTOR : natural := 1 --! Number of SHA-256 steps performed by a single round
	);
	port(
		--! Input value of the accumulator \f$A\f$
		a_in : in  std_logic_vector(WORD_WIDTH - 1 downto 0);
		--! Input value of the accumulator \f$B\f$
		b_in : in  std_logic_vector(WORD_WIDTH - 1 downto 0);
		--! Input value of the accumulator \f$C\f$
		c_in : in  std_logic_vector(WORD_WIDTH - 1 downto 0);
		--! Input value of the accumulator \f$D\f$
		d_in : in  std_logic_vector(WORD_WIDTH - 1 downto 0);
		--! Input value of the accumulator \f$E\f$
		e_in : in  std_logic_vector(WORD_WIDTH - 1 downto 0);
		--! Input value of the accumulator \f$F\f$
		f_in : in  std_logic_vector(WORD_WIDTH - 1 downto 0);
		--! Input value of the accumulator \f$G\f$
		g_in : in  std_logic_vector(WORD_WIDTH - 1 downto 0);
		--! Input value of the accumulator \f$H\f$
		h_in : in  std_logic_vector(WORD_WIDTH - 1 downto 0);
		--! Constant \f$K\f$ words
		K : in  std_logic_vector((UNROLLING_FACTOR * WORD_WIDTH) - 1 downto 0);
		--! Expanded message words
		W : in  std_logic_vector((UNROLLING_FACTOR * WORD_WIDTH) - 1 downto 0);
		--! Output value of the accumulator \f$A\f$
		a_out   : out std_logic_vector(WORD_WIDTH - 1 downto 0);
		--! Output value of the accumulator \f$B\f$
		b_out   : out std_logic_vector(WORD_WIDTH - 1 downto 0);
		--! Output value of the accumulator \f$C\f$
		c_out   : out std_logic_vector(WORD_WIDTH - 1 downto 0);
		--! Output value of the accumulator \f$D\f$
		d_out   : out std_logic_vector(WORD_WIDTH - 1 downto 0);
		--! Output value of the accumulator \f$E\f$
		e_out   : out std_logic_vector(WORD_WIDTH - 1 downto 0);
		--! Output value of the accumulator \f$F\f$
		f_out   : out std_logic_vector(WORD_WIDTH - 1 downto 0);
		--! Output value of the accumulator \f$G\f$
		g_out  : out std_logic_vector(WORD_WIDTH - 1 downto 0);
		--! Output value of the accumulator \f$H\f$
		h_out  : out std_logic_vector(WORD_WIDTH - 1 downto 0)
	);
end entity Transf_round_comb;