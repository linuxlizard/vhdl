
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.numeric_std.all;

entity androids is
end entity androids;

architecture androids_arch of androids is
    constant x_width : integer := 80;
    constant y_height : integer := 25;
    constant clk_period : time := 10 ns;

    constant space : unsigned(7 downto 0) := to_unsigned(16#20#,8);
    constant player : unsigned(7 downto 0) := to_unsigned(16#40#,8);
    constant android : unsigned(7 downto 0) := to_unsigned(16#41#,8);

    type game_board is array ( natural range <>, natural range <> ) of unsigned(7 downto 0 );
    signal room : game_board( 0 to y_height, 0 to x_width );

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

    function reset_room_next_state( state_in : in game_state ) return game_state is
    begin
        if state_in = STATE_RESET_ROOM_1 then
            return STATE_RESET_ROOM_2;
        else 
            return STATE_RESET_ROOM_1;
        end if;
    end reset_room_next_state;

    function calc_next_x( x : in integer; y : integer ) return integer is
    begin
        if x < x_width-1 then
            return x+1;
        else
            return 0;
        end if;
    end calc_next_x;

    function calc_next_y( x : in integer; y : in integer ) return integer is
    begin
        -- we want to traverse the entire width of X before we go to the next Y
        --    x  x  x  x
        -- y 00 10 20 30
        -- y 01 11 21 31
        -- y 02 12 22 32
        -- y 03 13 23 33
        if x = x_width-1 then
            if y < y_height-1 then
                return y+1;
            else
                return 0;
            end if;
        else
            return y;
        end if;
    end calc_next_y;

    -- indices into the game board RAM
    signal x : integer;
    signal next_x : integer;
    signal y : integer;
    signal next_y : integer;

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

    clock1 : process is
    begin
       mclk <= '0'; wait for clk_period/2;
       mclk <= '1'; wait for clk_period/2;
    end process clock1;

    
    state_machine_run : process(reset,mclk) is
    begin
        if( reset='1') then
            curr_state <= STATE_INIT;
            y <= 0;
            x <= 0;
        elsif( rising_edge(mclk)) then
            curr_state <= next_state;
            y <= next_y;
            x <= next_x;
        end if;
    end process state_machine_run;

    state_machine_process : process( curr_state ) is
        variable str : line;
    begin
        debug_num <= 0;
        next_y <= y;
        next_x <= x;
        next_state <= curr_state;

        case curr_state is
            when STATE_INIT =>
                debug_num <= 0;
                next_state <= STATE_RESET_ROOM_1;
                next_y <= 0;
                next_x <= 0;

            when STATE_RESET_ROOM_1 | STATE_RESET_ROOM_2 =>
                -- we ping/pong back and forth between these states to
                -- initialize our game board to a blank state
                write( str, string'("x=") & integer'image(x) );
                write( str, string'(" y=") & integer'image(y) );
                writeline(output,str);

                debug_num <= 1;
                room(y,x) <= space;
                next_state <= reset_room_next_state(curr_state);
                next_x <= calc_next_x(x,y);
                next_y <= calc_next_y(x,y);

                -- if we have reached the max position on the board, we are
                -- done. Go to wait for player
                if x=x_width-1 and y=y_height-1 then
                    next_state <= STATE_WAIT_FOR_PLAYER;
                end if;

            when STATE_WAIT_FOR_PLAYER =>
                write( str, string'("waiting for player") );
                writeline(output,str);

                debug_num <= 3;

            when others =>
                next_state <= STATE_INIT;

        end case;

    end process;

    stimulus : process 
    begin
        wait for clk_period;
        wait until mclk='0';
        reset <= '0';
        wait for clk_period;
        wait for clk_period;
        wait for clk_period;

        ax_wr <= '1';
        ax_in <= to_unsigned(99,8);
        wait for clk_period;

        ax_wr <= '0';
        ax_in <= to_unsigned(16#ee#,8);
        wait for clk_period;
        wait for clk_period;

        room(0,0) <= to_unsigned(16#30#,8);
        room(0,10) <= to_unsigned(16#30#,8);
        room(10,0) <= to_unsigned(16#30#,8);
        wait for clk_period;

        ax_wr <= '1';
        ax_in <= room(0,0);
        wait for clk_period;
        ax_wr <= '0';
        wait for clk_period;

        bx_wr <= '1';
        bx_in <= ax_out + to_unsigned(16#01#,8);
        wait for clk_period;

        bx_wr <= '0';
        wait for clk_period;

        room(11,11) <= bx_out;
        wait for clk_period;

        ax_wr <= '1';
        ax_in <= room(11,11);
        wait for clk_period;

        ax_wr <= '0';
        wait for clk_period;

        wait;
    end process stimulus;

end architecture androids_arch;


