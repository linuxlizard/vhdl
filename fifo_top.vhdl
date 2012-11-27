-- FIFO Top for Synthesis
-- ECE530 Fall 2012
-- David Poole

library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity fifo_top is 
    port(  mclk : in std_logic;
            btn : in std_logic_vector(3 downto 0);
             sw : in std_logic_vector(7 downto 0);
            led : out std_logic_vector( 7 downto 0 )
--            seg : out std_logic_vector( 6 downto 0 );
--             an : out std_logic_vector( 3 downto 0 );
--            dp : out std_logic
        ); 
end entity fifo_top;

architecture fifo_top_arch of fifo_top is 
    constant fifo_depth : integer := 16;
    constant fifo_num_bits : integer := 4; -- 2**fifo_num_bits = fifo_depth

    component fifo is
        generic ( depth : integer ; 
                  numbits : integer );
        port( write_clk : in std_logic;
                read_clk : in std_logic;
                reset : in std_logic;
                push : in std_logic;
                write_data : in unsigned ( 7 downto 0 );
                pop : in std_logic;

                -- outputs
                read_data : out unsigned ( 7 downto 0 );
                read_valid : out std_logic;
                full : out std_logic;
                empty : out std_logic );
    end component fifo;

    component clk_divider is
        generic (clkmax : integer);
        port ( reset : in std_logic;
               clk_in : in std_logic;
               clk_out : out std_logic );
    end component clk_divider;
    
    signal reset : std_logic;

    signal write_clk : std_logic := '0';
    signal read_clk : std_logic := '0';

    signal t_push : std_logic := '0';
    signal t_pop : std_logic := '0';
    signal t_write_data : unsigned (7 downto 0 ) := (others=>'0');

    signal t_read_data : unsigned (7 downto 0 );
    signal t_read_valid : std_logic;
    signal t_full : std_logic;
    signal t_empty : std_logic;
begin

    reset <= btn(0);

--    t_write_data <= to_unsigned(sw,8);

    clock1 : clk_divider
        generic map(clkmax => 12)
        port map( clk_in => mclk,
                reset => reset,
                clk_out => read_clk);

    clock2 : clk_divider
        generic map(clkmax => 120)
        port map( clk_in => mclk,
                reset => reset,
                clk_out => write_clk);


    run_fifo : fifo
        generic map( depth=>fifo_depth,
                     numbits => fifo_num_bits)
        port map ( 
                    write_clk=>write_clk,
                    read_clk => read_clk,

                    reset => reset,
                    push => t_push,
                    write_data => t_write_data,

                    pop => t_pop,

                    -- outputs
                    read_data => t_read_data,
                    read_valid => t_read_valid,
                    full => t_full,
                    empty => t_empty );

    run : process ( reset, mclk ) is
    begin
        if( reset='1' ) then

        elsif( rising_edge(mclk) ) then
            t_write_data <= unsigned(sw);
            led(3 downto 0) <= std_logic_vector(t_read_data(3 downto 0));
            led(4) <= t_read_valid;
            led(5) <= t_full;
            led(6) <= t_empty;
            led(7) <= '0';

            t_push <= btn(1);
            t_pop <= btn(2);

        end if;
    end process run;



end architecture fifo_top_arch;

