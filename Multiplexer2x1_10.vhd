library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Multiplexer2x1_10 is
    port (I0,I1: in std_logic_vector (9 downto 0);
    Sel: in std_logic;
    O: out std_logic_vector (9 downto 0));
end Multiplexer2x1_10;

architecture arch_Multiplexer2x1_10 of Multiplexer2x1_10 is
    signal Mux_resulti: std_logic_vector (9 downto 0);
    begin
    process(Sel,I0,I1)
    begin
        case Sel is
        when '0' =>
            O <= I0;
        when '1' =>
            O <= I1;
        when others =>
            O <= (others=>'0');
        end case;
    end process;
end arch_Multiplexer2x1_10;
