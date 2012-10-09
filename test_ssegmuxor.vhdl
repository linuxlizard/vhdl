library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity test_ssegmuxor is 
begin
end entity test_ssegmuxor;

architecture run_test_ssegmuxor of test_ssegmuxor is

    component clk_divider is
        generic (clkmax : integer);
        port ( reset : in std_logic;
               clk_in : in std_logic;
               clk_out : out std_logic );
    end component clk_divider;

    component ssegmuxor is
        port (  reset : in std_logic;
                clk : in std_logic;
                digit_0 : in std_logic_vector (6 downto 0 );
                digit_1 : in std_logic_vector (6 downto 0 );
                digit_2 : in std_logic_vector (6 downto 0 );
                digit_3 : in std_logic_vector (6 downto 0 );
            is_negative : in std_logic;

                anode_out : out std_logic_vector (3 downto 0 );
                digit_out : out std_logic_vector (6 downto 0 ); 
                   dp_out : out std_logic
            );
    end component ssegmuxor;

    signal t_rst : std_logic := '1';
    signal t_clk : std_logic := '0';
    signal t_seg_muxor_clock_in : std_logic := '0';
    signal t_digit_0 : std_logic_vector (6 downto 0);
    signal t_digit_1 : std_logic_vector (6 downto 0);
    signal t_digit_2 : std_logic_vector (6 downto 0);
    signal t_digit_3 : std_logic_vector (6 downto 0);
    signal t_is_negative : std_logic := '0';

    signal t_anode_out : std_logic_vector (3 downto 0);
    signal t_digit_out : std_logic_vector (6 downto 0);
    signal t_dp_out : std_logic;

begin
    seg_muxor_input_clock : clk_divider
        generic map(clkmax => 4)
        port map( reset => t_rst,
                 clk_in => t_clk,
                 clk_out => t_seg_muxor_clock_in );

    uut : ssegmuxor
        port map( reset => t_rst,
                  clk => t_seg_muxor_clock_in,
                  digit_0 => t_digit_0,
                  digit_1 => t_digit_1,
                  digit_2 => t_digit_2,
                  digit_3 => t_digit_3,
                  is_negative => t_is_negative,
                  anode_out => t_anode_out,
                  digit_out => t_digit_out,
                  dp_out => t_dp_out
                );

    clock : process is 
    begin
        t_clk <= '0'; wait for 10 ns;
        t_clk <= '1'; wait for 10 ns;
    end process clock;

    stimulus : process is
        variable str : line;
        variable i : integer;
    begin
        write( str, string'("Hello, world") );
        writeline( output, str );

        t_rst <= '1';
        -- 2, 4, 6, 8 encodings for 7-seg
        t_digit_0 <= "0100100";
        t_digit_1 <= "0011001";
        t_digit_2 <= "0000010";
        t_digit_3 <= "0000000";
        t_is_negative <= '1';
        wait for 15 ns;

        t_rst <= '0';
        wait for 10 ns;

        for i in 0 to 100 loop
            write( str, t_digit_out );
            write( str, string'(" ") );
            write( str, work.debug_utils.sevenseg_to_integer(t_digit_out) );
            write( str, string'(" ") );
            write( str, t_anode_out );
            write( str, string'(" dp=") );
            write( str, t_dp_out);
            writeline( output, str );
            wait for 50 ns;
        end loop;

        wait;

    end process stimulus;

end architecture run_test_ssegmuxor;

