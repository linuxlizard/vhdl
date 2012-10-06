-- Simulation test bench replicating parts of Basys-2 board.
--
-- David Poole  03-Oct-2012

library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity test_basys2 is 
end entity test_basys2;

architecture test_basys2_arch of test_basys2 is 
    -- use the same names as the actual hardware
    signal mclk :  std_logic;
    signal rst : std_logic;
    signal btn: std_logic_vector(3 downto 0);
    signal sw :  std_logic_vector(7 downto 0);
    signal led: std_logic_vector(7 downto 0);

    component switch_to_led is 
        port(   rst : in std_logic;
                clk : in std_logic;
                btn : in std_logic_vector(3 downto 0);
                 sw : in std_logic_vector(7 downto 0);
                led : out std_logic_vector(7 downto 0)
            ); 
    end component switch_to_led;

begin
    switch_to_led_uut : switch_to_led
        port map( rst => rst, 
                  clk => mclk,
                  btn => btn,
                  sw => sw,
                  led => led );
                  
    clock : process is
    begin
       mclk <= '0'; wait for 10 ns;
       mclk <= '1'; wait for 10 ns;
    end process clock;

    stimulus : process is
        variable str : line;
        variable i : integer;
    begin
        write( str, string'("hello, world") );
        writeline( output, str );

        rst <= '1';
        btn <= "0000";
        sw <= "00000000";
        wait for 15 ns;

        rst <= '0';
        wait for 10 ns;

        -- load register 1 with a value
        sw <= "01100000";
        btn <= "0001";  -- push button 0
        wait for 10 ns;

        btn <= "0000"; -- release button 0
        wait for 10 ns;

        -- load register 2 with a value
        sw <= "00000011";
        btn <= "0010";  -- push button 1
        wait for 10 ns;

        btn <= "0000"; -- release button 1
        wait for 10 ns;

        -- register1 and register2 should now hold values
        -- push button 3 to output the registers' values to the rotater
        btn <= "1000";
        wait for 10 ns;
        btn <= "0000";
        wait for 10 ns;

        -- so what do we have?
        for i in 0 to 100 loop 
            write( str, string'("led=") );
            write( str, led );
            writeline( output, str );
            wait for 10 ns;
        end loop;

        rst <= '1';
        wait for 10 ns;

       wait;
    end process stimulus;
end architecture test_basys2_arch;

