library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all; 
use IEEE.STD_LOGIC_ARITH.all;
use work.blocks.all;

entity InstructionMemory is
	port (ready_ram: in STD_LOGIC;	 
		words_block: in word_block;
		address: in STD_LOGIC_VECTOR(15 downto 0);
		DMready: in STD_LOGIC;
		ready, search_ram: out STD_LOGIC;
		block_address: out STD_LOGIC_VECTOR (9 downto 0);
		instruction: out std_logic_vector(31 downto 0)
	);
end InstructionMemory;

--}} End of automatically maintained section

architecture behavioral of InstructionMemory is	
	type block_array is array(255 downto 0) of word_block;
	type valid_array is array(255 downto 0) of std_logic;
	type tag_array is array(255 downto 0) of std_logic_vector(1 downto 0);
	signal tag : tag_array;
	signal valid : valid_array;
	signal memory : block_array;
	signal address_i : std_logic_vector(15 downto 0);
	
begin

	address_i <= address after 1ns;

process (address_i, ready_ram)
	begin
		if (DMready = '1') then
			if (valid(conv_integer(address_i(13 downto 6))) = '1') and (tag(conv_integer(address_i(13 downto 6))) = address_i(15 downto 14)) then 	
				instruction <= memory(conv_integer(address(13 downto 6)))(conv_integer(address(5 downto 2)));
				ready <= '1';
			else
				ready <= '0';
				block_address <= address(15 downto 6);
				search_ram <= '1';
				if ready_ram'event and ready_ram = '1' then
					memory(conv_integer(address(13 downto 6))) <= words_block;
					tag(conv_integer(address(13 downto 6))) <= address(15 downto 14);
					valid(conv_integer(address(13 downto 6))) <= '1';
					ready <= '1';
					instruction <= words_block(conv_integer(address(5 downto 2)));
					search_ram <= '0';
				end if;
			end if;
		end if;
	end process;									  
end behavioral;
