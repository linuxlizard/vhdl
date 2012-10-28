-- Very simple clock divider based on add/compare.
--
-- David Poole 05-Oct-2012

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clk_divider is
    generic (clkmax : integer := 50000 );
    port ( reset : in std_logic;
           clk_in : in std_logic;
           clk_out : out std_logic );
end entity clk_divider;

architecture clk_divider_arch of clk_divider is
    signal counter : integer := 0;
    signal curr_clk : std_logic := '0';
begin
    behavior : process(reset,clk_in) is
    begin
        if reset='1' then
            counter <= 0;
            curr_clk <= '0';
        elsif rising_edge(clk_in) then
            counter <= counter + 1;
            if counter=clkmax then
--                if curr_clk='1' then
--                    curr_clk <= '0';
--                else 
--                    curr_clk <= '1';
--                end if;
                curr_clk <= not curr_clk;
                counter <= 0;
            end if;
        end if;
    end process behavior;

    clk_out <= curr_clk;

end architecture clk_divider_arch;

