-- BCD to 7-segment display
--
-- David Poole 06-Oct-2012

library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity test_digits_to_7seg is

end entity test_digits_to_7seg;


architecture test_digits_to_7seg_arch of test_digits_to_7seg is 
    -- use the same names as the actual hardware
    signal mclk :  std_logic := '0';
    signal rst : std_logic := '1';
    signal btn: std_logic_vector(3 downto 0);
    signal sw :  std_logic_vector(7 downto 0);
    signal led: std_logic_vector(7 downto 0);

    -- 7seg display
    signal seg : std_logic_vector(6 downto 0 );

    -- anode of 7seg display
    signal an : std_logic_vector(3 downto 0);

    -- decimal point of 7seg display
    signal dp : std_logic := '0';

    signal t_byte_in : std_logic_vector( 7 downto 0 ) := "00000000";

    component digits_to_7seg is
        -- signals in Basys2
        port(  mclk : in std_logic;
             byte_in : in std_logic_vector(7 downto 0 );

                -- 7seg display
                seg : out std_logic_vector(6 downto 0 );

                -- anode of 7seg display
                an : out std_logic_vector(3 downto 0);

                -- decimal point of 7seg display
                dp : out std_logic
            ); 
    end component digits_to_7seg;

    procedure dbg_7seg( seg : std_logic_vector(6 downto 0 );
                         an : std_logic_vector(3 downto 0);
                         dp : std_logic ) is
        variable str : line;
    begin
        write( str, string'("foo=") );
        write( str, seg );
        write( str, string'(" ") );
        write( str, work.debug_utils.sevenseg_to_integer( seg ) );
        write( str, string'(" an=") );
        write( str, an );
        write( str, string'(" dp=") );
        write( str, dp );
        writeline(output,str);
    end procedure dbg_7seg;

begin
    run_digits_to_7seg : digits_to_7seg 
        port map ( mclk => mclk,
                    byte_in => t_byte_in,
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
        wait for 15 ns;

        rst <= '0';
        t_byte_in <= "10000000";
        wait for 10 ns;

        for i in 0 to 100 loop
            dbg_7seg( seg, an, dp ); 
            wait for 50 ns;
        end loop;

        wait;
    end process stimulus;

end architecture test_digits_to_7seg_arch;
