library IEEE;
use IEEE.STD_LOGIC_1164.all; 
use work.blocks.all;

entity Memory is
	port (IMread_address, DMread_address: in STD_LOGIC_VECTOR(15 downto 0);
		mem_read, mem_write, Clock, Reset : in std_logic;
		write_data : in std_logic_vector(31 downto 0);
		IMready, DMready: out STD_LOGIC;
		instruction, data: out std_logic_vector(31 downto 0)
		--DMsearch_ram_debug : out std_logic;
		);
end Memory;

--}} End of automatically maintained section

architecture structural of Memory is	
	component InstructionMemory
		port (ready_ram: in STD_LOGIC;	 
			words_block: in word_block;
			address: in STD_LOGIC_VECTOR(15 downto 0);
			DMready: in STD_LOGIC;
			ready, search_ram: out STD_LOGIC;
			block_address: out STD_LOGIC_VECTOR (9 downto 0);
			instruction: out std_logic_vector(31 downto 0)
			);
	end component;
	component ram
		generic(
			BE 		: integer 	:= 16; 
			BP 		: integer 	:= 32 
			);
		port(
			read_en	: in 	std_logic;
			write	: in 	std_logic;
			ender 	: in 	std_logic_vector(BE - 1 downto 0);
			enderEscrita : in std_logic_vector(BE - 1 downto 0);
			pronto 	: out 	std_logic;
			prontoescrita : out std_logic;
			dadoout 	: out word_block;
			dadoin 	: in word_block
			);
	end component;
	
	component DataMemory is
	port (ready_ram, mem_write, mem_read, Clock, Reset, busy: in STD_LOGIC;	 
		words_block: in word_block;
		read_address : in STD_LOGIC_VECTOR(15 downto 0);
		ready, search_ram, write_back: out STD_LOGIC;
		block_address: out STD_LOGIC_VECTOR (9 downto 0);
		write_block: out word_block;
		write_data : in std_logic_vector(31 downto 0);
		data: out std_logic_vector(31 downto 0)
		);
	end component;
	
	component MemBuffer is
    port(enable,ready_write  : in STD_LOGIC;
        data_block_in        : in word_block;
        block_address_in     : in STD_LOGIC_VECTOR (9 downto 0);
        busy, write          : out STD_LOGIC := '0';
        block_address_out    : out STD_LOGIC_VECTOR (15 downto 0);
        data_block_out       : out word_block
        );
	end component;
	component Multiplexer2x1_16 is
    port (I0,I1: in std_logic_vector (15 downto 0);
	    Sel: in std_logic;
	    O: out std_logic_vector (15 downto 0));
	end component;
	
	
	signal read_block : word_block;
	signal DMblock_address : std_logic_vector(9 downto 0);
	signal IMblock_address : STD_LOGIC_VECTOR (9 downto 0);
	signal IMsearch_ram, DMsearch_ram, search_ram : std_logic;
	signal ready_ram, busy, ready_write, write_back, write: std_logic;
	signal DMwrite_block, BFwrite_block : word_block;
	signal DMblock_address_extended, IMblock_address_extended, BFblock_address, block_address : std_logic_vector(15 downto 0);
	signal dm_ready : std_logic;
	
begin
	
	DMblock_address_extended <= DMblock_address & "000000";
	IMblock_address_extended <= IMblock_address & "000000";
	search_ram <= IMsearch_ram or DMsearch_ram;
	
	MUX1 : Multiplexer2x1_16 port map (IMblock_address_extended, DMblock_address_extended, DMsearch_ram, block_address);
	DM : DataMemory port map (ready_ram, mem_write, mem_read, Clock, Reset, busy, read_block, DMread_address, dm_ready, DMsearch_ram, write_back, DMblock_address, DMwrite_block, write_data, data); 
	IM : InstructionMemory port map (ready_ram, read_block, IMread_address, dm_ready, IMready, IMsearch_ram, IMblock_address, instruction);
	BF : MemBuffer port map (write_back, ready_write, DMwrite_block, DMblock_address, busy, write, BFblock_address, BFwrite_block); 
	RAM1 : ram port map (search_ram, write, block_address, BFblock_address, ready_ram, ready_write, read_block, BFwrite_block);
	
	DMready <= dm_ready;
	
end structural;
