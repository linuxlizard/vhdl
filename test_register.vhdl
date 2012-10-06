-- Test the register entity
--
-- David Poole 30-Sep-2012

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;

entity test_register is
begin
end;

architecture test_bench of test_register is

    signal t_clk : std_logic;
    signal t_reset : std_logic;
    signal t_input_enable : std_logic;
    signal t_output_enable : std_logic;
    signal t_data_in : std_logic_vector(7 downto 0);
    signal t_data_out : std_logic_vector(7 downto 0);

    component d_register is
        generic (width : integer);
        port (clk : in std_logic;
              reset : in std_logic := '1';
              input_enable : in std_logic;
              output_enable : in std_logic;
              data_in : in std_logic_vector( width-1 downto 0 );
              data_out : out std_logic_vector( width-1 downto 0 )
        );
    end component d_register;

begin

    uut : d_register
       generic map( width => 8)
       port map( clk => t_clk,
                 reset => t_reset,
                 input_enable => t_input_enable,
                 output_enable => t_output_enable,
                 data_in => t_data_in,
                 data_out => t_data_out );


    clock : process is
    begin
       t_clk <= '0'; wait for 10 ns;
       t_clk <= '1'; wait for 10 ns;
    end process clock;

    stimulus : process is
        variable str : line;
    begin
       write( output, string'("hello, world") );
       writeline( output, str );

       t_reset <= '1';
       t_input_enable <= '0';
       t_output_enable <= '0';
       t_data_in <= (others =>'0');
       wait for 15 ns;

       t_reset <= '0';
       wait for 10 ns;

       t_input_enable <= '1';
       t_data_in <= std_logic_vector(to_unsigned(42,t_data_in'length));
       wait for 10 ns;

       t_input_enable <= '0';
       wait for 10 ns;

       t_output_enable <= '1';
       wait for 10 ns;

       t_output_enable <= '0';
       wait for 10 ns;

       wait for 10 ns;
       wait for 10 ns;

       write( str, to_integer(signed(t_data_out)) );
       writeline( output, str );

       t_reset <= '1';
       wait for 10 ns;

       wait;
    end process stimulus;

end architecture test_bench;

