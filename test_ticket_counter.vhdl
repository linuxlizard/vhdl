library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity test_ticket_counter is

end entity test_ticket_counter;

architecture test_ticket_counter_arch of test_ticket_counter is
    -- use the same names as the actual hardware

    -- inputs
    signal mclk :  std_logic := '0';
    signal btn: std_logic_vector(3 downto 0) := (others=>'0');
    signal sw :  std_logic_vector(7 downto 0) := (others=>'0');

    -- outputs
    signal led: std_logic_vector(7 downto 0);
    signal seg : std_logic_vector( 6 downto 0 );
    signal an : std_logic_vector( 3 downto 0 );
    signal dp : std_logic;

    -- current value
    signal user_ticket_count : std_logic_vector(2 downto 0 );

    component ticket_counter is
        port( reset : in std_logic; 
                mclk : in std_logic;
                btn : in std_logic_vector(3 downto 0);

                led: out std_logic_vector(7 downto 0);
                seg : out std_logic_vector( 6 downto 0 );
                an : out std_logic_vector( 3 downto 0 );
                dp : out std_logic;

                ticket_count : out std_logic_vector(2 downto 0 )
            ); 
    end component ticket_counter;

    constant btn_none : std_logic_vector(3 downto 0) := "0000";
    constant btn_up : std_logic_vector(3 downto 0) := "0010";
    constant btn_down : std_logic_vector(3 downto 0) := "0001";
begin
    uut_ticket_counter : ticket_counter
        port map (
            reset => sw(0),
            mclk => mclk,
            btn => btn,
            led => led,
            seg => seg,
            an => an,
            dp => dp,
            
            ticket_count => user_ticket_count );

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
        write( str, string'("ticket_count=") );
        write( str, user_ticket_count );
        writeline(output,str );

        btn <= btn_up;
        -- leave it pressed for a looong time
        wait for 100 ns;
        write( str, string'("ticket_count=") );
        write( str, user_ticket_count );
        writeline(output,str );

        btn <= btn_down;
        -- leave it pressed for a looong time
        wait for 100 ns;
        write( str, string'("ticket_count=") );
        write( str, user_ticket_count );
        writeline(output,str );

        btn <= btn_none;
        wait for 20 ns;

        btn <= btn_down;
        -- leave it pressed for a looong time
        wait for 100 ns;
        write( str, string'("ticket_count=") );
        write( str, user_ticket_count );
        writeline(output,str );

        btn <= btn_none;
        wait for 20 ns;

        btn <= btn_down;
        -- leave it pressed for a looong time
        wait for 100 ns;
        write( str, string'("ticket_count=") );
        write( str, user_ticket_count );
        writeline(output,str );

        btn <= btn_up;
        -- leave it pressed for a looong time
        wait for 100 ns;
        write( str, string'("ticket_count=") );
        write( str, user_ticket_count );
        writeline(output,str );

        btn <= btn_down;
        -- leave it pressed for a looong time
        wait for 100 ns;
        write( str, string'("ticket_count=") );
        write( str, user_ticket_count );
        writeline(output,str );

        btn <= btn_none;
        wait for 20 ns;

        btn <= btn_down;
        -- leave it pressed for a looong time
        wait for 100 ns;
        write( str, string'("ticket_count=") );
        write( str, user_ticket_count );
        writeline(output,str );

        btn <= btn_none;
        wait for 20 ns;

        btn <= btn_down;
        -- leave it pressed for a looong time
        wait for 100 ns;
        write( str, string'("ticket_count=") );
        write( str, user_ticket_count );
        writeline(output,str );

        for i in 0 to 255 loop
            work.debug_utils.dbg_7seg( seg, an, dp ); 
            write( str, string'("ticket_count=") );
            write( str, user_ticket_count );
            writeline(output,str );
            wait for 50 ns;
        end loop;

        wait;
    end process stimulus;
end architecture test_ticket_counter_arch;

