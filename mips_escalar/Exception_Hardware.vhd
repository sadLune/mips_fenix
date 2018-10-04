-------------------------------------------------------------------------------
--
-- Title       : excception_hardware
-- Design      : exception_hardware
-- Author      : Gabriel Paliari
-- Group       : Diego, Gabriel, Jonathan, Larissa
--
-------------------------------------------------------------------------------
--
-- File        : c:\My_Designs\OrgArq\exception_hardware\src\excception_hardware.vhd
-- Generated   : Fri Oct 13 19:06:40 2017
--
-------------------------------------------------------------------------------
--
-- Description : Implementa o controle do tratamento de exceções 
--               utilizando uma	máquina de estados
--				 															   
-------------------------------------------------------------------------------

library IEEE;
use IEEE.numeric_bit.all;
use IEEE.STD_LOGIC_1164.ALL;   
USE ieee.std_logic_unsigned.ALL;

ENTITY Exception_Hardware IS
	PORT(Clk	 : in 	std_logic;
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
END Exception_Hardware;

ARCHITECTURE State_Machine OF Exception_Hardware IS
	TYPE STATE_TYPE IS (s0, I1, I2, H, E1, E2, E3);
   	SIGNAL state : STATE_TYPE;
BEGIN
   PROCESS (Clk, Reset, Request, Overflow, Exc_end)
   BEGIN
      IF Reset = '1' THEN
         state <= s0; -- Estado de espera
	  ELSIF Reset = '0' THEN
		  CASE state IS
	      	WHEN s0=>
			  IF Overflow = '1' THEN
			 	  state <= I1;
			  ELSIF Request = '1' THEN
				  state <= E1; -- Estado 1 de causa externa
	          END IF;
			WHEN E1=>
			  IF Overflow = '1' THEN
			 	  state <= I1;
			  ELSIF (Clk'EVENT and Clk = '1') THEN
				state <= E2;   -- Estado 2 de causa externa
			  END IF;
	        WHEN E2=>
			  IF Overflow = '1' THEN
			 	  state <= I1;
			  ELSIF Exc_end = '1' THEN
				state <= E3;   -- Estado 3 de causa externa
			  END IF;
			WHEN E3=>
			  IF Overflow = '1' THEN
			 	  state <= I1;
			  ELSIF (Clk'EVENT and Clk = '1') THEN
				state <= s0;   -- Volta ao estado de espera;
			  END IF;
			
			WHEN I1=>
			  IF (Clk'EVENT and Clk = '1') THEN
				state <= I2;   -- Estado 2 de causa interna
			  END IF;
	        WHEN I2=>
			  IF Overflow = '1' THEN
			 	  state <= I1;
			  ELSIF Exc_end = '1' THEN
				state <= H;	   -- Estado 1 de Halt
			  END IF;
			WHEN H=>
			  state <= H;	   -- Mantem a máquina nesse estado
	      END CASE;
	  END IF;
   END PROCESS;
   
   PROCESS (state)
   BEGIN
      CASE state IS
		 -- S0: Zera todos os sinais e espera por uma exceção (até Request ou overflow se tornar 1)
         WHEN s0 =>			
            Busy     <= '0';
			EPC_write<= '0';
			RC_write <= '0';
			Flush	 <= '0';
			PC_ctrl	 <= "00";
			EXC_addr <= x"00000000";
			Cause    <= x"00000000";
			State_id <= "000";
			Enable_UC<= '1';
		
		 -- E1: Ativa o sinal de Busy, escreve a causa no RC, o endereço do vetor de exc. no EPC, 
		 -- seleciona o dado do EPC para ser gravado no PC e espera um Clock 
         WHEN E1 =>
            Busy     <= '1';
			EPC_write<= '1';
			RC_write <= '1';
			PC_ctrl	 <= "01";
			EXC_addr <= x"0001000" & Exc_id;
			Cause    <= x"0000000" & Exc_id;
			State_id <= "100";
		
		 -- E2: Volta os sinais que controlam os registradores para 0,
		 -- seleciona o dado do programa no PC e aguarda pelo final do tratamento (Exc_end = 1)
         WHEN E2 =>
			EPC_write<= '0';
			RC_write <= '0';
			PC_ctrl	 <= "00";
			State_id <= "101";
		
		 -- E3: Seleciona o dado do EPC no PC e aguarda pelo clock para ser gravado
		 WHEN E3 =>	
		 	PC_ctrl	 <= "10";
		 	State_id <= "110";
		 
		 -- I1: Ativa o sinal de Busy, escreve a causa no RC, o endereço do vetor de exc. no EPC, 
		 -- seleciona o dado do EPC para ser gravado no PC e espera um Clock. Ativa o sinal de Flush 
		 WHEN I1 =>
            Busy     <= '1';
			EPC_write<= '1';
			RC_write <= '1';
			PC_ctrl	 <= "01"; 
			Flush 	 <= '1';
			EXC_addr <= x"00001000"; -- Definir o endereço de tratamento de overflow
			Cause    <= x"10000000"; -- Definir o número de causa de overflow
			State_id <= "001";
			
		 -- I2: Volta os sinais que controlam os registradores para 0, desativa o Flush,
		 -- seleciona o dado do programa no PC e aguarda pelo final do tratamento (Exc_end = 1)	
         WHEN I2 =>
			EPC_write<= '0';
			RC_write <= '0';
			PC_ctrl	 <= "00";
			Flush 	 <= '0';
			State_id <= "010";
			
		 -- HALT: Seleciona o dado do EPC no PC e permanece nesse estado
		 WHEN H =>	
		 	PC_ctrl	 <= "10";
		 	State_id <= "011";
			Enable_UC<= '0';
			 
			 
      END CASE;
   END PROCESS;									   
END State_Machine;	