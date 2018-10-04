library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Multiplexer4x1_32 is
	port (I0,I1,I2,I3: in std_logic_vector (31 downto 0);
	Sel: in std_logic_vector (1 downto 0);
	O: out std_logic_vector (31 downto 0));
end Multiplexer4x1_32;

architecture arch_Multiplexer4x1_32 of Multiplexer4x1_32 is
	signal Mux_resulti: std_logic_vector (31 downto 0);
	begin
	process(Sel,I0,I1,I2,I3)
	begin
		case Sel is
		when "00" =>
			O <= I0;
		when "01" =>
			O <= I1;
		when "10" =>
			O <= I2;
		when "11" =>
			O <= I3;
		when others =>
			O <= x"00000000";
		end case;
	end process;
end arch_Multiplexer4x1_32;
