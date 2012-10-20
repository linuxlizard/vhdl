-- BCD to 7-segment display
--
-- Connect a byte to the 7segment display. Connect enough components together
-- in a synthesizable state to test displaying a 3-digit number of 7seg.
--
-- David Poole 06-Oct-2012
--
-- davep 19-Oct-2012 ; copy to hex_to_7seg for hex display

library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity hex_to_7seg is
    -- signals in Basys2
    port(  mclk : in std_logic;

            word_in : in std_logic_vector(15 downto 0);

            -- 7seg display
            seg : out std_logic_vector(6 downto 0 );

            -- anode of 7seg display
            an : out std_logic_vector(3 downto 0);

            -- decimal point of 7seg display
            dp : out std_logic
        ); 
end entity hex_to_7seg;

architecture run_hex_to_7seg of hex_to_7seg is

    -- 7seg encoder out to 7segmuxor in 
    signal out7seg0 : std_logic_vector (6 downto 0 );
    signal out7seg1 : std_logic_vector (6 downto 0 );
    signal out7seg2 : std_logic_vector (6 downto 0 );
    signal out7seg3 : std_logic_vector (6 downto 0 );

    -- clock divider out to 7segmuxor in 
    signal divider_out_7segmuxor_in : std_logic;

    component clk_divider is
        generic (clkmax : integer);
        port ( reset : in std_logic;
               clk_in : in std_logic;
               clk_out : out std_logic );
    end component clk_divider;

    component ssegmuxor is
        port (  reset : in std_logic;
                clk : in std_logic;
    display_mask : in std_logic_vector( 3 downto 0 );
                digit_0 : in std_logic_vector (6 downto 0 );
                digit_1 : in std_logic_vector (6 downto 0 );
                digit_2 : in std_logic_vector (6 downto 0 );
                digit_3 : in std_logic_vector (6 downto 0 );
   decimal_point_mask : in std_logic_vector(3 downto 0 );

                anode_out : out std_logic_vector (3 downto 0 );
                digit_out : out std_logic_vector (6 downto 0 ) ;
            dp_out : out std_logic
            );
    end component ssegmuxor;

    component SevenSegmentEncoder is
          Port (rst : in std_logic;
                 ck:  in  std_logic;
                nibble: in std_logic_vector( 3 downto 0 );
                seg: out std_logic_vector(6 downto 0)
          );
    end component SevenSegmentEncoder;

    signal rst : std_logic:='0';

    signal bcd_is_negative : std_logic:='0';

begin
    -- future compatibility for an incoming reset signal
    rst <= '0';


    -- the actual divider will be 2.1e6 or so (25Mhz down to 15hz)
    run_divider : clk_divider
        generic map(clkmax => 4) -- simulation
--        generic map(clkmax => 50000) -- synthesis
        port map( clk_in => mclk,
                reset => rst,
                clk_out => divider_out_7segmuxor_in );

    -- right most digit
    sevenseg_digit3 : SevenSegmentEncoder
        port map ( rst => rst,
                    ck => mclk,
                    nibble => word_in(3 downto 0),
                    seg => out7seg3
                );
    
    sevenseg_digit2 : SevenSegmentEncoder
        port map ( rst => rst,
                    ck => mclk,
                    nibble => word_in(7 downto 4),
                    seg => out7seg2 
                );

    sevenseg_digit1 : SevenSegmentEncoder
        port map ( rst => rst,
                    ck => mclk,
                    nibble => word_in(11 downto 8),
                    seg => out7seg1
                );

    -- left most digit
    sevenseg_digit0 : SevenSegmentEncoder 
        port map ( rst => rst,
                    ck => mclk,
                    nibble => word_in(15 downto 12),
                    seg => out7seg0
                );

    sevenseg_muxor : ssegmuxor
        port map (  reset => rst,
                    clk => divider_out_7segmuxor_in,
                    display_mask => "1000", -- want left-most digit only
                    digit_0 => out7seg0,
                    digit_1 => "1000000",
                    digit_2 => "1000000",
                    digit_3 => "1000000",
                    decimal_point_mask => "0000", -- no decimal points
                    anode_out => an, -- 7segment display anode
                    digit_out => seg, -- 7segment display segment
                    dp_out => dp -- decimal point
                );

end architecture run_hex_to_7seg;

