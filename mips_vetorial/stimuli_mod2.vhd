library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.alu_types_pack.all;

entity stimuli_vector_alu is
	port
	(A_stim, B_stim 			: out reg_vector;
		ALU_op_stim 			: out ALU_operation;
	);

end stimuli_vector_alu ;

architecture test of stimuli_vector_alu  is
	constant TIME_DELTA : time := 100 ps;


begin

simulation : process

procedure check_vector_alu(constant a, b: in INTEGER; c : in ALU_operation) is
begin
	for i in 0 to 31 loop
		A_stim(i) <= std_logic_vector(to_unsigned(a,ADDRESS'length));
		B_stim(i) <= std_logic_vector(to_unsigned(b,ADDRESS'length));
	end loop;
	
	ALU_op_stim <= c;

wait for TIME_DELTA;
end procedure check_vector_alu;

begin
-- Test vectors application

check_vector_alu(2147483648, 1073741824, sum);
check_vector_alu(2147483648, 1073741824, subtract);
check_vector_alu(1073741824, 2147483648, lessthan); --false
check_vector_alu(2147483648, 1073741824, lessthan); --true
check_vector_alu(1431655765, 1, shiftleft);  --result: 2863311530
check_vector_alu(1717986918, 3435973836, logic_and); 
check_vector_alu(1717986918, 3435973836, logic_or);  
check_vector_alu(1717986918, 3435973836, nop);  



wait;
end process simulation;
end architecture test;