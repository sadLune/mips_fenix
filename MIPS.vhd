library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.blocks.all;

entity MIPS is
port(	Request,Clock, Reset: in std_logic;
		Exc_id : in std_logic_vector(3 downto 0)
	);
end MIPS;

architecture arch_MIPS of MIPS is

	-- Sinais de conexão
	signal PC_in,PC_out,IM_out, Mux2_out,Mux3_out,Mux4_out,Reg_out1,Reg_out2,Add1_out,ALU_Result : std_logic_vector(31 downto 0);
	signal SignExtend_out, Mux3_in3, DM_out,JumpAddress,SftL2_out,Add2_out,Mux6_out,Mux5_out: std_logic_vector(31 downto 0);
	signal SftL1_out: std_logic_vector(27 downto 0);
	signal Mux1_out: std_logic_vector(4 downto 0);
	signal ZeroALU,IMReady,DMReady,Mux8_out,And2_out,And3_out, nZeroALU: std_logic;
	signal Executando, EnablePC, ExcEnd, Busy, Flush2 : std_logic;
	signal auxiliar : std_logic;
	signal clk_delay: std_logic;
	
	signal	Op	:  std_logic_vector(5 downto 0);
	signal	Funct	:  std_logic_vector(5 downto 0);
	signal	Enable :  std_logic;
	signal	RegDst	:  std_logic_vector(1 downto 0);
	signal	Jump	:  std_logic;
	signal	Branch	:  std_logic;
	signal	BchSel	:  std_logic;
	signal	MemRead :  std_logic;
	signal	MemtoReg:  std_logic;
	signal	ALUOp	:  std_logic_vector(3 downto 0);
	signal	MemWrite:  std_logic;
	signal	ALUSrc	:  std_logic_vector(1 downto 0);
	signal	RegWrite:  std_logic;
	signal	JpReturn:  std_logic;
	signal	JumpAndLink: std_logic;
	signal	Mult	: std_logic;

	-- Sinais da caracterização
	signal CLK_count, INS_count, MEM_count: std_logic_vector(31 downto 0);
	signal ADD_count,ADDI_count,BEQ_count,BNEQ_count,JAL_count,JR_count,JUMP_count,LW_count,SLL_count,SLT_count,SLTI_count,SW_count,MUL_count: std_logic_vector(31 downto 0);

	signal DMReadyiTeste: std_logic;
	

		--Sinais da InstructionMemory
	signal	IMready_ram:  STD_LOGIC;	 
	signal	IMwords_block:  word_block;
	signal	IMaddress:  STD_LOGIC_VECTOR(15 downto 0);
	signal	IMsearch_ram:  STD_LOGIC;
	signal	IMblock_address:  STD_LOGIC_VECTOR (9 downto 0);

		--Sinas da RAM
	signal	RAMread_en	:  	std_logic;
	signal	RAMwrite	:  	std_logic;
	signal	RAMender 	:  	std_logic_vector(15 downto 0);
	signal	RAMenderEscrita :  std_logic_vector(15 downto 0);
	signal	RAMpronto 	: 	std_logic;
	signal	RAMprontoescrita : std_logic;
	signal	RAMdadoout 	: word_block;
	signal	RAMdadoin 	: word_block;

		--Sinais DataMemory
	signal	DMready_ram, DMmem_write, DMmem_read, DMClock, DMbusy: STD_LOGIC;	
	signal	DMwords_block: word_block;
	signal	DMread_address : STD_LOGIC_VECTOR(15 downto 0);
	signal	DMsearch_ram, DMwrite_back: STD_LOGIC;
	signal	DMblock_address: STD_LOGIC_VECTOR (9 downto 0);
	signal	DMwrite_block: word_block;
	signal	DMwrite_data : std_logic_vector(31 downto 0);

		--Sinais Buffer
	signal	BFFenable,BFFready_write  : STD_LOGIC;
	signal	BFFdata_block_in       : word_block;
	signal	BFFblock_address_in     : STD_LOGIC_VECTOR (9 downto 0);
	signal	BFFbusy, BFFwrite          : STD_LOGIC;
	signal	BFFblock_address_out    : STD_LOGIC_VECTOR (15 downto 0);
	signal	BFFdata_block_out       : word_block;



	
	component DataFlow is
		port (RegDst,ALUSrc: in std_logic_vector (1 downto 0);
		ALUOp, Exc_id: in std_logic_vector (3 downto 0);
		Jump,Branch,BchSel,MemRead,MemtoReg,MemWrite,RegWrite,JumpReturn,JumpAndLink,Mult,Request,ExcEnd,Clock,Reset: in std_logic;
		EnablePC : in std_logic;
		Enable, Zero, Busy, Executando: out std_logic;
		OP, Funct: out std_logic_vector (5 downto 0); 
		Flush2 : out std_logic
		);


	end component;
	component Unidade_Controle is
		port (Op		: in   std_logic_vector(5 downto 0);
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
	end component;

begin
	DF : DataFlow port map (RegDst,ALUSrc,ALUOp,Exc_id,Jump,Branch,BchSel,MemRead,MemtoReg,MemWrite,RegWrite,JpReturn,JumpAndLink,Mult,Request,ExcEnd,Clock,Reset,EnablePC,Enable,ZeroALU,Busy,Executando,Op,Funct, Flush2);
	UC : Unidade_Controle port map (Op,Funct,Enable,Clock,Reset,Executando,Flush2,RegDst,Jump,Branch,BchSel,MemRead,MemtoReg,ALUOp,MemWrite,ALUSrc,RegWrite,JpReturn,JumpAndLink,Mult,EnablePC,ExcEnd);
	

nZeroALU <= not(ZeroALU);
clk_delay <= Clock after 1ns;

-- processamento dos sinais de caracterização
process (clk_delay, Reset)
	begin
		if (Reset='1') then 
			CLK_count <= (others=>'0');
			INS_count <= (others=>'0');
			MEM_count <= (others=>'0');
			ADD_count <= (others=>'0');
			SLT_count <= (others=>'0');
			JR_count <= (others=>'0');
			SLL_count <= (others=>'0');
			LW_count <= (others=>'0');
			SW_count <= (others=>'0');
			ADDI_count <= (others=>'0');
			BEQ_count <= (others=>'0');
			BNEQ_count <= (others=>'0');
			SLTI_count <= (others=>'0');
			JUMP_count <= (others=>'0');
			JAL_count <= (others=>'0');
			MUL_count <= (others=>'0');
		elsif (clk_delay'event and clk_delay='1') then -- PC na borda de subida
			CLK_count <= std_logic_vector(unsigned(CLK_count) + 1);
			if(Enable='1') then 
				INS_count <= std_logic_vector(unsigned(INS_count) + 1);
				if (Op = "000000") then  --Logico-aritmeticas 
					if (Funct = "100000") then	 --add
						ADD_count <= std_logic_vector(unsigned(ADD_count) + 1);
					elsif (Funct = "101010") then	 --slt
						SLT_count <= std_logic_vector(unsigned(SLT_count) + 1);
					elsif (Funct = "001000") then	 --jr
						JR_count <= std_logic_vector(unsigned(JR_count) + 1);
					elsif (Funct = "000000") then	 --sll
						SLL_count <= std_logic_vector(unsigned(SLL_count) + 1);
					elsif (Funct = "100010") then  --mul
						MUL_count <= std_logic_vector(unsigned(MUL_count) + 1);
					end if;
				elsif (Op = "100011") then  --lw
					LW_count <= std_logic_vector(unsigned(LW_count) + 1);
				elsif (Op = "101011") then  --sw
					SW_count <= std_logic_vector(unsigned(SW_count) + 1);
				elsif (Op = "001000") then  --addi
					ADDI_count <= std_logic_vector(unsigned(ADDI_count) + 1);
				elsif (Op = "000100") then  --beq
					BEQ_count <= std_logic_vector(unsigned(BEQ_count) + 1);
				elsif (Op = "000101") then  --bne
					BNEQ_count <= std_logic_vector(unsigned(BNEQ_count) + 1);
				elsif (Op = "001010") then  --slti
					SLTI_count <= std_logic_vector(unsigned(SLTI_count) + 1);
				elsif (Op = "000010") then  --jump
					JUMP_count <= std_logic_vector(unsigned(JUMP_count) + 1);
				elsif (Op = "000011") then  --jal
					JAL_count <= std_logic_vector(unsigned(JAL_count) + 1);
				end if;
			end if;
		end if;
	end process;
end arch_MIPS;
