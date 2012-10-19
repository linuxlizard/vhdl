
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity edge_to_pulse is
    Port ( CLK : in  STD_LOGIC;
           Reset : in  STD_LOGIC;
           Edge_in : in  STD_LOGIC;
           Pulse_out : out  STD_LOGIC);
end edge_to_pulse;

architecture Behavioral of edge_to_pulse is

type state_type is (start, finish, temp);
signal current_state, next_state : state_type; 
   
begin

SYNC_PROC: process (Clk, Reset)
   begin
      if (Reset  = '1') then
                Current_state <= start;
        elsif (CLK'event and CLK = '1') then
            current_state <= next_state;
      end if;
end process;

NEXT_STATE_DECODE: process (current_state, Edge_in)
   begin
      case (Current_state) is
         when start =>
            if Edge_in = '1' then
               next_state <= finish;
               else
                    next_state <= start;
            end if;
            Pulse_out <= '0';
         when finish =>
            next_state <= temp;
            Pulse_out <= '1';
         when temp =>
            if Edge_in = '1' then
                    Next_state <= temp;
            else
                    next_state <= start;
            end if;
            Pulse_out <= '0';
       end case;      
   end process;

end Behavioral;

