library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SignExtend is
	port (I: in std_logic_vector (15 downto 0);
	O: out std_logic_vector (31 downto 0));
end SignExtend;

architecture arch_SignExtend of SignExtend is
	begin
	process(I)
	begin
		if I(15) = '0' then
			O(31 downto 16) <= "0000000000000000";
			O(15 downto 0) <= I;
		elsif I(15) = '1' then
			O(31 downto 16) <= "1111111111111111";
			O(15 downto 0) <= I;
		end if;
	end process;
end arch_SignExtend;

