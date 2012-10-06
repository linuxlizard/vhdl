library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;

package debug_utils is

  function sevenseg_to_integer( sseg : in std_logic_vector( 6 downto 0 )) return integer;

end package debug_utils;

package body debug_utils is

  function sevenseg_to_integer( sseg : in std_logic_vector( 6 downto 0 )) return integer is
    -- Convert seven-segment bits to a number suitable for printing.
    -- Handy for test/debug
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

end package body debug_utils;

