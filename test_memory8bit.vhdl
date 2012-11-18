-- RAM read/write
-- ECE530 Fall 2012
--
-- David Poole
-- 17-Nov-2012

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use std.textio.all;
use ieee.numeric_std.all;

entity test_memory8bit is
end entity test_memory8bit;

architecture test_memory8bit_arch of test_memory8bit is
    signal mclk :  std_logic := '0';
    
    signal t_write_en : std_logic := '0';
    signal t_addr : unsigned(7 downto 0 );
    signal t_data_in : unsigned( 7 downto 0 );
    signal t_data_out : unsigned( 7 downto 0 );

    component memory8bit is
        generic ( width : integer; depth : integer );
        port ( clk : in std_logic;
               write_enable : in std_logic;
               write_addr : in unsigned(7 downto 0 );
               read_addr : in unsigned(7 downto 0 );
               data_in : in unsigned( 7 downto 0 );
               data_out : out unsigned( 7 downto 0 )
             );
    end component memory8bit;

begin
    clock : process is
    begin
       mclk <= '0'; wait for 10 ns;
       mclk <= '1'; wait for 10 ns;
    end process clock;

    fifomem : memory8bit
        generic map( depth => 32 )
        port map ( clk => mclk,
                   write_enable => t_write_en,
                   write_addr => t_addr,
                   read_addr => t_addr,
                   data_in => t_data_in,
                   data_out => t_data_out
                );

    watcher : process(t_data_out) 
        variable str : line;
    begin
        write( str, string'("t_data_out=0x") );
        hwrite( str, std_logic_vector(t_data_out) );
        writeline( output, str );
    end process watcher;

    stimulus : process
        variable i : integer;
        variable str : line;
    begin
        write( str, string'("hello, world") );
        writeline( output, str );

        wait for 5 ns;

        t_addr <= X"01";
        t_data_in <= X"ee";
        t_write_en <= '1';
        wait for 10 ns;

        t_write_en <= '0';
        wait for 10 ns;
        wait for 10 ns;
        wait for 10 ns;

        t_addr <= X"02";
        t_data_in <= X"dd";
        t_write_en <= '1';
        wait for 10 ns;

        t_write_en <= '0';
        wait for 10 ns;
        wait for 10 ns;
        wait for 10 ns;

        t_addr <= X"01";
        wait for 10 ns;

        t_write_en <= '1';
        for i in 0 to 31 loop 
            t_addr <= to_unsigned(i,8);
            t_data_in <= to_unsigned(i+10,8);
            wait for 20 ns;
        end loop;

        t_write_en <= '0';
        wait for 30 ns;
        for i in 0 to 31 loop 
            t_addr <= to_unsigned(i,8);
            wait for 20 ns;
        end loop;

        report "test done";  
        wait;
    end process stimulus;

end architecture test_memory8bit_arch;

