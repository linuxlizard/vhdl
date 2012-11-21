library ieee;
use ieee.std_logic_1164.all;
 
entity d_ff is
    port (clk : in std_logic;
            reset : in std_logic;
            d : in std_logic_vector(7 downto 0);
            q : out std_logic_vector(7 downto 0) );
end entity d_ff;

architecture d_ff_arch of d_ff is
begin
    run_d_ff : process(clk,reset) is
    begin
        if( reset='1' ) then
            q <= (others=>'0');
        elsif( rising_edge(clk) ) then
            q <= d;
        end if; 
    end process run_d_ff;

end architecture d_ff_arch;

