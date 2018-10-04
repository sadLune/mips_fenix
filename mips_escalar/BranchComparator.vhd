 library IEEE;
use IEEE.STD_LOGIC_1164.all;	 

entity BranchComparator is
	port (op_code: in STD_LOGIC_vector(5 downto 0);
	input1, input2: in STD_LOGIC_vector(31 downto 0);
	branch_taken: out std_logic	
	);
end BranchComparator;


architecture behavioral of BranchComparator is	
begin
	process(op_code, input1, input2)
	begin
		if ((op_code = "000100" and input1 = input2) or (op_code = "000101" and input1 /= input2)) then  -- beq or bneq
			branch_taken <= '1';
		else
			branch_taken <= '0'; 
		end if;
	end process;
end behavioral;