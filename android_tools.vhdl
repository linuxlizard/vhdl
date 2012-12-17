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
    function calc_next_row( row : in integer; col : integer ) return integer;
    function calc_next_col( row : in integer; col : in integer ) return integer;

    function position_to_address( row : in integer; col : in integer ) 
                return natural;

--    constant row_width : integer := 32;
--    constant col_height : integer := 32;
--    constant row_width : integer := 16;
--    constant col_height : integer := 16;
    constant row_width : integer := 64;
    constant col_height : integer := 64;

    constant move_up      : unsigned(7 downto 0) := to_unsigned(16#38#,8); -- '8'
    constant move_none  : unsigned(7 downto 0) := to_unsigned(16#35#,8); -- '5'
    constant move_down      : unsigned(7 downto 0) := to_unsigned(16#32#,8); -- '2'

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

    -- iterating across columns then down rows
    --   n -> n -> n -> n -\
    --                     |
    --   /-----------------/
    --   |
    --   n -> n -> n -> n etc.
    --
    function calc_next_row( row : in integer; col : integer ) return integer is
    begin
        if col=col_height-1 then
            if row < row_width-1 then
                return row+1;
            else
                return 0;
            end if;
        else
            return row;
        end if;
    end calc_next_row;

    function calc_next_col( row : in integer; col : in integer ) return integer is
    begin
        -- we want to traverse the entire width of row before we go to the
        -- next col
        -- VT100 works on (row,col)
        -- 
        --     col col col col
        -- row  00  01  02  03
        -- row  10  11  12  13
        -- row  20  21  22  23
        -- row  30  31  32  33
        --
        --
        -- stored in the board RAM as:
        -- 00 01 02 03 10 11 12 13 20 21 22 23 30 31 32 33
        --
--        if row = row_width-1 then
            if col < col_height-1 then
                return col+1;
            else
                return 0;
            end if;
--        else
--            return col;
--        end if;
    end calc_next_col;

    function position_to_address( row : in integer; col : in integer ) 
                    return natural is
    begin
        -- player positions are 1-based (due to vt100 being 1-based
        -- (upper left is 1,1 not 0,0))                
        return ((row-1) * row_width) + (col-1);
    end function position_to_address;

end package body android_tools;

