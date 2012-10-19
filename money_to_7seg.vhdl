-- BCD to 7-segment display
--
-- Connect a byte to the 7segment display. Connect enough components together
-- in a synthesizable state to test displaying a 3-digit number of 7seg.
--
-- David Poole 06-Oct-2012
--
-- davep 18-Oct-2012 ; copy/paste from digit_to_7seg.vhdl to money_to_7seg.vhdl
--                     to make money display

library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity money_to_7seg is
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
end entity money_to_7seg;

architecture run_money_to_7seg of money_to_7seg is

    -- bcd out to 7seg encoder in
    signal bcd_outnibble0 : std_logic_vector (3 downto 0);
    signal bcd_outnibble1 : std_logic_vector (3 downto 0);
    signal bcd_outnibble2 : std_logic_vector (3 downto 0);
    signal bcd_outnibble3 : std_logic_vector (3 downto 0);
    signal bcd_outnibble4 : std_logic_vector (3 downto 0);

    -- 7seg encoder out to 7segmuxor in 
    signal out7seg0 : std_logic_vector (6 downto 0 );
    signal out7seg1 : std_logic_vector (6 downto 0 );
    signal out7seg2 : std_logic_vector (6 downto 0 );
    signal out7seg3 : std_logic_vector (6 downto 0 );

    -- clock divider out to 7segmuxor in 
    signal divider_out_7segmuxor_in : std_logic;

    -- decimal point mask
    signal dp_mask_in : std_logic_vector( 3 downto 0 ) := (others=>'0');

    signal display_mask : std_logic_vector( 3 downto 0 ) := (others=>'0');

    signal rst : std_logic:='0';


    component clk_divider is
        generic (clkmax : integer);
        port ( reset : in std_logic;
               clk_in : in std_logic;
               clk_out : out std_logic );
    end component clk_divider;

    component bcd_encoder is
        port (rst : in std_logic;
              clk : in std_logic;
              word_in : in std_logic_vector(15 downto 0 );
              bcd_out : out std_logic_vector( 19 downto 0 )
             );
    end component bcd_encoder;

    component ssegmuxor is
        port (  reset : in std_logic;
                clk : in std_logic;
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

    run_bcd_encoder : bcd_encoder
        port map ( rst => rst,
                    clk => mclk, 
                    word_in => word_in,
--                    byte_in => "11111100",
                   -- bcd is 20 digits so split into 5 groups of 4
                   bcd_out(19 downto 16) =>  bcd_outnibble4,
                   bcd_out(15 downto 12) =>  bcd_outnibble3,
                   bcd_out(11 downto 8) =>  bcd_outnibble2,
                   bcd_out( 7 downto 4) =>  bcd_outnibble1,
                   bcd_out( 3 downto 0) =>  bcd_outnibble0
                );

    -- something is backwards in my bcd or in my 7seg 

    -- right most digit
    sevenseg_digit3 : SevenSegmentEncoder
        port map ( rst => rst,
                    ck => mclk,
--                    nibble => "0010",
                    nibble => bcd_outnibble0,
                    seg => out7seg3
                );
    
    sevenseg_digit2 : SevenSegmentEncoder
        port map ( rst => rst,
                    ck => mclk,
--                    nibble => "0001",
                    nibble => bcd_outnibble1,
                    seg => out7seg2 
                );

    sevenseg_digit1 : SevenSegmentEncoder
        port map ( rst => rst,
                    ck => mclk,
--                    nibble => "0000",
                    nibble => bcd_outnibble2,
                    seg => out7seg1
                );

    -- left most digit
    sevenseg_digit0 : SevenSegmentEncoder 
        port map ( rst => rst,
                    ck => mclk,
                    nibble => bcd_outnibble3,
                    seg => out7seg0
                );


    sevenseg_muxor : ssegmuxor
        port map ( reset => rst,
                    clk => divider_out_7segmuxor_in,
                    digit_0 => out7seg0,
                    digit_1 => out7seg1,
                    digit_2 => out7seg2,
                    digit_3 => out7seg3,
         decimal_point_mask => dp_mask_in,

--                    is_negative => '1',
--                   digit_0 => "1111001",
--                   digit_1 => "0100100",
--                    digit_2 => "0110000",
--                    digit_3 => "0011001",

                    anode_out => an, -- 7segment display anode
                    digit_out => seg, -- 7segment display segment
                    dp_out => dp -- decimal point
                );

    make_change : process(mclk) is 
    begin
        -- incoming number is converted to bcd;
        -- we select which digits are active and where the decimal point is
        -- here to reflect a base-10 money system
        if rising_edge(mclk) then
            if word_in="0000000000000000" then
                -- output hardwired to "  0.0"
                display_mask <= "0011";
                dp_mask_in <= "0010";
            elsif word_in < "0000000001100100" then  -- < d'100
                display_mask <= "0111";
                dp_mask_in <= "0100";

            end if;
        end if;
    end process make_change;


end architecture run_money_to_7seg;
