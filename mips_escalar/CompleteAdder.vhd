library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity CompleteAdder is
	port (A,B,Cin: in std_logic;
	S,Cout: out std_logic);
end CompleteAdder;

architecture arch_CompleteAdder of CompleteAdder is
	begin
	S <= (A XOR B) XOR Cin;
	Cout <= (A AND B) OR (Cin AND (A XOR B));	
end arch_CompleteAdder;