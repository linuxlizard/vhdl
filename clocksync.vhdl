-- Clock Synchronization.
-- ECE530 Fall 2012
--
-- David Poole
-- 18-Nov-2012

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.numeric_std.all;
 
entity clocksync is
end entity;

architecture clock_sync_test_arch of clocksync is
    component d_ff is
        port (clk : in std_logic;
                reset : in std_logic;
                d : in std_logic;
                q : out std_logic );
    end component d_ff;

    signal data_in : std_logic;

    signal reset : std_logic := '1';

    signal clk1 : std_logic := '0';
    signal clk2 : std_logic := '0';

    signal source_to_Q1 : std_logic;
    signal Q1_to_Q2 : std_logic;

    signal sync_out : std_logic;
begin
    clock1 : process is
    begin
       clk1 <= '0'; wait for 5 ns;
       clk1 <= '1'; wait for 5 ns;
    end process clock1;

    clock2 : process is
    begin
       clk2 <= '0'; wait for 7 ns;
       clk2 <= '1'; wait for 7 ns;
    end process clock2;

    source_clk_ff : d_ff
        port map( clk => clk1,
                  reset => reset,
                  d => data_in,
                  q => source_to_Q1 );

    Q1 : d_ff
        port map( clk => clk2,
                  reset => reset,
                  d => source_to_Q1,
                  q => Q1_to_Q2 );
    Q2 : d_ff
        port map( clk => clk2,
                  reset => reset,
                  d => Q1_to_Q2,
                  q => sync_out );

    stimulus : process is
        variable str : line;
        variable i : integer;
    begin
        write( str, string'("hello, world") );
        writeline( output, str );
        data_in <= '0';
        wait for 10 ns;

        reset <= '0';
        data_in <= '1';
        wait for 10 ns;

        for i in 1 to 10 loop
            data_in <= '0';
            wait for i*10 ns;

            data_in <= '1';
            wait for i*10 ns;
        end loop;

        data_in <= '0';
        wait for 10 ns;

        report "test done";  
        wait;
    end process stimulus;

end architecture clock_sync_test_arch;

