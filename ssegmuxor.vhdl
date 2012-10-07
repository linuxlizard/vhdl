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
    signal save_digit_out : std_logic_vector(6 downto 0) := "0000000";
begin
    behavior : process(clk) is
    begin
        if reset='1' then
            counter <= 0;
        elsif rising_edge(clk) then
            case counter is
                when 0 => 
                    anode_out <= "0111";
                    save_digit_out <= digit_0;
--                    save_digit_out <= "1111001";  -- 1
                    counter <= 1;
                when 1 =>
                    anode_out <= "1011";
                    save_digit_out <= digit_1;
--                    digit_out <= "0100100";  -- 2
                    counter <= 2;
                when 2 =>
                    anode_out <= "1101";
                    save_digit_out <= digit_2;
--                    digit_out <= "0110000";  -- 3
                    counter <= 3;
                when 3 =>
                    anode_out <= "1110";
                    save_digit_out <= digit_3;
--                    digit_out <= "0011001";  -- 4
                    counter <= 0;
                when others =>
                    anode_out <= "0000";
                    save_digit_out <= "1111111";
            end case;
        end if;

        digit_out <= save_digit_out;
    end process behavior;
end architecture clk_ssegmuxor_arch;

