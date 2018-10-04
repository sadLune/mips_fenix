library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all; 
use IEEE.STD_LOGIC_ARITH.all;


entity MEM_WB_Buffer is
    port(
		read_data_in	: in std_logic_vector(31 downto 0);
		address_in			: in std_logic_vector(31 downto 0);	
		MEM_WB_OPcode_in		: in std_logic_vector (5 downto 0);
		read_data_out	: out std_logic_vector(31 downto 0);
		address_out			: out std_logic_vector(31 downto 0);
		MEM_WB_OPcode_out		: out std_logic_vector (5 downto 0);
		-- controle forwarding
		memread_in : in std_logic;
		memread_out : out std_logic;
	
		--controle WB
		jumpandlink_in, memtoreg_in, regwrite_in	: in std_logic;
		regdest_in	:	in std_logic_vector(1 downto 0);
		inst_20_11_in	: in std_logic_vector(20 downto 11);
		jumpandlink_out, memtoreg_out, regwrite_out	: out std_logic;
		regdest_out	:	out std_logic_vector(1 downto 0);
		inst_20_11_out	: out std_logic_vector(20 downto 11);
		
		enable, CLK, RST	: in STD_LOGIC
        );
end MEM_WB_Buffer;

architecture behavioral of MEM_WB_Buffer is
begin
    process (enable,CLK, RST)
    begin
	if RST = '1' then 
		-- controle forwarding
		memread_out <= '0';
		--controle WB  
		
		regwrite_out	<= '0';
		jumpandlink_out	<= '0';
		memtoreg_out	<= '0';			
	elsif enable = '1' then
		if CLK'event and CLK = '1' then 
			read_data_out <= read_data_in;
			address_out <= address_in;
			-- controle forwarding
			memread_out <= memread_in;	
			--controle WB
			regwrite_out <= regwrite_in;
			jumpandlink_out <= jumpandlink_in;
			memtoreg_out <= memtoreg_in;
			regdest_out		<= regdest_in;
			inst_20_11_out <= inst_20_11_in;  
			MEM_WB_OPcode_out <= MEM_WB_OPcode_in;
		end if;
	end if;
    end process;
end behavioral;
