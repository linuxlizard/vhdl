-- Opcodes 
-- davep 14-Sep-2012
-- Based on:
-- http://www.edaboard.com/thread169224.html

library ieee;
use ieee.std_logic_1164.all;

package OPCODES is  
   constant NOP : std_logic_vector(4 downto 0) := "00000" ;
   constant ADDWF : std_logic_vector(4 downto 0) := "00001" ;
   constant SUBWF : std_logic_vector(4 downto 0) := "00010" ;
   constant SWAPF : std_logic_vector(4 downto 0) := "00011" ;
   constant PASW : std_logic_vector(4 downto 0) := "00100" ;
   constant PASF : std_logic_vector(4 downto 0) := "00101" ;
   constant INCF : std_logic_vector(4 downto 0) := "00110" ;
   constant DECF : std_logic_vector(4 downto 0) := "00111" ;
   constant ANDWF : std_logic_vector(4 downto 0) := "01000" ;
   constant IORWF : std_logic_vector(4 downto 0) := "01001" ;
   constant XORWF : std_logic_vector(4 downto 0) := "01010" ;
   constant COMF : std_logic_vector(4 downto 0) := "01011" ;
   constant RLCF : std_logic_vector(4 downto 0) := "01100" ;
   constant RRCF : std_logic_vector(4 downto 0) := "01101" ;
   constant SARF : std_logic_vector(4 downto 0) := "01110" ;
   constant CLR : std_logic_vector(4 downto 0) := "01111";
end package OPCODES;

--package body OPCODES is
--end package body OPCODES;
