library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all; 
use IEEE.STD_LOGIC_ARITH.all;

entity EX_MEM_Buffer is
    port(
		reg2_in, alu_in		: in std_logic_vector(31 downto 0);
		EX_MEM_OPcode_in	: in std_logic_vector (5 downto 0);
		reg2_out, alu_out	: out std_logic_vector(31 downto 0);
		EX_MEM_OPcode_out	: out std_logic_vector (5 downto 0);
	
		--controle MEM
		memwrite_in, memread_in 	: in std_logic;
		memwrite_out, memread_out 	: out std_logic;
		
		--controle WB
		jumpandlink_in, memtoreg_in, regwrite_in	: in std_logic;
		regdest_in	:	in std_logic_vector(1 downto 0);
		inst_20_11_in	: in std_logic_vector(20 downto 11);
		jumpandlink_out, memtoreg_out, regwrite_out	: out std_logic;
		regdest_out	:	out std_logic_vector(1 downto 0);
		inst_20_11_out	: out std_logic_vector(20 downto 11);
		
		enable, CLK, RST	: in STD_LOGIC
        );
end EX_MEM_Buffer;

architecture behavioral of EX_MEM_Buffer is
begin
    process (enable,CLK, RST)
    begin
	if RST = '1' then
		alu_out <= (others => '0');
		--controle MEM
		memwrite_out	<= '0';
		memread_out 	<= '0';
		--controle WB
		regwrite_out	<= '0';
		jumpandlink_out	<= '0';
		memtoreg_out	<= '0';
		
	elsif enable = '1' then
		if CLK'event and CLK = '1' then 
			reg2_out <= reg2_in;
			alu_out  <= alu_in;
		
			--controle MEM
			memwrite_out <= memwrite_in;
			memread_out <= memread_in;
			
			--controle WB
			regwrite_out <= regwrite_in;
			jumpandlink_out <= jumpandlink_in;
			memtoreg_out <= memtoreg_in;
			regdest_out		<= regdest_in;
			inst_20_11_out <= inst_20_11_in;
			EX_MEM_OPcode_out <= EX_MEM_OPcode_in;
		end if;
	end if;
    end process;
end behavioral;
