-- Simulation test bench replicating parts of Basys-2 board.
--
-- David Poole  03-Oct-2012

library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity basys2 is 
end entity basys2;

architecture basys2_arch of basys2 is 
    -- use the same names as the actual hardware
    signal mclk :  std_logic;
    signal rst : std_logic;
    signal btn: std_logic_vector(3 downto 0) := (others=>'0');
    signal sw :  std_logic_vector(7 downto 0) := (others=>'0');
    signal led: std_logic_vector(7 downto 0) := (others=>'0');
    signal seg : std_logic_vector( 6 downto 0 ) := (others=>'0');
    signal an : std_logic_vector( 3 downto 0 ) := (others=>'0');
    signal dp : std_logic;

    component puter is 
        port(  mclk : in std_logic;
                btn : in std_logic_vector(3 downto 0);
                 sw : in std_logic_vector(7 downto 0);
                led : out std_logic_vector( 7 downto 0 );
                seg : out std_logic_vector( 6 downto 0 );
               an : out std_logic_vector( 3 downto 0 );
                dp : out std_logic
            ); 
    end component puter;

    procedure dbgdump( 
                led : in std_logic_vector( 7 downto 0 );
                seg : in std_logic_vector( 6 downto 0 );
               an : in std_logic_vector( 3 downto 0 );
                dp : in std_logic ) is
        variable str : line;
    begin
        work.debug_utils.dbg_7seg( seg, an, dp );
    end;

begin

    run_puter : puter 
        port map( 
            mclk => mclk,
            btn => btn,
            sw => sw,
            led => led,
            seg => seg,
            an => an,
            dp => dp );
                  
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

        -- load opcode register 
        sw <= "00000001"; -- ADDWF
--        sw <= "00000010"; -- SUB
        btn <= "0001";  -- push button 0
        wait for 10 ns;

        btn <= "0000"; -- release button 0
        wait for 10 ns;

        -- load W register with a value
--        sw <= "00000001";
        sw <= "00101010"; -- 42
        btn <= "0010";  -- push button 1
        wait for 10 ns;

        btn <= "0000"; -- release button 1
        wait for 10 ns;

        -- load F register with a value
--        sw <= "00000010";
        sw <= "00101010"; -- 42
        btn <= "0100";  -- push button 2
        wait for 10 ns;

        btn <= "0000"; -- release button 1
        wait for 10 ns;

        -- register1 and register2 should now hold values
        -- push button 3 to output the registers' values to the rotater
        btn <= "1000";
        wait for 10 ns;
        btn <= "0000";
        wait for 10 ns;
        dbgdump( led, seg, an, dp );

        -- so what do we have?
        for i in 0 to 20000 loop 
            dbgdump( led, seg, an, dp );
--            write( str, string'("led=") );
--            write( str, led );
--            writeline( output, str );
            wait for 40 ns;
        end loop;

        rst <= '1';
        wait for 10 ns;

       wait;
    end process stimulus;
end architecture basys2_arch;

