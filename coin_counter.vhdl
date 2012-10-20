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

    component money_to_7seg is
        -- signals in Basys2
        port(  mclk : in std_logic;
             word_in : in std_logic_vector(15 downto 0 );
                seg : out std_logic_vector(6 downto 0 );
                an : out std_logic_vector(3 downto 0);
                dp : out std_logic
            ); 
    end component money_to_7seg;

begin

    run_money_7seg : money_to_7seg 
        port map ( mclk => mclk,
                    word_in => total_money,
                    seg => seg,
                    an => an,
                    dp => dp );

    run_coin_counter : process(mclk,reset) is
    begin
        if reset='1' then
            total_money <= (others=>'0');
        elsif rising_edge(mclk) then
            -- do stuff
            if btn(0)='1' then
                counter <= counter + 100;
            elsif btn(1)='1' then
                counter <= counter + 25;
            elsif btn(2)='1' then
                counter <= counter + 10;
            end if;

            total_money <= std_logic_vector(counter);
        end if;
    end process run_coin_counter;

end architecture coin_counter_arch;

