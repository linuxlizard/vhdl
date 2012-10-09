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

    signal alu_result_out : std_logic_vector( 7 downto 0) := "00000000";

    component alu_wrapper is
        port ( mclk : in std_logic;
                btn : in std_logic_vector(3 downto 0);
                 sw : in std_logic_vector(7 downto 0);

                result : out std_logic_vector (7 downto 0 );
                led : out std_logic_vector (7 downto 0 )
             );
    end component alu_wrapper;

    component digits_to_7seg is
        -- signals in Basys2
        port(  mclk : in std_logic;
             byte_in : in std_logic_vector(7 downto 0 );
                seg : out std_logic_vector(6 downto 0 );
                an : out std_logic_vector(3 downto 0);
                dp : out std_logic
            ); 
    end component digits_to_7seg;

begin
    run_alu_wrapper : alu_wrapper
        port map( mclk => mclk,
                  btn => btn,
                  sw => sw,
                  result => alu_result_out,
                  led => led
                );

    run_digits_to_7seg : digits_to_7seg
        port map ( mclk => mclk,
                    byte_in => alu_result_out,
--                    byte_in => "11111110",
                    seg => seg,
                    an => an,
                    dp => dp 
                );

end architecture puter_arch;

