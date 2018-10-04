library IEEE;
use IEEE.numeric_bit.all;
use IEEE.STD_LOGIC_1164.ALL;   
USE ieee.std_logic_unsigned.ALL;

entity Unidade_Controle is
			
	Port(Op		: in   std_logic_vector(5 downto 0);
		Funct	: in   std_logic_vector(5 downto 0);
		Enable 	: in   std_logic;
		CLK 	: in   std_logic;
		Reset	: in   std_logic;
		NFimMult: in   std_logic;
		Flush2  : in   std_logic;
		RegDst	: out  std_logic_vector(1 downto 0);
		Jump	: out  std_logic;
		Branch	: out  std_logic;
		BchSel	: out  std_logic;
		MemRead	: out  std_logic;
		MemtoReg: out  std_logic;
		ALUOp	: out  std_logic_vector(3 downto 0);
		MemWrite: out  std_logic;
		ALUSrc	: out  std_logic_vector(1 downto 0);
		RegWrite: out  std_logic;
		JpReturn: out  std_logic;
		JumpAndLink: out std_logic;
		Mult	: out std_logic;
		EnablePC : out std_logic;
		ExcEnd : out std_logic);
end Unidade_Controle;


architecture Behave of Unidade_Controle is	
	signal pr_jump, pr_branch, pr_bchsel, pr_memread, pr_memtoreg, pr_excend : std_logic;
	signal pr_memwrite, pr_regwrite, pr_jpreturn, pr_jumpandlink, pr_mult, pr_enablepc :  std_logic;
	signal nx_mult : std_logic;
	signal pr_aluoop	: std_logic_vector(3 downto 0);
	signal pr_alusrc, pr_regdst	: std_logic_vector(1 downto 0);
	
	type state is (exeMult, idle);
	signal pr_state, nx_state: state := idle;
begin
	--FSM state register:	
	process(CLK, Reset)
	begin
		if Reset='1' then
			pr_state <= idle;
		elsif CLK'event and CLK='1' then
			pr_state <= nx_state;
		end if;
	end process;
	



	process(CLK,Op,Funct,Enable,NFimMult,pr_state,Reset,nx_mult, Flush2)
	begin
		-- Output register: 
	if (Reset = '1') then
		EnablePC <= '1';	
		RegDst	 <= "00";
		Jump	 <= '0';
		Branch	 <= '0';
		BchSel	 <= '0';
		MemRead	 <= '0';
		MemtoReg <= '0';
		ALUOp	 <= "0000";
		MemWrite <= '0';
		ALUSrc	 <= "00";
		RegWrite <= '0';
		JpReturn <= '0';
		JumpAndLink <= '0';
		Mult	 <= '0';
		ExcEnd   <= '0';
	elsif Flush2 = '1' then		
		RegDst	 <= "00";
		Jump	 <= '0';
		Branch	 <= '0';
		BchSel	 <= '0';
		MemRead	 <= '0';
		MemtoReg  <= '0';
		MemWrite  <= '0';
		ALUSrc	 <= "00";
		RegWrite <= '0';
		JpReturn <= '0';
		JumpAndLink <= '0';
		Mult		<= '0';	 
		ALUOp	 <= "0110"; --nop
	else
		if (CLK'event and CLK='1') then
			RegDst	 <= pr_regdst;
			Jump	 <= pr_jump;
			Branch	 <= pr_branch;
			BchSel	 <= pr_bchsel;
			MemRead	 <= pr_memread;
			MemtoReg <= pr_memtoreg;
			ALUOp	 <= pr_aluoop;
			MemWrite <= pr_memwrite;
			ALUSrc	 <= pr_alusrc;
			RegWrite <= pr_regwrite;
			JpReturn <= pr_jpreturn;
			JumpAndLink <= pr_jumpandlink;
			ExcEnd <= pr_excend;
			Mult	 <= pr_mult;
			nx_mult  <= pr_mult;
		end if;
		if (Enable = '1') then
		case pr_state is 
			when exeMult =>
				if (NFimMult = '1' and nx_mult = '0') then
					nx_state <= idle;
				else
					if (Op = "000000" and Funct = "100010") then  --mult
						pr_regdst	 <= "10";
						pr_jump	 <= '0';
						pr_branch	 <= '0';
						pr_memread	 <= '0';
						pr_memtoreg <= '0';
						pr_memwrite <= '0';
						pr_alusrc	 <= "00";
						pr_regwrite <= '1';
						pr_jpreturn <= '0';
						pr_jumpandlink <= '0';
						pr_mult		<= '1';
						pr_aluoop	 <= "0110";
						pr_excend <= '0';
						EnablePC <= '1';
						

					else
						pr_regdst	 <= "00";
						pr_jump	 	 <= '0';
						pr_branch	 <= '0';
						pr_bchsel	 <= '0';
						pr_memread	 <= '0';
						pr_memtoreg  <= '0';
						pr_memwrite  <= '0';
						pr_alusrc	 <= "00";
						pr_regwrite <= '0';
						pr_jpreturn <= '0';
						pr_jumpandlink <= '0';
						pr_mult		<= '0';
						pr_excend <= '0';
						pr_aluoop	 <= "0110"; --nop
						
						EnablePC <= '0';
					end if;
				end if;
					
			when idle =>
				EnablePC  <= '1';	
				pr_excend    <= '1';
				pr_regdst	 <= "00";
				pr_jump	 	 <= '0';
				pr_branch	 <= '0';
				pr_bchsel	 <= '0';
				pr_memread	 <= '0';
				pr_memtoreg  <= '0';
				pr_memwrite  <= '0';
				pr_alusrc	 <= "00";
				pr_regwrite <= '0';
				pr_jpreturn <= '0';
				pr_jumpandlink <= '0';
				pr_mult		<= '0';
				pr_excend <= '0';
				pr_aluoop	 <= "0110"; --nop
				
				if (Op = "000000") then  --Logico-aritmeticas 

					if (Funct = "100010") then	 --mult
						pr_regdst	 <= "10";
						pr_regwrite <= '1';
						pr_mult		<= '1';
						nx_state <= exeMult;
						
					elsif (Funct = "100000") then	 --add
						pr_regdst	 <= "10";
						pr_aluoop	 <= "0010";
						pr_regwrite <= '1';
						
					elsif (Funct = "011000") then	 --sub
						pr_regdst	 <= "10";
						pr_aluoop	 <= "0010";
						pr_regwrite <= '1';
						
					elsif (Funct = "101010") then	 --slt
						pr_regdst	 <= "10";
						pr_aluoop	 <= "0100";
						pr_regwrite <= '1';
						
					elsif (Funct = "001000") then	 --jr
						pr_aluoop	 <= "0110";
						pr_jpreturn <= '1';
						
					elsif (Funct = "011000") then	 --exception return
						pr_excend <= '1';
				  
					elsif (Funct = "000000") then	 --sll
						pr_regdst	 <= "10";
						pr_aluoop	 <= "0101";
						pr_alusrc	 <= "10";
						pr_regwrite <= '1';
					end if;	
						
				elsif (Op = "100011") then  --lw
					pr_memread	 <= '1';
					pr_memtoreg <= '1';
					pr_aluoop	 <= "0010";
					pr_alusrc	 <= "01";
					pr_regwrite <= '1';
					
				elsif (Op = "101011") then  --sw
					pr_aluoop	 <= "0010";
					pr_memwrite <= '1';
					pr_alusrc	 <= "01";
					
				elsif (Op = "001000") then  --addi
					pr_aluoop	 <= "0010";
					pr_alusrc	 <= "01";
					pr_regwrite <= '1';

				elsif (Op = "000100") then  --beq
					pr_branch	 <= '1'; 
					pr_bchsel	 <= '1';
					pr_aluoop	 <= "0011";

				elsif (Op = "000101") then  --bne
					pr_branch	 <= '1'; 
					pr_aluoop	 <= "0011";

				elsif (Op = "001010") then  --slti
					pr_aluoop	 <= "0100";
					pr_alusrc	 <= "01";
					pr_regwrite <= '1';

				elsif (Op = "000010") then  --jump 
					pr_jump	 <= '1';
					pr_aluoop	 <= "0110";

				elsif (Op = "000011") then  --jal	
					pr_regdst	 <= "01";
					pr_jump	 <= '1';
					pr_aluoop	 <= "0110";
					pr_regwrite <= '1';
					pr_jumpandlink <= '1';
				end if;
		end case;
		end if;
	end if;
	end process;
end Behave;
