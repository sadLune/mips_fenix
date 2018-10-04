library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Add is
	port (I1,I2: in std_logic_vector (31 downto 0);
	O: out std_logic_vector (31 downto 0));
end Add;

architecture arch_Add of Add is
	begin
	O <= std_logic_vector(unsigned(I1) + unsigned(I2));
end arch_Add;