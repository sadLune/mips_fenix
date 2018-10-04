-------------------------------------------------------------------------------
-- Design unit header --
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_signed.all;
--use ieee.std_logic_arith.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.blocks.all;

entity Ram is
	generic(
		BE 		: integer 	:= 16; 
		BP 		: integer 	:= 32; 
		NA		: string 	:= "mram.txt";  -- Nome do arquivo a ser lido
		Tz 		: time 		:= 1.5 ns; 
		Twrite 	: time 		:= 23 ns; 
		Tsetup 	: time 		:= 1 ns;
		Tprop   : time      := 1 ns;
		Tread 	: time  	:= 23 ns 
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
end Ram;

architecture Ram of Ram is
	
	---- Architecture declarations -----
	type 	tipo_memoria  is array (0 to 2**BE - 1) of std_logic_vector(BP/4 - 1 downto 0);
	signal Mram: tipo_memoria := ( others  => (others => '0')) ;
	
	
begin
	
	---- Processes ----
	Carga_Inicial_e_Ram_Memoria :process (read_en, write, ender) 
		variable endereco: integer range 0 to (2**BE - 1);
		variable enderecoEscrita: integer range 0 to (2**BE - 1);
		variable inicio: std_logic := '1';
		procedure fill_memory (signal Mem: inout tipo_memoria) is
			type HexTable is array (character range <>) of integer;
			-- Caracteres HEX válidos: o, 1, 2 , 3, 4, 5, 6, 6, 7, 8, 9, A, B, C, D, E, F  (somente caracteres maiúsculos)
			constant lookup: HexTable ('0' to 'F') :=
			(0, 1, 2, 3, 4, 5, 6, 7, 8, 9, -1, -1, -1, -1, -1, -1, -1, 10, 11, 12, 13, 14, 15);
			file infile: text open read_mode is NA; -- Abre o arquivo para leitura
			variable buff: line; 
			variable addr_s: string ((BE/4 + 1) downto 1); -- Digitos de endereço mais um espaço
			variable data_s: string ((BP/4 + 1) downto 1); -- ùltimo byte sempre tem um espaço separador
			variable addr_1, pal_cnt: integer;
			variable data: unsigned (BP - 1 downto 0); -- (2**BP - 1) downto 0
		begin
			while (not endfile(infile)) loop
				readline(infile,buff); -- Lê um linha do infile e coloca no buff
				read(buff, addr_s); -- Leia o conteudo de buff até encontrar um espaço e atribui à addr_s, ou seja, leio o endereço
				read(buff, pal_cnt); -- Leia o número de bytes da próxima linha
				-- addr_1 := lookup(addr_s(4)) * 4096 + lookup(addr_s(3)) * 256 + lookup(addr_s(2)) * 16 + lookup(addr_s(1));
				addr_1 := 0;
				for i in (BE/4 + 1) downto 2 loop
					addr_1 := addr_1 + lookup(addr_s(i))*16**(i - 2);
				end loop;
				readline(infile, buff);
				for i in 1 to pal_cnt loop
					read(buff, data_s); -- Leia dois dígitos Hex e o espaço separador
					-- data := lookup(data_s(3)) * 16 + lookup(data_s(2)); -- Converte o valor lido em Hex para inteiro
					data := x"00000000";
					data := data + lookup(data_s(2*i)) + lookup(data_s(2*i+1))*16;
					--for i in (BP/4 + 1) downto 2 loop		-- BP/4 + 1
					--	data := data + lookup(data_s(i))*16**(i-2);
					--end loop;
					Mem(addr_1) <= STD_LOGIC_VECTOR(to_unsigned(to_integer(data),8));
					--Mem(addr_1) <= CONV_STD_LOGIC_VECTOR(data, 8); -- Converte o conteúdo da palavra para std_logic_vector
					addr_1 := addr_1 + 1;	-- Endereça a próxima palavra a ser carregada
				end loop;
			end loop;
		end fill_memory;
		
	begin
		if inicio = '1' then
			-- Roda somente uma vez na inicialização
			fill_memory(Mram);
			-- Insere o conteúdo na memória
			inicio := '0';
		end if;
		if read_en = '1' then
			endereco := to_integer(unsigned(ender));
			--endereco := CONV_INTEGER(ender);
			-- Ciclo de Leitura
			dadoout(0) <= Mram(endereco+3) & Mram(endereco+2) & Mram(endereco+1) & Mram(endereco) after Tread;
			dadoout(1) <= Mram(endereco+7) & Mram(endereco+6) & Mram(endereco+5) & Mram(endereco+4) after Tread;
			dadoout(2) <= Mram(endereco+11) & Mram(endereco+10) & Mram(endereco+9) & Mram(endereco+8) after Tread;
			dadoout(3) <= Mram(endereco+15) & Mram(endereco+14) & Mram(endereco+13) & Mram(endereco+12) after Tread;
			dadoout(4) <= Mram(endereco+19) & Mram(endereco+18) & Mram(endereco+17) & Mram(endereco+16) after Tread;
			dadoout(5) <= Mram(endereco+23) & Mram(endereco+22) & Mram(endereco+21) & Mram(endereco+20) after Tread;
			dadoout(6) <= Mram(endereco+27) & Mram(endereco+26) & Mram(endereco+25) & Mram(endereco+24) after Tread;
			dadoout(7) <= Mram(endereco+31) & Mram(endereco+30) & Mram(endereco+29) & Mram(endereco+28) after Tread;
			dadoout(8) <= Mram(endereco+35) & Mram(endereco+34) & Mram(endereco+33) & Mram(endereco+32) after Tread;
			dadoout(9) <= Mram(endereco+39) & Mram(endereco+38) & Mram(endereco+37) & Mram(endereco+36) after Tread;
			dadoout(10) <= Mram(endereco+43) & Mram(endereco+42) & Mram(endereco+41) & Mram(endereco+40) after Tread;
			dadoout(11) <= Mram(endereco+47) & Mram(endereco+46) & Mram(endereco+45) & Mram(endereco+44) after Tread;
			dadoout(12) <= Mram(endereco+51) & Mram(endereco+50) & Mram(endereco+49) & Mram(endereco+48) after Tread;
			dadoout(13) <= Mram(endereco+55) & Mram(endereco+54) & Mram(endereco+53) & Mram(endereco+52) after Tread;
			dadoout(14) <= Mram(endereco+59) & Mram(endereco+58) & Mram(endereco+57) & Mram(endereco+56) after Tread;
			dadoout(15) <= Mram(endereco+63) & Mram(endereco+62) & Mram(endereco+61) & Mram(endereco+60) after Tread;
			pronto <= '1' after Tread;
		else 
			pronto <= '0' after Tprop;
		end if;
		
		if write = '1' then    --Ciclo de Escrita 
		enderecoEscrita := to_integer(unsigned(enderEscrita));
            --enderecoEscrita := conv_integer(enderEscrita);
            for i in 0 to 15 loop
                Mram(enderecoEscrita+i*4) <= dadoin(i)(7 downto 0) after Twrite;
                Mram(enderecoEscrita+1+i*4) <= dadoin(i)(15 downto 8) after Twrite;
                Mram(enderecoEscrita+2+i*4) <= dadoin(i)(23 downto 16) after Twrite;
                Mram(enderecoEscrita+3+i*4) <= dadoin(i)(31 downto 24) after Twrite;
            end loop;
            prontoescrita <= '1' after Twrite;
        else 
            prontoescrita <= '0' after Tprop;
        end if;
	end process;
	
end Ram;
