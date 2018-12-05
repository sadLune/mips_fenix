library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.alu_types_pack.all;

entity tb_vectorial_reg_bank is
end tb_vectorial_reg_bank;

architecture arch of tb_vectorial_reg_bank is
--tope
component vectorial_register_bank is
	port( 
		Read_reg_1	: in  std_logic_vector(5 downto 0);
		Read_reg_2	: in  std_logic_vector(5 downto 0);
		Write_reg	: in  std_logic_vector(5 downto 0);
		Write_data	: in  reg_vector;
		Reg_write	: in  std_logic;
		Reset		: in  std_logic;
		Clock		: in  std_logic;
		Read_data_1	: out reg_vector;
		Read_data_2	: out reg_vector
		);
end component;
component stimuli_vectorial_reg_bank is
	port
	(
		Read_reg_1_stim	: out  std_logic_vector(5 downto 0);
		Read_reg_2_stim	: out  std_logic_vector(5 downto 0);
		Write_reg_stim	: out  std_logic_vector(5 downto 0);
		Write_data_stim	: out  reg_vector;
		Reg_write_stim	: out  std_logic;
		Reset_stim		: out  std_logic;
		Clock_stim		: out  std_logic
	);
end component;
signal	read_reg_1_s	:  std_logic_vector(5 downto 0);
signal	read_reg_2_s	:  std_logic_vector(5 downto 0);
signal	write_reg_s		:  std_logic_vector(5 downto 0);
signal	write_data_s	:  reg_vector;
signal	reg_write_s		:  std_logic;
signal	reset_s			:  std_logic;
signal	clock_s			:  std_logic;
signal	read_data_1_s	:  reg_vector;
signal	read_data_2_s	:  reg_vector;

begin

	DP : vectorial_register_bank port map (read_reg_1_s, read_reg_2_s, write_reg_s, write_data_s, reg_write_s, reset_s, clock_s, read_data_1_s, read_data_2_s);
	stimuli : stimuli_vectorial_reg_bank port map(read_reg_1_s, read_reg_2_s, write_reg_s, write_data_s, reg_write_s, reset_s, clock_s);
	
end arch;