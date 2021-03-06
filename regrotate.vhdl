-- Every rising edge of incoming clock, swap the output between two inputs.
-- Created to rotate the 7-Seg display between two ouput sources.
-- David Poole 03-Oct-2012

library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;

entity regrotate is
    port ( reset : in std_logic;
           clk : in std_logic;
          reg1 : in std_logic_vector( 7 downto 0 );
          reg2 : in std_logic_vector( 7 downto 0 );
          reg_out : out std_logic_vector( 7 downto 0 ) ;
          which_out : out std_logic
         );
end entity regrotate;

architecture regrotater_arch of regrotate is 
    signal which : std_logic := '0';
    signal internal_reg_out : std_logic_vector (7 downto 0) := (others=>'0');
begin
    reg_rotate : process(clk,reset) is 
    begin
        if reset='1' then
            which <= '0';
            internal_reg_out <= "00000000";
            which_out <= '0';
        elsif rising_edge(clk) then
            if which='0' then
                internal_reg_out <= reg1;
            else
                internal_reg_out <= reg2;
            end if;
            which_out <= which;
            which <= not which;
        end if;
        reg_out <= internal_reg_out;
    end process reg_rotate;

end architecture regrotater_arch;

