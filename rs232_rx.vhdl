-- RS232
-- ECE530 Fall 2012
--
-- David Poole
-- 03-Dec-2012
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.numeric_std.all;

entity rs232_rx is
    port ( mclk : in std_logic;
            reset : in std_logic;
            rx : in std_logic;

            data_out : out unsigned(7 downto 0);
            empty: out std_logic;

            -- debug signals
            debug_baud_clk : out std_logic;
            debug_write_en : out std_logic
         );
end entity rs232_rx;

architecture rs232_rx_arch of rs232_rx is
    -- 57600
    constant baud_clk_divider : integer := 
    434*16
    -- pragma synthesis off
    - 434*16 + 4
    -- pragma synthesis on
    ;

    component clk_divider is
        generic (clkmax : integer);
        port ( reset : in std_logic;
               clk_in : in std_logic;
               clk_out : out std_logic );
    end component clk_divider;

    component fifo is
        generic ( depth : integer ; 
                  numbits : integer );
        port( write_clk : in std_logic;
                read_clk : in std_logic;
                reset : in std_logic;
                push : in std_logic;
                write_data : in unsigned ( 7 downto 0 );
                pop : in std_logic;

                -- outputs
                read_data : out unsigned ( 7 downto 0 );
                read_valid : out std_logic;
                full : out std_logic;
                empty : out std_logic );
    end component fifo;

    type rs232_state is 
        ( STATE_INIT, 
          STATE_START_BIT, 
          STATE_DATA_BITS, 
          STATE_STOP_BIT
        );

    signal curr_state, next_state: rs232_state;

    signal debug_num : integer;

    signal fast_clk : std_logic;

    signal data: unsigned(7 downto 0);
    signal next_data: unsigned(7 downto 0);

    signal counter : unsigned(4 downto 0);
    signal next_counter : unsigned(4 downto 0);

    signal data_bits_counter: unsigned(4 downto 0);
    signal next_data_bits_counter: unsigned(4 downto 0);

--    signal rs232_full : std_logic;
--    signal rs232_read : std_logic := '0';

--    signal fifo_byte_out : unsigned(7 downto 0);
--    signal fifo_read_valid : std_logic;
--    signal fifo_full : std_logic;
--    signal fifo_empty : std_logic;

begin
    debug_baud_clk <= fast_clk;
    debug_write_en <= '0';

    empty <= '0';

    data_out <= data;

    baud_clock : clk_divider
        -- divide 50Mhz down to 57600 bits/sec w/ 16x oversampling
        generic map(clkmax => baud_clk_divider-1 )
        port map( clk_in => mclk,
                reset => reset,
                clk_out => fast_clk);

--    run_fifo : fifo
--        generic map( depth=>32,
--                     numbits =>5)
--        port map ( write_clk=>mclk,
--                    read_clk => baud_clk,
--
--                    reset => reset,
--                    push => write_en,
--                    write_data => data_out,
--
--                    pop => rs232_read,
--
--                    -- outputs
--                    read_data => fifo_byte_out,
--                    read_valid => fifo_read_valid,
--                    full => fifo_full,
--                    empty => fifo_empty);
--

    state_machine_run : process(reset,fast_clk) is
    begin
        if( reset='1') then
            curr_state <= STATE_INIT;
            data <= (others=>'0');
            counter <= (others=>'0');
            data_bits_counter <= (others=>'0');
        elsif( rising_edge(fast_clk)) then
            curr_state <= next_state;
            data <= next_data;
            counter <= next_counter;
            data_bits_counter <= next_data_bits_counter;
        end if;
    end process state_machine_run;

    bit_banging : process( curr_state, data, counter, fast_clk, rx ) is
        variable f : boolean := false;
    begin
        next_state <= curr_state;
        next_data <= data;
        next_counter <= counter;
        next_data_bits_counter <= data_bits_counter;
        debug_num <= 0;

        case curr_state is
            when STATE_INIT =>
                debug_num <= 1;
                if( rx='0' ) then
                    -- start bit
                    next_state <= STATE_START_BIT;
                else 
                    next_state <= STATE_INIT;
                end if;

            when STATE_START_BIT =>
                debug_num <= 2;
                if counter = to_unsigned(15,5) then
                    next_state <= STATE_DATA_BITS;
                    next_counter <= (others=>'0');
                    next_data_bits_counter <= (others=>'0');
                else 
                    next_state <= STATE_START_BIT;
                    next_counter <= counter + 1;
                end if;

            when STATE_DATA_BITS =>
                debug_num <= 3;
                -- sample in the middle over our period
                if counter=to_unsigned(7,5) then
                    -- receive LSb to MSb
                    next_data <= rx & data(7 downto 1);
                    -- receive MSb to LSb
                    --next_data <= data(6 downto 0) & rx;
                end if;
                if counter=to_unsigned(15,5) then
                    -- if we've counted our 8 bits, move to the next state
                    if data_bits_counter=to_unsigned(7,5) then
                        next_state <= STATE_STOP_BIT;
                        next_counter <= (others=>'0');
                        next_data_bits_counter <= (others=>'0');
                    else 
                        next_state <= STATE_DATA_BITS;
                        next_counter <= (others=>'0');
                        next_data_bits_counter <= data_bits_counter + 1;
                    end if;
                else
                    next_state <= STATE_DATA_BITS;
                    next_counter <= counter + 1;
                end if;

            when STATE_STOP_BIT =>
                debug_num <= 4;
                if counter = to_unsigned(15,5) then
                    next_state <= STATE_INIT;
                    next_counter <= (others=>'0');
                else 
                    next_state <= STATE_STOP_BIT;
                    next_counter <= counter + 1;
                end if;

            when others =>
                next_state <= STATE_INIT;

        end case;

    end process bit_banging;

end architecture rs232_rx_arch;

