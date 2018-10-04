library ieee;
use ieee.std_logic_1164.all;

entity OrC is
	port (A,B: in std_logic;
	O: out std_logic);
end OrC;

architecture arch_OrC of OrC is
	begin
	O <= A or B;
end arch_OrC;