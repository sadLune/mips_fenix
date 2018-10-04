library IEEE;
use IEEE.numeric_bit.all;
use IEEE.STD_LOGIC_1164.ALL;   
USE ieee.std_logic_unsigned.ALL;

entity RegisterBank is
	generic(n_reg	: integer := 5;
			n_bits	: integer :=32);
			
	Port(Read_reg_1	: in  std_logic_vector(n_reg-1 downto 0);
		Read_reg_2	: in  std_logic_vector(n_reg-1 downto 0);
		Write_reg	: in  std_logic_vector(n_reg-1 downto 0);
		Write_data	: in  std_logic_vector(n_bits-1 downto 0);
		Reg_write	: in  std_logic;
		Reset		: in  std_logic;
		Clock		: in  std_logic;
		Read_data_1	: out std_logic_vector(n_bits-1 downto 0);
		Read_data_2	: out std_logic_vector(n_bits-1 downto 0));
end RegisterBank;

architecture arch_RegisterBank of RegisterBank is
type reg_file is array (2**n_reg-1 downto 0) of std_logic_vector(n_bits-1 downto 0);
signal regarray: reg_file; 
begin
process(Read_reg_1,Read_reg_2,Write_reg,Write_data,Reg_write,Reset,Clock)
variable addr_1,addr_2,addr_w:integer;
begin

if Reset = '0' then
	if Clock'event and Clock ='0' then						
		if (Reg_write = '1') then --?Ve se o sinal de escrita esta ativo
			regarray(conv_integer(Write_reg)) <= Write_data;--Escreve o dado 
		end if;
	end if;
elsif Reset = '1' then
	regarray(0) <= x"00000000";
	regarray(1) <= x"00000000";
	regarray(2) <= x"00000000";
	regarray(3) <= x"00000000";
	regarray(4) <= x"00000000";
	regarray(5) <= x"00000000";
	regarray(6) <= x"00000000";
	regarray(7) <= x"00000000";
	regarray(8) <= x"00000000";
	regarray(9) <= x"00000000";
	regarray(10) <= x"00000000";
	regarray(11) <= x"00000000";
	regarray(12) <= x"00000000";
	regarray(13) <= x"00000000";
	regarray(14) <= x"00000000";
	regarray(15) <= x"00000000";
	regarray(16) <= x"00000000";
	regarray(17) <= x"00000000";
	regarray(18) <= x"00000000";
	regarray(19) <= x"00000000";
	regarray(20) <= x"00000000";
	regarray(21) <= x"00000000";
	regarray(22) <= x"00000000";
	regarray(23) <= x"00000000";
	regarray(24) <= x"00000000";
	regarray(25) <= x"00000000";
	regarray(26) <= x"00000000";
	regarray(27) <= x"00000000";
	regarray(28) <= x"00008000";
	regarray(29) <= x"0000ffff";
	regarray(30) <= x"00007fff";
	regarray(31) <= x"00000000";

end if;
end process;
	Read_data_1 <= regarray(conv_integer(Read_reg_1));--Le registrador 1
	Read_data_2 <= regarray(conv_integer(Read_reg_2));--Le registrador 2
end arch_RegisterBank;
