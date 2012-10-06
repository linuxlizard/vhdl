-- Seven segment encode function with BCD conversion.
--
-- Started point was SimpleSsegLedDemo.vhd from Digilent's UserDemo
--
-- David Poole 02-Oct-2012
--

library ieee;
use ieee.std_logic_1164.ALL;
use ieee.std_logic_arith.ALL;
use ieee.std_logic_unsigned.ALL;

entity SevenSegmentEncoder is

  Port (rst : in std_logic;
         ck:  in  std_logic;
      nibble: in std_logic_vector( 3 downto 0 );
        seg: out std_logic_vector(6 downto 0)
  );

end SevenSegmentEncoder;

architecture Behavioral of SevenSegmentEncoder is

    -- http://vhdlguru.blogspot.com/2010/04/8-bit-binary-to-bcd-converter-double.html
    function to_bcd ( bin : std_logic_vector(7 downto 0) ) return std_logic_vector is

--    use ieee.std_logic_arith.all;
--    use ieee.std_logic_unsigned.all;

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

begin
  --HEX-to-seven-segment decoder
--   HEX:   in    STD_LOGIC_VECTOR (3 downto 0);
--   LED:   out   STD_LOGIC_VECTOR (6 downto 0);
-- 
-- segment encoinputg
--      0
--     ---  
--  5 |   | 1
--     ---   <- 6
--  4 |   | 2
--     ---
--      3
   
--    with cntDisp SELect
--   seg<= "1111001" when "0001",   --1
--         "0100100" when "0010",   --2
--         "0110000" when "0011",   --3
--         "0011001" when "0100",   --4
--         "0010010" when "0101",   --5
--         "0000010" when "0110",   --6
--         "1111000" when "0111",   --7
--         "0000000" when "1000",   --8
--         "0010000" when "1001",   --9
--         "0001000" when "1010",   --A
--         "0000011" when "1011",   --b
--         "1000110" when "1100",   --C
--         "0100001" when "1101",   --d
--         "0000110" when "1110",   --E
--         "0001110" when "1111",   --F
--         "1000000" when others;   --0
 
 
    calculate_7seg : process(ck) is
        variable num : std_logic_vector(7 downto 0 );
        variable tmp : std_logic_vector( 11 downto 0 );
        variable tmp2 : std_logic_vector( 3 downto 0 );
    begin
        if rising_edge(ck) then 
            -- unroll it due to inexperience with VHDL
            num := ('0','0','0','0',nibble(3),nibble(2),nibble(1),nibble(0));
            --num := ('0','0','0','0',cntDiv(3),cntDiv(2),cntDiv(1),cntDiv(0));
            --num := ('0','0','0','0',cntDisp(3),cntDisp(2),cntDisp(1),cntDisp(0));
            tmp := to_bcd(num);
            tmp2 := (tmp(3),tmp(2),tmp(1),tmp(0));
            
            case tmp2 is 
                when "0001" => -- 1
                    seg <= "1111001";
                when "0010" => -- 2
                    seg <= "0100100";
                when "0011" => -- 3
                    seg <= "0110000";
                when "0100" => --4
                    seg <= "0011001";
                when "0101" => --5
                    seg <= "0010010";
                when "0110" => -- 6
                    seg <= "0000010";
                when "0111" => -- 7
                    seg <= "1111000";
                when "1000" => -- 8
                    seg <= "0000000";
                when "1001" => -- 9
                    seg <= "0010000";
                when others => -- 0
                    seg <= "1000000";
            end case;
        end if;
   end process calculate_7seg;
    
end Behavioral;

