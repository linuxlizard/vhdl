-- RS232
-- ECE530 Fall 2012
--
-- David Poole
-- 28-Nov-2012
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.numeric_std.all;

entity rs232 is
    port ( mclk : in std_logic;
            reset : in std_logic;
            write_en : in std_logic;
            data_out : in unsigned(7 downto 0);

            -- outputs
            tx : out std_logic;
            full: out std_logic;

            debug_baud_clk : out std_logic
         );
end entity rs232;

architecture rs232_arch of rs232 is
    constant baud_clk_divider : integer := 
    434
    -- pragma synthesis off
    - 434 + 4
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
          STATE_FIFO_POP_START,
          STATE_FIFO_POP_FINISH,
          STATE_START_BIT, 
          STATE_DATA_BITS_7, 
          STATE_DATA_BITS_6, 
          STATE_DATA_BITS_5, 
          STATE_DATA_BITS_4, 
          STATE_DATA_BITS_3, 
          STATE_DATA_BITS_2, 
          STATE_DATA_BITS_1, 
          STATE_DATA_BITS_0, 
          STATE_STOP_BIT,
          STATE_WAIT );

    signal curr_state, next_state: rs232_state;

    signal baud_clk : std_logic;

    signal byte_to_send : unsigned(7 downto 0);
    signal byte_register_data : unsigned(7 downto 0);

    signal rs232_full : std_logic;
    signal rs232_read : std_logic := '0';

    signal fifo_byte_out : unsigned(7 downto 0);
    signal fifo_read_valid : std_logic;
    signal fifo_full : std_logic;
    signal fifo_empty : std_logic;

--    signal byte_to_send_hold : unsigned(7 downto 0);

--    signal next_full : std_logic := '0';
--    signal new_next_full : std_logic := '0';

--    signal start_write : std_logic := '0';
--    signal write_finish : std_logic := '0';

begin

    rs232_full <= fifo_full;

    full <= rs232_full;

    debug_baud_clk <= baud_clk;

    baud_clock : clk_divider
        -- for simulation
--        generic map(clkmax => 4)
        -- divide 50Mhz down to 115200 bits/sec
        generic map(clkmax => baud_clk_divider-1 )
--        generic map(clkmax => 434)
        port map( clk_in => mclk,
                reset => reset,
                clk_out => baud_clk);

    run_fifo : fifo
        generic map( depth=>32,
                     numbits =>5)
        port map ( write_clk=>mclk,
                    read_clk => baud_clk,

                    reset => reset,
                    push => write_en,
                    write_data => data_out,

                    pop => rs232_read,

                    -- outputs
                    read_data => fifo_byte_out,
                    read_valid => fifo_read_valid,
                    full => fifo_full,
                    empty => fifo_empty);


    state_machine_run : process(reset,baud_clk) is
    begin
        if( reset='1') then
            curr_state <= STATE_INIT;
        elsif( rising_edge(baud_clk)) then
            curr_state <= next_state;
        end if;
    end process state_machine_run;

    byte_register : process( reset, mclk ) is
    begin
        if( reset='1' ) then
            byte_to_send <= (others=>'0');
            byte_register_data <= (others=>'0');
        elsif( rising_edge(mclk) ) then
            if( fifo_read_valid='1') then
                byte_register_data <= fifo_byte_out;
            end if;
            byte_to_send <= byte_register_data;
        end if;
    end process;

    bit_banging : process( curr_state, fifo_full, fifo_empty ) is
    begin
        rs232_read <= '0';
        tx <= '1';

        case curr_state is
            when STATE_INIT =>
                tx <= '1';
                if( fifo_empty='0' ) then
                    next_state <= STATE_FIFO_POP_START;
                else 
                    next_state <= STATE_INIT;
                end if;

            when STATE_FIFO_POP_START =>
                rs232_read <= '1';
                next_state <= STATE_FIFO_POP_FINISH;

            when STATE_FIFO_POP_FINISH =>
                rs232_read <= '0';
                next_state <= STATE_START_BIT;

            when STATE_START_BIT =>
                tx <= '0';
                next_state <= STATE_DATA_BITS_0;

            when STATE_DATA_BITS_0 =>
                tx <= byte_to_send(0);
                next_state <= STATE_DATA_BITS_1;

            when STATE_DATA_BITS_1 =>
                tx <= byte_to_send(1);
                next_state <= STATE_DATA_BITS_2;

            when STATE_DATA_BITS_2 =>
                tx <= byte_to_send(2);
                next_state <= STATE_DATA_BITS_3;

            when STATE_DATA_BITS_3 =>
                tx <= byte_to_send(3);
                next_state <= STATE_DATA_BITS_4;

            when STATE_DATA_BITS_4 =>
                tx <= byte_to_send(4);
                next_state <= STATE_DATA_BITS_5;

            when STATE_DATA_BITS_5 =>
                tx <= byte_to_send(5);
                next_state <= STATE_DATA_BITS_6;

            when STATE_DATA_BITS_6 =>
                tx <= byte_to_send(6);
                next_state <= STATE_DATA_BITS_7;

            when STATE_DATA_BITS_7 =>
                tx <= byte_to_send(7);
                next_state <= STATE_STOP_BIT;

            when STATE_STOP_BIT =>
                tx <= '1';
                next_state <= STATE_WAIT;

            when STATE_WAIT =>
                tx <= '1';
                next_state <= STATE_INIT; 

            when others =>
--                    assert 1=0 
--                        severity failure;
--                        report integer'image(integer(curr_state));
                tx <= '0';
                next_state <= STATE_INIT;
        end case;

    end process bit_banging;

end architecture rs232_arch;

