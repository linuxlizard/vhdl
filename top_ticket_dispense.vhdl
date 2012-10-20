-- Top level simulation test for the ticket_dispense component
-- used for showing the ticket dispensing.
-- davep 20-Oct-2012

library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

library work;
use work.ticketzones.all;

entity top_ticket_dispense is 
    port(  mclk : in std_logic;
            btn : in std_logic_vector(3 downto 0);
             sw : in std_logic_vector(7 downto 0);
            led : out std_logic_vector( 7 downto 0 );
            seg : out std_logic_vector( 6 downto 0 );
            an : out std_logic_vector( 3 downto 0 );
            dp : out std_logic
        ); 
end entity top_ticket_dispense;

architecture top_ticket_dispense_arch of top_ticket_dispense is 

    signal user_zone_choice : std_logic_vector(1 downto 0 ) := zone_a;
    signal user_ticket_count : unsigned(2 downto 0) := "001";

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

    run_zone_dispense : ticket_dispense
        port map (
            reset => sw(0),
            mclk => mclk,
            zone_choice => user_zone_choice,
            ticket_count => user_ticket_count,

            seg => seg,
            an => an,
            dp => dp );

    run_top : process(mclk)
    begin
        if rising_edge(mclk) then
            if sw(0)='1' then 
                -- reset
                led <= X"00";

                user_zone_choice <= zone_b;
                user_ticket_count <= to_unsigned(3,2);
            end if;
        end if;
    end process run_top;

end architecture top_ticket_dispense_arch;

