library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.alu_types_pack.all;

entity vector_MU is
	port( 
		A, B 			: in reg_vector;
		Enable,Clock,Reset: in std_logic;
		Overflow 	: out STD_LOGIC_VECTOR(31 downto 0);
		Executando,Ready: out std_logic;
		O 		: out reg_vector
		);
	
end vector_MU;

architecture arch of vector_MU is

component MultiplicationUnit is
	port (
		A,B: in std_logic_vector (31 downto 0);
		Enable,Clock,Reset: in std_logic;
		Overflow,Executando,Ready: out std_logic;
		O: out std_logic_vector (31 downto 0)
	);
end component;

	signal Executandoi, Readyi : std_logic_vector(31 downto 0);
begin

gen_mu: 
	for i in 0 to 31 GENERATE
		mu : MultiplicationUnit port map
		(A(i), B(i), Enable, Clock, Reset, Overflow(i), Executandoi(i), Readyi(i), O(i));
	end GENERATE gen_mu;
	
	Executando <= OR Executandoi(i);
	Ready <= OR Readyi(i);

end arch;