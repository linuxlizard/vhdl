library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity test_regrotate is 
  begin
  end entity test_regrotate;

architecture run_test_regrotate of test_regrotate is

    component regrotate is
        port ( reset : in std_logic;
               clk : in std_logic;
              reg1 : in std_logic_vector( 7 downto 0 );
              reg2 : in std_logic_vector( 7 downto 0 );
              reg_out : out std_logic_vector( 7 downto 0 ) ;
              which_out : out std_logic
             );
    end component regrotate;

    signal t_rst : std_logic := '1';
    signal t_clk : std_logic := '0';
    signal t_reg1 : std_logic_vector( 7 downto 0 );
    signal t_reg2 : std_logic_vector( 7 downto 0 );
    signal t_reg_out : std_logic_vector( 7 downto 0 );
    signal t_which_out : std_logic;

begin
    uut : regrotate
        port map( reset => t_rst,
                    clk => t_clk,
                    reg1 => t_reg1,
                    reg2 => t_reg2,
                    reg_out => t_reg_out,
                    which_out => t_which_out 
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
        t_rst <= '1';
        t_reg1 <= "11000011";
        t_reg2 <= "00011000";
        wait for 15 ns;

        t_rst <= '0';
        wait for 10 ns;

        wait;
    end process stimulus;
end architecture run_test_regrotate;

