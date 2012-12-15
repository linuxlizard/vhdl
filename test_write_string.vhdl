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

entity test_write_string is
end entity test_write_string;

architecture test_write_string_arch of test_write_string is
    constant clk_period : time := 10 ns;

    signal mclk :  std_logic := '0';
    signal reset : std_logic := '1';

    signal debug_num : integer := 0;

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

    signal t_string : string(15 downto 1 ) := (others=>nul);
    signal t_write_en : std_logic := '0';
    signal t_tx_full : std_logic := '0';

    -- signals from write_string to this testbench
    signal t_tx_out_char : unsigned(7 downto 0);
    signal t_tx_write_en : std_logic;
    signal t_write_complete : std_logic;
begin
    -- this is the main clock
    clock1 : process is
    begin
       mclk <= '0'; wait for clk_period/2;
       mclk <= '1'; wait for clk_period/2;
    end process clock1;

    write_string_subsm : write_string 
        port map(clk=>mclk,
                reset=>reset,
                write_en=>t_write_en,
                str_in=>t_string,
                tx_full => t_tx_full,

                -- outputs
                tx_out_char => t_tx_out_char,
                tx_write_en => t_tx_write_en,

                write_complete=>t_write_complete );

    stimulus : process 
    begin
        debug_num <= 0;
        wait for clk_period;
        wait until mclk='0';
        reset <= '0';
        wait for clk_period;
        wait for clk_period;
        wait for clk_period;

        t_string <= ('h','e','l','l','o',' ','w','o','r','l','d','!','@','#',nul);
        wait for clk_period;

        t_write_en <= '1';
        wait for clk_period;

        t_write_en <= '0';
        wait for clk_period;

        wait;
    end process stimulus;

end architecture test_write_string_arch;

