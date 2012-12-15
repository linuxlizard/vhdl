-- Androids Game Board
-- ECE 530 Fall 2012
--
-- David Poole
-- 13-Dec-2012

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.numeric_std.all;

entity androids is
end entity androids;

architecture androids_arch of androids is
    constant row_width : integer := 4;
    constant col_height : integer := 4;
    constant xshift : integer := 2;
--    constant row_width : integer := 80;
--    constant col_height : integer := 25;

    constant clk_period : time := 10 ns;

    -- ascii characters for blank, the player '@', and androids 'A' 
    constant space : unsigned(7 downto 0) := to_unsigned(16#20#,8);
    constant player : unsigned(7 downto 0) := to_unsigned(16#40#,8);
    constant android : unsigned(7 downto 0) := to_unsigned(16#41#,8);

    signal mclk :  std_logic := '0';
    signal reset : std_logic := '1';

    component d_register is
        generic (width : integer);
        port (clk : in std_logic;
              reset : in std_logic := '1';
              input_enable : in std_logic;
              output_enable : in std_logic;
              data_in : in unsigned( 7 downto 0 );
              data_out : out unsigned( 7 downto 0 )
        );
    end component d_register;

    component board is
        port ( clk : in std_logic;
                reset : in std_logic;
                write_en : in std_logic;

                row : in integer;
                col : in integer;

                data_in : in unsigned(7 downto 0);
                data_out : out unsigned(7 downto 0)
             );
    end component board;

    signal ax_in : unsigned(7 downto 0);
    signal ax_out : unsigned(7 downto 0);
    signal ax_wr : std_logic := '0';

    signal bx_in : unsigned(7 downto 0);
    signal bx_out : unsigned(7 downto 0);
    signal bx_wr : std_logic := '0';

    type game_state is
        ( STATE_INIT,
          STATE_RESET_ROOM_1,
          STATE_RESET_ROOM_2,
          STATE_WAIT_FOR_PLAYER );

    signal curr_state, next_state: game_state;

    signal debug_num : integer;
    signal debug_num2 : integer;

    function reset_room_next_state( state_in : in game_state ) return game_state is
    begin
        if state_in = STATE_RESET_ROOM_1 then
            return STATE_RESET_ROOM_2;
        else 
            return STATE_RESET_ROOM_1;
        end if;
    end reset_room_next_state;

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

    -- indices into the game board RAM
    signal row : integer;
    signal next_row : integer;
    signal col : integer;
    signal next_col : integer;

    -- disable the board state machine
    signal mclk2 : std_logic := '0';
    
    signal room_write_en : std_logic := '0';
    signal room_data_in : unsigned(7 downto 0 ) := (others=>'0');
    signal room_data_out : unsigned(7 downto 0 );
begin
    ax : d_register
        generic map(width=>8)
        port map(clk=>mclk,
                reset=>reset,
                input_enable => ax_wr,
                output_enable => '1',
                data_in => ax_in,
                data_out => ax_out 
            );
    bx : d_register
        generic map(width=>8)
        port map(clk=>mclk,
                reset=>reset,
                input_enable => bx_wr,
                output_enable => '1',
                data_in => bx_in,
                data_out => bx_out 
            );

    room : board
        port map( clk=>mclk,
                   reset=>reset,
                   write_en=> room_write_en,
                   row => row,
                   col => col,
                   data_in => room_data_in,
                   data_out => room_data_out );

    -- this is the main clock
    -- pragma synthesis off
    clock1 : process is
    begin
       mclk <= '0'; wait for clk_period/2;
       mclk <= '1'; wait for clk_period/2;
    end process clock1;
    -- pragma synthesis on

    -- state machine to control the game board
    state_machine_run : process(reset,mclk) is
    begin
        if( reset='1') then
            curr_state <= STATE_INIT;
            row <= 0;
            col <= 0;
        elsif( rising_edge(mclk)) then
            curr_state <= next_state;
            row <= next_row;
            col <= next_col;
        end if;
    end process state_machine_run;

    state_machine_process : process( curr_state, row, col ) is
        variable str : line;
    begin
        debug_num <= 0;
        next_row <= row;
        next_col <= col;
        next_state <= curr_state;
        room_write_en <= '0';

        case curr_state is
            when STATE_INIT =>
                debug_num <= 0;
                next_state <= STATE_RESET_ROOM_1;
                next_row <= 0;
                next_col <= 0;

            when STATE_RESET_ROOM_1 | STATE_RESET_ROOM_2 =>
                -- we ping/pong back and forth between these states to
                -- initialize our game board to a blank state

                debug_num <= 1;
                room_write_en <= '1';
                room_data_in <= space;
                next_state <= reset_room_next_state(curr_state);
                next_row <= calc_next_row(row,col);
                next_col <= calc_next_col(row,col);

                -- pragma synthesis off
                write( str, string'("row=") & integer'image(row) );
                write( str, string'(" col=") & integer'image(col) );
                writeline(output,str);
                -- pragma synthesis on

                -- if we have reached the max position on the board, we are
                -- done. Go to wait for player
                if row=row_width-1 and col=col_height-1 then
                    next_state <= STATE_WAIT_FOR_PLAYER;
--                    room_write_en <= '0';
                end if;

            when STATE_WAIT_FOR_PLAYER =>
                -- pragma synthesis off
                write( str, string'("waiting for player") );
                writeline(output,str);
                -- pragma synthesis on

                debug_num <= 3;

            when others =>
                next_state <= STATE_INIT;

        end case;

    end process;

    -- pragma synthesis off
    stimulus : process 
        variable idx : integer;
        variable row : integer;
        variable col : integer;
    begin
        debug_num2 <= 0;
        wait for clk_period;
        wait until mclk='0';
        reset <= '0';
        wait for clk_period;
        wait for clk_period;
        wait for clk_period;

        wait;

        debug_num2 <= 1;
        ax_wr <= '1';
        ax_in <= to_unsigned(99,8);
        wait for clk_period;

        debug_num2 <= 2;
        ax_wr <= '0';
        ax_in <= to_unsigned(16#ee#,8);
        wait for clk_period;
        wait for clk_period;

        debug_num2 <= 3;
        row := 0;
        col := 0;
--        room_write_en <= '1';
--        room_data_in <= space;
--        room(0,0 ) <= to_unsigned(16#30#,8);
--        room(0,10) <= to_unsigned(16#30#,8);
--        room(10,0) <= to_unsigned(16#30#,8);
        wait for clk_period;

--        room_write_en <= '0';
--        wait;

        debug_num2 <= 4;
        ax_wr <= '1';
--        ax_in <= room(0,0);
        wait for clk_period;
        ax_wr <= '0';
        wait for clk_period;

        bx_wr <= '1';
        bx_in <= ax_out + to_unsigned(16#01#,8);
        wait for clk_period;

        bx_wr <= '0';
        wait for clk_period;

--        room(11,11) <= bx_out;
        wait for clk_period;

        ax_wr <= '1';
--        ax_in <= room(11,11);
        wait for clk_period;

        ax_wr <= '0';
        wait for clk_period;

        wait;
    end process stimulus;
    -- pragma synthesis on

end architecture androids_arch;


