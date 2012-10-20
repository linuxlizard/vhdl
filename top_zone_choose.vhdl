-- Top level simulation test for the ticket_display component
-- use for chosing the destination zone.
-- davep 20-Oct-2012

library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

library work;
use work.ticketzones.all;

entity top_ticket_choose is 
    port(  mclk : in std_logic;
            btn : in std_logic_vector(3 downto 0);
             sw : in std_logic_vector(7 downto 0);
            led : out std_logic_vector( 7 downto 0 );
            seg : out std_logic_vector( 6 downto 0 );
            an : out std_logic_vector( 3 downto 0 );
            dp : out std_logic
        ); 
end entity top_ticket_choose;

architecture top_ticket_choose_arch of top_ticket_choose is 

    signal user_zone_choice : std_logic_vector(1 downto 0 );

    component ticket_display is
        port( reset : in std_logic; 
                mclk : in std_logic;
                btn : in std_logic_vector(3 downto 0);
                seg : out std_logic_vector( 6 downto 0 );
                an : out std_logic_vector( 3 downto 0 );
                dp : out std_logic;
                zone_choice : out std_logic_vector(1 downto 0 )
            ); 
    end component ticket_display;

begin

    run_zone_choose : ticket_display
        port map (
            reset => sw(0),
            mclk => mclk,
            btn => btn,
            seg => seg,
            an => an,
            dp => dp,
            zone_choice => user_zone_choice );

    run_top : process(mclk)
    begin
        if rising_edge(mclk) then
            if sw(0)='1' then 
                -- reset
                led <= X"00";
            else 
                led <= "000000" & user_zone_choice;
            end if;
        end if;
    end process run_top;

end architecture top_ticket_choose_arch;


