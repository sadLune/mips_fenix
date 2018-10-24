library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.alu_types_pack.all;

--arrays 2D
--https://www.nandland.com/vhdl/examples/example-array-type-vhdl.html

entity vector_ALU is
	port( 
		A, B 			: in reg_vector;
		ALU_op 			: in ALU_operation;
		Zero, Overflow 	: out STD_LOGIC_VECTOR(31 downto 0);
		ALU_result 		: out reg_vector
		);
	
end vector_ALU;

architecture arch of vector_ALU is

component ArithmeticLogicUnit is
	port (
		A,B				: in std_logic_vector (31 downto 0);
		ALU_op			: in ALU_operation;
		Zero,Overflow	: out std_logic;
		ALU_result		: out std_logic_vector (31 downto 0)
	);
end component;

begin

gen_alu: 
	for i in 0 to 31 GENERATE
		alu : ArithmeticLogicUnit port map
		(A(i), B(i), ALU_op, Zero(i), Overflow(i), ALU_result(i));
	end GENERATE gen_alu;

end arch;