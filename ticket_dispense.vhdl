-- Dispense tickets. Display zone code and count blinking for 3 seconds. 
-- Then display the change.
--
-- davep 20-Oct-2012

library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

library work;
use work.ticketzones.all;

entity ticket_dispense is
    port( reset : in std_logic; 
            mclk : in std_logic;
            zone_choice : in std_logic_vector (1 downto 0 );
            ticket_count : in unsigned (2 downto 0);

            seg : out std_logic_vector( 6 downto 0 );
            an : out std_logic_vector( 3 downto 0 );
            dp : out std_logic
        ); 
end entity ticket_dispense;

architecture ticket_dispense_arch of ticket_dispense is

    signal up : std_logic;
    signal down : std_logic;

    signal display_out : std_logic_vector(15 downto 0);

    component edge_to_pulse is
        Port ( CLK : in  STD_LOGIC;
               Reset : in  STD_LOGIC;
               Edge_in : in  STD_LOGIC;
               Pulse_out : out  STD_LOGIC);
    end component;

    component hex_to_7seg is
        generic (display_mask_param : std_logic_vector(3 downto 0));
        port(  rst : in std_logic;
                mclk : in std_logic;
                word_in : in std_logic_vector(15 downto 0 );
                seg : out std_logic_vector(6 downto 0 );
                an : out std_logic_vector(3 downto 0);
                dp : out std_logic
            ); 
    end component hex_to_7seg;

begin

    run_hex_to_7seg : hex_to_7seg 
        -- ticket dispense needs two digits
        generic map (display_mask_param => "1100" )
        port map ( rst => reset,
                    mclk => mclk,
                    word_in => display_out,
                    seg => seg,
                    an => an,
                    dp => dp );

    run_ticket_dispense : process(mclk,reset) is
    begin
        if reset='1' then
            display_out <= X"0000";
        elsif rising_edge(mclk) then
            -- create a 16-bit value for display:
            --  four bits "A" 
            -- two bits zero & ticket count
            -- pad four more bits;
            if zone_choice=zone_a then
                display_out <= ((X"a" & "0") &
                                std_logic_vector(ticket_count) ) & X"00";
            elsif zone_choice=zone_b then
                display_out <= ((X"b" & "0") &
                                std_logic_vector(ticket_count) ) & X"00";

            elsif zone_choice=zone_c then
                display_out <= ((X"c" & "0") &
                                std_logic_vector(ticket_count) ) & X"00";
            else
                display_out <= X"ffff";
            end if;
        end if;
            
    end process run_ticket_dispense;

end architecture ticket_dispense_arch;

