
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity basys2_mux is 
    port(  rst : in std_logic;
            output_sel : in unsigned;
            
            mclk : in std_logic;
            btn : in std_logic_vector(3 downto 0);
             sw : in std_logic_vector(7 downto 0);
            led : out std_logic_vector( 7 downto 0 );
            seg : out std_logic_vector( 6 downto 0 );
             an : out std_logic_vector( 3 downto 0 );
             dp : out std_logic
        ); 
end entity basys2_mux;

architecture basys2_mux_arch of basys2_mux is
    type basys2_io is record
            mclk : std_logic;
            btn : std_logic_vector(3 downto 0);
             sw : std_logic_vector(7 downto 0);
            led : std_logic_vector( 7 downto 0 );
            seg : std_logic_vector( 6 downto 0 );
             an : std_logic_vector( 3 downto 0 );
             dp : std_logic;
    end record basys2_io;

begin

    run_basys2_mux : process(mclk,rst) 
    begin
        if rst='1' then

        elsif rising_edge(mclk) then

        end if;
    end process run_basys2_mux;

end architecture basys2_mux_arch;


