-- Send switches to LEDs using button presses as the assignment requires.
--
-- Currently for testing internal components. Will synthesize, too.
--
-- David Poole 03-Oct-2012

library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity switch_to_led is 
    port(  mclk : in std_logic;
            btn : in std_logic_vector(3 downto 0);
             sw : in std_logic_vector(7 downto 0);
            led : out std_logic_vector(7 downto 0)
        ); 
end entity switch_to_led;

architecture run_switch_to_led of switch_to_led is

	 signal rst : std_logic;
	 
    component clk_divider is
        generic (clkmax : integer);
        port ( reset : in std_logic;
               clk_in : in std_logic;
               clk_out : out std_logic );
    end component clk_divider;

    component d_register is
        generic (width : integer);
        port (clk : in std_logic;
              reset : in std_logic := '1';
              input_enable : in std_logic;
              output_enable : in std_logic;
              data_in : in std_logic_vector( width-1 downto 0 );
              data_out : out std_logic_vector( width-1 downto 0 )
        );
    end component d_register;

    component regrotate is
        port ( reset : in std_logic;
               clk : in std_logic;
              reg1 : in std_logic_vector( 7 downto 0 );
              reg2 : in std_logic_vector( 7 downto 0 );
              reg_out : out std_logic_vector( 7 downto 0 ) ;
              which_out : out std_logic
             );
    end component regrotate;

    signal reg_num : std_logic;

    signal rotater_clock : std_logic;

    signal reg1_output : std_logic_vector( 7 downto 0 );
    signal reg1_in_en : std_logic;
    signal reg1_out_en : std_logic;

    signal reg2_output : std_logic_vector( 7 downto 0 );
    signal reg2_in_en : std_logic;
    signal reg2_out_en : std_logic;

begin
	 rst <= '0';
	 
    -- the actual divider will be 125e6 or so (25Mhz down to 0.20hz)
    divider : clk_divider
        generic map(clkmax => 125000000)
        port map( clk_in => mclk,
                reset => rst,
                clk_out => rotater_clock );

    register_1 : d_register
       generic map( width => 8)
       port map( clk => mclk,
                 reset => rst,
                 input_enable => btn(0),
                 output_enable => btn(3),
                 data_in => sw,
                 data_out => reg1_output);

    register_2 : d_register
       generic map( width => 8)
       port map( clk => mclk,
                 reset => rst,
                 input_enable => btn(1),
                 output_enable => btn(3),
                 data_in => sw,
                 data_out => reg2_output);

    register_rotater : regrotate
        port map( clk => rotater_clock,
                  reset => rst,
                  reg1 => reg1_output,
                  reg2 => reg2_output,
                  reg_out => led,
                  which_out => reg_num );

end architecture run_switch_to_led;

