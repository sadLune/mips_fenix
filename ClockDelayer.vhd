library IEEE;
use IEEE.STD_LOGIC_1164.all; 

entity ClockDelayer is
	port (CLK: in STD_LOGIC;
		  CLK_delayed: out STD_LOGIC
	);
end ClockDelayer;

--}} End of automatically maintained section

architecture structural of ClockDelayer is	
begin		
--	process 
--	begin
--		CLK_delayed <= '0';
--		wait for 4 ns;
--		CLK_delayed <= '1';
--		wait for 2 ns;
	process(CLK)
	begin
		if CLK'event and CLK = '1' then
			CLK_delayed <= CLK;-- after 8 ns;	  
		elsif CLK'event and CLK = '0' then
			CLK_delayed <= CLK after 2 ns;	   
		end if;		
	end process;
end structural;