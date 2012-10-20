-- Test ticket denspense
--
-- davep 20-Oct-2012

library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

library work;
use work.ticketzones.all;

entity test_ticket_dispense is
end entity test_ticket_dispense;

architecture test_ticket_dispense_arch of test_ticket_dispense is
    -- use the same names as the actual hardware

    -- inputs
    signal mclk :  std_logic := '0';
    signal btn: std_logic_vector(3 downto 0) := (others=>'0');
    signal sw :  std_logic_vector(7 downto 0) := (others=>'0');

    signal user_zone_choice : std_logic_vector (1 downto 0);
    signal user_ticket_count : unsigned (2 downto 0);

    -- outputs
    signal led: std_logic_vector(7 downto 0);
    signal seg : std_logic_vector( 6 downto 0 );
    signal an : std_logic_vector( 3 downto 0 );
    signal dp : std_logic;

    component ticket_dispense is
        port( reset : in std_logic; 
                mclk : in std_logic;
                zone_choice : in std_logic_vector (1 downto 0 );
                ticket_count : in unsigned (2 downto 0);

                seg : out std_logic_vector( 6 downto 0 );
                an : out std_logic_vector( 3 downto 0 );
                dp : out std_logic
            ); 
    end component ticket_dispense;


begin
    uut_ticket_dispense : ticket_dispense
        port map (
            reset => sw(0),
            mclk => mclk,
            zone_choice => user_zone_choice,
            ticket_count => user_ticket_count,
            seg => seg,
            an => an,
            dp => dp);

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

        -- zone choice is "B", ticket sum is 3
        user_zone_choice <= zone_b;
        user_ticket_count <= "011";
        sw <= "00000000"; -- release reset
        wait for 10 ns;

        for i in 0 to 255 loop
            work.debug_utils.dbg_7seg( seg, an, dp ); 
            wait for 50 ns;
        end loop;

        wait;
    end process stimulus;
end architecture test_ticket_dispense_arch;

