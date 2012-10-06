library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity d_counter is
    port ( rst : in std_logic;
           clk : in std_logic;
           do_count : in std_logic;
           total : out unsigned (15 downto 0)
        );
end entity d_counter;

architecture counter_arch of d_counter is
  signal current_value : unsigned (15 downto 0) := (others=>'0');
begin
  count_up : process(clk) is
  begin
    if rst='1' then
      current_value <= (others=>'0');
--      total <= (others=>'0');
    elsif rising_edge(clk) then
      if do_count='1' then
        current_value <= current_value + 1;
--        current_value <= current_value + to_unsigned(1,16);
      end if;
    end if;
--    total <= x"0";
    total <= current_value;
--    total <= unsigned'(current_value);
--    total <= unsigned'("0101010101010101");
  end process count_up;
--  total <= current_value;
end architecture counter_arch;

