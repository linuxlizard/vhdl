library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

library work;
use work.opcodes.all;

entity test_alu_wrapper is 
end entity test_alu_wrapper;

architecture test_alu_wrapper_arch of test_alu_wrapper is 

    -- use the same names as the actual hardware
    signal mclk :  std_logic;
    signal rst : std_logic;
    signal btn: std_logic_vector(3 downto 0);
    signal sw :  std_logic_vector(7 downto 0);
    signal led: std_logic_vector(7 downto 0);
    signal seg : std_logic_vector( 6 downto 0 );
    signal an : std_logic_vector( 3 downto 0 );
    signal dp : std_logic;

    signal alu_result_out : std_logic_vector( 7 downto 0) := "00000000";

    component alu_wrapper is
        port ( mclk : in std_logic;
                btn : in std_logic_vector(3 downto 0);
                 sw : in std_logic_vector(7 downto 0);

            wreg_out : out std_logic_vector (7 downto 0 );
            freg_out : out std_logic_vector (7 downto 0 );
                led : out std_logic_vector (7 downto 0 )
             );
    end component alu_wrapper;

    component digits_to_7seg is
        -- signals in Basys2
        port(  mclk : in std_logic;
            digit0_in : in std_logic_vector(3 downto 0 );
             byte_in : in std_logic_vector(7 downto 0 );
                seg : out std_logic_vector(6 downto 0 );
                an : out std_logic_vector(3 downto 0);
                dp : out std_logic
            ); 
    end component digits_to_7seg;

    signal regw_output : std_logic_vector( 7 downto 0 ) := (others=>'0');
    signal regf_output : std_logic_vector( 7 downto 0 ) := (others=>'0');

begin
    run_alu_wrapper : alu_wrapper
        port map( mclk => mclk,
                  btn => btn,
                  sw => sw,
                wreg_out => regw_output,
                freg_out => regf_output,

                  led => led
                );

    run_digits_to_7seg : digits_to_7seg
        port map ( mclk => mclk,
                digit0_in => "0111", -- indicates W or F reg; hardwire for now
                    byte_in => regf_output,
--                    byte_in => alu_result_out ,
                    seg => seg,
                    an => an,
                    dp => dp 
                );

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

        -- reset state
        dp <= '0';
        rst <= '1';
        btn <= "0000";
        sw <= "00000000";
        wait for 15 ns;

        -- load Opcode register
        sw <= "000" & SUBWF; --(others=>IORWF) );
--        sw <= "000" & PASF; --(others=>IORWF) );
--        sw <= "000" & PASW; --(others=>IORWF) );
--        sw <= "000" & ADDWF; --(others=>IORWF) );
--        sw <= "000" & IORWF; --(others=>IORWF) );
        btn <= "0001";  -- push button 0
        wait for 20 ns;

        write( str, string'("OPCODE_register loaded") );
        writeline( output, str );

        btn <= "0000"; -- release button 0
        wait for 20 ns;

        -- load W_register  with a value
        sw <= "00000001";
        btn <= "0010";  -- push button 1
        wait for 20 ns;
        
        write( str, string'("W_register loaded") );
        writeline( output, str );

        btn <= "0000"; -- release button 0
        wait for 20 ns;

        -- load F_register with a value
        sw <= "00000110";
        btn <= "0100";  -- push button 2
        wait for 20 ns;

        write( str, string'("F_register loaded") );
        writeline( output, str );

        btn <= "0000"; -- release button 1
        wait for 20 ns;

        -- push button 3 to execute
        btn <= "1000";
        wait for 20 ns;

        btn <= "0000"; -- release button 1
        wait for 20 ns;

        write( str, string'("W_out=") );
        hwrite( str, regw_output );
        write( str, string'(" F_out=") );
        hwrite( str, regf_output );
        writeline( output, str );
        wait for 20 ns;

        wait;
    end process stimulus;
end architecture test_alu_wrapper_arch;

