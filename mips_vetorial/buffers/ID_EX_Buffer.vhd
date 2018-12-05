library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all; 
use IEEE.STD_LOGIC_ARITH.all;


entity ID_EX_Buffer is
    port(
		
		reg1_in, reg2_in	: in std_logic_vector(31 downto 0);
		inst_15_0_ext_in	: in std_logic_vector(31 downto 0);
		ID_EX_OPcode_in		: in std_logic_vector (5 downto 0);
		reg1_out, reg2_out	: out std_logic_vector(31 downto 0);
		inst_15_0_ext_out	: out std_logic_vector(31 downto 0);
		ID_EX_OPcode_out	: out std_logic_vector (5 downto 0);
		
		--controle EX
		alusrc_in			: in std_logic_vector(1 downto 0);
		aluop_in			: in ALU_operation;
		mult_in				: in std_logic;
		alusrc_out			: out std_logic_vector(1 downto 0);
		aluop_out			: out ALU_operation;
		mult_out			: out std_logic;
		
		--controle MEM
		--memwrite_in, memread_in 	: in std_logic;
		--memwrite_out, memread_out 	: out std_logic;
		
		--controle WB
		jumpandlink_in, regwrite_in	: in std_logic;
		--memtoreg_in	: in std_logic;
		regdest_in	:	in std_logic_vector(1 downto 0);
		inst_25_6_in	: in std_logic_vector(25 downto 6);
		jumpandlink_out, regwrite_out	: out std_logic;
		--memtoreg_out	: out std_logic;
		regdest_out	:	out std_logic_vector(1 downto 0);
		inst_25_6_out	: out std_logic_vector(25 downto 6);
		
		enable, CLK, RST	: in STD_LOGIC
        );
end ID_EX_Buffer;

architecture behavioral of ID_EX_Buffer is
begin
    process (enable,CLK, RST)
    begin
	if RST = '1' then
		--controle EX
		alusrc_out		<= (others => '0');
		aluop_out		<= (others => '0');
		mult_out		<= '0';
		--controle MEM
		--memwrite_out	<= '0';
		--memread_out 	<= '0';
		--controle WB
		regwrite_out	<= '0';
		jumpandlink_out	<= '0';
		--memtoreg_out	<= '0';
	
	elsif enable = '1' then
		if CLK'event and CLK = '1' then 
			
			reg1_out <= reg1_in;
			reg2_out <= reg2_in;
			inst_15_0_ext_out <= inst_15_0_ext_in;
			
			--controle EX
			alusrc_out <= alusrc_in;
			aluop_out <= aluop_in;
			mult_out <= mult_in;
			
			--controle MEM
			--memwrite_out <= memwrite_in;
			--memread_out <= memread_in;
			
			--controle WB
			regwrite_out <= regwrite_in;
			jumpandlink_out <= jumpandlink_in;
			--memtoreg_out <= memtoreg_in;
			regdest_out		<= regdest_in;
			inst_25_6_out <= inst_25_6_in;	 
			ID_EX_OPcode_out <= ID_EX_OPcode_in;
		end if;
	end if;
    end process;
end behavioral;
