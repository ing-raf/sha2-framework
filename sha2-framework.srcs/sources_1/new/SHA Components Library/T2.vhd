--! @file T2.vhd
--! @brief \f$T_2\f$ step function entity definition and implementation

--! Standard library 
library ieee;
--! Standard 9-values logic library 
use ieee.std_logic_1164.all;
--! Arithmetic library, included for the unsigned modulo addition 
use ieee.numeric_std.all;

--! @brief \f$T_2\f$ step function block
--! @details This component computes the function
--! \f[ {T_2}_t = \Sigma_0\left(A_t\right) + Maj\left(A_t,B_t,C_t\right) \quad \forall t\in\left[0,R-1\right] \f]
entity T2 is
	generic (
		WORD_WIDTH : natural := 32 --! Width of the words of the Compressor
	);
	port(
		--! Input \f$A\f$ to the step function block
		a : in std_logic_vector(WORD_WIDTH - 1 downto 0);
		--! Input \f$B\f$ to the step function block
		b : in std_logic_vector(WORD_WIDTH - 1 downto 0);
		--! Input \f$C\f$ to the step function block
		c : in std_logic_vector(WORD_WIDTH - 1 downto 0);
		--! Output of the step function block
		o : out std_logic_vector(WORD_WIDTH - 1 downto 0)
	);
end entity T2;

--! Architecture of the \f$T_2\f$ step function block
architecture RTL of T2 is

	--! Output of the \f$\Sigma_0\f$ function block
	signal Sigma_0_o : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
	--! Output of the \f$Maj\f$ function block
	signal Maj_o : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');

begin
	
	--! \f$\Sigma_0\f$ function block
	sigma : entity work.Sigma_0
		generic map (
			WORD_WIDTH => WORD_WIDTH
		)
		port map(
			x => a,
			o => Sigma_0_o
		);
	
	--! \f$Maj\f$ function block	
	maj : entity work.Majority
		generic map(
			width => WORD_WIDTH
		)
		port map(
			x => a,
			y => b,
			z => c,
			o => Maj_o
		);
	
	o <= std_logic_vector(unsigned(Sigma_0_o) + unsigned(Maj_o));

end architecture RTL;
