library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Multiplexer2x1_1 is
	port (I0,I1: in std_logic;
	Sel: in std_logic;
	O: out std_logic);
end Multiplexer2x1_1;

architecture arch_Multiplexer2x1_1 of Multiplexer2x1_1 is
	signal Mux_resulti: std_logic;
	begin
	process(Sel,I0,I1)
	begin
		case Sel is
		when '0' =>
			O <= I0;
		when '1' =>
			O <= I1;
		when others =>
			O <= '0';
		end case;
	end process;
end arch_Multiplexer2x1_1;
