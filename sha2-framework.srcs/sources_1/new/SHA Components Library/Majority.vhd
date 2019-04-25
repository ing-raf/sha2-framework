--! @file Majority.vhd
--! @brief \f$Maj\f$ entity definition and implementation

--! Standard library
library ieee;
--! Standard 9-values logic library
use ieee.std_logic_1164.all;

--! @brief \f$Maj\f$ function block
--! @details This component computes the function
--! \f[  Maj\left(x,y,z\right) = \left(x \wedge y\right) \oplus \left(x \wedge z\right) \oplus \left(y \wedge z\right) \f]
entity Majority is
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
end entity Majority;

--! Architecture of the \f$Maj\f$ function block
architecture RTL of Majority is
	
begin
	
	o <= (x and y) xor (x and z) xor (y and z);

end architecture RTL;
