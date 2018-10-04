library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all; 
use IEEE.STD_LOGIC_ARITH.all;
use work.blocks.all;

entity BranchPredictor is
	port (op_code: in STD_LOGIC_VECTOR(5 downto 0);	 
		branch_taken, CLK_delayed, CLK: in STD_LOGIC;
		branch_PC, current_PC, branch_target, jump_target: in STD_LOGIC_VECTOR(31 downto 0);
		flush: out STD_LOGIC;	   
		next_PC: out std_logic_vector(31 downto 0)
	);
end BranchPredictor;

--}} End of automatically maintained section

architecture behavioral of BranchPredictor is	
	type branch_array is array(15 downto 0) of std_logic_vector(31 downto 0);
	type valid_array is array(15 downto 0) of std_logic;
	type tag_array is array(15 downto 0) of std_logic_vector(9 downto 0);	
	type state_array is array(15 downto 0) of std_logic_vector(1 downto 0);
	signal tag : tag_array;
	signal valid : valid_array;
	signal state : state_array := (others => "00");
	signal branch : branch_array;
	signal next_PC1 : std_logic_vector(31 downto 0); 
	--signal flush_i : std_logic;
	
begin
process (op_code, branch_PC, CLK_delayed, CLK)
	begin	
		if (tag(conv_integer(current_PC(5 downto 2))) = current_PC(15 downto 6)) and (valid(conv_integer(current_PC(5 downto 2))) = '1') and (state(conv_integer(current_PC(5 downto 2)))(1) = '1') then 	
			next_PC <= branch(conv_integer(current_PC(5 downto 2)));
		else 
			next_PC <= current_PC + "100";
		end if;	
				  		
		flush <= '0';
		
		
		if (op_code = "000100" or op_code = "000101") and (tag(conv_integer(branch_PC(5 downto 2))) /= branch_PC(15 downto 6)) and CLK'event and CLK = '0' then
			branch(conv_integer(branch_PC(5 downto 2))) <= branch_target;
			valid(conv_integer(branch_PC(5 downto 2))) <= '1';
			tag(conv_integer(branch_PC(5 downto 2))) <= branch_PC(15 downto 6);
			state(conv_integer(branch_PC(5 downto 2))) <= "00";
		elsif (op_code = "000010" or op_code = "000011") and (tag(conv_integer(branch_PC(5 downto 2))) /= branch_PC(15 downto 6)) and CLK'event and CLK = '0' then
			branch(conv_integer(branch_PC(5 downto 2))) <= jump_target;
			valid(conv_integer(branch_PC(5 downto 2))) <= '1';
			tag(conv_integer(branch_PC(5 downto 2))) <= branch_PC(15 downto 6);	
			state(conv_integer(branch_PC(5 downto 2))) <= "10";
		end if;
		
		
		if (tag(conv_integer(branch_PC(5 downto 2))) = branch_PC(15 downto 6)) and (valid(conv_integer(branch_PC(5 downto 2))) = '1') and (CLK = '0') and CLK_delayed'event then
			if (op_code = "000010" or op_code = "000011") and state(conv_integer(branch_PC(5 downto 2))) = "10" then 
				flush <= '1';
				next_PC <= jump_target;	
				--branch(conv_integer(branch_PC(5 downto 2))) <= jump_target;
			elsif op_code /= "000010" and op_code /= "000011" and branch_taken = '0' and state(conv_integer(branch_PC(5 downto 2)))(1) = '1' then	 
				flush <= '1'; 			  
				next_PC <= branch_PC + "100";
			elsif op_code /= "000010" and op_code /= "000011" and branch_taken = '1' and state(conv_integer(branch_PC(5 downto 2)))(1) = '0' then
				flush <= '1';  			 
				next_PC <= branch_target; 
				--branch(conv_integer(branch_PC(5 downto 2))) <= branch_target;
			end if;
			--state(conv_integer(branch_PC(5 downto 2))) <= "11"; 
			if (op_code /= "000010" and op_code /= "000011") then 	
				case state(conv_integer(branch_PC(5 downto 2))) is
					when "00" =>
						if branch_taken = '1' then 
							state(conv_integer(branch_PC(5 downto 2))) <= "01"; 
						else 
							state(conv_integer(branch_PC(5 downto 2))) <= "00"; 
						end if;										   
					when "01" =>
						if branch_taken = '1' then 
							state(conv_integer(branch_PC(5 downto 2))) <= "10"; 
						else 
							state(conv_integer(branch_PC(5 downto 2))) <= "00"; 
						end if;	 
					when "10" => 	 
						if branch_taken = '1' then 
							state(conv_integer(branch_PC(5 downto 2))) <= "11"; 
						else 
							state(conv_integer(branch_PC(5 downto 2))) <= "01"; 
						end if;	 
					when "11" =>
						if branch_taken = '1' then 
							state(conv_integer(branch_PC(5 downto 2))) <= "11"; 
						else 
							state(conv_integer(branch_PC(5 downto 2))) <= "10"; 
						end if;
					when others =>
						state(conv_integer(branch_PC(5 downto 2))) <= "00";
				end case;	
			else 
				if state(conv_integer(branch_PC(5 downto 2))) = "10" then
					state(conv_integer(branch_PC(5 downto 2))) <= "11";
				end if;
			end if;
		end if;		
end process; 

--process(op_code, branch_PC, CLK_delayed, CLK, flush_i) 	
--	begin
--	if (tag(conv_integer(branch_PC(5 downto 2))) = branch_PC(15 downto 6)) and (valid(conv_integer(branch_PC(5 downto 2))) = '1') and (CLK_delayed = '0') then
--			if (op_code = "000010" or op_code = "000011") and state(conv_integer(branch_PC(5 downto 2))) = "10" then 
--				if CLK_delayed'event and CLK_delayed = '0' then
--					flush_i <= '1';								
--				else 
--					flush_i <= '0';
--				end if;
--				--branch(conv_integer(branch_PC(5 downto 2))) <= jump_target;
--			elsif branch_taken = '0' and state(conv_integer(branch_PC(5 downto 2)))(1) = '1' then	 
--				if CLK_delayed'event and CLK_delayed = '0' then
--					flush_i <= '1';								
--				else 
--					flush_i <= '0';
--				end if;  			  	
--			elsif branch_taken = '1' and state(conv_integer(branch_PC(5 downto 2)))(1) = '0' then
--				if CLK_delayed'event and CLK_delayed = '0' then
--					flush_i <= '1';								
--				else 
--					flush_i <= '0';
--				end if;  			 		 
--				--branch(conv_integer(branch_PC(5 downto 2))) <= branch_target;
--			end if;	
--		end if;	
--end process;

-- flush <= flush_i;

end behavioral;