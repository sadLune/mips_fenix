library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.alu_types_pack.all;

entity stimuli_vector_mu is
	port
	(A_stim, B_stim 							: out reg_vector;
		Enable_stim,Clock_stim,Reset_stim 		: out std_logic
	);

end stimuli_vector_mu ;

architecture test of stimuli_vector_mu  is
	constant TIME_DELTA : time := 100 ps;


begin

simulation : process

procedure check_vector_mu(clock, en, rst : in std_logic; a, b: in std_logic_vector(31 downto 0)) is
begin
	for i in 0 to 31 loop
		A_stim(i) <= a;
		B_stim(i) <= b;
	end loop;
	
	Clock_stim <= clock;
	Enable_stim <= en;
	Reset_stim <= rst;

wait for TIME_DELTA;
end procedure check_vector_mu;

begin
-- Test vectors application

check_vector_mu('1', '1', '1', "00000000000000000000000000000000", "00000000000000000000000000000000");
check_vector_mu('0', '1', '0', "00000000000000000000000000000000", "00000000000000000000000000000000");
check_vector_mu('1', '1', '0', "00000000000000000000000000000000", "00000000000000000000000000000000");
check_vector_mu('0', '1', '0', "00000000000000000000000000000000", "00000000000000000000000000000000");
check_vector_mu('1', '1', '0', "00000000000000000000000000000000", "00000000000000000000000000000000");
check_vector_mu('0', '1', '0', "00000000000000000000000000000000", "00000000000000000000000000000000");
check_vector_mu('1', '1', '0', "00000000000000000000000000000000", "00000000000000000000000000000000");
check_vector_mu('0', '1', '0', "00000000000000000000000000000000", "00000000000000000000000000000000");
check_vector_mu('1', '1', '0', "00000000000000000000000000000000", "00000000000000000000000000000000");

wait;
end process simulation;
end architecture test;