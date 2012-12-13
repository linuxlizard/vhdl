--  http://vhdlguru.blogspot.com/2010/03/random-number-generator-in-vhdl.html 
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;
use ieee.numeric_std.all;

ENTITY test_random IS
END test_random;

ARCHITECTURE behavior OF test_random IS
   --Input and Output definitions.
   signal clk : std_logic := '0';
   signal random_num : std_logic_vector(3 downto 0);
   -- Clock period definitions
   constant clk_period : time := 1 ns;
BEGIN

    -- Instantiate the Unit Under Test (UUT)
   uut: entity work.random generic map (width => 4) PORT MAP (
          clk => clk,
          random_num => random_num
        );

   -- Clock process definitions
   clk_process :process
   begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
   end process;

   process(random_num)
        variable str : line;
   begin
        write(str,random_num);
        write(str, string'(" ") );
        write(str,to_integer(unsigned(random_num)));
        writeline(output,str);
   end process;

END;

