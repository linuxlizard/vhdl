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
    component clk_divider is
        generic (clkmax : integer);
        port ( reset : in std_logic;
               clk_in : in std_logic;
               clk_out : out std_logic );
    end component clk_divider;

    type rs232_state is 
        ( STATE_INIT, 
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
    signal byte_to_send_hold : unsigned(7 downto 0);

    signal next_full : std_logic := '0';
    signal new_next_full : std_logic := '0';

    signal start_write : std_logic := '0';
    signal write_finish : std_logic := '0';
begin
    full <= new_next_full;

    debug_baud_clk <= baud_clk;

    baud_clock : clk_divider
        -- for simulation
--        generic map(clkmax => 4)
        -- divide 50Mhz down to 115200 bits/sec
        generic map(clkmax => 434)
        port map( clk_in => mclk,
                reset => reset,
                clk_out => baud_clk);

    state_machine_run : process(reset,baud_clk) is
    begin
        if( reset='1') then
            curr_state <= STATE_INIT;
        elsif( rising_edge(baud_clk)) then
            curr_state <= next_state;
        end if;
    end process state_machine_run;

    full_flag : process( write_en, write_finish ) is
    begin
        if( write_en='1' ) then
            start_write <= '1';
            new_next_full <= '1';
        end if;
        if( write_finish='1' ) then 
            start_write <= '0';
            new_next_full <= '0';
        end if;
            
    end process full_flag;

    bit_banging : process( curr_state, start_write ) is
        -- pragma synthesis off
        variable s : line;
        -- pragma synthesis on
    begin
        byte_to_send <= X"45";

        case curr_state is
            when STATE_INIT =>
                tx <= '1';
                next_full <= '0';
                if start_write ='1' then
                    next_full <= '1';
                    next_state <= STATE_START_BIT;
                    byte_to_send_hold <= data_out;
                    write_finish <= '0';
                end if;
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
                write_finish <= '1';

            when STATE_WAIT =>
                tx <= '1';
                next_state <= STATE_INIT; 
                write_finish <= '1';

            when others =>
--                    assert 1=0 
--                        severity failure;
--                        report integer'image(integer(curr_state));
                tx <= '0';
                next_state <= STATE_INIT;
                next_full <= '1';
        end case;

    end process bit_banging;

end architecture rs232_arch;

