
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY tb_Edge_to_Pulse IS
END tb_Edge_to_Pulse;
 
ARCHITECTURE behavior OF tb_Edge_to_Pulse IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT edge_to_pulse
    PORT(
         CLK : IN  std_logic;
         Reset : IN  std_logic;
         Edge_in : IN  std_logic;
         Pulse_out : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal CLK : std_logic := '0';
   signal Reset : std_logic := '0';
   signal Edge_in : std_logic := '0';

 	--Outputs
   signal Pulse_out : std_logic;

   -- Clock period definitions
   constant CLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: edge_to_pulse PORT MAP (
          CLK => CLK,
          Reset => Reset,
          Edge_in => Edge_in,
          Pulse_out => Pulse_out
        );

   -- Clock process definitions
   CLK_process :process
   begin
		CLK <= '0';
		wait for CLK_period/2;
		CLK <= '1';
		wait for CLK_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- pulse reset
		wait for CLK_period/4;
		Reset <= '1';
		wait for CLK_period;
		Reset <= '0';
		Wait for CLK_period;
		-- turn edge_in on for 2 periods
		Edge_in <= '1';
      wait for CLK_period*2;
		Edge_in <='0';
      wait for CLK_period*5;
		-- turn edge_in on for 1 periods
		Edge_in <= '1';
      wait for CLK_period*5;
		Edge_in <='0';
      wait for CLK_period*5;
		-- turn edge_in on for 1/2 periods
		Edge_in <= '1';
      wait for CLK_period/2;
		Edge_in <='0';
      wait for CLK_period*5;
      wait;
   end process;

END;
