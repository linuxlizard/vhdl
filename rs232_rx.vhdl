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

            debug_baud_clk : out std_logic
         );
end entity rs232_rx;

architecture rs232_rx_arch of rs232_rx is
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

--    component fifo is
--        generic ( depth : integer ; 
--                  numbits : integer );
--        port( write_clk : in std_logic;
--                read_clk : in std_logic;
--                reset : in std_logic;
--                push : in std_logic;
--                write_data : in unsigned ( 7 downto 0 );
--                pop : in std_logic;
--
--                -- outputs
--                read_data : out unsigned ( 7 downto 0 );
--                read_valid : out std_logic;
--                full : out std_logic;
--                empty : out std_logic );
--    end component fifo;

    type rs232_state is 
        ( STATE_INIT, 
--          STATE_FIFO_POP_START,
--          STATE_FIFO_POP_FINISH,
--          STATE_START_BIT, 
          STATE_DATA_BITS_7, 
          STATE_DATA_BITS_6, 
          STATE_DATA_BITS_5, 
          STATE_DATA_BITS_4, 
          STATE_DATA_BITS_3, 
          STATE_DATA_BITS_2, 
          STATE_DATA_BITS_1, 
          STATE_DATA_BITS_0, 
          STATE_STOP_BIT
--          STATE_WAIT 
          );

    signal curr_state, next_state: rs232_state;

    signal baud_clk : std_logic;

    signal recv_byte : unsigned(7 downto 0);
    signal byte_register_data : unsigned(7 downto 0);
    signal byte_register_data_in : unsigned(7 downto 0);
    signal byte_register_write_en : std_logic;

--    signal rs232_full : std_logic;
--    signal rs232_read : std_logic := '0';

--    signal fifo_byte_out : unsigned(7 downto 0);
--    signal fifo_read_valid : std_logic;
--    signal fifo_full : std_logic;
--    signal fifo_empty : std_logic;

begin
    debug_baud_clk <= baud_clk;

    empty <= '0';

    data_out <= recv_byte;

    baud_clock : clk_divider
        -- for simulation
--        generic map(clkmax => 4)
        -- divide 50Mhz down to 115200 bits/sec
        generic map(clkmax => baud_clk_divider )
--        generic map(clkmax => 434)
        port map( clk_in => mclk,
                reset => reset,
                clk_out => baud_clk);

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

    state_machine_run : process(reset,baud_clk) is
    begin
        if( reset='1') then
            curr_state <= STATE_INIT;
        elsif( rising_edge(baud_clk)) then
            curr_state <= next_state;
        end if;
    end process state_machine_run;

    byte_register : process( reset, baud_clk ) is
    begin
        if( reset='1' ) then
            recv_byte <= (others=>'0');
            byte_register_data <= (others=>'0');
        elsif( falling_edge(baud_clk) ) then
            if( byte_register_write_en='1') then
                byte_register_data <= byte_register_data_in;
            end if;
            recv_byte <= byte_register_data;
        end if;
    end process;

    bit_banging : process( curr_state, rx ) is
    begin
        byte_register_write_en <= '0';
        byte_register_data_in <= (others=>'0');
--        data_out <= X"aa";

        case curr_state is
            when STATE_INIT =>
                if( rx='0' ) then
                    -- start bit
                    next_state <= STATE_DATA_BITS_0;
--                    data_out <= X"aa";
                else 
                    next_state <= STATE_INIT;
--                    data_out <= X"11";
                end if;

--            when STATE_START_BIT =>
--                next_state <= STATE_DATA_BITS_0;

            when STATE_DATA_BITS_0 =>
                byte_register_write_en <= '1';
                byte_register_data_in <= recv_byte(6 downto 0) & rx;
                next_state <= STATE_DATA_BITS_1;

            when STATE_DATA_BITS_1 =>
                byte_register_write_en <= '1';
                byte_register_data_in <= recv_byte(6 downto 0) & rx;
                next_state <= STATE_DATA_BITS_2;

            when STATE_DATA_BITS_2 =>
                byte_register_write_en <= '1';
                byte_register_data_in <= recv_byte(6 downto 0) & rx;
                next_state <= STATE_DATA_BITS_3;

            when STATE_DATA_BITS_3 =>
                byte_register_write_en <= '1';
                byte_register_data_in <= recv_byte(6 downto 0) & rx;
                next_state <= STATE_DATA_BITS_4;

            when STATE_DATA_BITS_4 =>
                byte_register_write_en <= '1';
                byte_register_data_in <= recv_byte(6 downto 0) & rx;
                next_state <= STATE_DATA_BITS_5;

            when STATE_DATA_BITS_5 =>
                byte_register_write_en <= '1';
                byte_register_data_in <= recv_byte(6 downto 0) & rx;
                next_state <= STATE_DATA_BITS_6;

            when STATE_DATA_BITS_6 =>
                byte_register_write_en <= '1';
                byte_register_data_in <= recv_byte(6 downto 0) & rx;
                next_state <= STATE_DATA_BITS_7;

            when STATE_DATA_BITS_7 =>
                byte_register_write_en <= '1';
                byte_register_data_in <= recv_byte(6 downto 0) & rx;
                next_state <= STATE_STOP_BIT;

            when STATE_STOP_BIT =>
--                byte_register_data_in <= X"AA";
--                next_state <= STATE_STOP_BIT;
                next_state <= STATE_INIT;

            when others =>
--                    assert 1=0 
--                        severity failure;
--                        report integer'image(integer(curr_state));
                next_state <= STATE_INIT;
        end case;

    end process bit_banging;

end architecture rs232_rx_arch;

