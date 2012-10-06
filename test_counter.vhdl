library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity test_counter is 
  begin
  end entity test_counter;

architecture run_test_counter of test_counter is

  signal t_rst : std_logic := '1';
  signal t_clk : std_logic := '0';
  signal t_do_count : std_logic;
  signal t_total : unsigned( 15 downto 0 );

  component d_counter is
    port ( rst : in std_logic;
           clk : in std_logic;
           do_count : in std_logic;
           total : out unsigned( 15 downto 0 )
        );
  end component d_counter;

begin
  uut : d_counter
    port map( rst => t_rst,
      clk => t_clk,
      do_count => t_do_count,
      total => t_total );

    clock : process is 
    begin
        t_clk <= '0'; wait for 10 ns;
        t_clk <= '1'; wait for 10 ns;
    end process clock;

    stimulus : process is
        variable i : integer;
        variable str : line;
    begin
      t_rst <= '1';
      t_do_count <= '0';
--      t_total <= (others =>'0');
      wait for 15 ns;

      t_rst <= '0';
      wait for 10 ns;

      t_do_count <= '1';
      wait for 10 ns;

      t_do_count <= '0';
      wait for 10 ns;

      hwrite( str, std_logic_vector(t_total) );
      writeline( output, str );
      t_do_count <= '1';
      wait for 10 ns;

      t_do_count <= '0';
      wait for 10 ns;

      hwrite( str, std_logic_vector(t_total) );
      writeline( output, str );

      t_do_count <= '1';
      wait for 10 ns;

      t_do_count <= '0';
      wait for 10 ns;

      for i in 0 to 100 loop
          t_do_count <= '1';
          wait for 10 ns;

          hwrite( str, std_logic_vector(t_total) );
          writeline( output, str );
          t_do_count <= '0';
          wait for 10 ns;
      end loop;

      hwrite( str, std_logic_vector(t_total) );
      writeline( output, str );

      t_rst <= '1';
      wait for 10 ns;
      wait;

    end process stimulus;
end architecture run_test_counter;

