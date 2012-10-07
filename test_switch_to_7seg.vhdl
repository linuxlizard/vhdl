-- Simulation test bench replicating parts of Basys-2 board.
--
-- David Poole  03-Oct-2012

library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity test_switch_to_7seg is 
end entity test_switch_to_7seg;

architecture test_switch_to_7seg_arch of test_switch_to_7seg is 
    -- use the same names as the actual hardware
    signal mclk :  std_logic;
    signal rst : std_logic;
    signal btn: std_logic_vector(3 downto 0);
    signal sw :  std_logic_vector(7 downto 0);
    signal led: std_logic_vector(7 downto 0);
    signal seg : std_logic_vector( 6 downto 0 );
    signal an : std_logic_vector( 3 downto 0 );
    signal dp : std_logic;

    component switch_to_7seg is 
        port(  mclk : in std_logic;
                btn : in std_logic_vector(3 downto 0);
                 sw : in std_logic_vector(7 downto 0);
                seg : out std_logic_vector( 6 downto 0 );
                 an : out std_logic_vector( 3 downto 0 )
            ); 
    end component switch_to_7seg;

begin
    run_switch_to_7seg : switch_to_7seg
        port map( mclk => mclk,
                  btn => btn,
                  sw => sw,
                  seg => seg,
                  an => an
                  );
                  
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

        dp <= '0';
        rst <= '1';
        btn <= "0000";
        sw <= "00000000";
        wait for 15 ns;

        rst <= '0';
        wait for 10 ns;

        -- load register 1 with a value
        sw <= "00000001";
        btn <= "0001";  -- push button 0
        wait for 10 ns;
        write( str, string'("register1 loaded") );
        writeline( output, str );

        btn <= "0000"; -- release button 0
        wait for 10 ns;

        -- load register 2 with a value
        sw <= "00000010";
        btn <= "0010";  -- push button 1
        wait for 10 ns;
        write( str, string'("register2 loaded") );
        writeline( output, str );

        btn <= "0000"; -- release button 1
        wait for 10 ns;

        -- register1 and register2 should now hold values
        -- push button 3 to output the registers' values to the rotater
        btn <= "1000";
        wait for 10 ns;
        btn <= "0000";
        wait for 10 ns;

        -- so what do we have?
        for i in 0 to 1000 loop
            work.debug_utils.dbg_7seg( seg, an, dp ); 
            wait for 20 ns;
        end loop;

        rst <= '1';
        wait for 10 ns;

       wait;
    end process stimulus;
end architecture test_switch_to_7seg_arch;

