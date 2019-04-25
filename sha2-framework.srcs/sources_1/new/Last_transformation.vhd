--! @file Last_transformation.vhd
--! @brief Chaining block entity and implementation

--! Standard library
library ieee;
--! Standard 9-values logic library
use ieee.std_logic_1164.all;
--! Arithmetic library, included for the unsigned modulo addition 
use ieee.numeric_std.all;

--! @brief Last pipeline stage
--! @details Combinatorial component which performs the final sum between the old values of the
--! accumulators and the newly computed values to get the new intermediate hash value
--! @details The MSB of the input, which is the validity flag of the pipeline registers, is simply
--! propagated to the output
entity Last_transformation is
	generic (
		WORD_WIDTH : natural := 32 --! Word width of the circuit
	);
	port (
		h_in :  in  std_logic_vector(8*WORD_WIDTH downto 0); --! Newly computed values of the accumulators
		iv :  in  std_logic_vector(8*WORD_WIDTH - 1 downto 0); --! Old values of the accumulators
		h_out :  out  std_logic_vector(8*WORD_WIDTH downto 0) --! New intermediate hash value
	);
end entity Last_transformation;

--! @brief Architecture of the last pipeline stage
--! @details In order to make things simpler, aliases are employed to identify operands
architecture RTL of Last_transformation is
	
	--! Computed value for the hash accumulator \f$A\f$
	alias a_acc is h_in(8*WORD_WIDTH - 1 downto 7*WORD_WIDTH);
	--! Computed value for the hash accumulator \f$B\f$
	alias b_acc is h_in(7*WORD_WIDTH - 1 downto 6*WORD_WIDTH);
	--! Computed value for the hash accumulator \f$C\f$
	alias c_acc is h_in(6*WORD_WIDTH - 1 downto 5*WORD_WIDTH);
	--! Computed value for the hash accumulator \f$D\f$
	alias d_acc is h_in(5*WORD_WIDTH - 1 downto 4*WORD_WIDTH);
	--! Computed value for the hash accumulator \f$E\f$
	alias e_acc is h_in(4*WORD_WIDTH - 1 downto 3*WORD_WIDTH);
	--! Computed value for the hash accumulator \f$F\f$
	alias f_acc is h_in(3*WORD_WIDTH - 1 downto 2*WORD_WIDTH);
	--! Computed value for the hash accumulator \f$G\f$
	alias g_acc is h_in(2*WORD_WIDTH - 1 downto WORD_WIDTH);
	--! Computed value for the hash accumulator \f$H\f$
	alias h_acc is h_in(WORD_WIDTH - 1 downto 0);
	--! Old value for the hash accumulator \f$A\f$
	alias a_iv is iv(8*WORD_WIDTH - 1 downto 7*WORD_WIDTH);
	--! Old value for the hash accumulator \f$B\f$
	alias b_iv is iv(7*WORD_WIDTH - 1 downto 6*WORD_WIDTH);
	--! Old value for the hash accumulator \f$C\f$
	alias c_iv is iv(6*WORD_WIDTH - 1 downto 5*WORD_WIDTH);
	--! Old value for the hash accumulator \f$D\f$
	alias d_iv is iv(5*WORD_WIDTH - 1 downto 4*WORD_WIDTH);
	--! Old value for the hash accumulator \f$E\f$
	alias e_iv is iv(4*WORD_WIDTH - 1 downto 3*WORD_WIDTH);
	--! Old value for the hash accumulator \f$F\f$
	alias f_iv is iv(3*WORD_WIDTH - 1 downto 2*WORD_WIDTH);
	--! Old value for the hash accumulator \f$G\f$
	alias g_iv is iv(2*WORD_WIDTH - 1 downto WORD_WIDTH);
	--! Old value for the hash accumulator \f$H\f$
	alias h_iv is iv(WORD_WIDTH - 1 downto 0);
	--! New value for the hash accumulator \f$A\f$
	alias a_new is h_out(8*WORD_WIDTH - 1 downto 7*WORD_WIDTH);
	--! New value for the hash accumulator \f$B\f$
	alias b_new is h_out(7*WORD_WIDTH - 1 downto 6*WORD_WIDTH);
	--! New value for the hash accumulator \f$C\f$
	alias c_new is h_out(6*WORD_WIDTH - 1 downto 5*WORD_WIDTH);
	--! New value for the hash accumulator \f$D\f$
	alias d_new is h_out(5*WORD_WIDTH - 1 downto 4*WORD_WIDTH);
	--! New value for the hash accumulator \f$E\f$
	alias e_new is h_out(4*WORD_WIDTH - 1 downto 3*WORD_WIDTH);
	--! New value for the hash accumulator \f$F\f$
	alias f_new is h_out(3*WORD_WIDTH - 1 downto 2*WORD_WIDTH);
	--! New value for the hash accumulator \f$G\f$
	alias g_new is h_out(2*WORD_WIDTH - 1 downto WORD_WIDTH);
	--! New value for the hash accumulator \f$H\f$
	alias h_new is h_out(WORD_WIDTH - 1 downto 0);
	
begin
	
	a_new   <= std_logic_vector(unsigned(a_acc) + unsigned(a_iv));
	b_new   <= std_logic_vector(unsigned(b_acc) + unsigned(b_iv));
	c_new   <= std_logic_vector(unsigned(c_acc) + unsigned(c_iv));
	d_new   <= std_logic_vector(unsigned(d_acc) + unsigned(d_iv));
	e_new   <= std_logic_vector(unsigned(e_acc) + unsigned(e_iv));
	f_new   <= std_logic_vector(unsigned(f_acc) + unsigned(f_iv));
	g_new   <= std_logic_vector(unsigned(g_acc) + unsigned(g_iv));
	h_new   <= std_logic_vector(unsigned(h_acc) + unsigned(h_iv));
	
	h_out(8*WORD_WIDTH) <= h_in (8*WORD_WIDTH);
	
end architecture RTL;