library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.blocks.all;

entity DataFlow is
port(
	RegDst,ALUSrc: in std_logic_vector (1 downto 0);
	ALUOp, Exc_id: in std_logic_vector (3 downto 0);
	Jump,Branch,BchSel,MemRead,MemtoReg,MemWrite,RegWrite,JumpReturn,JumpAndLink,Mult,Request,ExcEnd,Clock,Reset: in std_logic;
	EnablePC : in std_logic;
	Enable, Zero, Busy, Executando: out std_logic;
	OP, Funct: out std_logic_vector (5 downto 0);
	Flush2 : out std_logic
	);
end DataFlow;

architecture arch_DataFlow of DataFlow is

	signal PC_in,PC_out,IM_out, Mux2_out,Mux3_out,Mux4_out, mux8_out, mux14_out, mux15_out, mux16_out, Reg_out1,Reg_out2,Add1_out,ALU_Result,Mult_Result : std_logic_vector(31 downto 0);
	signal SignExtend_out, Mux3_in3, DM_out,JumpAddress,SftL2_out,Add2_out,Mux6_out,Mux5_out: std_logic_vector(31 downto 0);
	signal SftL1_out: std_logic_vector(27 downto 0);
	signal Mux1_out: std_logic_vector(4 downto 0);
	signal ZeroALU,OverflowALU,OverflowMult,MultReady,IMReady,DMReady,And2_out,And3_out, nZeroALU,Enablei: std_logic;
	signal pc_enable, CLK_mult : std_logic;
	
	signal  Mux9_out,Mux10_out,Mux11_out : std_logic;
	signal  Mux12_out		: std_logic_vector(1 downto 0);
	signal  Mux13_out		: std_logic_vector(20 downto 11);
	
		--Sinais de caracterização
	signal BO_count, DM_count, IM_count: std_logic_vector(31 downto 0);
	
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

		--Sinais Mem Buffer
	signal	BFFenable,BFFready_write  : STD_LOGIC;
	signal	BFFdata_block_in       : word_block;
	signal	BFFblock_address_in     : STD_LOGIC_VECTOR (9 downto 0);
	signal	BFFbusy, BFFwrite          : STD_LOGIC;
	signal	BFFblock_address_out    : STD_LOGIC_VECTOR (15 downto 0);
	signal	BFFdata_block_out       : word_block;

		--Sinais Buffers de estagios
	signal	BFenable				: STD_LOGIC;
	
	signal 	IFBpc_out, IFBim_out, IFBpc_plus4_out 	: std_logic_vector(31 downto 0);
	
	signal	IDBreg1_out, IDBreg2_out : std_logic_vector(31 downto 0);
	signal 	IDBinst_15_0_ext_out 	: std_logic_vector(31 downto 0);
	signal	IDEXOpcode_out		: std_logic_vector(5 downto 0);
	signal 	IDBmult_out,IDBmemwrite_out,IDBmemread_out,IDBregwrite_out,IDBjumpandlink_out,IDBmemtoreg_out : std_logic;
	signal	IDBalusrc_out			: std_logic_vector(1 downto 0);
	signal 	IDBaluop_out			: std_logic_vector(3 downto 0);
	signal  IDBregdest_out			: std_logic_vector(1 downto 0);
	signal 	IDBinst_25_6_out 		: std_logic_vector(25 downto 6);
	signal	EXMEMOpcode_out, MEMWBOpcode_out	: std_logic_vector(5 downto 0);

	signal  MULjumpandlink_out,MULmemtoreg_out,MULregwrite_out : std_logic;
	signal  MULregdest_out			: std_logic_vector(1 downto 0);
	signal  MULinst_20_11_out		: std_logic_vector(20 downto 11);
	
	signal  EXBreg2_out, EXBalu_out : std_logic_vector(31 downto 0);
	signal  EXBmemwrite_out,EXBmemread_out,EXBregwrite_out,EXBjumpandlink_out,EXBmemtoreg_out : std_logic;
	signal  EXBregdest_out			: std_logic_vector(1 downto 0);
	signal 	EXBinst_20_11_out 		: std_logic_vector(20 downto 11);
	
	signal  MEMmemread_out : std_logic;
	signal  MEMBread_data_out 			: std_logic_vector(31 downto 0);
	signal  MEMBaddress_out			 	: std_logic_vector(31 downto 0);
	signal  MEMBregwrite_out,MEMBjumpandlink_out,MEMBmemtoreg_out : std_logic;
	signal  MEMBregdest_out				: std_logic_vector(1 downto 0);
	signal 	MEMBinst_20_11_out 			: std_logic_vector(20 downto 11);

	--signal O_PC, I2_Add1, O_Add1, O_Add2, O_SignExtend, O_ShiftLeft, O_Mux1, O_Mux2, ALU_result, O_Mux3 : signed (31 downto 0);
	--signal Clock, Zero : std_logic;
	--signal aux, O_InstrMem, O1_Reg, O2_Reg, O_DataMem : std_logic_vector (31 downto 0);

		
	--Sinais do Hardware de Excecoes
	signal EXC_addr, Cause, Cause_out, EPC_addr, Next_PC: std_logic_vector (31 downto 0);
	signal PC_ctrl: std_logic_vector (1 downto 0);
	signal State_id : std_logic_vector (2 downto 0);
	signal Overflow, EPC_write, RC_write, Flush, Enable_UC, Reset_buffers, Enable_inter : std_logic; --verificar origem do Overflow e destino do Enable_UC
	
	--Sinais do Forwarding Unit
	signal stall, notstall, enable_inter2, enable_inter3 : std_logic;
	signal mux_forward_1, mux_forward_2, mux_forward_3, mux_forward_4 : std_logic_vector(1 downto 0);	  
	
	--Sinais do Branch Predictor
	signal branch_taken, clock_delayed, reset_for_branch, flush_from_branch : std_logic;
	signal nextPC, SignExtend_Shifted_out, branch_target, jump_target : std_logic_vector(31 downto 0); 

	
	--Estagio IF
	component ProgramCounter is
		port (I: in std_logic_vector (31 downto 0);
		clock,reset,enable, flush: in std_logic;
		O: out std_logic_vector (31 downto 0));
	end component;
	component IF_ID_Buffer is
		port(pc_in, instruction_in, pc_plus4_in	: in std_logic_vector(31 downto 0);
			enable, CLK, RST, flush, flush2  	: in STD_LOGIC;
			pc_out, instruction_out, pc_plus4_out : out std_logic_vector(31 downto 0)
			);
	end component;
	--Estagio ID
	component RegisterBank is
		Port(Read_reg_1	: in  std_logic_vector(4 downto 0);
		Read_reg_2	: in  std_logic_vector(4 downto 0);
		Write_reg	: in  std_logic_vector(4 downto 0);
		Write_data	: in  std_logic_vector(31 downto 0);
		Reg_write	: in  std_logic;
		Reset		: in std_logic;
		Clock		: in std_logic;
		Read_data_1	: out std_logic_vector(31 downto 0);
		Read_data_2	: out std_logic_vector(31 downto 0));
	end component;
	component ID_EX_Buffer is
		port(
		
		reg1_in, reg2_in	: in std_logic_vector(31 downto 0);
		inst_15_0_ext_in	: in std_logic_vector(31 downto 0);
		ID_EX_OPcode_in		: in std_logic_vector (5 downto 0);
		reg1_out, reg2_out	: out std_logic_vector(31 downto 0);
		inst_15_0_ext_out	: out std_logic_vector(31 downto 0);
		ID_EX_OPcode_out	: out std_logic_vector (5 downto 0);
		
		--controle EX
		alusrc_in			: in std_logic_vector(1 downto 0);
		aluop_in			: in std_logic_vector(3 downto 0);
		mult_in				: in std_logic;
		alusrc_out			: out std_logic_vector(1 downto 0);
		aluop_out			: out std_logic_vector(3 downto 0);
		mult_out			: out std_logic;
		
		--controle MEM
		memwrite_in, memread_in 	: in std_logic;
		memwrite_out, memread_out 	: out std_logic;
		
		--controle WB
		jumpandlink_in, memtoreg_in, regwrite_in	: in std_logic;
		regdest_in	:	in std_logic_vector(1 downto 0);
		inst_25_6_in	: in std_logic_vector(25 downto 6);
		jumpandlink_out, memtoreg_out, regwrite_out	: out std_logic;
		regdest_out	:	out std_logic_vector(1 downto 0);
		inst_25_6_out	: out std_logic_vector(25 downto 6);
		
		enable, CLK, RST	: in STD_LOGIC
		);	
	end component; 	 
	
	-- Branch Predictor 
	component BranchPredictor is
	port (op_code: in STD_LOGIC_VECTOR(5 downto 0);	 
		branch_taken, CLK_delayed, CLK: in STD_LOGIC;
		branch_PC, current_PC, branch_target, jump_target: in STD_LOGIC_VECTOR(31 downto 0);
		flush: out STD_LOGIC;		
		next_PC: out std_logic_vector(31 downto 0)
	);
	end component;	   
	
	-- Branch Compartor
	component BranchComparator is
	port (op_code: in STD_LOGIC_vector(5 downto 0);
	input1, input2: in STD_LOGIC_vector(31 downto 0);
	branch_taken: out std_logic	
	);
	end component;
	
	
	
	--Estagio EX
	component ArithmeticLogicUnit is
		port (A,B: in std_logic_vector (31 downto 0);
		ALU_operation: in std_logic_vector (3 downto 0);
		Zero,Overflow: out std_logic;
		ALU_result: out std_logic_vector (31 downto 0));
	end component;
	component MultiplicationUnit is
		port (A,B: in std_logic_vector (31 downto 0);
		Enable,Clock,Reset: in std_logic;
		EXBjumpandlink_out,EXBmemtoreg_out,EXBregwrite_out: in std_logic;
		EXBregdest_out: in std_logic_vector (1 downto 0);
		EXBinst_20_11_out: in std_logic_vector (20 downto 11);
		Overflow,Executando,Ready: out std_logic;
		EXBjumpandlink_outs,EXBmemtoreg_outs,EXBregwrite_outs: out std_logic;
		EXBregdest_outs: out std_logic_vector (1 downto 0);
		EXBinst_20_11_outs: out std_logic_vector (20 downto 11);
		O: out std_logic_vector (31 downto 0));
	end component;
	component EX_MEM_Buffer is
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
	end component;
	
	-- ForwardingUnit + Hazard Detection
	component ForwardingUnit is
		port (EX_MEM_OP, MEM_WB_OP: in std_logic_vector(5 downto 0);
		EX_MEM_RegWrite, MEM_WB_RegWrite, UC_MemRead, MEM_WB_MemRead, ID_EX_MemWrite, ID_EX_RegWrite, CLK: in STD_LOGIC;
		EX_MEM_RD, EX_MEM_RT : in STD_LOGIC_Vector(4 downto 0); -- instruction(15,11)
		MEM_WB_RD, MEM_WB_RT : in std_logic_vector(4 downto 0); -- instruction(15,11)
		ID_EX_RS, ID_EX_RT, ID_EX_RD : in std_logic_vector(4 downto 0); -- instruction(25,21), instruction(20-16)
		IF_ID_RS, IF_ID_RT : in std_logic_vector(4 downto 0); -- instruction(25,21), instruction(20-16)
		IM_RS, IM_RT : in std_logic_vector(4 downto 0); -- instruction(25,21), instruction(20-16)
		mux_forward_1, mux_forward_2, mux_forward_3, mux_forward_4: out STD_LOGIC_vector(1 downto 0);
		stall : out std_logic);
	end component;

	
	--Estagio MEM
	component Memory is
		port (IMread_address, DMread_address: in STD_LOGIC_VECTOR(15 downto 0);
		mem_read, mem_write, Clock, Reset : in std_logic;
		write_data : in std_logic_vector(31 downto 0);
		IMready, DMready: out STD_LOGIC;
		instruction, data: out std_logic_vector(31 downto 0)
		);
	end component;
	--component DataMemory is
		--port(mem_read: in std_logic;
		--mem_write: in std_logic;
		--clock: in std_logic;
		--address: in std_logic_vector (15 downto 0);
		--write_data: in std_logic_vector (31 downto 0);
		--read_data: out std_logic_vector (31 downto 0);
		--ready: out std_logic);
	--end component;
	--component InstructionMemory is
		--port(address: in std_logic_vector (15 downto 0);
		--read_data: out std_logic_vector (31 downto 0);
		--ready: out std_logic);
	--end component;
	component MEM_WB_Buffer is
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
	end component;
	
	--Hardware de Excecoes
	Component Exception_Hardware is			
	Port(Clk	 : in 	std_logic;
		Reset 	 : in 	std_logic;
		Request  : in   std_logic;
		Exc_end  : in   std_logic;
		Overflow : in   std_logic;
		Exc_id 	 : in 	std_logic_vector (3 downto 0);
		Busy	 : out  std_logic;
		EPC_write: out	std_logic;
		Cause	 : out 	std_logic_vector (31 downto 0);
		RC_write : out	std_logic;
		EXC_addr : out	std_logic_vector (31 downto 0);
		PC_ctrl	 : out	std_logic_vector (1 downto 0);
		Flush	 : out	std_logic;
		Enable_UC: out  std_logic;
		State_id : out	std_logic_vector (2 downto 0));
	end component;
	
	--Extras
	component Multiplexer2x1_32 is
		port (I0,I1: in std_logic_vector (31 downto 0);
		Sel: in std_logic;
		O: out std_logic_vector (31 downto 0));
	end component;
	component Multiplexer2x1_10 is
		port (I0,I1: in std_logic_vector (9 downto 0);
		Sel: in std_logic;
		O: out std_logic_vector (9 downto 0));
	end component;
	component Multiplexer2x1_2 is
		port (I0,I1: in std_logic_vector (1 downto 0);
		Sel: in std_logic;
		O: out std_logic_vector (1 downto 0));
	end component;
	component Multiplexer2x1_1 is
		port (I0,I1: in std_logic;
		Sel: in std_logic;
		O: out std_logic);
	end component;
	component Multiplexer4x1_5 is
		port (I0,I1,I2,I3: in std_logic_vector (4 downto 0);
		Sel: in std_logic_vector (1 downto 0);
		O: out std_logic_vector (4 downto 0));
	end component;
	component Multiplexer4x1_32 is
		port (I0,I1,I2,I3: in std_logic_vector (31 downto 0);
		Sel: in std_logic_vector (1 downto 0);
		O: out std_logic_vector (31 downto 0));
	end component;
	component Add is
		port (I1,I2: in std_logic_vector (31 downto 0);
		O: out std_logic_vector (31 downto 0));
	end component;
	component SignExtend is
		port (I: in std_logic_vector (15 downto 0);
		O: out std_logic_vector (31 downto 0));
	end component;
	component ShiftLeft_32 is
		port (I: in std_logic_vector (31 downto 0);
		O: out std_logic_vector (31 downto 0));
	end component;
	component ShiftLeft_26 is
		port (I: in std_logic_vector (25 downto 0);
		O: out std_logic_vector (27 downto 0));
	end component;
	component AndC is
		port (A,B: in std_logic;
		O: out std_logic);
	end component;
	component OrC is
		port (A,B: in std_logic;
		O: out std_logic);
	end component;
	component NotC is
		port (A: in std_logic;
		O: out std_logic);
	end component;	  
	component ClockDelayer is
	port (CLK: in STD_LOGIC;
		  CLK_delayed: out STD_LOGIC
	);
	end component;
	
begin

	--Decisao do PC, falta inserir previsao de desvio
	Add1 : Add port map (PC_out,x"00000004",Add1_out);
	--SftL1 : ShiftLeft_26 port map (IM_out(25 downto 0),SftL1_out);
	--JumpAddress <= Add1_out(31 downto 28) & SftL1_out;
	--SftL2 : ShiftLeft_32 port map (SignExtend_out,SftL2_out);
	--Add2 : Add port map (Add1_out,SftL2_out,Add2_out);
	--Mux5 : Multiplexer2x1_32 port map (Add1_out,Add2_out,Mux8_out,Mux5_out);
	--Mux6 : Multiplexer2x1_32 port map (Mux5_out,JumpAddress,Jump,Mux6_out);
	--Mux7 : Multiplexer2x1_32 port map (Mux6_out,Reg_out1,JumpReturn,PC_in);
	--And2 : AndC port map (Branch,ZeroALU,And2_out);
	--nZeroALU <= not(ZeroALU);
	--And3 : AndC port map (Branch,nZeroALU,And3_out);
	--Mux8 : Multiplexer2x1_1 port map (And3_out,And2_out,BchSel,Mux8_out);
	
	--Estagio IF
		--PC : ProgramCounter port map (Add1_out,Clock,Reset,pc_enable,PC_out);
		PC : ProgramCounter port map (PC_in,Clock,Reset,enable_inter2, stall,PC_out);
		--IM : InstructionMemory port map (PC_out(15 downto 0),IM_out,IMReady);
		--DM : DataMemory port map (MemRead,MemWrite,Clock,ALU_result(15 downto 0),Reg_out2,DM_out,DMReady);
		OP <= IM_out(31 downto 26);
		Funct <= IM_out(5 downto 0);
		IFB: IF_ID_Buffer port map(PC_out,IM_out,Add1_out,IMReady,Clock, reset_buffers, stall, flush_from_branch,IFBpc_out,IFBim_out, IFBpc_plus4_out);
	
	--Estagio ID
		Mux2: Multiplexer2x1_32 port map(Mux4_out,Add1_out,JumpAndLink,Mux2_out);
		Reg : RegisterBank port map (IFBim_out(25 downto 21),IFBim_out(20 downto 16),Mux1_out,Mux2_out,MEMBregwrite_out,Reset,Clock,Reg_out1,Reg_out2);
		SgnExt : SignExtend port map (IFBim_out(15 downto 0),SignExtend_out);
		IDB:  ID_EX_Buffer port map (Reg_out1,Reg_out2,SignExtend_out,IFBim_out(31 downto 26),IDBreg1_out, IDBreg2_out,IDBinst_15_0_ext_out,IDEXOpcode_out,
				ALUSrc,ALUOp,Mult,IDBalusrc_out,IDBaluop_out,IDBmult_out,
				MemWrite,MemRead,IDBmemwrite_out,IDBmemread_out,
				JumpAndLink,MemtoReg,RegWrite,RegDst,IFBim_out(25 downto 6),IDBjumpandlink_out,IDBmemtoreg_out,IDBregwrite_out,IDBregdest_out,IDBinst_25_6_out,
				BFenable,Clock,Reset_buffers);
				
		-- Branch Predictor
		BP : BranchPredictor port map (IFBim_out(31 downto 26), branch_taken, clock_delayed, clock,IFBpc_out, PC_out, branch_target, jump_target, flush_from_branch, nextPC);
		-- Branch Compartor
		BC : BranchComparator port map (IFBim_out(31 downto 26), mux15_out, mux16_out, branch_taken); 
		-- CLK Delayer
		Clk_Delay : ClockDelayer port map (Clock, clock_delayed);
		-- Branch Target Calculation 
		Sft_Left : ShiftLeft_32 port map (SignExtend_out, SignExtend_Shifted_out); 
		Add2 : Add port map (SignExtend_Shifted_out, IFBpc_plus4_out, branch_target);  
		--Or3 : OrC port map(Reset, flush2, reset_for_branch);
		-- Jump Target Calculation
		SftL1 : ShiftLeft_26 port map (IFBim_out(25 downto 0),SftL1_out);
        jump_target <= IFBpc_out(31 downto 28) & SftL1_out;	
		-- mux para forward de branch
		Mux15 : Multiplexer4x1_32 port map (Reg_out1, Mux5_out, EXBalu_out, x"FFFFAAAA", mux_forward_3, mux15_out);
		Mux16 : Multiplexer4x1_32 port map (Reg_out2, Mux5_out, EXBalu_out, x"FFFFBBBB", mux_forward_4, mux16_out);
		
		
		
	
	--Estagio EX
		Mux3_in3 <= "000000000000000000000000000" & IDBinst_25_6_out(10 downto 6);
		Mux3: Multiplexer4x1_32 port map (mux14_out,IDBinst_15_0_ext_out,Mux3_in3,x"00000000",IDBalusrc_out,Mux3_out);
		ALU: ArithmeticLogicUnit port map (mux8_out,Mux3_out,IDBaluop_out,ZeroALU,OverflowALU,ALU_Result);
		Zero <= ZeroALU;
		CLK_mult <= Clock after 1 ns;
		Multipli: MultiplicationUnit port map (mux8_out,mux14_out,IDBmult_out,CLK_mult,Reset,
			IDBjumpandlink_out,IDBmemtoreg_out,IDBregwrite_out,IDBregdest_out,IDBinst_25_6_out(20 downto 11),
			OverflowMult,Executando,MultReady,
			MULjumpandlink_out,MULmemtoreg_out,MULregwrite_out,MULregdest_out,MULinst_20_11_out,
			Mult_Result);
		Or1: OrC port map (OverflowALU, OverflowMult, Overflow);
		Mux5: Multiplexer2x1_32 port map (ALU_Result,Mult_Result,MultReady,Mux5_out);
		Overflow <= (OverflowALU or OverflowMult);
		EXB: EX_MEM_Buffer port map(mux14_out, Mux5_out,IDEXOpcode_out, EXBreg2_out, EXBalu_out,EXMEMOpcode_out,
				IDBmemwrite_out,IDBmemread_out,EXBmemwrite_out,EXBmemread_out,
				Mux9_out,Mux10_out,Mux11_out,Mux12_out,Mux13_out,EXBjumpandlink_out,EXBmemtoreg_out,EXBregwrite_out,EXBregdest_out,EXBinst_20_11_out,
				BFenable,Clock,Reset_buffers); --corrigir enables
		Mux9  : Multiplexer2x1_1 port map (IDBjumpandlink_out,MULjumpandlink_out,MultReady,Mux9_out);
		Mux10 : Multiplexer2x1_1 port map (IDBmemtoreg_out,MULmemtoreg_out,MultReady,Mux10_out);
		Mux11 : Multiplexer2x1_1 port map (IDBregwrite_out,MULregwrite_out,MultReady,Mux11_out);
		Mux12 : Multiplexer2x1_2 port map (IDBregdest_out,MULregdest_out,MultReady,Mux12_out);
		Mux13 : Multiplexer2x1_10 port map (IDBinst_25_6_out(20 downto 11),MULinst_20_11_out,MultReady,Mux13_out);
		
		--FwrdUnit : ForwardingUnit port map (EXBregwrite_out, MEMBregwrite_out, IDBmemread_out, MEMmemread_out, Clock,
--			EXBinst_20_11_out(15 downto 11), -- instruction(15,11)
--			MEMBinst_20_11_out(15 downto 11), MEMBinst_20_11_out(20 downto 16), -- instruction(15,11)
--			IDBinst_25_6_out(25 downto 21), IDBinst_25_6_out(20 downto 16),  -- instruction(25,21), instruction(20-16)
--			IFBim_out(25 downto 21), IFBim_out(20 downto 16),  -- instruction(25,21), instruction(20-16)
--			mux_forward_1, mux_forward_2, 
--			stall);
FwrdUnit : ForwardingUnit port map (EXMEMOpcode_out, MEMWBOpcode_out,
			EXBregwrite_out, MEMBregwrite_out, MemRead, MEMmemread_out, IDBmemwrite_out, IDBregwrite_out, Clock,
			EXBinst_20_11_out(15 downto 11), EXBinst_20_11_out(20 downto 16), -- instruction(15,11)
			MEMBinst_20_11_out(15 downto 11), MEMBinst_20_11_out(20 downto 16), -- instruction(15,11)
			IDBinst_25_6_out(25 downto 21), IDBinst_25_6_out(20 downto 16), IDBinst_25_6_out(15 downto 11), -- instruction(25,21), instruction(20-16)
			IFBim_out(25 downto 21), IFBim_out(20 downto 16),  -- instruction(25,21), instruction(20-16)
			IM_out(25 downto 21), IM_out(20 downto 16),
			mux_forward_1, mux_forward_2, mux_forward_3, mux_forward_4,
			stall);
		
		--Mux8 : Multiplexer4x1_32 port map (IDBreg1_out,	IDBreg1_out,	IDBreg1_out, IDBreg1_out, mux_forward_1, mux8_out);
--		Mux14 : Multiplexer4x1_32 port map (IDBreg2_out, IDBreg2_out, IDBreg2_out, IDBreg2_out, mux_forward_2, mux14_out);
		Mux8 : Multiplexer4x1_32 port map (IDBreg1_out,	EXBalu_out,	Mux4_out, x"00000000", mux_forward_1, mux8_out);
		Mux14 : Multiplexer4x1_32 port map (IDBreg2_out, EXBalu_out, Mux4_out, EXBreg2_out, mux_forward_2, mux14_out); 
		

	--Estagio MEM
		Mem : Memory port map(PC_out(15 downto 0),EXBalu_out(15 downto 0),EXBmemread_out,EXBmemwrite_out,Clock,Reset,EXBreg2_out,IMReady,DMReady,IM_out,DM_out);
		MEMB: MEM_WB_Buffer port map(DM_out,EXBalu_out,EXMEMOpcode_out,MEMBread_data_out,MEMBaddress_out,MEMWBOpcode_out ,EXBmemread_out, MEMmemread_out,	
				EXBjumpandlink_out,EXBmemtoreg_out,EXBregwrite_out,EXBregdest_out,EXBinst_20_11_out,MEMBjumpandlink_out,MEMBmemtoreg_out,MEMBregwrite_out,MEMBregdest_out,MEMBinst_20_11_out,
				BFenable,Clock,Reset_buffers); --corrigir enables

	--Estagio WB
		Mux4 : Multiplexer2x1_32 port map (MEMBaddress_out,MEMBread_data_out,MEMBmemtoreg_out,Mux4_out);
		Mux1 : Multiplexer4x1_5 port map (MEMBinst_20_11_out(20 downto 16),"11111",MEMBinst_20_11_out(15 downto 11),"00000",MEMBregdest_out,Mux1_out);

	
	--Hardware de Excecao 
	    Excep_Hw:  Exception_Hardware port map (Clock, Reset, Request, ExcEnd, Overflow, Exc_id, Busy, EPC_write, Cause, RC_write, Exc_addr, PC_ctrl, Flush, Enable_UC, State_id);
		Cause_Reg: ProgramCounter port map (Cause, Clock, Reset, RC_write, '0',Cause_out); 
		EPC_Reg:   ProgramCounter port map (PC_out, Clock, Reset, EPC_write, '0', EPC_addr);
		Mux_Excep: Multiplexer4x1_32 port map (nextPC, Exc_addr, EPC_addr, nextPC, PC_ctrl, PC_in);
		Or2: OrC port map (Reset, Flush, Reset_buffers);
		
	--Extras
	And1 : AndC port map (DMReady,IMReady,Enable_inter);
	And2 : AndC port map (Enable_UC, Enable_inter, Enablei); --Enable_inter criado como intermediario para se utilizar o enable_UC do exc_hardw
	And3 : AndC port map (Enablei,EnablePC,enable_inter2);
	Not1 : NotC port map (stall, notstall);
	And4 : AndC port map (enable_inter2, notstall, pc_enable);
	And5 : AndC port map (enablei, notstall, enable_inter3);
	
	
	
	Enable <= enable_inter3;
	
	BFenable <= Enablei;  
	
	Flush2 <= flush_from_branch;   
	
		
	-- processamento dos sinais de caracterização
	process (Clock, Reset)
		begin
			if (Reset='1') then 
				BO_count <= (others=>'0');
			elsif (Clock'event and Clock='1') then
				if(enable_inter2='0') then 
					BO_count <= std_logic_vector(unsigned(BO_count) + 1);
				end if;
			end if;
	end process;
	
	process (DMReady, Reset)
		begin
			if (Reset='1') then 
				DM_count <= (others=>'0');
			elsif (DMReady'event and DMReady='1') then --miss no cache de dados
				DM_count <= std_logic_vector(unsigned(DM_count) + 1);
			end if;
	end process;
	
	process (IMReady, Reset)
		begin
			if (Reset='1') then 
				IM_count <= (others=>'0');
			elsif (IMReady'event and IMReady='1') then --miss no cache de instrucoes
				IM_count <= std_logic_vector(unsigned(IM_count) + 1);
			end if;
	end process;

end arch_DataFlow;
