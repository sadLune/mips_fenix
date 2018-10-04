library IEEE;
use IEEE.STD_LOGIC_1164.all; 
use IEEE.STD_LOGIC_UNSIGNED.all; 
use IEEE.STD_LOGIC_ARITH.all;

entity ForwardingUnit is
	port (EX_MEM_OP, MEM_WB_OP : in std_logic_vector(5 downto 0);
	EX_MEM_RegWrite, MEM_WB_RegWrite, UC_MemRead, MEM_WB_MemRead, ID_EX_MemWrite, ID_EX_RegWrite, CLK : in STD_LOGIC; 
	EX_MEM_RD, EX_MEM_RT: in STD_LOGIC_Vector(4 downto 0); -- instruction(15,11)
	MEM_WB_RD, MEM_WB_RT : in std_logic_vector(4 downto 0); -- instruction(15,11)
	ID_EX_RS, ID_EX_RT, ID_EX_RD : in std_logic_vector(4 downto 0); -- instruction(25,21), instruction(20-16)
	IF_ID_RS, IF_ID_RT : in std_logic_vector(4 downto 0); -- instruction(25,21), instruction(20-16)
	IM_RS, IM_RT : in std_logic_vector(4 downto 0); -- instruction(25,21), instruction(20-16)
	mux_forward_1, mux_forward_2, mux_forward_3, mux_forward_4: out STD_LOGIC_vector(1 downto 0);
	stall : out std_logic
	);
end ForwardingUnit;


architecture behavioral of ForwardingUnit is	
begin
	process(EX_MEM_RegWrite, MEM_WB_RegWrite, UC_MemRead, EX_MEM_RD, MEM_WB_RD, ID_EX_RS, ID_EX_RT, IF_ID_RS, IF_ID_RT, CLK)
	begin  
		
		if (EX_MEM_RegWrite = '1' and EX_MEM_RD /= "00000" and EX_MEM_RD = ID_EX_RS) or 
			((EX_MEM_OP = "001000" or EX_MEM_OP = "001010") and EX_MEM_RegWrite = '1' and EX_MEM_RT /= "00000" and EX_MEM_RT = ID_EX_RS) then -- Dependencia de dados aritmeticos, tira pós ula e manda para pré ula
			mux_forward_1 <= "01";
		elsif (MEM_WB_RegWrite = '1' and MEM_WB_RD /= "00000" and MEM_WB_RD = ID_EX_RS) or 
			(MEM_WB_RegWrite = '1' and MEM_WB_RT /= "00000" and MEM_WB_RT = ID_EX_RS) or ((MEM_WB_OP = "001000" or MEM_WB_OP = "001010") and MEM_WB_RegWrite = '1' and MEM_WB_RT /= "00000" and MEM_WB_RT = ID_EX_RS) then  -- Dependencia de dados aritmeticos, tira pós memória e manda pré ula
			mux_forward_1 <= "10";
		else
			mux_forward_1 <= "00";
		end if;
			
		if (EX_MEM_RegWrite	= '1' and EX_MEM_RD /= "00000" and EX_MEM_RD = ID_EX_RT) or 
			((EX_MEM_OP = "001000" or EX_MEM_OP = "001010") and EX_MEM_RegWrite = '1' and EX_MEM_RT /= "00000" and EX_MEM_RT = ID_EX_RT) then -- Dependencia de dados aritmeticos, tira pós ula e manda para pré ula
			mux_forward_2 <= "01";
		elsif (MEM_WB_RegWrite = '1' and MEM_WB_RD /= "00000" and MEM_WB_RD = ID_EX_RT) or ( MEM_WB_RegWrite = '1' and MEM_WB_RT /= "00000" and MEM_WB_RT = ID_EX_RT) or
			((MEM_WB_OP = "001000" or MEM_WB_OP = "001010") and MEM_WB_RegWrite = '1' and MEM_WB_RT /= "00000" and MEM_WB_RT = ID_EX_RT) then -- Dependencia de dados aritmeticos, tira pós memória e manda pré ula
			mux_forward_2 <= "10";
		elsif (ID_EX_MemWrite = '1' and MEM_WB_RD = ID_EX_RT) then
			mux_forward_2 <= "11";
		else
			mux_forward_2 <= "00";
		end if;	  
		
		if (ID_EX_RegWrite = '1' and ID_EX_RD /= "00000" and ID_EX_RD = IF_ID_RS) then
			mux_forward_3 <= "01";
		elsif (EX_MEM_RegWrite = '1' and EX_MEM_RD /= "00000" and EX_MEM_RD = IF_ID_RS) then
			mux_forward_3 <= "10";
		else 
			mux_forward_3 <= "00";
		end if;
		
		if (ID_EX_RegWrite = '1' and ID_EX_RD /= "00000" and ID_EX_RD = IF_ID_RT) then
			mux_forward_4 <= "01";
		elsif (EX_MEM_RegWrite = '1' and EX_MEM_RD /= "00000" and EX_MEM_RD = IF_ID_RT) then
			mux_forward_4 <= "10";
		else 
			mux_forward_4 <= "00";
		end if;
		
			
		if CLK'event and CLK = '1' then  
			
			  -- Dependencia de dados loads, um stall
            if (UC_MemRead = '1' and ((IF_ID_RT = IM_RS) or (IF_ID_RT = IM_RT))) then
                stall <= '1';
            else 
                stall <= '0';
            end if;
		end if;
		
	end process;
end behavioral;