library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all; 
use IEEE.STD_LOGIC_ARITH.all;
use work.blocks.all;

entity MemBuffer is
    port(enable,ready_write  : in STD_LOGIC;
        data_block_in        : in word_block;
        block_address_in     : in STD_LOGIC_VECTOR (9 downto 0);
        busy, write          : out STD_LOGIC := '0';
        block_address_out    : out STD_LOGIC_VECTOR (15 downto 0);
        data_block_out       : out word_block
        );
end MemBuffer;

architecture behavioral of MemBuffer is
begin
    process (enable,ready_write)
    begin
    if enable'event and enable = '1' then 
        busy <= '1';
        write <= '1';
        block_address_out <= block_address_in & "000000";
        data_block_out <= data_block_in;
    end if;
    if ready_write = '1' then
        busy <= '0';
        write <= '0';
    end if;
    end process;
end behavioral;
