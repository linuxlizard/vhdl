-- Write a string to Tx FIFO
--
-- ECE 530 Fall 2012
--
-- David Poole
-- 15-Dec-2012

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use std.textio.all;
use ieee.numeric_std.all;

entity write_string is
    port ( clk : in std_logic;
            reset : in std_logic;

            write_en : in std_logic;
            str_in : in string(15 downto 1);

            -- when tx_full='1' we have to wait before sending more data
            tx_full : in std_logic;

            -- character written to Tx
            tx_out_char : out unsigned(7 downto 0);

            -- enable/disable write to Tx
            tx_write_en : out std_logic;

            -- pulse high when write is complete
            write_complete : out std_logic
         );
end entity write_string;

architecture write_string_arch of write_string is

    type state is
        ( STATE_INIT, STATE_TX_CHAR_1, STATE_TX_CHAR_2 );
    signal curr_state, next_state : state;

    signal curr_string : string(15 downto 1);
    signal next_curr_string : string(15 downto 1);

    function write_string_next_state( state_in : in state ) return state is
    begin
        if state_in=STATE_TX_CHAR_1 then
            return STATE_TX_CHAR_2;
        else
            return STATE_TX_CHAR_1;
        end if;
    end write_string_next_state;

begin
    
    -- 
    -- state machine to drive characters from a null terminated 
    -- string to a Tx UART
    -- 
    run_write_sm : process(reset,clk) is
    begin
        if( reset='1') then
            curr_state <= STATE_INIT;
            curr_string <= (1=>nul,others=>nul);
        elsif( rising_edge(clk)) then
            curr_state <= next_state;
            curr_string <= next_curr_string;
        end if;
    end process run_write_sm;

    write_sm : process(curr_state,write_en,curr_string,str_in,tx_full) is
    begin
        next_curr_string <= curr_string;
        next_state <= curr_state;
        tx_out_char <= to_unsigned(16#ee#,8);
        tx_write_en <= '0';
        write_complete <= '0';

        case curr_state is
            when STATE_INIT =>
                if write_en='1' then
                    next_state <= STATE_TX_CHAR_1;
                    next_curr_string <= str_in;   
                end if;
                
            when STATE_TX_CHAR_1 | STATE_TX_CHAR_2 =>
                -- if transmitter still has space, send another char
                if tx_full='0' then
                    -- when we hit the null terminator of our string, stop
                    if curr_string(15)=nul then
                        next_state <= state_init;
                        write_complete <= '1';
                        tx_write_en <= '0';
                    else
                        -- shift the string 1 character left
                        tx_out_char <= to_unsigned(character'pos(curr_string(15)),8);
                        next_curr_string <= curr_string( 14 downto 1 ) & nul;
                        next_state <= write_string_next_state(curr_state);
                        tx_write_en <= '1';
                    end if;
                end if;

            when others =>
                next_state <= STATE_INIT;

        end case;
    end process write_sm;

end architecture write_string_arch;

