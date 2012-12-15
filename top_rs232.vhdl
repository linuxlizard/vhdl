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

    -- local echo
    type echo_state is
        ( ECHO_STATE_INIT, ECHO_STATE_START_POP, ECHO_STATE_DONE_POP,
          ECHO_STATE_START_TX, ECHO_STATE_DONE_TX,
          -- drive a string out the Tx on each keypress 
          -- (for testing string writer)
          ECHO_STATE_TX_STRING_START,
          ECHO_STATE_TX_STRING_DONE,
          ECHO_STATE_TX_STRING_WAIT
          );
    signal echo_curr_state, echo_next_state : echo_state;
    signal echo_tx_write_en, echo_next_tx_write_en : std_logic := '0';
    signal echo_data, echo_next_data : unsigned (7 downto 0 ) := (others=>'0');
    signal echo_rx_pop, echo_next_rx_pop : std_logic := '0';
    signal echo_en : std_logic := '1';

    -- string output
    signal str_write_en : std_logic := '0';
    signal str_string : string(15 downto 1) := (others=>nul);
    signal str_tx_out_char : unsigned(7 downto 0);
    signal str_tx_write_en : std_logic;
    signal str_write_complete : std_logic;

begin
    -- Reset Button
    reset <= sw(0);

    -- drive test pattern when sw(1) is high
    -- do local echo when sw(2) is high
    -- otherwise, drive string out Tx on keypress
    test_pattern_en <= sw(1);
--    echo_en <= sw(2);

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
                    echo_data when echo_en='1' else
                    str_tx_out_char;
    t_write_en <= tp_write_en when test_pattern_en='1' else
                  echo_tx_write_en when echo_en='1' else
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
                 echo_rx_pop;
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
    -- state machine to drive local echo
    -- 
    echo_sm_run : process(reset,mclk) is
    begin
        if( reset='1') then
            echo_curr_state <= ECHO_STATE_INIT;
            echo_rx_pop <= '0';
            echo_data <= (others=>'0');
            echo_tx_write_en <= '0';
        elsif( rising_edge(mclk)) then
            echo_curr_state <= echo_next_state;
            echo_rx_pop <= echo_next_rx_pop;
            echo_data <= echo_next_data;
            echo_tx_write_en <= echo_next_tx_write_en;
        end if;
    end process echo_sm_run;

    echo_sm :
    process(echo_curr_state,rx_empty,tx_full,echo_rx_pop,
            echo_data,echo_tx_write_en,t_read_data,str_write_complete,
            sw) is
    begin
        echo_next_state <= echo_curr_state;
        echo_next_rx_pop <= echo_rx_pop;
        echo_next_data <= echo_data;
        echo_next_tx_write_en <= echo_tx_write_en;

        -- to test the string writer state machine, write a string to Tx on
        -- each keypress
        str_string <= (1=>nul,others=>nul);
        str_write_en <= '0';

        echo_en <= '1';

        case echo_curr_state is
            when ECHO_STATE_INIT =>
                -- if the Rx UART has data
                if rx_empty='0' then
                    -- we have characters we can transfer to the write 
                    echo_next_state <= ECHO_STATE_START_POP;
                    echo_next_rx_pop <= '1';
                end if;

            when ECHO_STATE_START_POP =>
                echo_next_rx_pop <= '0';
--                echo_next_data <= t_read_data;
                echo_next_state <= ECHO_STATE_DONE_POP;

            when ECHO_STATE_DONE_POP =>
                -- we have popped a value from the Rx UART
                echo_next_data <= t_read_data;
                echo_next_state <= ECHO_STATE_START_TX;

            when ECHO_STATE_START_TX =>
                -- if the Tx UART has space
                if tx_full='0' then
                    -- write our received byte to the Tx UART
                    echo_next_tx_write_en <= '1';

                    echo_next_state <= ECHO_STATE_DONE_TX;
                end if;

            when ECHO_STATE_DONE_TX =>
                echo_next_tx_write_en <= '0';

                -- if sw(2) is enabled, drive an extra string out the serial
                -- port to validate our string writer
                if sw(2)='1' then
                    echo_next_state <= ECHO_STATE_TX_STRING_START;
                    -- let the string writer drive Tx
                    echo_en <= '0';
                else 
                    echo_next_state <= ECHO_STATE_INIT;
                end if;

            when ECHO_STATE_TX_STRING_START =>
                -- transmit a hardcoded string to test our string writer
                -- load the string writer with a string
                str_string <= ('h','e','l','l','o',' ','w','o','r','l','d','!','@','#',nul);
                str_write_en <= '1';
                echo_next_state <= ECHO_STATE_TX_STRING_DONE;

                -- let the string writer drive Tx
                echo_en <= '0';

            when ECHO_STATE_TX_STRING_DONE =>
                str_write_en <= '0';
                echo_next_state <= ECHO_STATE_TX_STRING_WAIT;

                -- let the string writer drive Tx
                echo_en <= '0';

            when ECHO_STATE_TX_STRING_WAIT =>
                -- wait for string writer to complete
                if str_write_complete='1' then
                    echo_next_state <= ECHO_STATE_INIT;
                    -- echo will once again drive string writer
                    echo_en <= '1';
                else
                    echo_next_state <= ECHO_STATE_TX_STRING_WAIT;
                    -- let the string writer drive Tx
                    echo_en <= '0';
                end if;
                
            when others =>
                echo_next_state <= ECHO_STATE_INIT;
        end case;
    end process echo_sm;

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

