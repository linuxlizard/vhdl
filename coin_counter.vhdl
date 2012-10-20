-- Coin Counter.
-- davep 19-Oct-2012

library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity coin_counter is
    port( reset : in std_logic; 
            mclk : in std_logic;
            btn : in std_logic_vector(3 downto 0);
            seg : out std_logic_vector( 6 downto 0 );
            an : out std_logic_vector( 3 downto 0 );
            dp : out std_logic
        ); 
end entity coin_counter;

architecture coin_counter_arch of coin_counter is

    signal total_money : std_logic_vector(15 downto 0 ) := (others=>'0') ;

    signal counter : unsigned (15 downto 0 ) := (others=>'0');

    signal coin_100_in : std_logic;
    signal coin_25_in : std_logic;
    signal coin_10_in : std_logic;

    component edge_to_pulse is
        Port ( CLK : in  STD_LOGIC;
               Reset : in  STD_LOGIC;
               Edge_in : in  STD_LOGIC;
               Pulse_out : out  STD_LOGIC);
    end component;

    component money_to_7seg is
        -- signals in Basys2
        port( rst : in std_logic; 
                mclk : in std_logic;
             word_in : in std_logic_vector(15 downto 0 );
                seg : out std_logic_vector(6 downto 0 );
                an : out std_logic_vector(3 downto 0);
                dp : out std_logic
            ); 
    end component money_to_7seg;

begin

    run_money_7seg : money_to_7seg 
        port map ( rst => reset,
                    mclk => mclk,
                    word_in => total_money,
                    seg => seg,
                    an => an,
                    dp => dp );

    coin_10_edge_to_pulse : edge_to_pulse
        port map ( CLK => mclk,
                   Reset => reset,
                   Edge_in => btn(2),
                   Pulse_out => coin_10_in );

    coin_25_edge_to_pulse : edge_to_pulse
        port map ( CLK => mclk,
                   Reset => reset,
                   Edge_in => btn(1),
                   Pulse_out => coin_25_in );

    coin_100_edge_to_pulse : edge_to_pulse
        port map ( CLK => mclk,
                   Reset => reset,
                   Edge_in => btn(0),
                   Pulse_out => coin_100_in );

    run_coin_counter : process(mclk,reset) is
        variable value : integer;
    begin
        if reset='1' then
            total_money <= (others=>'0');
            counter <= (others=>'0');
        elsif rising_edge(mclk) then
            -- do stuff
            value := 0;
            if coin_100_in = '1' then
--                counter <= counter + 100;
                value := 100;
            elsif coin_25_in = '1' then
--                counter <= counter + 25;
                value := 25;
            elsif coin_10_in = '1' then
--                counter <= counter + 10;
                value := 10;
            end if;

            if counter + value <= 1000 then
                counter <= counter + value;
            end if;

            total_money <= std_logic_vector(counter);
        end if;
    end process run_coin_counter;

end architecture coin_counter_arch;

