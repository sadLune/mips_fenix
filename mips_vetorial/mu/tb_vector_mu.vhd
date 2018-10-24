library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.alu_types_pack.all;

entity tb_vector_mu is
end tb_vector_mu;

architecture arch of tb_vector_alu is
--tope
component vector_MU is
	port( 
		A, B 			: in reg_vector;
		Enable,Clock,Reset: in std_logic;
		Overflow 	: out STD_LOGIC_VECTOR(31 downto 0);
		Executando,Ready: out std_logic;
		O 		: out reg_vector
		);
end component;
component stimuli_vector_mu is
	port
	(A_stim, B_stim 							: out reg_vector;
		Enable_stim,Clock_stim,Reset_stim 		: out std_logic
	);
end component;

signal  A_s, B_s 					:  reg_vector;
signal  Enable_s,Clock_s,Reset_s	:  std_logic;
signal  Overflow_s		 			:  STD_LOGIC_VECTOR(31 downto 0);
signal	Executando_s,Ready_s		:  std_logic;
signal  MU_result_s 				:  reg_vector;


begin

	DP : vector_MU port map (A_s, B_s, Enable_s, Clock_s, Reset_s, Overflow_s, Executando_s,  Ready_s, MU_result_s);
	stimuli : stimuli_vector_mu port map(A_s, B_s, Enable_s, Clock_s, Reset_s);
	
end arch;