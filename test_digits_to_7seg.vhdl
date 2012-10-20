-- BCD to 7-segment display
--
-- David Poole 06-Oct-2012

library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity test_digits_to_7seg is

end entity test_digits_to_7seg;


architecture test_digits_to_7seg_arch of test_digits_to_7seg is 
    -- use the same names as the actual hardware
    signal mclk :  std_logic := '0';
    signal rst : std_logic := '1';
    signal btn: std_logic_vector(3 downto 0);
    signal sw :  std_logic_vector(7 downto 0);
    signal led: std_logic_vector(7 downto 0);

    -- 7seg display
    signal seg : std_logic_vector(6 downto 0 );

    -- anode of 7seg display
    signal an : std_logic_vector(3 downto 0);

    -- decimal point of 7seg display
    signal dp : std_logic := '0';

    signal t_word_in : std_logic_vector( 15 downto 0 ) := (others=>'0');

    component digits_to_7seg is
        -- signals in Basys2
        port(  rst : in std_logic; 
                mclk : in std_logic;
             word_in : in std_logic_vector(15 downto 0 );
                seg : out std_logic_vector(6 downto 0 );
                an : out std_logic_vector(3 downto 0);
                dp : out std_logic
            ); 
    end component digits_to_7seg;

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
    run_digits_to_7seg : digits_to_7seg 
        port map ( rst => rst,
                    mclk => mclk,
                    word_in => t_word_in,
                    seg => seg,
                    an => an,
                    dp => dp );

    clock : process is
    begin
       mclk <= '0'; wait for 10 ns;
       mclk <= '1'; wait for 10 ns;
    end process clock;

    stimulus : process is
        variable str : line;
        variable i : integer;
    begin
        write( str, string'("hello, world") );
        writeline( output, str );

        rst <= '1';
        wait for 15 ns;

        rst <= '0';
        t_word_in <= std_logic_vector(to_unsigned(12345,16));
--        t_word_in <= std_logic_vector(to_unsigned(65535,16));
        wait for 10 ns;

        for i in 0 to 255 loop
            work.debug_utils.dbg_7seg( seg, an, dp ); 
            wait for 50 ns;
        end loop;

        wait;
    end process stimulus;

end architecture test_digits_to_7seg_arch;

