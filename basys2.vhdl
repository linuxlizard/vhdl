-- Simulation test bench replicating parts of Basys-2 board.
--
-- David Poole  03-Oct-2012

library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity basys2 is 
end entity basys2;

architecture basys2_arch of basys2 is 
    -- pio_tx is driven by the top_rs232
    constant pio_tx : integer := 73;
    -- pio_rx is driven by this testbench code
    constant pio_rx : integer := 74;

    constant clk_period : time := 10 ns;

    -- drive simulation at 16x the simulated Rx sampling clock
    constant baud_clk_divider : integer := 4*16;

    -- use the same names as the actual hardware
    signal mclk :  std_logic;
    signal btn: std_logic_vector(3 downto 0) := (others=>'0');
    signal sw :  std_logic_vector(7 downto 0) := (others=>'0');
    signal led: std_logic_vector(7 downto 0) := (others=>'0');
    signal seg : std_logic_vector( 6 downto 0 ) := (others=>'0');
    signal an : std_logic_vector( 3 downto 0 ) := (others=>'0');
    signal dp : std_logic;
    signal PIO : std_logic_vector( 87 downto 72 );
    signal rx_baud_clk : std_logic;

    signal debug_rxd : std_logic;

    component clk_divider is
        generic (clkmax : integer);
        port ( reset : in std_logic;
               clk_in : in std_logic;
               clk_out : out std_logic );
    end component clk_divider;

    component top_rs232 is
        port(  mclk : in std_logic;
                btn : in std_logic_vector(3 downto 0);
                 sw : in std_logic_vector(7 downto 0);

               PIO  : inout std_logic_vector (87 downto 72); 

                led : out std_logic_vector( 7 downto 0 );
                seg : out std_logic_vector( 6 downto 0 );
                 an : out std_logic_vector( 3 downto 0 );
                 dp : out std_logic
            ); 
    end component top_rs232;

    signal byte_to_send : std_logic_vector(7 downto 0);
begin
    -- This is the main clock
    clock : process is
    begin
       mclk <= '0'; wait for clk_period/2;
       mclk <= '1'; wait for clk_period/2;
    end process clock;

    run_top_rs232 : top_rs232
        port map ( mclk => mclk,
                   btn => btn ,
                   sw => sw ,

                   PIO => PIO,
                   led => led,
                   seg => seg,
                   an => an,
                   dp => dp
                 );
                  
    -- generate a 57600 baud clock for the transmitter (we transmit to the
    -- top_rs232 and top_rs232 transmits to us)
    baud_clock : clk_divider
        generic map(clkmax => baud_clk_divider-1 )
        port map( clk_in => mclk,
                reset => sw(0),
                clk_out => rx_baud_clk);

    stimulus : process is
        variable str : line;
        variable i : integer;
    begin
        write( str, string'("hello, world") );
        writeline( output, str );

        btn <= "0000";
        sw <= "00000001";
        wait for clk_period;

        -- clear reset 
        sw <= "00000000";
        wait for clk_period;
        wait for clk_period/2;

        -- davep 15-dec-2012 ; add "string output" test on sw(2)
        sw <= "00000100";
        wait for clk_period;

       wait;
    end process stimulus;

    -- create a signal on the received data (the DCE Tx)
    char_input : process is 
        variable i : integer;
        variable debug_value : std_logic_vector(7 downto 0);
        variable s : line;
    begin
        -- allow top_rs232 to drive this line
        PIO(pio_tx) <= 'Z';

        -- Drive this line pretending to be the PC sending data
        PIO(pio_rx) <= '1';
        debug_rxd <= '1';

        -- wait for reset to drop
        wait until sw="00000000";

        wait until falling_edge(rx_baud_clk);
        wait until falling_edge(rx_baud_clk);
        wait until falling_edge(rx_baud_clk);

        byte_to_send <= x"31";

        -- start bit
        PIO(pio_rx) <= '0';
        debug_rxd <= '0';
        wait until falling_edge(rx_baud_clk);

        -- data bits
        for i in 0 to 7 loop
            debug_value := std_logic_vector(to_unsigned(i,8));
            -- transmit LSb to MSb
            debug_rxd <= byte_to_send(0);
            PIO(pio_rx) <= byte_to_send(0);
            byte_to_send <= '0' & byte_to_send(7 downto 1);

            write(s,string'("i=") & integer'image(i));
            write(s,string'(" bit="));
            write(s,byte_to_send(0));
            writeline(output,s);
            wait until falling_edge(rx_baud_clk);
        end loop;

        -- wait 3 ticks 
--        wait until rising_edge(rx_baud_clk);
--        wait until rising_edge(rx_baud_clk);
--        wait until rising_edge(rx_baud_clk);
--
--        wait until rising_edge(rx_baud_clk);
--        PIO(pio_rx) <= '0';
--        debug_rxd <= '0';
--
--        wait until rising_edge(rx_baud_clk);
--        PIO(pio_rx) <= '1';
--        debug_rxd <= '1';
--
--        wait until rising_edge(rx_baud_clk);
--        PIO(pio_rx) <= '0';
--        debug_rxd <= '0';
--
--        wait until rising_edge(rx_baud_clk);
--        PIO(pio_rx) <= '1';
--        debug_rxd <= '1';
--
--        wait until rising_edge(rx_baud_clk);
--        PIO(pio_rx) <= '0';
--        debug_rxd <= '0';
--
--        wait until rising_edge(rx_baud_clk);
--        PIO(pio_rx) <= '1';
--        debug_rxd <= '1';
--
--        wait until rising_edge(rx_baud_clk);
--        PIO(pio_rx) <= '0';
--        debug_rxd <= '0';
--
--        wait until rising_edge(rx_baud_clk);
--        PIO(pio_rx) <= '1';
--        debug_rxd <= '1';
--
--        wait until rising_edge(rx_baud_clk);
--        PIO(pio_rx) <= '0';
--        debug_rxd <= '0';
--

        -- stop bit
        wait until rising_edge(rx_baud_clk);
        PIO(pio_rx) <= '1';
        debug_rxd <= '1';


        wait;
    end process char_input;

end architecture basys2_arch;

