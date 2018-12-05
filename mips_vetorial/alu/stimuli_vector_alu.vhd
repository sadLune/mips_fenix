library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.alu_types_pack.all;

entity stimuli_vector_alu is
	port
	(
		A_stim, B_stim 			: out reg_vector;
		ALU_op_stim 			: out ALU_operation
	);

end stimuli_vector_alu ;

architecture test of stimuli_vector_alu  is
	constant TIME_DELTA : time := 100 ps;





begin
procedure check_vector_alu(a, b: in std_logic_vector(31 downto 0); c : in ALU_operation) is
begin
	for i in 0 to 31 loop
		A_stim(i) <= a;
		B_stim(i) <= b;
	end loop;
	
	ALU_op_stim <= c;

	wait for 100 ps;
end procedure check_vector_alu;
process
begin



-- Test vectors application

check_vector_alu("01000000000000000000000000000000", "00100000000000000000000000000000", sum);
check_vector_alu("01000000000000000000000000000000", "00100000000000000000000000000000", subtract);
check_vector_alu("00100000000000000000000000000000", "01000000000000000000000000000000", lessthan); --false
check_vector_alu("01000000000000000000000000000000", "00100000000000000000000000000000", lessthan); --true
check_vector_alu("01010101010101010101010101010101", "00000000000000000000000000000001", shiftleft);  --result: 2863311530
check_vector_alu("01100110011001100110011001100110", "00110011001100110011001100110011", logic_and); 
check_vector_alu("01100110011001100110011001100110", "00110011001100110011001100110011", logic_or);  
check_vector_alu("01100110011001100110011001100110", "00110011001100110011001100110011", nop);  



wait;
end process;
end architecture test;