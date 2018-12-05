library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all; 
use IEEE.STD_LOGIC_ARITH.all;


entity IF_ID_Buffer is
    port(pc_in, instruction_in, pc_plus4_in	: in std_logic_vector(31 downto 0);
		enable, CLK, RST, flush, flush2 : in STD_LOGIC;
		pc_out, instruction_out, pc_plus4_out : out std_logic_vector(31 downto 0)
        );
end IF_ID_Buffer;

architecture behavioral of IF_ID_Buffer is
signal old_instruction, instruction_outi : std_logic_vector(31 downto 0);
begin
    process (enable,CLK, RST, flush)
    begin
	if RST = '1' then
		pc_out 			<= (others => '0');
		instruction_outi <= (others => '0'); 
		pc_plus4_out <= (others => '0');
	elsif flush'event and flush = '1' then
		instruction_outi <= old_instruction;
		
	elsif enable = '1' then
		if CLK'event and CLK = '1' then	
			if flush2 = '0' then
				pc_plus4_out <= pc_plus4_in;
				pc_out <= pc_in;
				old_instruction <= instruction_outi;
				instruction_outi <= instruction_in;
			else 
				pc_plus4_out <= x"00000000";
				pc_out <= x"00000000";
				old_instruction <= x"00000000";
				instruction_outi <= x"00000000";
			end if;
 
		end if;
	end if;
    end process;
	instruction_out <= instruction_outi;
end behavioral;
