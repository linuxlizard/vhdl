-- Ticket zone constants for ticket display
-- davep 20-Oct-2012

library ieee;
use ieee.std_logic_1164.all;

package ticketzones is  
    -- invalid used during error conditions
    constant zone_invalid : std_logic_vector (1 downto 0 ) := "00";
    constant zone_a : std_logic_vector(1 downto 0) := "01";
    constant zone_b : std_logic_vector(1 downto 0) := "10";
    constant zone_c : std_logic_vector(1 downto 0) := "11";
end package ticketzones;

