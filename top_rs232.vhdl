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
                debug_baud_clk : out std_logic
             );
    end component rs232;

    component rs232_rx is
        port ( mclk : in std_logic;
                reset : in std_logic;
                rx : in std_logic;

                -- outputs 
                data_out : out unsigned(7 downto 0);
                empty: out std_logic;
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

    component clk_divider is
        generic (clkmax : integer);
        port ( reset : in std_logic;
               clk_in : in std_logic;
               clk_out : out std_logic );
    end component clk_divider;

    signal reset : std_logic := '1';
    signal t_write_en : std_logic := '0';
    signal t_write_data : unsigned (7 downto 0 ) := (others=>'0');
    signal t_read_data : unsigned (7 downto 0 ) := (others=>'0');

    signal t_tx : std_logic;
    signal t_full : std_logic;
    signal t_empty: std_logic;
    signal t_rx : std_logic;

    signal char_to_write : unsigned(7 downto 0);
    signal char_counter_next : std_logic := '0';

    type char_write_state is 
        ( STATE_INIT, STATE_WRITE_CHAR, STATE_WAIT_1, STATE_WAIT_NOT_FULL );
    signal curr_state, next_state: char_write_state;

    signal tx_baud_clk : std_logic;
    signal rx_baud_clk : std_logic;
    signal rx_debug_write_en : std_logic;
begin
    -- Reset Button
    reset <= sw(0);

    -- Led set to current recieved byte
    led <= std_logic_vector(t_read_data);
    -- attach the receiver to the bottom LED
--    led <= sw(7 downto 1) & t_rx;
--    led <= sw(7 downto 1) & '0';

    --
    --  7 segment display
    --
    run_hex_to_7seg : hex_to_7seg 
        port map ( rst => reset,
                    mclk => mclk,
                    word_in => X"abcd",
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
                   full => t_full,
                   debug_baud_clk => tx_baud_clk
                 );

    -- 
    --  Serial Rx
    --
    run_rs232_rx : rs232_rx
        port map ( mclk=>mclk,
                    reset=>reset,
                    rx=>t_rx,

                    -- outputs
                    data_out => t_read_data,
                    empty => t_empty,
                    debug_baud_clk => rx_baud_clk, 
                    debug_write_en => rx_debug_write_en
                 );

    -- 
    -- state machine to drive characters into the Tx FIFO
    -- 
    char_write_sm_run : process(reset,mclk) is
    begin
        if( reset='1') then
            curr_state <= STATE_INIT;
        elsif( rising_edge(mclk)) then
            curr_state <= next_state;
        end if;
    end process char_write_sm_run;

    --
    --  State machine to drive rotating character pattern output. Writes
    --  the characters ' ' (space, 0x20) to '~' (tilde, 0x7e) forever.
    -- 
    char_counter : process(reset,mclk) is
        variable counter_register_data : unsigned(7 downto 0);
    begin
        if( reset='1' ) then
            char_to_write <= X"20";
            counter_register_data := X"20";
        elsif( falling_edge(mclk) ) then
            if( char_counter_next='1' ) then 
                if( counter_register_data = X"7e" ) then
                    counter_register_data := X"20";
                else 
                    counter_register_data := counter_register_data+1;
                end if;
            end if;
            char_to_write <= counter_register_data;
        end if;
    end process char_counter;

    --
    --  State machine to driver chacters into the Tx FIFO
    --
    char_write_sm : process(curr_state,t_full) is
    begin
        t_write_data <= char_to_write;
        char_counter_next <= '0';
        t_write_en <= '0';

        case curr_state is 
            when STATE_INIT =>
                next_state <= STATE_WRITE_CHAR;

            when STATE_WRITE_CHAR =>
                t_write_en <= '1';
                next_state <= STATE_WAIT_NOT_FULL;
                char_counter_next <= '1';

            when STATE_WAIT_NOT_FULL =>
                if( t_full='0' ) then
                    next_state <= STATE_WRITE_CHAR;
                else
                    next_state <= STATE_WAIT_NOT_FULL;
                end if;

            when others =>
                next_state <= STATE_INIT;

        end case;

    end process char_write_sm;

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
    PIO(84) <= mclk;
    PIO(85) <= rx_baud_clk;
    PIO(86) <= t_full;
    PIO(87) <= rx_debug_write_en;

end architecture top_rs232_arch;

