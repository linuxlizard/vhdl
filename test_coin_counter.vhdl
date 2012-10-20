library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity test_coin_counter is

end entity test_coin_counter;

architecture test_coin_counter_arch of test_coin_counter is
    -- use the same names as the actual hardware

    -- inputs
    signal mclk :  std_logic := '0';
    signal rst : std_logic := '0';
    signal btn: std_logic_vector(3 downto 0) := (others=>'0');
    signal sw :  std_logic_vector(7 downto 0) := (others=>'0');

    -- outputs
    signal led: std_logic_vector(7 downto 0);
    signal seg : std_logic_vector( 6 downto 0 );
    signal an : std_logic_vector( 3 downto 0 );
    signal dp : std_logic;

    component coin_counter is
        port( reset : in std_logic; 
                mclk : in std_logic;
                btn : in std_logic_vector(3 downto 0);
                seg : out std_logic_vector( 6 downto 0 );
                an : out std_logic_vector( 3 downto 0 );
                dp : out std_logic
            ); 
    end component coin_counter;
begin
    uut_coin_counter : coin_counter
        port map (
            reset => sw(0),
            mclk => mclk,
            btn => btn,
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
        sw <= "00000001"; -- switch 0 is a reset
        wait for 15 ns;

        sw <= "00000000"; -- release reset
        wait for 10 ns;

        btn <= "0001";  -- $1
        wait for 10 ns;

        btn <= "0000";  -- release
        wait for 10 ns;

        wait for 100 ns;

        work.debug_utils.dbg_7seg_loop( seg, an, dp ); 

        wait;
    end process stimulus;
end architecture test_coin_counter_arch;

