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
    signal btn: std_logic_vector(3 downto 0) := (others=>'0');
    signal sw :  std_logic_vector(7 downto 0) := (others=>'0');

    -- outputs
    signal led: std_logic_vector(7 downto 0);
    signal seg : std_logic_vector( 6 downto 0 );
    signal an : std_logic_vector( 3 downto 0 );
    signal dp : std_logic;

    -- result of coin_counter
    signal user_total_money : std_logic_vector(15 downto 0);

    component coin_counter is
        port( reset : in std_logic; 
                mclk : in std_logic;
                btn : in std_logic_vector(3 downto 0);
                seg : out std_logic_vector( 6 downto 0 );
                an : out std_logic_vector( 3 downto 0 );
                dp : out std_logic;
                total_money : out std_logic_vector(15 downto 0 )
            ); 
    end component coin_counter;

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
    uut_coin_counter : coin_counter
        port map (
            reset => sw(0),
            mclk => mclk,
            btn => btn,
            seg => seg,
            an => an,
            dp => dp,
            total_money => user_total_money );

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

        btn <= add_coin( 100);
        -- leave it pressed for a looong time
        wait for 100 ns;

        btn <= "0000";
        wait for 20 ns;

        btn <= add_coin( 100 );
        -- leave it pressed for a looong time
        wait for 100 ns;

        btn <= add_coin( 25 );
        -- leave it pressed for a looong time
        wait for 100 ns;

        for i in 0 to 255 loop
            work.debug_utils.dbg_7seg( seg, an, dp ); 
            wait for 50 ns;
        end loop;

        wait;
    end process stimulus;
end architecture test_coin_counter_arch;

