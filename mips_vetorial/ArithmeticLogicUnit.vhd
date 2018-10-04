library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use alu_types_pack.all;

entity ArithmeticLogicUnit is
	port (	
		A,B: in std_logic_vector (31 downto 0);
		ALU_op: in ALU_operation;
		Zero,Overflow: out std_logic;
		ALU_result: out std_logic_vector (31 downto 0)
	);
end ArithmeticLogicUnit;

architecture arch_ArithmeticLogicUnit of ArithmeticLogicUnit is
	signal ALU_resulti: std_logic_vector (31 downto 0);
	begin
	process(ALU_op,A,B,ALU_resulti)
	begin
		Overflow <= '0';
		case ALU_op is
		when logic_and =>
			ALU_resulti <= A and B;
		when logic_or =>
			ALU_resulti <= A or B;
		when sum =>
			ALU_resulti <= std_logic_vector(signed(A) + signed(B));
			if (A(31) = B(31)) and (A(31) /= ALU_resulti(31)) then
				Overflow <= '1';
			end if;
		when subtract =>
			ALU_resulti <= std_logic_vector(signed(A) - signed(B));
			if (A(31) /= B(31)) and (A(31) /= ALU_resulti(31)) then
				Overflow <= '1';
			end if;
		when lessthan =>
			if(signed(A) < signed(B)) then
				ALU_resulti <= x"00000001";
			else
				ALU_resulti <= x"00000000";
			end if;
		when shiftleft =>
			ALU_resulti <= std_logic_vector(unsigned(A) sll to_integer(unsigned(B)));
			--ALU_resulti <= std_logic_vector(shift_left(unsigned(A),to_integer(unsigned(B))));
		when nop =>
			ALU_resulti <= A;
		when others =>
			ALU_resulti <= x"00000000";
		end case;
		if ALU_resulti = x"00000000" then
			Zero <= '1';
		else
			Zero <= '0';
		end if;
	end process;
	ALU_result <= ALU_resulti;
end arch_ArithmeticLogicUnit;
