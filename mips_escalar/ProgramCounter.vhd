library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ProgramCounter is
	port (I: in std_logic_vector (31 downto 0);
	clock, reset, enable, flush: in std_logic;
	O: out std_logic_vector (31 downto 0));
end ProgramCounter;

architecture arch_ProgramCounter of ProgramCounter is
	signal aux, old_I: std_logic_vector (31 downto 0);
	begin
	process(clock,I,reset,enable, flush)
	begin
		if reset = '1' then
			aux <= x"00000000";
		elsif flush'event and flush = '1' then
			aux <= old_I;
		elsif enable = '1' then
			if Clock'event and Clock ='1' then
				old_I <= aux;
				aux <= I;
			end if;
		end if;
	
	--begin
--		if reset = '0' then
--			if enable = '1' then
--				if Clock'event and Clock ='1' then
--					aux <= I;
--				end if;
--			end if;
--		elsif reset = '1' then
--			aux <= x"00000000";
--		end if;
	end process;
		O <= aux;
end arch_ProgramCounter;