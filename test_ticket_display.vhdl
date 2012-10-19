-- davep 20-Oct-2012

library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity test_ticket_display is
end entity test_ticket_display;

architecture test_ticket_display_arch of test_ticket_display is
    -- use the same names as the actual hardware

    -- inputs
    signal mclk :  std_logic := '0';
    signal btn: std_logic_vector(3 downto 0) := (others=>'0');
    signal sw :  std_logic_vector(7 downto 0) := (others=>'0');

    signal user_zone_choice : unsigned (1 downto 0);

    -- outputs
    signal led: std_logic_vector(7 downto 0);
    signal seg : std_logic_vector( 6 downto 0 );
    signal an : std_logic_vector( 3 downto 0 );
    signal dp : std_logic;

    component ticket_display is
        port( reset : in std_logic; 
                mclk : in std_logic;
                btn : in std_logic_vector(3 downto 0);

                seg : out std_logic_vector( 6 downto 0 );
                an : out std_logic_vector( 3 downto 0 );
                dp : out std_logic;
                zone_choice : out unsigned(1 downto 0 )
            ); 
    end component ticket_display;

begin
    uut_ticket_display : ticket_display
        port map (
            reset => sw(0),
            mclk => mclk,
            btn => btn,
            seg => seg,
            an => an,
            dp => dp,
            zone_choice => user_zone_choice );

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
        sw <= "00000001"; -- switch 0 is a reset
        wait for 15 ns;

        sw <= "00000000"; -- release reset
        wait for 10 ns;

        for i in 0 to 4 loop
            work.debug_utils.dbg_7seg( seg, an, dp ); 
            wait for 50 ns;
        end loop;

        wait for 100 ns;

        -- Press Down
        write( str, string'("press down (should go to 0xb)"));
        writeline(output,str);
        btn <= "0010"; -- down 
        wait for 20 ns;
        btn <= "0000"; -- clear
        wait for 1 us; -- wait for result to percolate to 7seg 
        for i in 0 to 255 loop
            work.debug_utils.dbg_7seg( seg, an, dp ); 
            wait for 100 ns;
        end loop;

        -- Down again
        write( str, string'("press down again (should go to 0xc)"));
        writeline(output,str);
        btn <= "0010"; -- down 
        wait for 20 ns;
        btn <= "0000"; -- clear
        wait for 1 us; -- wait for result to percolate to 7seg 
        for i in 0 to 4 loop
            work.debug_utils.dbg_7seg( seg, an, dp ); 
            wait for 80 ns;
        end loop;

        -- Down again (should be ignored)
        write( str, string'("press down again (should be ignored, stay on 0x0c)"));
        writeline(output,str);
        btn <= "0010"; -- down 
        wait for 20 ns;
        btn <= "0000"; -- clear
        wait for 1 us; -- wait for result to percolate to 7seg 
        for i in 0 to 4 loop
            work.debug_utils.dbg_7seg( seg, an, dp ); 
            wait for 50 ns;
        end loop;

        -- Press up 
        write( str, string'("press up (should go to 0x0b)"));
        writeline(output,str);
        btn <= "0001"; -- up 
        wait for 20 ns;
        btn <= "0000"; -- clear
        wait for 100 ns; -- wait for result to percolate to 7seg 
        for i in 0 to 4 loop
            work.debug_utils.dbg_7seg( seg, an, dp ); 
            wait for 50 ns;
        end loop;

        -- Press up 
        write( str, string'("press up again (should go to 0x0a)"));
        writeline(output,str);
        btn <= "0001"; -- up 
        wait for 20 ns;
        btn <= "0000"; -- clear
        wait for 100 ns; -- wait for result to percolate to 7seg 
        for i in 0 to 4 loop
            work.debug_utils.dbg_7seg( seg, an, dp ); 
            wait for 50 ns;
        end loop;
        wait;
    end process stimulus;
end architecture test_ticket_display_arch;

