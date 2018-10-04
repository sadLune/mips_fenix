library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all; 
use IEEE.STD_LOGIC_ARITH.all;
use work.blocks.all;

entity DataMemory is
	port (ready_ram, mem_write, mem_read, Clock, Reset, busy: in STD_LOGIC;	 
		words_block: in word_block;
		read_address: in STD_LOGIC_VECTOR(15 downto 0);
		ready  : out std_logic := '1';
		search_ram, write_back: out STD_LOGIC;
		block_address: out STD_LOGIC_VECTOR (9 downto 0);
		write_block: out word_block;
		write_data : in std_logic_vector(31 downto 0);
		data: out std_logic_vector(31 downto 0)
		);
end DataMemory;

--}} End of automatically maintained section

architecture behavioral of DataMemory is	
	type block_array is array(127 downto 0) of word_block;
	type onebit_array is array(127 downto 0) of std_logic;
	type tag_array is array(127 downto 0) of std_logic_vector(2 downto 0);
	signal LRU : onebit_array := (others => '0');
	signal tag1 : tag_array;
	signal valid1 : onebit_array := (others => '0');
	signal dirtybit1 : onebit_array := (others => '0');
	signal memory1 : block_array;
	signal tag2 : tag_array;
	signal valid2 : onebit_array := (others => '0');
	signal dirtybit2 : onebit_array := (others => '0');
	signal memory2 : block_array;
	signal temp_mem_read : std_logic := '0';
	signal temp_mem_write : std_logic := '0';
	signal temp_ready : std_logic := '1';
	
	signal temp_read_address: STD_LOGIC_VECTOR(15 downto 0);
	
begin

	temp_read_address <= read_address;
					 
	process (temp_ready, Reset)
	begin
		if Reset = '1' then
			ready <= '1';
		else
			ready <= temp_ready;
		end if;
	end process;
	
	process (Reset, temp_read_address, ready_ram, mem_read, temp_mem_write, busy)
	begin
		if busy = '0' then
			write_back <= '0';
		end if;
		if Reset = '1' then
			search_ram <= '0';
			write_back <= '0';
		else
			if mem_read = '1' then -- le o cache
				if (valid1(conv_integer(temp_read_address(12 downto 6))) = '1') and (tag1(conv_integer(temp_read_address(12 downto 6))) = read_address(15 downto 13)) then -- achou no bloco 1	
					data <= memory1(conv_integer(temp_read_address(12 downto 6)))(conv_integer(temp_read_address(5 downto 2)));
					LRU(conv_integer(temp_read_address(12 downto 6))) <= '0';
					temp_ready <= '1';
				elsif (valid2(conv_integer(temp_read_address(12 downto 6))) = '1') and ((tag2(conv_integer(temp_read_address(12 downto 6))) = read_address(15 downto 13))) then	-- achou no bloco 2
					data <= memory2(conv_integer(temp_read_address(12 downto 6)))(conv_integer(temp_read_address(5 downto 2)));
					LRU(conv_integer(temp_read_address(12 downto 6))) <= '1';
					temp_ready <= '1';
				else -- nao achou em nenhum bloco
					--ready <= '0';	-- procura o bloco na ram
					
					if (LRU(conv_integer(temp_read_address(12 downto 6))) = '1') then -- o bloco um vai ser substituido
						if (dirtybit1(conv_integer(temp_read_address(12 downto 6))) = '1') then	-- eh dirty bit
							if (busy = '0') then  -- buffer nao ta ocupado
								-- escreve no buffer
								write_block <= memory1(conv_integer(temp_read_address(12 downto 6))); 
								write_back <= '1';
								block_address <= temp_read_address(15 downto 6);
								search_ram <= '1';
								temp_ready <= '0';
								if ready_ram'event and ready_ram = '1' then
									-- substitui na memoria 
									LRU(conv_integer(temp_read_address(12 downto 6))) <= '0';
									memory1(conv_integer(temp_read_address(12 downto 6))) <= words_block;
									tag1(conv_integer(temp_read_address(12 downto 6))) <= temp_read_address(15 downto 13);
									valid1(conv_integer(temp_read_address(12 downto 6))) <= '1';
									temp_ready <= '1';
									data <= words_block(conv_integer(temp_read_address(5 downto 2)));
									search_ram <= '0';
								end if;
							end if;
						elsif (dirtybit1(conv_integer(temp_read_address(12 downto 6))) = '0') then -- nao tem dirty bit
							block_address <= temp_read_address(15 downto 6);
							search_ram <= '1';
							temp_ready <= '0';	
							if ready_ram'event and ready_ram = '1' then
								-- substitui na memoria 
								LRU(conv_integer(temp_read_address(12 downto 6))) <= '0';
								memory1(conv_integer(temp_read_address(12 downto 6))) <= words_block;
								tag1(conv_integer(temp_read_address(12 downto 6))) <= temp_read_address(15 downto 13);
								valid1(conv_integer(temp_read_address(12 downto 6))) <= '1';
								temp_ready <= '1';
								data <= words_block(conv_integer(temp_read_address(5 downto 2)));
								search_ram <= '0';
							end if;
						end if;
					elsif (LRU(conv_integer(temp_read_address(12 downto 6))) = '0') then	  -- bloco dois vai ser substituido
						if (dirtybit2(conv_integer(temp_read_address(12 downto 6))) = '1') then	-- eh dirty bit
							if (busy = '0') then  -- buffer nao ta ocupado
								-- escreve no buffer
								write_block <= memory2(conv_integer(temp_read_address(12 downto 6))); 
								write_back <= '1';
								block_address <= temp_read_address(15 downto 6);
								search_ram <= '1';
								temp_ready <= '0';
								if ready_ram'event and ready_ram = '1' then
									-- substitui na memoria 
									LRU(conv_integer(temp_read_address(12 downto 6))) <= '1';
									memory2(conv_integer(temp_read_address(12 downto 6))) <= words_block;
									tag2(conv_integer(temp_read_address(12 downto 6))) <= temp_read_address(15 downto 13);
									valid2(conv_integer(temp_read_address(12 downto 6))) <= '1';
									temp_ready <= '1';
									data <= words_block(conv_integer(temp_read_address(5 downto 2)));
									search_ram <= '0';
								end if;
							end if;
						elsif (dirtybit2(conv_integer(temp_read_address(12 downto 6))) = '0') then -- nao tem dirty bit
							block_address <= temp_read_address(15 downto 6);
							search_ram <= '1';
							temp_ready <= '0';
							if ready_ram'event and ready_ram = '1' then
								-- substitui na memoria 
								LRU(conv_integer(temp_read_address(12 downto 6))) <= '1';
								memory2(conv_integer(temp_read_address(12 downto 6))) <= words_block;
								tag2(conv_integer(temp_read_address(12 downto 6))) <= temp_read_address(15 downto 13);
								valid2(conv_integer(temp_read_address(12 downto 6))) <= '1';
								temp_ready <= '1';
								data <= words_block(conv_integer(temp_read_address(5 downto 2)));
								search_ram <= '0';
							end if;
						end if;				
					end if;
				end if;
			elsif temp_mem_write = '1' then
				if (valid1(conv_integer(temp_read_address(12 downto 6))) = '1') and (tag1(conv_integer(temp_read_address(12 downto 6))) = temp_read_address(15 downto 13)) then
					memory1(conv_integer(temp_read_address(12 downto 6)))(conv_integer(temp_read_address(5 downto 2))) <= write_data;
					dirtybit1(conv_integer(temp_read_address(12 downto 6))) <= '1';
					LRU(conv_integer(temp_read_address(12 downto 6))) <= '0';
					temp_ready <= '1';
				elsif (valid2(conv_integer(temp_read_address(12 downto 6))) = '1') and (tag2(conv_integer(temp_read_address(12 downto 6))) = temp_read_address(15 downto 13)) then
					memory2(conv_integer(temp_read_address(12 downto 6)))(conv_integer(temp_read_address(5 downto 2))) <= write_data;
					dirtybit2(conv_integer(temp_read_address(12 downto 6))) <= '1';
					LRU(conv_integer(temp_read_address(12 downto 6))) <= '1';
					temp_ready <= '1';
				else -- nao achou nos blocos precisa buscar
					--ready <= '0';
					if (LRU(conv_integer(temp_read_address(12 downto 6))) = '1') then
						if (dirtybit1(conv_integer(temp_read_address(12 downto 6))) = '1') then
							if (busy = '0') then
								block_address <= temp_read_address(15 downto 6);
								search_ram <= '1';
								temp_ready <= '0';
								-- escreve no buffer
								write_block <= memory1(conv_integer(temp_read_address(12 downto 6)));
								write_back <= '1';
								-- 
								if ready_ram'event and ready_ram = '1' then
									dirtybit1(conv_integer(temp_read_address(12 downto 6))) <= '1';
									memory1(conv_integer(temp_read_address(12 downto 6))) <= words_block;
									tag1(conv_integer(temp_read_address(12 downto 6))) <= temp_read_address(15 downto 13);
									valid1(conv_integer(temp_read_address(12 downto 6))) <= '1';
									memory1(conv_integer(temp_read_address(12 downto 6)))(conv_integer(temp_read_address(5 downto 2))) <= write_data;
									LRU(conv_integer(temp_read_address(12 downto 6))) <= '0';
									search_ram <= '0';
									temp_ready <= '1';
								end if;
							end if;
						elsif (dirtybit1(conv_integer(temp_read_address(12 downto 6))) = '0') then
							block_address <= temp_read_address(15 downto 6);
							search_ram <= '1';
							temp_ready <= '0';
							if ready_ram'event and ready_ram = '1' then
								dirtybit1(conv_integer(temp_read_address(12 downto 6))) <= '1';
								memory1(conv_integer(temp_read_address(12 downto 6))) <= words_block;
								tag1(conv_integer(temp_read_address(12 downto 6))) <= temp_read_address(15 downto 13);
								valid1(conv_integer(temp_read_address(12 downto 6))) <= '1';
								memory1(conv_integer(temp_read_address(12 downto 6)))(conv_integer(temp_read_address(5 downto 2))) <= write_data;
								LRU(conv_integer(temp_read_address(12 downto 6))) <= '0';
								search_ram <= '0';
								temp_ready <= '1';
							end if;
						end if;
					elsif LRU(conv_integer(temp_read_address(12 downto 6))) = '0' then	
						if dirtybit2(conv_integer(temp_read_address(12 downto 6))) = '1' then
							if busy = '0' then
								block_address <= temp_read_address(15 downto 6);
								search_ram <= '1';
								temp_ready <= '0';
								write_block <= memory2(conv_integer(temp_read_address(12 downto 6)));
								write_back <= '1';
								if ready_ram'event and ready_ram = '1' then
									dirtybit2(conv_integer(temp_read_address(12 downto 6))) <= '1';
									memory2(conv_integer(temp_read_address(12 downto 6))) <= words_block;
									tag2(conv_integer(temp_read_address(12 downto 6))) <= temp_read_address(15 downto 13);
									valid2(conv_integer(temp_read_address(12 downto 6))) <= '1';
									memory2(conv_integer(temp_read_address(12 downto 6)))(conv_integer(temp_read_address(5 downto 2))) <= write_data;
									LRU(conv_integer(temp_read_address(12 downto 6))) <= '1';
									search_ram <= '0';
									temp_ready <= '1';
								end if;
							end if;
						elsif dirtybit2(conv_integer(temp_read_address(12 downto 6))) = '0' then
							block_address <= temp_read_address(15 downto 6);
							search_ram <= '1';
							temp_ready <= '0';
							if ready_ram'event and ready_ram = '1' then
								dirtybit2(conv_integer(temp_read_address(12 downto 6))) <= '1';
								memory2(conv_integer(temp_read_address(12 downto 6))) <= words_block;
								tag2(conv_integer(temp_read_address(12 downto 6))) <= temp_read_address(15 downto 13);
								valid2(conv_integer(temp_read_address(12 downto 6))) <= '1';
								memory2(conv_integer(temp_read_address(12 downto 6)))(conv_integer(temp_read_address(5 downto 2))) <= write_data;
								LRU(conv_integer(temp_read_address(12 downto 6))) <= '1';
								search_ram <= '0';
								temp_ready <= '1';
							end if;
						end if;
					end if;
				end if;
			end if;
		end if;
	end process;
	
	temp_mem_write<= mem_write;
	
end behavioral;
