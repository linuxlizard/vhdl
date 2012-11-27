-- RAM read/write
-- ECE530 Fall 2012
--
-- David Poole
-- 17-Nov-2012

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity memory8bit is
    generic ( depth : integer := 32 );
    port ( clk : in std_logic;
           write_enable : in std_logic;
           write_addr : in unsigned(7 downto 0 );
           data_in : in unsigned( 7 downto 0 );
           read_addr : in unsigned(7 downto 0 );
           data_out : out unsigned( 7 downto 0 )
         );
end entity memory8bit;

architecture memory_8bit_arch of memory8bit is
    type mem_array is array (0 to depth-1) of unsigned(7 downto 0 );
    signal RAM : mem_array;
begin

    run_memory8bit : process(clk) is
    begin
        if( rising_edge(clk) ) then
            if( write_enable = '1' ) then
                RAM(to_integer(write_addr)) <= data_in;
            end if;
            data_out <= RAM(to_integer(read_addr));
        end if;
    end process run_memory8bit;


end architecture memory_8bit_arch;

