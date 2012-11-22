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
    constant clk1_cycle : time := 5 ns;
    constant clk2_cycle : time := 7 ns;
--    constant clk1_cycle : time := 7 ns;
--    constant clk2_cycle : time := 5 ns;

    component d_ff is
        port (clk : in std_logic;
                reset : in std_logic;
                d : in std_logic_vector(7 downto 0);
                q : out std_logic_vector(7 downto 0) );
    end component d_ff;

    signal data_in : std_logic_vector(7 downto 0);

    signal reset : std_logic := '1';

    signal clk1 : std_logic := '0';
    signal clk2 : std_logic := '0';

    signal source_to_Q1 : std_logic_vector(7 downto 0);
    signal Q1_to_Q2 : std_logic_vector(7 downto 0);

    signal data_out : std_logic_vector(7 downto 0);
begin
    clock1 : process is
    begin
       clk1 <= '0'; wait for clk1_cycle;
       clk1 <= '1'; wait for clk1_cycle;
    end process clock1;

    clock2 : process is
    begin
       clk2 <= '0'; wait for clk2_cycle;
       clk2 <= '1'; wait for clk2_cycle;
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
                  q => data_out );

    stimulus : process is
        variable str : line;
        variable i : integer;
    begin
        write( str, string'("hello, world") );
        writeline( output, str );
        wait for clk1_cycle;

        reset <= '0';
        wait for clk1_cycle;

        data_in <= X"aa";
        wait for 2*clk1_cycle;

        data_in <= X"bb";
        wait for 2*clk1_cycle;

        for i in 1 to 10 loop
            data_in <= std_logic_vector(to_unsigned(i,8));
            wait for 2*clk1_cycle;
--            wait for i*10 ns;

--            data_in <= std_logic_vector(to_unsigned(i*2,8));
--            wait for i*10 ns;
        end loop;

        data_in <= x"ee";
        wait for 2*clk1_cycle;

        report "test done";  
        wait;
    end process stimulus;

end architecture clock_sync_test_arch;

