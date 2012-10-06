-- Test the Seven Segment / BCD encoder
--
-- Uses code from SimpleSsegLedDemo.vhd 
--
-- David Poole 30-Sep-2012


library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity test_sseg is 
  begin
  end entity test_sseg;

architecture run_test_sseg of test_sseg is

    component SevenSegmentEncoder is
          Port (rst : in std_logic;
                 ck:  in  std_logic;
                nibble: in std_logic_vector( 3 downto 0 );
                seg: out std_logic_vector(6 downto 0)
          );
    end component SevenSegmentEncoder;

  signal t_rst : std_logic := '1';
  signal t_clk : std_logic := '0';
  signal t_buttons : std_logic_vector( 3 downto 0 );
  signal t_switches : std_logic_vector( 7 downto 0 );
  signal t_leds : std_logic_vector( 7 downto 0 );
  signal t_segments : std_logic_vector( 6 downto 0 );
  signal t_decimal_points : std_logic;
  signal t_anodes : std_logic_vector( 3 downto 0 );
  signal t_nibble: std_logic_vector( 3 downto 0 );

  function sevenseg_to_integer( sseg : in std_logic_vector( 6 downto 0 )) return integer is
    -- Convert seven-segment bits to a number suitable for printing.
    -- Handy for test/debug
    -- Uses code from SimpleSsegLedDemo.vhd 
    begin
        case sseg is 
         when "1111001" => return 1;
         when "0100100" => return 2;
         when "0110000" => return 3;
         when "0011001" => return 4;
         when "0010010" => return 5;
         when "0000010" => return 6;
         when "1111000" => return 7;
         when "0000000" => return 8;
         when "0010000" => return 9;
         when "0001000" => return 16#A#;
         when "0000011" => return 16#b#;
         when "1000110" => return 16#C#;
         when "0100001" => return 16#d#;
         when "0000110" => return 16#E#;
         when "0001110" => return 16#F#;
         when "1000000" => return 0;
         when others => return -1;            
        end case;
    end sevenseg_to_integer;

begin
    uut : SevenSegmentEncoder 
        port map( rst => t_rst,
                ck => t_clk,
                nibble => t_nibble,
                seg => t_segments
               );

    clock : process is 
    begin
        t_clk <= '0'; wait for 10 ns;
        t_clk <= '1'; wait for 10 ns;
    end process clock;

    stimulus : process is
        variable str : line;
        variable i : integer;
        variable num : unsigned (3 downto 0);
    begin
        t_buttons <= "0000";
        t_switches <= "00000000";
        t_nibble <= "0000";

        write( str, string'("Hello, world") );
        writeline( output, str );

        t_rst <= '1';
        wait for 15 ns;

        t_rst <= '0';
        wait for 10 ns;

        num := "0001";

        for i in 0 to 20 loop
            t_nibble <= std_logic_vector(num);
            write( str, t_segments );
            write( str, string'(" = "));
            write( str, sevenseg_to_integer( t_segments ) );
            writeline( output, str );
            wait for 20 ns;

            num := num+1; 
            wait for 20 ns;
        end loop;

--        hwrite( str, t_segments );
--        writeline( output, str );

        wait;
    end process stimulus;

end architecture run_test_sseg;

