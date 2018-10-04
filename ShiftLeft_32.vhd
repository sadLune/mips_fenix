library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ShiftLeft_32 is
	port (I: in std_logic_vector (31 downto 0);
	O: out std_logic_vector (31 downto 0));
end ShiftLeft_32;

architecture arch_ShiftLeft_32 of ShiftLeft_32 is
	begin
	O(31 downto 2) <= I(29 downto 0);
	O(1 downto 0) <= "00";
end arch_ShiftLeft_32;
