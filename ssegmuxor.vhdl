-- Four 7-segment display muxor. State-ish machine to rotate digits 
--
-- David Poole 03-Oct-2012

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ssegmuxor is
    port (  reset : in std_logic;
            clk : in std_logic;
            digit_0 : in std_logic_vector (6 downto 0 );
            digit_1 : in std_logic_vector (6 downto 0 );
            digit_2 : in std_logic_vector (6 downto 0 );
            digit_3 : in std_logic_vector (6 downto 0 );

            anode_out : out std_logic_vector (3 downto 0 );
            digit_out : out std_logic_vector (6 downto 0 ) 
        );

end entity ssegmuxor;

architecture clk_ssegmuxor_arch of ssegmuxor is
    signal counter : integer := 0;
begin
    behavior : process(clk) is
    begin
        if reset='1' then
            counter <= 0;
        elsif rising_edge(clk) then
            counter <= (counter + 1) mod 4;
            case counter is
                when 0 => 
                    anode_out <= "0111";
                    digit_out <= digit_0;
                when 1 =>
                    anode_out <= "1011";
                    digit_out <= digit_1;
                when 2 =>
                    anode_out <= "1101";
                    digit_out <= digit_2;
                when 3 =>
                    anode_out <= "1110";
                    digit_out <= digit_3;
                when others =>
                    anode_out <= "0000";
                    digit_out <= "1111111";
            end case;
        end if;
    end process behavior;
end architecture clk_ssegmuxor_arch;

