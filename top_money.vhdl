--  Top level simulation test for the money counter.
-- davep 20-Oct-2012

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;


entity top_money is 
    port(  mclk : in std_logic;
            btn : in std_logic_vector(3 downto 0);
             sw : in std_logic_vector(7 downto 0);
            led : out std_logic_vector( 7 downto 0 );
            seg : out std_logic_vector( 6 downto 0 );
           an : out std_logic_vector( 3 downto 0 );
            dp : out std_logic
        ); 
end entity top_money;

architecture top_money_arch of top_money is 

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

begin

    run_coin_counter : coin_counter
        port map (
            reset => sw(0),
            mclk => mclk,
            btn => btn,
            seg => seg,
            an => an,
            dp => dp,
            total_money => user_total_money );

    run_top : process(mclk)
    begin
        if rising_edge(mclk) then
            if sw(0)='1' then
                led <= X"00";
            else
                led <= user_total_money(7 downto 0);
            end if;
        end if;
    end process run_top;

end architecture top_money_arch;

