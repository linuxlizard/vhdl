-- Put useful functions into a shareable package.
--
-- David Poole 06-Oct-2012

library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

package debug_utils is

  function sevenseg_to_integer( sseg : in std_logic_vector( 6 downto 0 )) return integer;

  procedure dbg_7seg( seg : std_logic_vector(6 downto 0 );
                         an : std_logic_vector(3 downto 0);
                         dp : std_logic );

end package debug_utils;


package body debug_utils is

  function sevenseg_to_integer( sseg : in std_logic_vector( 6 downto 0 )) return integer is
    -- Convert seven-segment bits to a number suitable for printing.
    -- Handy for test/debug
    begin
        case sseg is 
         when "1111001" => return 1; -- 0x79
         when "0100100" => return 2; -- 0x24
         when "0110000" => return 3; -- 0x30
         when "0011001" => return 4; -- 0x29
         when "0010010" => return 5; -- 0x12
         when "0000010" => return 6; -- 0x02
         when "1111000" => return 7; -- 0x78
         when "0000000" => return 8; -- 0x00
         when "0010000" => return 9; -- 0x10
         when "0001000" => return 16#A#;
         when "0000011" => return 16#b#;
         when "1000110" => return 16#C#;
         when "0100001" => return 16#d#;
         when "0000110" => return 16#E#;
         when "0001110" => return 16#F#;
         when "1000000" => return 0; -- 0x40
         when others => return -1;            
        end case;
    end sevenseg_to_integer;

    procedure dbg_7seg( seg : std_logic_vector(6 downto 0 );
                         an : std_logic_vector(3 downto 0);
                         dp : std_logic ) is
        variable str : line;
    begin
        write( str, string'("seg=") );
        write( str, seg );
        write( str, string'(" value=") );
        write( str, work.debug_utils.sevenseg_to_integer( seg ) );
        write( str, string'(" an=") );
        write( str, an );
        write( str, string'(" dp=") );
        write( str, dp );
        writeline(output,str);
    end procedure dbg_7seg;

end package body debug_utils;

