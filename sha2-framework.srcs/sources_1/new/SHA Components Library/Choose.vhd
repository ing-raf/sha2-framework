--! @file Choose.vhd
--! @brief \f$Ch\f$ entity definition and implementation

--! Standard library
library ieee;
--! Standard 9-values logic library
use ieee.std_logic_1164.all;

--! @brief \f$Ch\f$ function block
--! @details This component computes the function
--! \f[ Ch\left(x,y,z\right) = \left(x\wedge z\right) \oplus \left(\neg y\wedge z\right) \f]
entity Choose is
	generic(
		width : natural := 32 --! Width of the words of the Compressor
	);
	port(
		--! \f$x\f$ input of the function block
		x : in  std_logic_vector(width - 1 downto 0); 
		--! \f$y\f$ input of the function block
		y : in  std_logic_vector(width - 1 downto 0);
		--! \f$z\f$ input of the function block 
		z : in  std_logic_vector(width - 1 downto 0); 
		--! Output of the function block
		o : out std_logic_vector(width - 1 downto 0) 
	);
end entity Choose;

--! Architecture of the \f$Ch\f$ function block
architecture RTL of Choose is

begin

	o <= (x and y) xor (not x and z);

end architecture RTL;
