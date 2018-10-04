library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ShiftLeft_26 is
	port (I: in std_logic_vector (25 downto 0);
	O: out std_logic_vector (27 downto 0));
end ShiftLeft_26;

architecture arch_ShiftLeft_26 of ShiftLeft_26 is
	begin
	O(27 downto 2) <= I(25 downto 0);
	O(1 downto 0) <= "00";
end arch_ShiftLeft_26;
