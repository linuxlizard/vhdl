-- Androids Game Board
-- ECE 530 Fall 2012
--
-- RAM with row,col positional input ports
-- 
-- David Poole
-- 13-Dec-2012

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.numeric_std.all;

entity board is
    port ( clk : in std_logic;
            reset : in std_logic;
            write_en : in std_logic;

            address : natural;

            data_in : in unsigned(7 downto 0);
            data_out : out unsigned(7 downto 0)
         );
end entity board;

architecture board_arch of board is
--    constant row_width : integer := 4;
--    constant col_height : integer := 4;
--    constant xshift : integer := 2;

    type game_board is array ( 0 to
            work.android_tools.row_width *
            work.android_tools.col_height-1 ) of unsigned(7 downto 0 );

    signal room : game_board;
begin

    process (clk,reset)
    begin
       if reset='1' then
         -- do something
       elsif( rising_edge(clk)) then
         if ( write_en= '1') then
            room(address) <= data_in;
         end if;
         data_out <= room(address);
       end if;
    end process;

--    run_board :  process(clk,reset) is
--        variable idx : integer;
--    begin
--        if reset='1' then
--            data_out <= to_unsigned(16#ee#,8);
--            idx := 0;
--        elsif(rising_edge(clk)) then
--            -- convert 2d row/col into 1d index
--            idx := (row*work.android_tools.row_width) + col;
--            if write_en='1' then
--                room(idx) <= data_in;
--            end if;
--            data_out <= room(idx);
--        end if;
--    end process run_board;
end architecture board_arch;

