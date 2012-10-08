-- Test the BCD encode function
-- David Poole 28-Sep-2012

library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity test_bcd is
begin
end entity test_bcd;

architecture run_test_bcd of test_bcd is
    signal t_rst : std_logic := '1';
    signal t_clk : std_logic := '0';
    signal t_byte_in : std_logic_vector( 7 downto 0 );
    signal t_bcd_out : std_logic_vector( 11 downto 0 );
    signal t_negative_flag : std_logic;

    component bcd_encoder is
        port (rst : in std_logic;
              clk : in std_logic;
              byte_in : in std_logic_vector(7 downto 0 );
              bcd_out : out std_logic_vector( 11 downto 0 );
              negative_out : out std_logic
             );
    end component bcd_encoder;

    procedure dbg_bcd( byte_value : in std_logic_vector(7 downto 0 );
                      bcd_value : in std_logic_vector(11 downto 0 );
                      negative_flag : in std_logic ) is

        variable str : line;
    begin
        write( str, string'("input=") );
        hwrite( str, byte_value );
        write( str, string'(" output=") );
        hwrite( str, bcd_value );
        if negative_flag = '1' then
            write( str, string'(" negative") );
        end if;
        writeline( output, str );

    end procedure dbg_bcd;

begin
    uut : bcd_encoder 
        port map( rst => t_rst,
                  clk => t_clk,
                  byte_in => t_byte_in,
                  bcd_out => t_bcd_out,
                  negative_out => t_negative_flag
                );
    
    clock : process is 
    begin
        t_clk <= '0'; wait for 10 ns;
        t_clk <= '1'; wait for 10 ns;
    end process clock;

    stimulus : process is
        variable i : integer;
        variable str : line;
    begin
        write( output, string'("hello, world") );
        t_byte_in <= "00000000";
        t_rst <= '1';
        wait for 15 ns;

        t_byte_in <= "00000001";
        t_rst <= '0';
        wait for 10 ns;

        wait for 10 ns;
        dbg_bcd( t_byte_in, t_bcd_out, t_negative_flag );
        wait for 10 ns;

        t_byte_in <= "00001110";
        wait for 10 ns;
        dbg_bcd( t_byte_in, t_bcd_out, t_negative_flag );
        wait for 10 ns;

        -- negative one (-2) 
        t_byte_in <= "11111110";
        wait for 10 ns;
        dbg_bcd( t_byte_in, t_bcd_out, t_negative_flag );
        wait for 10 ns;

        t_byte_in <= "10000000";
        wait for 10 ns;
        dbg_bcd( t_byte_in, t_bcd_out, t_negative_flag );
        wait for 10 ns;

        for i in 1 to 255 loop
            t_byte_in <= std_logic_vector(to_unsigned(i,8));
            wait for 10 ns;

            dbg_bcd( t_byte_in, t_bcd_out, t_negative_flag );
            wait for 10 ns;
        end loop;

       wait;
    end process stimulus;

end architecture run_test_bcd;

