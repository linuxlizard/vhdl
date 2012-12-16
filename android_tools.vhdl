-- Utility functions for Androids game project
--
-- ECE 530 Fall 2012
--
-- David Poole
-- 15-Dec-2012

library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

package android_tools is

    function write_pos( num : in integer ) return string;

end package android_tools;

package body android_tools is

    -- Convert an incoming row or column (1 or 2 digit number) into a two 
    -- digit string. The string is used to poke values into the "set cursor
    -- position" VT100 string.
    function write_pos( num : in integer ) return string is
        variable pos_s1 : string(1 downto 1);
        variable pos_s2 : string(2 downto 1);
        variable s : line;
    begin
        -- write two digit of 'num into incoming string at position 'pos';
        -- write leading 0 if <10
        if num < 10 then
            pos_s1 := integer'image(num);

            pos_s2(1) := '0';
            pos_s2(2) := pos_s1(1);
--            t_string(12) <= character'val(row+16#30#);
        else 
            pos_s2 := integer'image(num);
        end if;

        return pos_s2;
    end write_pos;

end package body android_tools;

