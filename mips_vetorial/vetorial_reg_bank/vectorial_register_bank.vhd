library IEEE;
use IEEE.numeric_bit.all;
use IEEE.STD_LOGIC_1164.ALL;   
USE ieee.std_logic_unsigned.ALL;
use work.alu_types_pack.all;

entity vectorial_register_bank is
	Port(Read_reg_1	: in  std_logic_vector(5 downto 0);
		Read_reg_2	: in  std_logic_vector(5 downto 0);
		Write_reg	: in  std_logic_vector(5 downto 0);
		Write_data	: in  reg_vector;
		Reg_write	: in  std_logic;
		Reset		: in  std_logic;
		Clock		: in  std_logic;
		Read_data_1	: out reg_vector;
		Read_data_2	: out reg_vector);
end vectorial_register_bank;

architecture arch_vectorial_register_bank of vectorial_register_bank is
type reg_file is array (31 downto 0) of reg_vector;
signal reg_file_s: reg_file; 
signal reg_vector_s: reg_vector;
begin
process(Read_reg_1,Read_reg_2,Write_reg,Write_data,Reg_write,Reset,Clock)
begin

if Reset = '0' then
	if Clock'event and Clock ='0' then						
		if (Reg_write = '1') then --?Ve se o sinal de escrita esta ativo
			reg_file_s(conv_integer(Write_reg)) <= Write_data;--Escreve o dado 
		end if;
	end if;
elsif Reset = '1' then
	for i in 0 to 31 loop
		reg_vector_s(i) <= x"00000000";
	end loop;
	for j in 0 to 31 loop
		regarray(j) <= reg_vector_s;
	end loop;
end if;
end process;
	Read_data_1 <= regarray(conv_integer(Read_reg_1));--Le registrador 1
	Read_data_2 <= regarray(conv_integer(Read_reg_2));--Le registrador 2
end arch_vectorial_register_bank;
