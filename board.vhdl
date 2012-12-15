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

            row : in integer;
            col : in integer;

            data_in : in unsigned(7 downto 0);
            data_out : out unsigned(7 downto 0)
         );
end entity board;

architecture board_arch of board is
    constant row_width : integer := 4;
    constant col_height : integer := 4;
    constant xshift : integer := 2;

    type game_board is array ( 0 to row_width*col_height-1 ) of unsigned(7 downto 0 );
    signal room : game_board;
begin
    run_board :  process(clk,reset) is
        variable idx : integer;
    begin
        if reset='1' then
            data_out <= to_unsigned(16#ee#,8);
            idx := 0;
        elsif(rising_edge(clk)) then
            idx := (row*row_width) + col;
            if write_en='1' then
                room(idx) <= data_in;
            end if;
            data_out <= room(idx);
        end if;
    end process run_board;
end architecture board_arch;

