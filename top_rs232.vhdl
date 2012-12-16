-- Test RS232 in Synthesis
-- ECE530 Fall 2012
--
-- David Poole
-- 28-Nov-2012

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use std.textio.all;
use ieee.numeric_std.all;

entity top_rs232 is
    port(  mclk : in std_logic;
            btn : in std_logic_vector(3 downto 0);
             sw : in std_logic_vector(7 downto 0);

           PIO  : inout std_logic_vector (87 downto 72); 

            led : out std_logic_vector( 7 downto 0 );
            seg : out std_logic_vector( 6 downto 0 );
             an : out std_logic_vector( 3 downto 0 );
             dp : out std_logic
        ); 
end entity top_rs232;

architecture top_rs232_arch of top_rs232 is

    constant vt100_clear_screen : string(15 downto 1) :=
        ( esc,'[','2','J',nul,others=>nul);

    constant vt100_move_home : string(15 downto 1) :=
        ( esc,'[','1',';','1','H',nul,others=>nul);

    -- Clear screen and move home all in one constant. Send this string at game
    -- start to clear the terminal and position ourselves in upper left.
    constant vt100_clear_screen_and_move_home : string(15 downto 1) :=
        ( esc,'[','2','J',esc,'[','1',';','1','H',nul,others=>nul);

    -- vt100 sequences for cursor movement
    constant vt100_cursor_up : string(15 downto 1) := 
        ( esc,'[','A',nul,others=>nul);
    constant vt100_cursor_down : string(15 downto 1) := 
        ( esc,'[','B',nul,others=>nul);

    constant vt100_cursor_right : string(15 downto 1) := 
        ( esc,'[','C',nul,others=>nul);
    constant vt100_cursor_left : string(15 downto 1) := 
        ( esc,'[','D',nul,others=>nul);

    constant vt100_cursor_upright: string(15 downto 1) := 
        ( esc,'[','A',esc,'[','C',nul,others=>nul);
    constant vt100_cursor_upleft : string(15 downto 1) := 
        ( esc,'[','A',esc,'[','D',nul,others=>nul);

    constant vt100_cursor_downright: string(15 downto 1) := 
        ( esc,'[','B',esc,'[','C',nul,others=>nul);
    constant vt100_cursor_downleft : string(15 downto 1) := 
        ( esc,'[','B',esc,'[','D',nul,others=>nul);

    constant empty_string : string(15 downto 1) :=
        ( nul, nul, nul, nul, nul, nul, nul, nul, nul, nul, nul, nul, nul, nul, nul );
--        ( nul, others=>nul );

    -- character motion input characters
    constant move_upleft  : unsigned(7 downto 0) := to_unsigned(16#37#,8); -- '7'
    constant move_up      : unsigned(7 downto 0) := to_unsigned(16#38#,8); -- '8'
    constant move_upright : unsigned(7 downto 0) := to_unsigned(16#39#,8); -- '9'

    constant move_left  : unsigned(7 downto 0) := to_unsigned(16#34#,8); -- '4'
    constant move_none  : unsigned(7 downto 0) := to_unsigned(16#35#,8); -- '5'
    constant move_right : unsigned(7 downto 0) := to_unsigned(16#36#,8); -- '6'

    constant move_downleft  : unsigned(7 downto 0) := to_unsigned(16#31#,8); -- '1'
    constant move_down      : unsigned(7 downto 0) := to_unsigned(16#32#,8); -- '2'
    constant move_downright : unsigned(7 downto 0) := to_unsigned(16#33#,8); -- '3'

    function game_move_response_string( user_char : in unsigned(7 downto 0) ) 
                   return string is
    begin
                    -- for some reason a case statement didn't work here; 
                    -- complained that my "move_xxx" constants were "not a
                    -- locally static expression"
                    -- 7 8 9
                    if user_char=move_upright then
                        return vt100_cursor_upright;
                    elsif user_char=move_upleft then
                        return vt100_cursor_upleft;
                    elsif user_char=move_up then
                        return vt100_cursor_up;

                    -- 4 5 6
                    elsif user_char=move_right then
                        return vt100_cursor_right;
                    elsif user_char=move_none then
                        return empty_string;
                    elsif user_char=move_left then
                        return vt100_cursor_left;

                    -- 1 2 3 
                    elsif user_char=move_downright then
                        return vt100_cursor_downright;
                    elsif user_char=move_down then
                        return vt100_cursor_down;
                    elsif user_char=move_downleft then
                        return vt100_cursor_downleft;
                    else
                        return empty_string;
                    end if;
--        case user_char is
--            when move_upright =>
--                return vt100_cursor_upright;
--            when move_up =>
--                return vt100_cursor_up;
--            when move_upleft =>
--                return vt100_cursor_upleft;
--
--            when move_left =>
--                return vt100_cursor_left;
--            when move_right =>
--                return vt100_cursor_right;
--            when move_none =>
--                return empty_string;
--
--            when move_downright =>
--                return vt100_cursor_downright;
--            when move_downleft =>
--                return vt100_cursor_downleft;
--            when move_down =>
--                return vt100_cursor_down;
--
--            when others =>
--                return empty_string;
--
--        end case;
    end function game_move_response_string;

    component rs232 is
        port ( mclk : in std_logic;
                reset : in std_logic;
                write_en : in std_logic;
                data_out : in unsigned(7 downto 0) ;

                -- outputs
                tx : out std_logic;
                full : out std_logic;

                -- test/debug signals
                debug_baud_clk : out std_logic
             );
    end component rs232;

    component rs232_rx is
        port ( mclk : in std_logic;
                reset : in std_logic;
                read_en : in std_logic;
                rx : in std_logic;

                -- outputs 
                data_in : out unsigned(7 downto 0);
                empty: out std_logic;

                -- test/debug signals
                debug_baud_clk : out std_logic;
                debug_write_en : out std_logic
             );
    end component rs232_rx;

    component edge_to_pulse is
        Port ( CLK : in  STD_LOGIC;
               Reset : in  STD_LOGIC;
               Edge_in : in  STD_LOGIC;
               Pulse_out : out  STD_LOGIC);
    end component;

    component hex_to_7seg is
        port(  rst : in std_logic;
                mclk : in std_logic;
                word_in : in std_logic_vector(15 downto 0 );
                display_mask_in : in std_logic_vector (3 downto 0 );
                seg : out std_logic_vector(6 downto 0 );
                an : out std_logic_vector(3 downto 0);
                dp : out std_logic
            ); 
    end component hex_to_7seg;

    component stub_hex_to_7seg is
        port(  rst : in std_logic;
                mclk : in std_logic;
                word_in : in std_logic_vector(15 downto 0 );
                display_mask_in : in std_logic_vector (3 downto 0 );
                seg : out std_logic_vector(6 downto 0 );
                an : out std_logic_vector(3 downto 0);
                dp : out std_logic
            ); 
    end component stub_hex_to_7seg;

    component clk_divider is
        generic (clkmax : integer);
        port ( reset : in std_logic;
               clk_in : in std_logic;
               clk_out : out std_logic );
    end component clk_divider;

    component write_string is
        port ( clk : in std_logic;
                reset : in std_logic;

                write_en : in std_logic;
                str_in : in string(15 downto 1);
                tx_full : in std_logic;

                tx_out_char : out unsigned(7 downto 0);
                tx_write_en : out std_logic;
                write_complete : out std_logic
             );
    end component write_string;

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

    signal reset : std_logic := '1';

    -- test pattern generator
    signal tp_write_en : std_logic := '0';
    signal tp_write_data : unsigned (7 downto 0 ) := (others=>'0');
    signal test_pattern_en : std_logic;
    signal tp_test_character : unsigned(7 downto 0);
    signal char_counter_next : std_logic := '0';
    type tp_write_state is 
        ( TP_STATE_INIT, TP_STATE_WRITE_CHAR, TP_STATE_WAIT_NOT_FULL );
    signal tp_curr_state, tp_next_state: tp_write_state;


    -- Tx/Rx connections
    signal t_write_en : std_logic := '0';
    signal t_write_data : unsigned (7 downto 0 ) := (others=>'0');

    signal t_read_en : std_logic := '0';
    signal t_read_data : unsigned (7 downto 0 ) := (others=>'0');

    signal t_tx : std_logic;
    signal tx_full : std_logic;

    signal rx_empty: std_logic;
    signal t_rx : std_logic;

    signal tx_baud_clk : std_logic;
    signal rx_baud_clk : std_logic;
    signal rx_debug_write_en : std_logic;

    signal seven_seg_word : std_logic_vector(15 downto 0);
    signal next_seven_seg_word : std_logic_vector(15 downto 0);

    -- The Game state machine
    type game_state is
        ( GAME_STATE_INIT, 
          GAME_STATE_IDLE, 
          GAME_STATE_START_POP, 
          GAME_STATE_DONE_POP,

          -- local echo ; drives the Rx'd char to Tx UART
          GAME_STATE_TX_START, 
          GAME_STATE_TX_DONE,
          GAME_STATE_TX_WAIT,

          -- drive a null terminated string to the Tx UART
          GAME_STATE_TX_STRING_START,
          GAME_STATE_TX_STRING_DONE,
          GAME_STATE_TX_STRING_WAIT
        );
    signal game_curr_state, game_next_state : game_state;
    signal game_tx_write_en, game_next_tx_write_en : std_logic := '0';
    signal game_data, game_next_data : unsigned (7 downto 0 ) := (others=>'0');
    signal game_rx_pop, game_next_rx_pop : std_logic := '0';
    signal game_en : std_logic := '1';

    signal game_string : string(15 downto 1) := (others=>nul);
    signal next_game_string : string(15 downto 1) := (others=>nul);

    -- string output submachine (drives a null terminated string into the Tx
    -- UART
    signal str_write_en : std_logic := '0';
    signal str_string : string(15 downto 1) := (others=>nul);
    signal str_tx_out_char : unsigned(7 downto 0);
    signal str_tx_write_en : std_logic;
    signal str_write_complete : std_logic;

    -- player position
    signal player_row : unsigned(7 downto 0):= to_unsigned(1,8);
    signal player_col : unsigned(7 downto 0):= to_unsigned(1,8);
begin
    -- Reset Button
    reset <= sw(0);

--    str_string <= c_str_string;

    -- drive test pattern when sw(1) is high
    -- do local echo when sw(2) is high
    -- otherwise, drive string out Tx on keypress
    test_pattern_en <= sw(1);
--    game_en <= sw(2);

    -- Led set to current recieved byte
    led <= std_logic_vector(t_read_data);
    -- attach the receiver to the bottom LED
--    led <= sw(7 downto 1) & t_rx;
--    led <= sw(7 downto 1) & '0';

    --
    --  7 segment display
    --
    run_hex_to_7seg : stub_hex_to_7seg 
        port map ( rst => reset,
                    mclk => mclk,
                    word_in => seven_seg_word,
                    display_mask_in => "1111",
                    seg => seg,
                    an => an,
                    dp => dp );

    --
    --  Serial Tx
    --
    run_rs232 : rs232
        port map ( mclk => mclk,
                   reset => reset,
                   write_en => t_write_en,
                   data_out => t_write_data,
                   tx => t_tx,

                   --outputs
                   full => tx_full,
                   debug_baud_clk => tx_baud_clk
                 );

    t_write_data <= tp_write_data when test_pattern_en='1' else
                    game_data when game_en='1' else
                    str_tx_out_char;
    t_write_en <= tp_write_en when test_pattern_en='1' else
                  game_tx_write_en when game_en='1' else
                  str_tx_write_en;

    -- pragma synthesis off
    -- test/debug tool to watch character being transmitted
    watch_tx : process(t_write_en,t_write_data) is
        variable str : line;
    begin
        if t_write_en='1' then
            write(str,string'("t_write_data="));
            write(str, std_logic_vector(t_write_data) );
            writeline(output,str);
        end if;
    end process watch_tx;
    -- pragma synthesis on

    -- 
    --  Serial Rx
    --
    run_rs232_rx : rs232_rx
        port map ( mclk=>mclk,
                    reset=>reset,
                    read_en => t_read_en,
                    rx=>t_rx,

                    -- outputs
                    data_in => t_read_data,
                    empty => rx_empty,
                    debug_baud_clk => rx_baud_clk, 
                    debug_write_en => rx_debug_write_en
                 );

    t_read_en <= '0' when test_pattern_en='1' else
                 game_rx_pop;
    --
    --  State machine to drive rotating character pattern output. Writes
    --  the characters ' ' (space, 0x20) to '~' (tilde, 0x7e) forever.
    --  (output used by test pattern state machine)
    -- 
    run_char_iterator : process(reset,mclk) is
        variable counter_register_data : unsigned(7 downto 0);
    begin
        if( reset='1' ) then
            tp_test_character <= X"20";
            counter_register_data := X"20";
        elsif( falling_edge(mclk) ) then
            if( char_counter_next='1' ) then 
                if( counter_register_data = X"7e" ) then
                    counter_register_data := X"20";
                else 
                    counter_register_data := counter_register_data+1;
                end if;
            end if;
            tp_test_character <= counter_register_data;
        end if;
    end process run_char_iterator;

    -- 
    -- state machine to drive characters into the Tx FIFO
    -- 
    tp_char_write_sm_run : process(reset,mclk) is
    begin
        if( reset='1') then
            tp_curr_state <= TP_STATE_INIT;
        elsif( rising_edge(mclk)) then
            tp_curr_state <= tp_next_state;
        end if;
    end process tp_char_write_sm_run;

    --
    --  State machine to drive test pattern characters when Tx fifo is not full
    --
    --  Note I'm using the tx_full signal directly from the Tx 
    tp_char_write_sm : process(tp_curr_state,tx_full,tp_test_character) is
    begin
        tp_write_data <= tp_test_character;
        char_counter_next <= '0';
        tp_write_en <= '0';

        case tp_curr_state is 
            when TP_STATE_INIT =>
                tp_next_state <= TP_STATE_WRITE_CHAR;

            when TP_STATE_WRITE_CHAR =>
                tp_write_en <= '1';
                tp_next_state <= TP_STATE_WAIT_NOT_FULL;
                char_counter_next <= '1';

            when TP_STATE_WAIT_NOT_FULL =>
                if( tx_full='0' ) then
                    tp_next_state <= TP_STATE_WRITE_CHAR;
                else
                    tp_next_state <= TP_STATE_WAIT_NOT_FULL;
                end if;

            when others =>
                tp_next_state <= TP_STATE_INIT;
        end case;
    end process tp_char_write_sm;

    -- 
    -- state machine to drive game
    -- 
    game_sm_run : process(reset,mclk) is
    begin
        if( reset='1') then
            game_curr_state <= GAME_STATE_INIT;
            game_rx_pop <= '0';
            game_data <= (others=>'0');
            game_tx_write_en <= '0';
            game_string <= empty_string;
        elsif( rising_edge(mclk)) then
            game_curr_state <= game_next_state;
            game_rx_pop <= game_next_rx_pop;
            game_data <= game_next_data;
            game_tx_write_en <= game_next_tx_write_en;
            game_string <= next_game_string;
        end if;
    end process game_sm_run;

    -- input to string transmitter which sends a null terminated string to the
    -- Tx UART
    str_string <= game_string;

    game_sm :
    process(game_curr_state,rx_empty,tx_full,game_rx_pop,
            game_data,game_tx_write_en,t_read_data,str_write_complete,
            sw) is
    begin
        game_next_state <= game_curr_state;
        game_next_rx_pop <= game_rx_pop;
        game_next_data <= game_data;
        game_next_tx_write_en <= game_tx_write_en;

        -- to test the string writer state machine, write a string to Tx on
        -- each keypress
        next_game_string <= empty_string;
--        str_string <= (15=>nul,others=>nul);
        str_write_en <= '0';
        
        -- game drives Tx UART
--        game_en <= '1';
        -- string writer drives Tx UART by default
        game_en <= '0';

        case game_curr_state is
            when GAME_STATE_INIT =>
                next_game_string <= vt100_clear_screen_and_move_home;
                game_next_state <= GAME_STATE_TX_STRING_START;

            when GAME_STATE_IDLE =>
                next_game_string <= (nul,others=>nul);
                -- if the Rx UART has data
                if rx_empty='0' then
                    -- we have characters we can transfer to the write 
                    game_next_state <= GAME_STATE_START_POP;
                    game_next_rx_pop <= '1';
                    -- game drives Tx UART
--                    game_en <= '1';
                end if;

            when GAME_STATE_START_POP =>
                game_next_rx_pop <= '0';
                game_next_state <= GAME_STATE_DONE_POP;
                -- game drives Tx UART
--                game_en <= '1';

            when GAME_STATE_DONE_POP =>
                -- we have popped a value from the Rx UART
                game_next_data <= t_read_data;

                -- sw(2) is a "local echo" mode; simply re-write the received
                -- character back out the Tx UART
                if sw(2)='1' then
                    game_next_state <= GAME_STATE_TX_START;
                    -- game drives Tx UART
                    game_en <= '1';
                else 
                    -- 
                    -- evaluate the user input, choose a Vt100 string to move
                    -- the cursor to new user position
                    --
                    game_next_state <= GAME_STATE_TX_STRING_START;

                    next_game_string <= game_move_response_string(t_read_data);
--                    -- for some reason a case statement didn't work here; 
--                    -- complained that my "move_xxx" constants were "not a
--                    -- locally static expression"
--                    -- 7 8 9
--                    if t_read_data=move_upright then
--                        next_game_string <= vt100_cursor_upright;
--                    elsif t_read_data=move_upleft then
--                        next_game_string <= vt100_cursor_upleft;
--                    elsif t_read_data=move_up then
--                        next_game_string <= vt100_cursor_up;
--
--                    -- 4 5 6
--                    elsif t_read_data=move_right then
--                        next_game_string <= vt100_cursor_right;
--                    elsif t_read_data=move_none then
--                        next_game_string <= empty_string;
--                    elsif t_read_data=move_left then
--                        next_game_string <= vt100_cursor_left;
--
--                    -- 1 2 3 
--                    elsif t_read_data=move_downright then
--                        next_game_string <= vt100_cursor_downright;
--                    elsif t_read_data=move_down then
--                        next_game_string <= vt100_cursor_down;
--                    elsif t_read_data=move_downleft then
--                        next_game_string <= vt100_cursor_downleft;
--                    else
--                        next_game_string <= empty_string;
--                    end if;
                end if;

            when GAME_STATE_TX_START =>
                -- if the Tx UART has space
                if tx_full='0' then
                    -- write our received byte to the Tx UART
                    game_next_tx_write_en <= '1';

                    game_next_state <= GAME_STATE_TX_DONE;
                end if;
                -- game drives Tx UART
                game_en <= '1';

            when GAME_STATE_TX_DONE =>
                game_next_tx_write_en <= '0';
                game_next_state <= GAME_STATE_TX_WAIT;
                -- game drives Tx UART
                game_en <= '1';

            when GAME_STATE_TX_WAIT =>
                -- if sw(2) is enabled, drive an extra string out the serial
                -- port to validate our string writer
--                if sw(2)='1' then
--                    -- XXX temp drive a test string
--                    -- TODO interpret user char, send command to change
--                    -- position
--                    next_game_string <= vt100_cursor_downleft;
--
--                    game_next_state <= GAME_STATE_TX_STRING_START;
--                else 
--                    game_next_state <= GAME_STATE_IDLE;
--                end if;
                game_en <= '1';
                game_next_state <= GAME_STATE_IDLE;

            when GAME_STATE_TX_STRING_START =>
                -- transmit a hardcoded string to test our string writer
                -- load the string writer with a string
                -- VT100 move to 1,1 (let's see if leading zeros work)
--                str_string <= (esc,'[','0','1',';','0','1','H',nul,others=>nul);
--                str_string <= vt100_cursor_downleft;
--                str_string <= ('h','e','l','l','o',' ','w','o','r','l','d','!','@','#',nul);
                game_next_state <= GAME_STATE_TX_STRING_DONE;
                str_write_en <= '1';

            when GAME_STATE_TX_STRING_DONE =>
                str_write_en <= '0';
                game_next_state <= GAME_STATE_TX_STRING_WAIT;
                if str_write_complete='1' then
                    game_next_state <= GAME_STATE_IDLE;
                end if;

            when GAME_STATE_TX_STRING_WAIT =>
                -- wait for string writer to complete
                if str_write_complete='1' then
                    game_next_state <= GAME_STATE_IDLE;
                else
                    game_next_state <= GAME_STATE_TX_STRING_WAIT;
                end if;
                
            when others =>
                game_next_state <= GAME_STATE_IDLE;
        end case;
    end process game_sm;

    --
    -- Write a string on keystroke (test for string writing in synthesis)
    --
    write_string_subsm : write_string 
        port map(clk=>mclk,
                reset=>reset,
                write_en=>str_write_en,
                str_in=>str_string,
                tx_full => tx_full,

                -- outputs
                tx_out_char => str_tx_out_char,
                tx_write_en => str_tx_write_en,

                -- pulses on completion of the write 
                write_complete=>str_write_complete );

--    write_string_on_key : process(reset,mclk,rx_empty) is
--    begin
--        if reset='0' then
--            str_write_en <= '0';
--        elsif rising_edge(mclk) then
--            if rx_empty='0' then
--                str_write_en <= '1';
--                str_string <= ('h','e','l','l','o',' ','w','o','r','l','d','!','@','#',nul);
--            else
--                str_write_en <= '0';
--            end if;
--        end if;
--    end process write_string_on_key;

    --
    -- PIO
    --
    --  DTE/DCE Signals
    --
    --  Signals for logic analyzer
    --

    -- RTX? CTX?  72/75 are RTX/CTX. Not using right now.
    PIO(72) <= 'Z';
    PIO(75) <= 'Z';

    -- transmit from my code to the PC. My code owns this line.
--    PIO(73) <= 'Z'; 
    PIO(73) <= t_tx; 

    -- receive from the PC to my code. The PC owns this line.
--    PIO(74) <= 'Z'; 
    t_rx <= PIO(74); 
    PIO(74) <= 'Z';
    
--    PIO(83 downto 80) <= (others=>'Z');

    -- Send serial transmit byte out PIO for debugging
    PIO(83 downto 76) <= std_logic_vector(t_read_data);

    -- debug signals
--    PIO(84) <= 'Z';
    PIO(84) <= tx_baud_clk;
    PIO(85) <= rx_baud_clk;
    PIO(86) <= tx_full;
    PIO(87) <= rx_debug_write_en;

end architecture top_rs232_arch;

