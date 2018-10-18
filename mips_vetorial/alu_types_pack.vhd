library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package alu_types_pack is
	type reg_vector is array(31 downto 0) of STD_LOGIC_VECTOR(31 downto 0);
	type ALU_operation is (logic_and, logic_or, sum, subtract, lessthan, shiftleft, nop);
end alu_types_pack;

