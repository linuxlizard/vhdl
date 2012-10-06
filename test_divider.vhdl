-- Test the Clock Divider
--
-- David Poole 03-Oct-2012

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity test_divider is
begin
end;

architecture test_divider_arch of test_divider is
    component clk_divider is
        generic (clkmax : integer);
        port ( reset : in std_logic;
               clk_in : in std_logic;
               clk_out : out std_logic );
    end component clk_divider;
    
    signal t_clk : std_logic;
    signal t_reset : std_logic;
    signal t_clk_out_1 : std_logic;
    signal t_clk_out_2 : std_logic;
    
begin
    uut_1 : clk_divider
        generic map(clkmax => 12)
        port map( clk_in => t_clk,
                reset => t_reset,
                clk_out => t_clk_out_1 );

    uut_2 : clk_divider
        generic map(clkmax => 120)
        port map( clk_in => t_clk,
                reset => t_reset,
                clk_out => t_clk_out_2 );

    
    clock : process is
    begin
       t_clk <= '0'; wait for 10 ns;
       t_clk <= '1'; wait for 10 ns;
    end process clock;

    stimulus : process is
        variable str : line;
    begin
        t_reset <= '1';
        write( str, string'("Hello, world") );
        writeline( output, str );
        wait for 15 ns;

        t_reset <= '0';
        wait for 10 ns;

       wait;
    end process stimulus;
end architecture test_divider_arch;

