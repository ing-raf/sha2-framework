library ieee;
use ieee.std_logic_1164.all;
--! Standard math library, required for the log function
use ieee.math_real.all;

package utils is
	type CONFIGURABLE_ROM is array(natural range <>) of std_logic_vector;

	function cycles_per_stage (width : natural; stages : natural; uf : natural) return natural;
	--! @details To be compatible with Xilinx ISim, it is appropriate to return -1 if the argument of the log2 function equals 0
	function bits_to_encode(x : natural) return integer;
	function rom_content (word : natural; cps: natural; uf : natural; stage : natural; pf : natural := 0) return CONFIGURABLE_ROM;
			
end package utils;

package body utils is

	function cycles_per_stage (width : natural; stages : natural; uf : natural) return natural is
	begin
		if (width = 256) then
			return 64 / (stages * uf);
		elsif (width = 512) then
			return 80 / (stages * uf);
		end if;
	end function;
	
	function bits_to_encode(x : natural) return integer is
	begin
		if (x = 1) then
			return -1;
		else
			return integer(log2(real(x - 1)));
		end if;
	end function;
		
	
	function rom_content (word : natural; cps: natural; uf : natural; stage : natural; pf : natural := 0) return CONFIGURABLE_ROM is
		constant ROM_CONTENT : CONFIGURABLE_ROM(79 downto 0)(63 downto 0) := (
			x"6c44198c4a475817", x"5fcb6fab3ad6faec", x"597f299cfc657e2a", x"4cc5d4becb3e42b6", x"431d67c49c100d4c", x"3c9ebe0a15c9bebc", x"32caab7b40c72493", x"28db77f523047d84",
			x"1b710b35131c471b", x"113f9804bef90dae", x"0a637dc5a2c898a6", x"06f067aa72176fba", x"f57d4f7fee6ed178", x"eada7dd6cde0eb1e", x"d186b8c721c0c207", x"ca273eceea26619c",
			x"c67178f2e372532b", x"bef9a3f7b2c67915", x"a4506cebde82bde9", x"90befffa23631e28", x"8cc702081a6439ec", x"84c87814a1f0ab72", x"78a5636f43172f60", x"748f82ee5defb2fc",
			x"682e6ff3d6b2b8a3", x"5b9cca4f7763e373", x"4ed8aa4ae3418acb", x"391c0cb3c5c95a63", x"34b0bcb5e19b48a8", x"2748774cdf8eeb99", x"1e376c085141ab53", x"19a4c116b8d2d0c8",
			x"106aa07032bbd1b8", x"f40e35855771202a", x"d69906245565a910", x"d192e819d6ef5218", x"c76c51a30654be30", x"c24b8b70d0f89791", x"a81a664bbc423001", x"a2bfe8a14cf10364",
			x"92722c851482353b", x"81c2c92e47edaee6", x"766a0abb3c77b2a8", x"650a73548baf63de", x"53380d139d95b3df", x"4d2c6dfc5ac42aed", x"2e1b21385c26c926", x"27b70a8546d22ffc",
			x"142929670a0e6e70", x"06ca6351e003826f", x"d5a79147930aa725", x"c6e00bf33da88fc2", x"bf597fc7beef0ee4", x"b00327c898fb213f", x"a831c66d2db43210", x"983e5152ee66dfab",
			x"76f988da831153b5", x"5cb0a9dcbd41fbd4", x"4a7484aa6ea6e483", x"2de92c6f592b0275", x"240ca1cc77ac9c65", x"0fc19dc68b8cd5b5", x"efbe4786384f25e3", x"e49b69c19ef14ad2",
			x"c19bf174cf692694", x"9bdc06a725c71235", x"80deb1fe3b1696b1", x"72be5d74f27b896f", x"550c7dc3d5ffb4e2", x"243185be4ee4b28c", x"12835b0145706fbe", x"d807aa98a3030242",
			x"ab1c5ed5da6d8118", x"923f82a4af194f9b", x"59f111f1b605d019", x"3956c25bf348b538", x"e9b5dba58189dbbc", x"b5c0fbcfec4d3b2f", x"7137449123ef65cd", x"428a2f98d728ae22"      					
		);		
		variable selected_rom_content : CONFIGURABLE_ROM (cps - 1 downto 0)((uf * word) - 1 downto 0);
	begin
		for i in cps - 1 downto 0 loop
			for j in uf - 1 downto 0 loop
				selected_rom_content(i)(((j + 1) * word) - 1 downto j * word) := ROM_CONTENT((stage * cps * uf + (i * uf) + (pf * uf) + j) mod 80)(63 downto 64-word);
			end loop;
		end loop;
		return selected_rom_content;
	end function;

end package body utils;
