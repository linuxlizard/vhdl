-- davep 18-Oct-2012 ; remove negative

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
          word_in : in std_logic_vector(15 downto 0 );
          bcd_out : out std_logic_vector( 19 downto 0 )
         );
end entity bcd_encoder;


architecture bcd_encoder_arch of bcd_encoder is 

    -- http://vhdlguru.blogspot.com/2010/04/8-bit-binary-to-bcd-converter-double.html
    function to_bcd ( bin : std_logic_vector(15 downto 0) ) return std_logic_vector is
        variable i : integer:=0;
        variable bcd : std_logic_vector(19 downto 0) := (others => '0');
        variable bint : std_logic_vector(15 downto 0) := bin;

    begin
        for i in 0 to 15 loop  -- repeating 8 times.
            bcd(19 downto 1) := bcd(18 downto 0);  --shifting the bits.
            bcd(0) := bint(15);
            bint(15 downto 1) := bint(14 downto 0);
            bint(0) :='0';


            if(i < 15 and bcd(3 downto 0) > "0100") then --add 3 if BCD digit is greater than 4.
                bcd(3 downto 0) := bcd(3 downto 0) + "0011";
            end if;

            if(i < 15 and bcd(7 downto 4) > "0100") then --add 3 if BCD digit is greater than 4.
                bcd(7 downto 4) := bcd(7 downto 4) + "0011";
            end if;

            if(i < 15 and bcd(11 downto 8) > "0100") then  --add 3 if BCD digit is greater than 4.
                bcd(11 downto 8) := bcd(11 downto 8) + "0011";
            end if;

            if(i < 15 and bcd(15 downto 12) > "0100") then  --add 3 if BCD digit is greater than 4.
                bcd(15 downto 12) := bcd(15 downto 12) + "0011";
            end if;

            if(i < 15 and bcd(19 downto 16) > "0100") then  --add 3 if BCD digit is greater than 4.
                bcd(19 downto 16) := bcd(19 downto 16) + "0011";
            end if;
        end loop;

        return bcd;
    end to_bcd;

    signal internal_bcd_out : std_logic_vector(19 downto 0) := (others=>'0');
--    signal internal_negative_out : std_logic := '0';
--    signal num : unsigned(7 downto 0) := (others=>'0');
begin

    convert_to_bcd : process(rst,clk) is
        variable str : line;
    begin
        if rst='1' then
            internal_bcd_out <= (others=>'0');
        elsif rising_edge(clk) then
		  
--            -- if high bit set, assume is negative number. Take two's
--            -- complement, turn that into positive. Send sign bit out with the
--            -- encoded value
--            if byte_in > 127 then
--                -- convert from negative to positive
--                internal_bcd_out <= to_bcd(std_logic_vector((unsigned(not byte_in)) + 1));
--                internal_negative_out <= '1';
--            else 
--                internal_bcd_out <= to_bcd(byte_in);
--                internal_negative_out <= '0';
--            end if;
            internal_bcd_out <= to_bcd(word_in);
--            internal_negative_out <= '0';
				
        end if;
		
--        negative_out <= internal_negative_out;
    end process convert_to_bcd;

    bcd_out <= internal_bcd_out;

end architecture bcd_encoder_arch;

