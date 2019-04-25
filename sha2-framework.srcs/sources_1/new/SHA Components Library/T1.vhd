--! @file T1.vhd
--! @brief \f$T_1\f$ step function entity definition and implementation

--! Standard library 
library ieee;
--! Standard 9-values logic library 
use ieee.std_logic_1164.all;
--! Arithmetic library, included for the unsigned modulo addition 
use ieee.numeric_std.all;

--! @brief \f$T_1\f$ step function block
--! @details This component computes the function
--! \f[ {T_1}_t = H_t + \Sigma_1\left(E_t\right) + Ch\left(E_t, F_t, G_t\right) + K_t + W_t \quad \forall t\in\left[0,R-1\right] \f]
entity T1 is
	generic (
		WORD_WIDTH : natural := 32
	);
	port(
		--! Input \f$E\f$ to the step function block
		e : in  std_logic_vector(WORD_WIDTH - 1 downto 0);
		--! Input \f$F\f$ to the step function block
		f : in  std_logic_vector(WORD_WIDTH - 1 downto 0);
		--! Input \f$G\f$ to the step function block
		g : in  std_logic_vector(WORD_WIDTH - 1 downto 0);
		--! Input \f$H\f$ to the step function block
		h : in  std_logic_vector(WORD_WIDTH - 1 downto 0);
		--! Constant \f$K\f$ word input to the step function block
		K : in  std_logic_vector(WORD_WIDTH - 1 downto 0);
		--! Expanded message word input to the step function block
		W : in  std_logic_vector(WORD_WIDTH - 1 downto 0);
		--! Output of the step function block
		o : out std_logic_vector(WORD_WIDTH - 1 downto 0)
	);
end entity T1;

--! Architecture of the \f$T_1\f$ step function block
architecture RTL of T1 is
	
	--! Output of the \f$\Sigma_1\f$ function block
	signal Sigma_1_o : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
	--! Output of the \f$Ch\f$ function block
	signal Ch_o : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');

begin

	--! \f$\Sigma_1\f$ function block
	sigma : entity work.Sigma_1
		generic map(
			WORD_WIDTH => WORD_WIDTH
		)
		port map(
			x => e,
			o => Sigma_1_o
		);

	--! \f$Ch\f$ function block
	choose : entity work.Choose
		generic map(
			width => WORD_WIDTH
		)
		port map(
			x => e,
			y => f,
			z => g,
			o => Ch_o
		);

	o <= std_logic_vector(unsigned(h) + unsigned(Sigma_1_o) + unsigned(Ch_o) + unsigned(K) + unsigned(W));

end architecture RTL;
