-- Four 7-segment display muxor. State-ish machine to rotate digits 
--
-- David Poole 03-Oct-2012
--
-- davep 19-Oct-2012 ; add display_mask to hide digits when we don't want to
--                      illuminate certain chars

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ssegmuxor is
    port (  reset : in std_logic;
            clk : in std_logic;
    display_mask : in std_logic_vector( 3 downto 0 );
            digit_0 : in std_logic_vector (6 downto 0 );
            digit_1 : in std_logic_vector (6 downto 0 );
            digit_2 : in std_logic_vector (6 downto 0 );
            digit_3 : in std_logic_vector (6 downto 0 );
   decimal_point_mask : in std_logic_vector(3 downto 0 );

            anode_out : out std_logic_vector (3 downto 0 );
            digit_out : out std_logic_vector (6 downto 0 );
            dp_out : out std_logic
        );

end entity ssegmuxor;

architecture clk_ssegmuxor_arch of ssegmuxor is
    signal counter : integer := 0;
    signal internal_anode_out : std_logic_vector(3 downto 0) := "0000";
    signal internal_digit_out : std_logic_vector(6 downto 0) := "0000000";
    signal internal_dp_out : std_logic := '0';
begin
    behavior : process(clk) is
    begin
        if reset='1' then
            counter <= 0;
        elsif rising_edge(clk) then
            case counter is
                when 0 => 
                    internal_anode_out <= "0111" or (not display_mask);
                    internal_digit_out <= digit_0;
--                    internal_digit_out <= "1111001";  -- 1
                    counter <= 1;
                    internal_dp_out <= decimal_point_mask(3);
                when 1 =>
                    internal_anode_out <= "1011" or (not display_mask);
                    internal_digit_out <= digit_1;
--                    digit_out <= "0100100";  -- 2
                    counter <= 2;
                    internal_dp_out <= decimal_point_mask(2);
                when 2 =>
                    internal_anode_out <= "1101" or (not display_mask);
                    internal_digit_out <= digit_2;
                    internal_dp_out <= decimal_point_mask(1);
--                    digit_out <= "0110000";  -- 3
                    counter <= 3;
                when 3 =>
                    internal_anode_out <= "1110" or (not display_mask);
                    internal_digit_out <= digit_3;
                    internal_dp_out <= decimal_point_mask(0);
--                    digit_out <= "0011001";  -- 4
                    counter <= 0;
                when others =>
                    internal_anode_out <= "0000";
                    internal_digit_out <= "1111111";
                    internal_dp_out <= '1';
            end case;
        end if;

        digit_out <= internal_digit_out;
        anode_out <= internal_anode_out;
        dp_out <= internal_dp_out;
    end process behavior;
end architecture clk_ssegmuxor_arch;

