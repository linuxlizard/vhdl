--  Top level simulation test for the ticket_counter
-- davep 20-Oct-2012

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity top_ticket_counter is 
    port(  mclk : in std_logic;
            btn : in std_logic_vector(3 downto 0);
             sw : in std_logic_vector(7 downto 0);
            led : out std_logic_vector( 7 downto 0 );
            seg : out std_logic_vector( 6 downto 0 );
           an : out std_logic_vector( 3 downto 0 );
            dp : out std_logic
        ); 
end entity top_ticket_counter;

architecture top_ticket_counter_arch of top_ticket_counter is 

    signal user_ticket_count : std_logic_vector (2 downto 0) := (others=>'0');

    component ticket_counter is
        port( reset : in std_logic; 
                mclk : in std_logic;
                btn : in std_logic_vector(3 downto 0);
                seg : out std_logic_vector( 6 downto 0 );
                an : out std_logic_vector( 3 downto 0 );
                dp : out std_logic;
                ticket_count : out std_logic_vector(2 downto 0 )
            ); 
    end component ticket_counter;

begin

    run_ticket_counter : ticket_counter
        port map (
            reset => sw(0),
            mclk => mclk,
            btn => btn,
            seg => seg,
            an => an,
            dp => dp,
            ticket_count => user_ticket_count );

    run_top : process(mclk)
    begin
        if rising_edge(mclk) then
            if sw(0)='0' then
                -- reset
                led <= X"00";
            else 
                led <= "00000" & user_ticket_count;
            end if ;
        end if;
    end process run_top;

end architecture top_ticket_counter_arch;

