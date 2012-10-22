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

            -- on cancel, display "--" blinking instead of the code+number
            -- (ugly hack)
            cancel : in std_logic;
            
            zone_choice : in std_logic_vector (1 downto 0 );
            ticket_count : in std_logic_vector (2 downto 0);

            seg : out std_logic_vector( 6 downto 0 );
            an : out std_logic_vector( 3 downto 0 );
            dp : out std_logic
        ); 
end entity ticket_dispense;

architecture ticket_dispense_arch of ticket_dispense is

    signal up : std_logic;
    signal down : std_logic;

    signal display_out : std_logic_vector(15 downto 0);
    signal display_mask : std_logic_vector(3 downto 0) := "1100";

    signal blink_clock : std_logic := '0';

    component edge_to_pulse is
        Port ( CLK : in  STD_LOGIC;
               Reset : in  STD_LOGIC;
               Edge_in : in  STD_LOGIC;
               Pulse_out : out  STD_LOGIC);
    end component;

    component hex_to_7seg is
        port(  rst : in std_logic;
                mclk : in std_logic;
                word_in : in std_logic_vector(15 downto 0 );
                display_mask_in : in std_logic_vector (3 downto 0 );
                seg : out std_logic_vector(6 downto 0 );
                an : out std_logic_vector(3 downto 0);
                dp : out std_logic
            ); 
    end component hex_to_7seg;

    component clk_divider is
        generic (clkmax : integer);
        port ( reset : in std_logic;
               clk_in : in std_logic;
               clk_out : out std_logic );
    end component clk_divider;

begin

    divider : clk_divider
        -- pragma synthesis off
        generic map(clkmax => 8) -- simulation
        -- pragma synthesis on
        generic map(clkmax => 12500000) -- synthesis
        port map( clk_in => mclk,
                reset => reset,
                clk_out => blink_clock );

    run_hex_to_7seg : hex_to_7seg 
        port map ( rst => reset,
                    mclk => mclk,
                    word_in => display_out,
                    -- ticket dispense needs two digits or no digits for
                    -- blinking
                    display_mask_in => display_mask,
                    seg => seg,
                    an => an,
                    dp => dp );

    run_ticket_dispense : process(mclk,reset) is
    begin
        if reset='1' then
            display_out <= X"0000";
            display_mask <= "1100";
        elsif rising_edge(mclk) then
            -- create a 16-bit value for display:
            --  four bits "A" 
            -- two bits zero & ticket count
            -- pad four more bits;
            if cancel='1' then
                display_mask <= "0110";
                display_out <= X"ffff";
            else 
                display_mask <= "1100";
                if zone_choice=zone_a then
                    display_out <= ((X"a" & "0") & ticket_count ) & X"00";
                elsif zone_choice=zone_b then
                    display_out <= ((X"b" & "0") & ticket_count ) & X"00";

                elsif zone_choice=zone_c then
                    display_out <= ((X"c" & "0") & ticket_count ) & X"00";
                else
                    display_out <= X"ffff";
                end if;
            end if;

            -- blink by turning entire segment on/off
            if blink_clock='0' then
                -- digits on
                if cancel='1' then
                    display_mask <= "0110";
                else 
                    display_mask <= "1100";
                end if;
            else 
                -- digits off
                display_mask <= "0000";
            end if;

        end if;
            
    end process run_ticket_dispense;

end architecture ticket_dispense_arch;

