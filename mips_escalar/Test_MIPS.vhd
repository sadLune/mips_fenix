library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.blocks.all;

entity Test_MIPS is
end Test_MIPS;

architecture Arch_Test_MIPS of Test_MIPS is

component MIPS
	port(Request,Clock, Reset: in std_logic;
		Exc_id : in std_logic_vector(3 downto 0)
	);
end component;

signal tb_clock, tb_reset, tb_request: std_logic;
signal tb_exc_id: std_logic_vector(3 downto 0);

begin
uut: MIPS port map (
	Request => tb_request,
    Clock => tb_clock,
	Reset => tb_reset,
	Exc_id => tb_exc_id
	);

process
	begin
		tb_reset <= '1';
		wait for 19 ns;
		tb_reset <= '0';
		wait for 1000000000 ns;
	end process;

process
	begin
		tb_clock <= '0';
		wait for 10 ns;
		tb_clock <= '1';
		wait for 10 ns;
	end process;
	
process
	begin
		tb_request <= '0';
		tb_exc_id <= "0000";
		wait for 100 ns;
		tb_request <= '0';
		tb_exc_id <= "0000";
		wait for 20 ns;
		tb_request <= '0';
		tb_exc_id <= "0000";
		wait for 1000000000 ns;
	end process;
end architecture;

