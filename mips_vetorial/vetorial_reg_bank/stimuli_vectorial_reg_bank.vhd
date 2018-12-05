library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.alu_types_pack.all;

entity stimuli_vectorial_reg_bank is
	port
	(
		Read_reg_1_stim	: out  std_logic_vector(5 downto 0);
		Read_reg_2_stim	: out  std_logic_vector(5 downto 0);
		Write_reg_stim	: out  std_logic_vector(5 downto 0);
		Write_data_stim	: out  reg_vector;
		Reg_write_stim	: out  std_logic;
		Reset_stim		: out  std_logic;
		Clock_stim		: out  std_logic
	);
end stimuli_vectorial_reg_bank ;

architecture test of stimuli_vectorial_reg_bank  is
	constant TIME_DELTA : time := 100 ps;


begin

simulation : process

procedure check_vectorial_reg_bank(constant read_reg1, read_reg2, write_reg, write_data: in INTEGER; reg_write_e, reset, clock : in std_logic) is
begin
	for i in 0 to 31 loop
		Write_data_stim(i) <= std_logic_vector(to_unsigned(write_data,Write_data_stim(i)'length));
	end loop;
	
	Read_reg_1_stim	<= std_logic_vector(to_unsigned(read_reg1,Read_reg_1_stim'length));
	Read_reg_2_stim <= std_logic_vector(to_unsigned(read_reg2,Read_reg_2_stim'length));
    Write_reg_stim	<= std_logic_vector(to_unsigned(write_reg,Write_reg_stim'length));
	
	Reg_write_stim	<= reg_write_e;
	Reset_stim		<= reset;
	Clock_stim		<= clock;
	
wait for TIME_DELTA;
end procedure check_vectorial_reg_bank;

begin
-- Test vectors application

check_vectorial_reg_bank(14, 15, 14, 1, '1', '1', '0');
check_vectorial_reg_bank(14, 15, 14, 1, '1', '1', '1');
check_vectorial_reg_bank(14, 15, 15, 1, '1', '1', '0');
check_vectorial_reg_bank(14, 15, 15, 1, '1', '1', '1');
check_vectorial_reg_bank(14, 15, 14, 2, '1', '0', '0');
check_vectorial_reg_bank(14, 15, 14, 2, '1', '0', '1');
check_vectorial_reg_bank(14, 15, 15, 2, '1', '0', '0');
check_vectorial_reg_bank(14, 15, 15, 2, '1', '0', '1');
check_vectorial_reg_bank(14, 15, 14, 1, '1', '0', '0');
check_vectorial_reg_bank(14, 15, 14, 1, '1', '0', '1');
check_vectorial_reg_bank(14, 15, 15, 1, '1', '0', '0');
check_vectorial_reg_bank(14, 15, 15, 1, '1', '0', '1');
check_vectorial_reg_bank(14, 15, 14, 65535, '1', '0', '0');
check_vectorial_reg_bank(14, 15, 14, 65535, '1', '0', '1');
check_vectorial_reg_bank(14, 15, 15, 65535, '0', '0', '0');
check_vectorial_reg_bank(14, 15, 15, 65535, '0', '0', '1');
check_vectorial_reg_bank(14, 15, 14, 1, '0', '0', '0');
check_vectorial_reg_bank(14, 15, 14, 1, '0', '0', '1');

wait;
end process simulation;
end architecture test;