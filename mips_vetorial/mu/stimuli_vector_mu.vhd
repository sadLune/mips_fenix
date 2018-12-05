library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.alu_types_pack.all;

entity stimuli_vector_mu is
	port
	(A_stim, B_stim 							: out reg_vector_frag;
		Enable_stim,Clock_stim,Reset_stim 		: out std_logic
	);

end stimuli_vector_mu ;

architecture test of stimuli_vector_mu  is
	constant TIME_DELTA : time := 100 ps;


begin

simulation : process

procedure check_vector_mu(clock, en, rst : in std_logic; constant a, b: in INTEGER) is
begin
	for i in 0 to 3 loop
		A_stim(i) <= std_logic_vector(to_unsigned(a,A_stim(i)'length));
		B_stim(i) <= std_logic_vector(to_unsigned(b,B_stim(i)'length));
	end loop;
	
	Clock_stim <= clock;
	Enable_stim <= en;
	Reset_stim <= rst;

wait for TIME_DELTA;
end procedure check_vector_mu;

begin
-- Test vectors application

--check_vector_mu('1', '1', '1', 65535, 65535);
--check_vector_mu('0', '1', '0', 65535, 65535);
--check_vector_mu('1', '1', '0', 65535, 65535);
--check_vector_mu('0', '1', '0', 65535, 65535);
--check_vector_mu('1', '1', '0', 65535, 65535);
--check_vector_mu('0', '1', '0', 65535, 65535);
--check_vector_mu('1', '1', '0', 65535, 65535);
--check_vector_mu('0', '1', '0', 65535, 65535);
--check_vector_mu('1', '1', '0', 65535, 65535);

check_vector_mu('1', '1', '1', 3, 5);
check_vector_mu('0', '1', '0', 3, 5);
check_vector_mu('1', '1', '0', 3, 5);
check_vector_mu('0', '1', '0', 3, 5);
check_vector_mu('1', '1', '0', 3, 5);
check_vector_mu('0', '1', '0', 3, 5);
check_vector_mu('1', '1', '0', 3, 5);
check_vector_mu('0', '1', '0', 3, 5);
check_vector_mu('1', '1', '0', 3, 5);

wait;
end process simulation;
end architecture test;