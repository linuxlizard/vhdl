-- Display ticket choices. User scrolls through choices with button0 and
-- button1
--
-- Users choses zone with btn3.

-- davep 19-Oct-2012

library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

library work;
use work.ticketzones.all;

entity ticket_display is
    port( reset : in std_logic; 
            mclk : in std_logic;
            btn : in std_logic_vector(3 downto 0);

            seg : out std_logic_vector( 6 downto 0 );
            an : out std_logic_vector( 3 downto 0 );
            dp : out std_logic;
            zone_choice : out std_logic_vector ( 1 downto 0 )
        ); 
end entity ticket_display;

architecture ticket_display_arch of ticket_display is

    signal btn_0_pushed : std_logic;
    signal btn_1_pushed : std_logic;
    signal btn_3_pushed : std_logic;

    signal up : std_logic;
    signal down : std_logic;

    signal zone_display_out : std_logic_vector(15 downto 0);

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
    btn_0_edge_to_pulse : edge_to_pulse
        port map ( CLK => mclk,
                   Reset => reset,
                   Edge_in => btn(0),
                   Pulse_out => btn_0_pushed );

    btn_1_edge_to_pulse : edge_to_pulse
        port map ( CLK => mclk,
                   Reset => reset,
                   Edge_in => btn(1),
                   Pulse_out => btn_1_pushed );

    btn_3_edge_to_pulse : edge_to_pulse
        port map ( CLK => mclk,
                   Reset => reset,
                   Edge_in => btn(3),
                   Pulse_out => btn_3_pushed );

    run_hex_to_7seg : hex_to_7seg 
        -- ticket display needs one digit
        generic map (display_mask_param => "1000" )
        port map ( rst => reset,
                    mclk => mclk,
                    word_in => zone_display_out,
                    seg => seg,
                    an => an,
                    dp => dp );

    run_ticket_display : process(mclk,reset) is
        variable current_pos : integer := 0;
    begin
        if reset='1' then
            zone_display_out <= X"a000";
            current_pos := 0;
            zone_choice <= zone_invalid;
        elsif rising_edge(mclk) then
            if btn_0_pushed='1' and current_pos /= 0 then
                -- up
                current_pos := current_pos -1;
            elsif btn_1_pushed='1' and current_pos /= 2 then
                -- down
                current_pos := current_pos +1;
            elsif btn_3_pushed='1' then
                -- selection chosen
                if current_pos = 0 then
                    zone_choice <= zone_a;
                elsif current_pos = 1 then
                    zone_choice <= zone_b;
                elsif current_pos = 2 then
                    zone_choice <= zone_c;
                else
                    zone_choice <= zone_invalid;
                end if;
            end if;

            if current_pos = 0 then
                zone_display_out <= X"a000";
            elsif current_pos = 1 then
                zone_display_out <= X"b000";
            elsif current_pos = 2 then
                zone_display_out <= X"c000";
            else 
                zone_display_out <= X"ffff";
            end if;

        end if;
            
    end process run_ticket_display;

end architecture ticket_display_arch;

