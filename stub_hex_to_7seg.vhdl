-- Stub 7segment controller for simulation.
-- 
-- ECE 530 Fall 2012
--
-- David Poole 14-Dec-2012
-- 
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use std.textio.all;
use ieee.numeric_std.all;

entity stub_hex_to_7seg is

    -- signals in Basys2
    port(  rst : in std_logic;

            mclk : in std_logic;

            word_in : in std_logic_vector(15 downto 0);

            -- want to use the same hex display for both the ticket selector and the
            -- ticket dispensor. The ticket selector uses 1 digit and the ticket
            -- dispensor uses 2 digits

            display_mask_in : in std_logic_vector (3 downto 0 );

            -- 7seg display
            seg : out std_logic_vector(6 downto 0 );

            -- anode of 7seg display
            an : out std_logic_vector(3 downto 0);

            -- decimal point of 7seg display
            dp : out std_logic
        ); 
end entity stub_hex_to_7seg;

architecture stub_hex_to_7seg_arch of stub_hex_to_7seg is

begin
    seg <= (others=>'0');
    an <= (others=>'0');
    dp <= '0';

-- run_hex_to_7seg   process(mclk) is
--    begin
--    end process;
end architecture stub_hex_to_7seg_arch;

