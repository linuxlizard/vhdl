-- Seven segment encode function.
--
-- Started point was SimpleSsegLedDemo.vhd from Digilent's UserDemo
--
-- David Poole 02-Oct-2012
--

library ieee;
use ieee.std_logic_1164.ALL;
--use ieee.std_logic_arith.ALL;
--use ieee.std_logic_unsigned.ALL;

entity SevenSegmentEncoder is

  Port (rst : in std_logic;
         ck:  in  std_logic;
      nibble: in std_logic_vector( 3 downto 0 );
        seg: out std_logic_vector(6 downto 0)
  );

end SevenSegmentEncoder;

architecture Behavioral of SevenSegmentEncoder is

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
    begin
        if rst='1' then
            -- todo?
        elsif rising_edge(ck) then 
            case nibble is 
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
                when "1010" => -- 0x0a d'10
                    seg <= "0001000";
                when "1011" => -- 0x0b d'11
                    seg <= "0000011";  
                when "1100" => -- 0x0c d'12
                    seg <= "1000110";
                when "1101" => -- 0x0d d'13
                    seg <= "0100001";
                when "1110" => -- 0x0e d'14
                    seg <= "0000110";
                when "1111" => -- 0x0f d'15
                    seg <= "0001110";
                when others => -- 0
                    seg <= "1000000";
            end case;
        end if;
   end process calculate_7seg;
    
end Behavioral;

