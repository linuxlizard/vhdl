library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity bcd_test is 
begin
end entity bcd_test;

architecture run_bcd_test of bcd_test is

-- http://vhdlguru.blogspot.com/2010/04/8-bit-binary-to-bcd-converter-double.html 
-- https://en.wikipedia.org/wiki/Double_dabble 
function to_bcd ( bin : std_logic_vector(7 downto 0) ) return std_logic_vector is
    variable i : integer:=0;
    variable bcd : std_logic_vector(11 downto 0) := (others => '0');
    variable bint : std_logic_vector(7 downto 0) := bin;
begin
    for i in 0 to 7 loop  -- repeating 8 times.
        bcd(11 downto 1) := bcd(10 downto 0);  --shifting the bits.
        bcd(0) := bint(7);
        bint(7 downto 1) := bint(6 downto 0);
        bint(0) :='0';


        if(i < 7 and bcd(3 downto 0) > "0100") then --add 3 if BCD digit is greater than 4.
            bcd(3 downto 0) := std_logic_vector( unsigned(bcd(3 downto 0)) + "0011" );
--            bcd(3 downto 0) := bcd(3 downto 0) + "0011";
        end if;

        if(i < 7 and bcd(7 downto 4) > "0100") then --add 3 if BCD digit is greater than 4.
            bcd(7 downto 4) := std_logic_vector( unsigned(bcd(7 downto 4)) + "0011" );
--            bcd(7 downto 4) := bcd(7 downto 4) + "0011";
        end if;

        if(i < 7 and bcd(11 downto 8) > "0100") then  --add 3 if BCD digit is greater than 4.
            bcd(11 downto 8) := std_logic_vector( unsigned(bcd(11 downto 8)) + "0011" );
--            bcd(11 downto 8) := bcd(11 downto 8) + "0011";
        end if;
    end loop;

    return bcd;
end to_bcd;

begin
    stimulus : process is
        variable num : integer;
        variable bin : std_logic_vector( 7 downto 0 );
        variable bcd : std_logic_vector( 11 downto 0 );
        variable str : line;
    begin
        write( output, string'("hello, world") );

        num := 10;

        bin := "00010001"; 

        bcd := to_bcd( bin );

        write( str, to_integer(signed(bcd)) );
        writeline( output, str );

        write( str, to_integer(signed(bin)) );
        writeline( output, str );

        wait;
    end process stimulus;

end architecture run_bcd_test;


