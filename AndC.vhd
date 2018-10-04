library ieee;
use ieee.std_logic_1164.all;

entity AndC is
	port (A,B: in std_logic;
	O: out std_logic);
end AndC;

architecture arch_AndC of AndC is
	begin
	O <= A and B;
end arch_AndC;