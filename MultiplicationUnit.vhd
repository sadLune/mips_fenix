library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

entity MultiplicationUnit is
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
end MultiplicationUnit;

architecture arch_MultiplicationUnit of MultiplicationUnit is
	signal	Ai,Bi: std_logic_vector(31 downto 0);
	signal  SigA2,SigB2,SigA3,SigB3,SigAS,SigBS: std_logic;
	signal	Enable2,Enable3,Readyi: std_logic;
	signal	A0B,A1B,A2B,A3B,A4B,A5B,A6B,A7B,A8B,A9B,A10B,A11B,A12B,A13B,A14B,A15B: signed(15 downto 0);
	signal	Ai2,Bi2: signed(31 downto 0);
	signal  Oi: std_logic_vector(31 downto 0);
	signal EXBjumpandlink_out2,EXBmemtoreg_out2,EXBregwrite_out2: std_logic;
	signal EXBregdest_out2: std_logic_vector (1 downto 0);
	signal EXBinst_20_11_out2: std_logic_vector (9 downto 0);
	signal EXBjumpandlink_out3,EXBmemtoreg_out3,EXBregwrite_out3: std_logic;
	signal EXBregdest_out3: std_logic_vector (1 downto 0);
	signal EXBinst_20_11_out3: std_logic_vector (9 downto 0);
	begin

	process(Clock,Reset)
		begin
		if Reset = '1' then
		Ai <= x"00000000";
		Bi <= x"00000000";
		SigA2 <= '0';
		SigB2 <= '0';
		SigA3 <= '0';
		SigB3 <= '0';
		SigAS <= '0';
		SigBS <= '0';
		Enable2 <= '0';
		Enable3 <= '0';
		Ready <= '0';
		Overflow <= '0';
		Ai2 <= x"00000000";
		Bi2 <= x"00000000";
		A0B <= x"0000";
		A1B <= x"0000";
		A2B <= x"0000";
		A3B <= x"0000";
		A4B <= x"0000";
		A5B <= x"0000";
		A6B <= x"0000";
		A7B <= x"0000";
		A8B <= x"0000";
		A9B <= x"0000";
		A10B <= x"0000";
		A11B <= x"0000";
		A12B <= x"0000";
		A13B <= x"0000";
		A14B <= x"0000";
		A15B <= x"0000";
		Oi <= x"00000000";
		elsif Clock'event and Clock = '1' then
			if Enable = '1' then
				--Salvando o sinal das Entradas
				--Ainput2 <= A;
				--Binput2 <= B;
				SigA2 <= A(31);
				SigB2 <= B(31);
				
				-- Complemento de 2
				if A(31) = '1' and B(31) = '1'  then
					Ai <= std_logic_vector(unsigned(not(A)) + 1);
					Bi <= std_logic_vector(unsigned(not(B)) + 1);
				elsif A(31) = '1' and B(31) = '0' then
					Ai <= std_logic_vector(unsigned(not(A)) + 1);
					Bi <= B;
				elsif A(31) = '0' and B(31) = '1' then
					Ai <= A;
					Bi <= std_logic_vector(unsigned(not(B)) + 1);
				else
					Ai <= A;
					Bi <= B;
				end if;
			end if;
			if Enable2 = '1' then
			-- Salvando Sinais das Entradas
			SigA3 <= SigA2;
			SigB3 <= SigB2;
			end if;
			if Enable3 = '1' then
			-- Salvando Sinais das Entradas e Overflow
			SigAS <= SigA3;
			SigBS <= SigB3;
			end if;
		elsif Clock'event and Clock = '0' then
			if Enable = '1' then
				-- Teste de Overflow
				--Overflow <= (or_reduce (Ai(31 downto 16))) or (or_reduce (Bi(31 downto 16)));
				if ((SigA2 = '0') and (unsigned(Ai) > 65535)) or ((SigB2 = '0') and (unsigned(Bi) > 65535)) or
                   		((SigA2 = '1') and (unsigned(Ai) > 32767)) or ((SigB2 = '1') and (unsigned(Bi) > 32767)) then
					Overflow <= '1';
				else
					Overflow <= '0';
				end if;

				-- Calculo dos produtos parciais
				A0B <= signed((15 downto 0 => Ai(0)) and Bi(15 downto 0));
				A1B <= signed((15 downto 0 => Ai(1)) and Bi(15 downto 0));
				A2B <= signed((15 downto 0 => Ai(2)) and Bi(15 downto 0));
				A3B <= signed((15 downto 0 => Ai(3)) and Bi(15 downto 0));
				A4B <= signed((15 downto 0 => Ai(4)) and Bi(15 downto 0));
				A5B <= signed((15 downto 0 => Ai(5)) and Bi(15 downto 0));
				A6B <= signed((15 downto 0 => Ai(6)) and Bi(15 downto 0));
				A7B <= signed((15 downto 0 => Ai(7)) and Bi(15 downto 0));
				A8B <= signed((15 downto 0 => Ai(8)) and Bi(15 downto 0));
				A9B <= signed((15 downto 0 => Ai(9)) and Bi(15 downto 0));
				A10B <= signed((15 downto 0 => Ai(10)) and Bi(15 downto 0));
				A11B <= signed((15 downto 0 => Ai(11)) and Bi(15 downto 0));
				A12B <= signed((15 downto 0 => Ai(12)) and Bi(15 downto 0));
				A13B <= signed((15 downto 0 => Ai(13)) and Bi(15 downto 0));
				A14B <= signed((15 downto 0 => Ai(14)) and Bi(15 downto 0));
				A15B <= signed((15 downto 0 => Ai(15)) and Bi(15 downto 0));
			end if;
			if Enable2 = '1' then
				--Soma parcial (Somente para efeito de "simular" o comportamento do algoritmo
				--(diferente da organizacao do algoritmo de Dadda, mas produz dois operandos como resultado)
				Ai2 <=  ("0000000000000000" & A0B) +
					("000000000000000" & A1B & "0") +
					("00000000000000" & A2B & "00") +
					("0000000000000" & A3B & "000") +
					("000000000000" & A4B & "0000") +
					("00000000000" & A5B & "00000") +
					("0000000000" & A6B & "000000") +
					("000000000" & A7B & "0000000") ;

				Bi2 <=  ("00000000" & A8B & "00000000") +
					("0000000" & A9B & "000000000") +
					("000000" & A10B & "0000000000") +
					("00000" & A11B & "00000000000") +
					("0000" & A12B & "000000000000") +
					("000" & A13B & "0000000000000") +
					("00" & A14B & "00000000000000") +
					("0" & A15B & "000000000000000") ;
			end if;
			if Enable3 = '1' then
				if (SigAS = '1' and SigBS = '0') or (SigAS = '0' and SigBS = '1') then
					Oi <= std_logic_vector(unsigned(not(Ai2 + Bi2)) + 1);
				else
					Oi <= std_logic_vector(Ai2 + Bi2);
				end if;
			end if;
			Enable2 <= Enable;
			Enable3 <= Enable2;
			Ready <= Enable3;
			EXBjumpandlink_out2 <= EXBjumpandlink_out;
			EXBmemtoreg_out2 <= EXBmemtoreg_out;
			EXBregwrite_out2 <= EXBregwrite_out;
			EXBregdest_out2 <= EXBregdest_out;
			EXBinst_20_11_out2 <= EXBinst_20_11_out;
			EXBjumpandlink_out3 <= EXBjumpandlink_out2;
			EXBmemtoreg_out3 <= EXBmemtoreg_out2;
			EXBregwrite_out3 <= EXBregwrite_out2;
			EXBregdest_out3 <= EXBregdest_out2;
			EXBinst_20_11_out3 <= EXBinst_20_11_out2;
			EXBjumpandlink_outs <= EXBjumpandlink_out3;
			EXBmemtoreg_outs <= EXBmemtoreg_out3;
			EXBregwrite_outs <= EXBregwrite_out3;
			EXBregdest_outs <= EXBregdest_out3;
			EXBinst_20_11_outs <= EXBinst_20_11_out3;
		end if;
	end process;
	O <= Oi;
	Executando <= Enable3;
end arch_MultiplicationUnit;