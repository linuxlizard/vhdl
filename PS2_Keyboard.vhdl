--
-- PS/2 Keyboard Controller.
-- Ported from Simple SsegLedDemo.vhd from Basys2 UserDemo
-- 
-- David Poole 30-Oct-2012
-- Original header below:
--
----------------------------------------------------------------------------------
-- Company: Digilent RO
-- Engineer: Mircea Dabacan
-- 
-- Create Date:    19:04:55 03/22/2009 
-- Design Name: 
-- Module Name:    SimpleSsegLesDemo - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- This is the source file for the Simple Demo for Basys 2, 
-- provided by the Digilent Reference Component Library.

-- The project demonstrates the behavior of:
--  - Switches and LEDs: switches control LEDs state
--  When SW6 is LOW:
--  - seven segment display: all digits count synchronously from 0 to F
--    hexadecimal. All decimal points are turned ON. 
--  - buttons: pressing a button turns OFF the coresponding seven 
--    segment display digit
--  When SW6 is HIGH:
--  - seven segment display: last two digits show the last received scan code
--    from a keyboard connected to the PS2 port. All decimal points are turned ON. 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created 20/03/2009(MirceaD)
-- Revision 0.02 - Modified for Basys2UserTest 23/03/2009(MirceaD)

-- Additional Comments: 
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity PS2_Keyboard is
    
    port( ck : in std_logic;
        PS2C: in std_logic;   -- PS2 serial clock 
        PS2D: in std_logic;    -- PS2 serial data 

        key_code_out : out std_logic_vector(7 downto 0) 
        );

end PS2_Keyboard;

architecture PS2_Keyboard_arch of PS2_Keyboard is 

  signal cntDiv: std_logic_vector(28 downto 0); -- general clock div/cnt
  alias cntDisp: std_logic_vector(3 downto 0) is cntDiv(28 downto 25);
  alias clkDisp: std_logic is cntDiv(16);  -- divided clock
  -- 50MHz/2^17=381Hz
  alias ck1: std_logic is cntDiv(9);  -- divided clock
  -- 50MHz/2^10=48828Hz

  signal s_buf:std_logic_vector (9 downto 0);  -- buffer for PS2 receiver
  signal key_code:std_logic_vector (7 downto 0):= x"00";  -- scan code from keyboard
  signal par:std_logic; -- parity bit for PS2 receiver
  signal wdg: integer range 0 to 50000000; -- watch dog counter (1 sec at 50MHz)
  signal digit:std_logic_vector (3 downto 0);  -- curent displayed digit
  signal PS2Cold:std_logic;  -- stored PS2C for edge d

begin
  ckDivider: process(ck)
  begin
    if ck'event and ck='1' then
      cntDiv <= cntDiv + '1';
    end if;
  end process;

-- watchdog counter

  wdgCnt: process(ck)
  begin
    if ck'event and ck = '1' then
      if PS2D = '0' then -- PS2 data not idle  
        wdg <= 0; -- reset watchdog
      else
        if wdg < 50000000 then -- less than 1 sec
            wdg <= wdg + 1; -- increment
        end if;
      end if;          
    end if;
  end process;     

  process (ck1,wdg,PS2C)
  begin
    if ck1'event and ck1 = '1' then
      PS2Cold <= PS2C;               -- storing old value of PS2C for edge detection 
      if  wdg = 50000000 then          -- PS2D idle for the last 1 sec. 
        s_buf<="1111111111";
        par<='0';
        key_code<="00000000";                        -- no valid byte available 
      elsif PS2Cold = '0' and PS2C = '1' then  -- rising egde of PS2C
        if s_buf(0)='0' then                            -- 11 bits received ("start bit" reached S_buf(0))
          if (par='1' and PS2D='1') then        -- correct byte: parity OK, stop bit OK.
            key_code<=s_buf(8 downto 1);        -- the received byte is delivered
            s_buf<="1111111111";                    -- a new reception is prepared
            par<='0';
          else                                             -- incorrect byte
            s_buf<="1111111111";
            par<='0';
            key_code<="00000000";                -- no valid byte available 
          end if;
        else                                                 -- not yet 11 bits
          s_buf<=PS2D&s_buf(9 downto 1);        -- shift bits to right, adding the new received one
          par<=par xor PS2D;                        -- parity check. Includes the received parity bit.
        end if;
      end if;
    end if;
  end process;

  key_code_out <= key_code;

end architecture PS2_Keyboard_arch;

