library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

library work;
use work.opcodes.all;

entity puter is 
    port(  mclk : in std_logic;
            btn : in std_logic_vector(3 downto 0);
             sw : in std_logic_vector(7 downto 0);
            led : out std_logic_vector( 7 downto 0 );
            seg : out std_logic_vector( 6 downto 0 );
           an : out std_logic_vector( 3 downto 0 );
            dp : out std_logic
        ); 
end entity puter;

architecture puter_arch of puter is 

    component alu_wrapper is
        port ( mclk : in std_logic;
                btn : in std_logic_vector(3 downto 0);
                 sw : in std_logic_vector(7 downto 0);

            wreg_out : out std_logic_vector (7 downto 0 );
            freg_out : out std_logic_vector (7 downto 0 );
                led : out std_logic_vector (7 downto 0 )
             );
    end component alu_wrapper;

    component digits_to_7seg is
        -- signals in Basys2
        port(  mclk : in std_logic;
            digit0_in : in std_logic_vector(3 downto 0);
             byte_in : in std_logic_vector(7 downto 0 );
                seg : out std_logic_vector(6 downto 0 );
                an : out std_logic_vector(3 downto 0);
                dp : out std_logic
            ); 
    end component digits_to_7seg;

    component regrotate is
        port ( reset : in std_logic;
               clk : in std_logic;
              reg1 : in std_logic_vector( 7 downto 0 );
              reg2 : in std_logic_vector( 7 downto 0 );
              reg_out : out std_logic_vector( 7 downto 0 ) ;
              which_out : out std_logic
             );
    end component regrotate;

    component clk_divider is
        generic (clkmax : integer);
        port ( reset : in std_logic;
               clk_in : in std_logic;
               clk_out : out std_logic );
    end component clk_divider;


--    signal alu_result_out : std_logic_vector( 7 downto 0) := "00000000";
    signal regw_output : std_logic_vector( 7 downto 0 ) := (others=>'0');
    signal regf_output : std_logic_vector( 7 downto 0 ) := (others=>'0');
    signal rotater_out : std_logic_vector( 7 downto 0 ) := (others=>'0');
    signal rotater_which_out : std_logic := '0';
    signal rotater_clock_in : std_logic := '0';

    signal digit_zero_or_one : std_logic_vector( 3 downto 0 ) := (others=>'0');
begin
    run_alu_wrapper : alu_wrapper
        port map( mclk => mclk,
                  btn => btn,
                  sw => sw,
                wreg_out => regw_output,
                freg_out => regf_output,
                  led => led
                );

    -- the actual divider will be 125e6 or so (25Mhz down to 0.20hz)
    run_rotate_divider : clk_divider
        generic map(clkmax => 8) -- simulation
--        generic map(clkmax => 125000000) -- synthesis
        port map( clk_in => mclk,
                reset => '0',
                clk_out => rotater_clock_in );


    run_regrotate : regrotate
        port map( reset => '0',
                    clk => rotater_clock_in,
                    reg1 => regw_output,
                    reg2 => regf_output,
                    reg_out => rotater_out,
                    which_out => rotater_which_out
                );

    -- somehow have to conver the 1-bit rotater output (0/1) into a 4 bit
    -- digit for the 7seg display
    -- when in doubt, use brute force.
    run_puter : process(mclk) is 
    begin
        if( rotater_which_out='1' ) then
            digit_zero_or_one <= "0000";
        else 
            digit_zero_or_one <= "0001";
        end if;
    end process run_puter;

    run_digits_to_7seg : digits_to_7seg
        port map ( mclk => mclk,
                digit0_in => digit_zero_or_one,
                    byte_in => rotater_out,
--                    byte_in => "11111110",
                    seg => seg,
                    an => an,
                    dp => dp 
                );

end architecture puter_arch;

