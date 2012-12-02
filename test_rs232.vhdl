-- Test RS232 in Simulation
-- ECE530 Fall 2012
--
-- David Poole
-- 28-Nov-2012

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use std.textio.all;
use ieee.numeric_std.all;

entity test_rs232 is
end entity test_rs232;

architecture test_rs232_arch of test_rs232 is
    constant clk_period : time := 10 ns;

    component rs232 is
        port ( mclk : in std_logic;
                reset : in std_logic;
                write_en : in std_logic;
                data_out : in unsigned(7 downto 0) ;

                -- outputs
                tx : out std_logic;
                full : out std_logic
             );
    end component rs232;

    signal mclk :  std_logic := '0';
    signal reset : std_logic := '1';
    signal t_write_en : std_logic := '0';
    signal t_write_data : unsigned (7 downto 0 ) := (others=>'0');

    signal t_tx : std_logic;
    signal t_full : std_logic;
begin
    run_rs232 : rs232
        port map ( mclk => mclk,
                   reset => reset,
                   write_en => t_write_en,
                   data_out => t_write_data,
                   tx => t_tx,
                   full => t_full
                 );

    clock : process is
    begin
       mclk <= '0'; wait for clk_period/2;
       mclk <= '1'; wait for clk_period/2;
    end process clock;

    run : process is
        variable i : integer;
    begin
        wait for clk_period;
        wait for clk_period/2;
        reset <= '0';

        for i in 16#20# to 16#7e# loop
            t_write_en <= '1';
            t_write_data <= to_unsigned(i,8);
            wait for clk_period;

            t_write_en <= '0';
            wait for clk_period;

            wait until t_full='0';
        end loop;

        wait;
    end process run;

end architecture test_rs232_arch;

