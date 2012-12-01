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
            tx : out std_logic
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
        ( STATE_INIT, STATE_START_BIT, STATE_DATA_BITS_1, STATE_DATA_BITS_2, STATE_STOP_BIT );

    signal baud_clk : std_logic;

    signal curr_state, next_state: rs232_state;

    signal debug_byte_to_send : unsigned(7 downto 0);
begin
    baud_clock : clk_divider
        -- for simulation
        generic map(clkmax => 4)
        -- divide 50Mhz down to 115200 bits/sec
--        generic map(clkmax => 434)
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

    bit_banging : process( curr_state, write_en ) is
        variable bit_counter : unsigned(3 downto 0);
        variable byte_to_send : unsigned(7 downto 0);
        variable s : line;
    begin
        if( rising_edge(write_en) ) then
            next_state <= STATE_START_BIT;
            byte_to_send := data_out;
            tx <= '0';
        else
            case curr_state is
                when STATE_INIT =>
                    write( s, string'("state_init"));
                    writeline(output,s);
                    tx <= '0';

                when STATE_START_BIT =>
                    write( s, string'("state_start_bit"));
                    writeline(output,s);
                    tx <= '1';
                    next_state <= STATE_DATA_BITS_1;
                    bit_counter := X"8"; 

                when STATE_DATA_BITS_1 =>
                    write( s, string'("state_data_bits bit_counter=") &
                                      integer'image(to_integer(bit_counter)) );
                    writeline(output,s);

                    tx <= not byte_to_send(7);

                    byte_to_send := byte_to_send(6 downto 0) & '0';
                    debug_byte_to_send <= byte_to_send;

                    bit_counter := bit_counter - 1;
                    if( bit_counter=0 ) then
                        next_state <= STATE_STOP_BIT;
                    else 
                        next_state <= STATE_DATA_BITS_2;
                    end if;

                when STATE_DATA_BITS_2 =>
                    write( s, string'("state_data_bits bit_counter=") &
                                      integer'image(to_integer(bit_counter)) );
                    writeline(output,s);

                    tx <= not byte_to_send(7);

                    byte_to_send := byte_to_send(6 downto 0) & '0';
                    debug_byte_to_send <= byte_to_send;

                    bit_counter := bit_counter - 1;
                    if( bit_counter=0 ) then
                        next_state <= STATE_STOP_BIT;
                    else 
                        next_state <= STATE_DATA_BITS_1;
                    end if;

                when STATE_STOP_BIT =>
                    write( s, string'("state_stop_bit"));
                    writeline(output,s);
                    tx <= '0';
                    next_state <= STATE_INIT;

                when others =>
                    assert 1=0 
                        severity failure;
--                        report integer'image(integer(curr_state));
                    tx <= '0';
                    next_state <= STATE_INIT;

            end case;
        end if;

    end process bit_banging;

end architecture rs232_arch;

