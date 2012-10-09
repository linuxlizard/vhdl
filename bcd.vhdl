-- http://vhdlguru.blogspot.com/2010/04/8-bit-binary-to-bcd-converter-double.html
library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

-- using std_logic_unsigned for the to_bcd() function below
use ieee.std_logic_unsigned.all;

entity bcd_encoder is
    port (rst : in std_logic;
          clk : in std_logic;
          byte_in : in std_logic_vector(7 downto 0 );
          bcd_out : out std_logic_vector( 11 downto 0 );
          negative_out : out std_logic
         );
end entity bcd_encoder;


architecture bcd_encoder_arch of bcd_encoder is 

    -- http://vhdlguru.blogspot.com/2010/04/8-bit-binary-to-bcd-converter-double.html
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
                bcd(3 downto 0) := bcd(3 downto 0) + "0011";
            end if;

            if(i < 7 and bcd(7 downto 4) > "0100") then --add 3 if BCD digit is greater than 4.
                bcd(7 downto 4) := bcd(7 downto 4) + "0011";
            end if;

            if(i < 7 and bcd(11 downto 8) > "0100") then  --add 3 if BCD digit is greater than 4.
                bcd(11 downto 8) := bcd(11 downto 8) + "0011";
            end if;
        end loop;

        return bcd;
    end to_bcd;

    signal internal_bcd_out : std_logic_vector(11 downto 0) := (others=>'0');
    signal internal_negative_out : std_logic := '0';
    signal num : unsigned(7 downto 0) := (others=>'0');
begin

    convert_to_bcd : process(clk) is
        variable str : line;
    begin
        if rst='1' then
            -- todo
        elsif rising_edge(clk) then
            -- if high bit set, assume is negative number. Take two's
            -- complement, turn that into positive. Send sign bit out with the
            -- encoded value
            if byte_in > 127 then
                -- convert from negative to positive
--                bcd_out <= to_bcd(std_logic_vector((unsigned(not byte_in)) + 1));
--                negative_out <= '1';
                internal_bcd_out <= to_bcd(std_logic_vector((unsigned(not byte_in)) + 1));
                internal_negative_out <= '1';
            else 
--                bcd_out <= to_bcd(byte_in);
--                negative_out <= '0';
                internal_bcd_out <= to_bcd(byte_in);
                internal_negative_out <= '0';
            end if;

--            internal_bcd_out <= "000100100011"; -- "123"
        end if;
		
--        bcd_out <= "000100100011";
--        negative_out <= '1';
        bcd_out <= internal_bcd_out;
        negative_out <= internal_negative_out;
    end process convert_to_bcd;

end architecture bcd_encoder_arch;

