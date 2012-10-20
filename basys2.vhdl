-- Simulation test bench replicating parts of Basys-2 board.
--
-- David Poole  03-Oct-2012

library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

library work;
use work.debug_utils.all;

entity basys2 is 
end entity basys2;

architecture basys2_arch of basys2 is 
    -- use the same names as the actual hardware
    signal mclk :  std_logic;
    signal btn: std_logic_vector(3 downto 0) := (others=>'0');
    signal sw :  std_logic_vector(7 downto 0) := (others=>'0');
    signal led: std_logic_vector(7 downto 0) := (others=>'0');
    signal seg : std_logic_vector( 6 downto 0 ) := (others=>'0');
    signal an : std_logic_vector( 3 downto 0 ) := (others=>'0');
    signal dp : std_logic;

    component subway_tickets is 
        port(  mclk : in std_logic;
                btn : in std_logic_vector(3 downto 0);
                sw : in std_logic_vector(7 downto 0);
                led : out std_logic_vector( 7 downto 0 );
                seg : out std_logic_vector( 6 downto 0 );
                an : out std_logic_vector( 3 downto 0 );
                dp : out std_logic
            ); 
    end component subway_tickets;

    procedure dbgdump( 
                led : in std_logic_vector( 7 downto 0 );
                seg : in std_logic_vector( 6 downto 0 );
               an : in std_logic_vector( 3 downto 0 );
                dp : in std_logic ) is
        variable str : line;
    begin
        work.debug_utils.dbg_7seg( seg, an, dp );
    end;

    function add_coin ( value : in integer ) return std_logic_vector is 
    begin
        if value=10 then
            return "0100";
        elsif value=25 then
            return "0010";
        elsif value=100 then
            return "0001";
        else 
            -- TODO halt somehow
            return "1111";
        end if;
    end;

begin

    run_subway_tickets : subway_tickets
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

        btn <= "0000";
        sw <= "00000001";
        wait for 55 ns;

        -- clear reset
        sw <= "00000000";
        wait for 80 ns;

        -- insert $3
        btn <= add_coin( 100 );
        wait for 20 ns;
        btn <= "0000";
        wait for 80 ns;

        btn <= add_coin( 100 );
        wait for 20 ns;
        btn <= "0000";
        wait for 80 ns;

        btn <= add_coin( 100 );
        wait for 20 ns;
        btn <= "0000";
        wait for 80 ns;

        btn <= add_coin( 100 );
        wait for 20 ns;
        btn <= "0000";
        wait for 80 ns;

        -- done entering money; push & release btn3 to go to zone chooser
        btn <= "1000";
        wait for 80 ns;
        btn <= "0000";
        wait for 80 ns;


        -- push & release btn 3 to go to next state (we'll go to zone A)
        btn <= "1000";
        wait for 80 ns;
        btn <= "0000";
        wait for 80 ns;

        --push & release btn 3 to indicate we want one ticket (the default)
        btn <= "1000";
        wait for 80 ns;
        btn <= "0000";
        wait for 80 ns;

        -- should be dispensing tickets now

        -- so what do we have?
        for i in 0 to 20000 loop 
            dbgdump( led, seg, an, dp );
--            write( str, string'("led=") );
--            write( str, led );
--            writeline( output, str );
            
            -- sample 2x the 7seg display rate; in simulation
            -- clock period is 20ns. 7seg divider is 4 so 7seg period is 80ns ;
            -- sample @ Nyquist just so I can show off I know what Nyquist
            -- means
--            wait for 40 ns;
            wait for 1 us;
        end loop;

        wait for 10 ns;

       wait;
    end process stimulus;
end architecture basys2_arch;

