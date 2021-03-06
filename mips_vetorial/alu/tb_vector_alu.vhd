library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.alu_types_pack.all;

entity tb_vector_alu is
end tb_vector_alu;

architecture arch of tb_vector_alu is
--tope
component vector_ALU is
	port( 
		A, B 			: in reg_vector_frag;
		ALU_op 			: in ALU_operation;
		Zero, Overflow 	: out STD_LOGIC_VECTOR(3 downto 0);
		ALU_result 		: out reg_vector_frag
		);
end component;
component stimuli_vector_alu is
	port
	(
		A_stim, B_stim 		: out reg_vector_frag;
		ALU_op_stim 			: out ALU_operation
	);

end component;

signal  A_s, B_s 			:  reg_vector_frag;
signal  ALU_op_s 			:  ALU_operation;
signal  Zero_s, Overflow_s 	:  STD_LOGIC_VECTOR(3 downto 0);
signal  ALU_result_s 		:  reg_vector_frag;


begin

	DP : vector_ALU port map (A_s, B_s, ALU_op_s, Zero_s, Overflow_s, ALU_result_s);
	stimuli : stimuli_vector_alu port map(A_s, B_s, ALU_op_s);
end arch;