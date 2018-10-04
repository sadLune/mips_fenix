library ieee;
use ieee.std_logic_1164.all;

entity NotC is
	port (A: in std_logic;
	O: out std_logic);
end NotC;

architecture arch_NotC of NotC is
	begin
	O <= not A;
end arch_NotC;