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
    constant clk_period : time := 10 ns;

    -- use the same names as the actual hardware
    signal mclk :  std_logic;
    signal btn: std_logic_vector(3 downto 0) := (others=>'0');
    signal sw :  std_logic_vector(7 downto 0) := (others=>'0');
    signal led: std_logic_vector(7 downto 0) := (others=>'0');
    signal seg : std_logic_vector( 6 downto 0 ) := (others=>'0');
    signal an : std_logic_vector( 3 downto 0 ) := (others=>'0');
    signal dp : std_logic;
    signal PIO : std_logic_vector( 87 downto 72 );

    component top_rs232 is
        port(  mclk : in std_logic;
                btn : in std_logic_vector(3 downto 0);
                 sw : in std_logic_vector(7 downto 0);

               PIO  : inout std_logic_vector (87 downto 72); 

                led : out std_logic_vector( 7 downto 0 );
                seg : out std_logic_vector( 6 downto 0 );
                 an : out std_logic_vector( 3 downto 0 );
                 dp : out std_logic
            ); 
    end component top_rs232;

begin
    run_top_rs232 : top_rs232
        port map ( mclk => mclk,
                   btn => btn ,
                   sw => sw ,

                   PIO => PIO,
                   led => led,
                   seg => seg,
                   an => an,
                   dp => dp
                 );
                  
    clock : process is
    begin
       mclk <= '0'; wait for clk_period/2;
       mclk <= '1'; wait for clk_period/2;
    end process clock;

    stimulus : process is
        variable str : line;
        variable i : integer;
    begin
        write( str, string'("hello, world") );
        writeline( output, str );

        btn <= "0000";
        sw <= "00000001";
        wait for clk_period;

        -- clear reset
        sw <= "00000000";
        wait for clk_period;
        wait for clk_period/2;

       wait;
    end process stimulus;
end architecture basys2_arch;

