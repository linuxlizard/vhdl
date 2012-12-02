-- Test RS232 in Synthesis
-- ECE530 Fall 2012
--
-- David Poole
-- 28-Nov-2012

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use std.textio.all;
use ieee.numeric_std.all;

entity top_rs232 is
    port(  mclk : in std_logic;
            btn : in std_logic_vector(3 downto 0);
             sw : in std_logic_vector(7 downto 0);

           PIO  : out std_logic_vector (87 downto 72); 

            led : out std_logic_vector( 7 downto 0 );
            seg : out std_logic_vector( 6 downto 0 );
             an : out std_logic_vector( 3 downto 0 );
             dp : out std_logic
        ); 
end entity top_rs232;

architecture top_rs232_arch of top_rs232 is
    component rs232 is
        port ( mclk : in std_logic;
                reset : in std_logic;
                write_en : in std_logic;
                data_out : in unsigned(7 downto 0) ;

                -- outputs
                tx : out std_logic;
                full : out std_logic;
                debug_baud_clk : out std_logic
             );
    end component rs232;

    component edge_to_pulse is
        Port ( CLK : in  STD_LOGIC;
               Reset : in  STD_LOGIC;
               Edge_in : in  STD_LOGIC;
               Pulse_out : out  STD_LOGIC);
    end component;

    component hex_to_7seg is
        port(  rst : in std_logic;
                mclk : in std_logic;
                word_in : in std_logic_vector(15 downto 0 );
                display_mask_in : in std_logic_vector (3 downto 0 );
                seg : out std_logic_vector(6 downto 0 );
                an : out std_logic_vector(3 downto 0);
                dp : out std_logic
            ); 
    end component hex_to_7seg;

    component clk_divider is
        generic (clkmax : integer);
        port ( reset : in std_logic;
               clk_in : in std_logic;
               clk_out : out std_logic );
    end component clk_divider;

    signal reset : std_logic := '1';
    signal t_write_en : std_logic := '0';
    signal t_write_data : unsigned (7 downto 0 ) := (others=>'0');

    signal t_tx : std_logic;
    signal t_full : std_logic;

    signal char_write_clk : std_logic;

    type char_write_state is 
        ( STATE_INIT, STATE_WRITE_CHAR, STATE_WAIT_1, STATE_WAIT_NOT_FULL );
    signal curr_state, next_state: char_write_state;

    signal debug_byte_to_send : unsigned(7 downto 0);

    signal t_baud_clk : std_logic;
begin
    -- Reset Button
    reset <= sw(0);

    led <= sw(7 downto 1) & '0';

    PIO(72) <= 'Z';
    PIO(73) <= t_tx;
    PIO(74) <= 'Z';
    PIO(75) <= 'Z';
    
--    PIO(79 downto 76) <= btn;

--    PIO(83 downto 80) <= (others=>'Z');

    PIO(83 downto 76) <= std_logic_vector(t_write_data);

--    PIO(84) <= 'Z';
    PIO(84) <= mclk;
    PIO(85) <= t_baud_clk;
    PIO(86) <= t_full;
    PIO(87) <= t_write_en;

    run_hex_to_7seg : hex_to_7seg 
        port map ( rst => reset,
                    mclk => mclk,
                    word_in => X"abcd",
                    display_mask_in => "1111",
                    seg => seg,
                    an => an,
                    dp => dp );

    char_write : clk_divider
        -- divide 50Mhz down to 1 char/sec
        generic map(clkmax => 12500000) 
--        generic map(clkmax => 2 ) 
        port map( clk_in => mclk,
                reset => reset,
                clk_out => char_write_clk);

    run_rs232 : rs232
        port map ( mclk => mclk,
                   reset => reset,
                   write_en => t_write_en,
                   data_out => t_write_data,
                   tx => t_tx,
                   full => t_full,
                   debug_baud_clk => t_baud_clk
                 );

    char_write_sm_run : process(reset,mclk) is
    begin
        if( reset='1') then
            curr_state <= STATE_INIT;
        elsif( rising_edge(mclk)) then
            curr_state <= next_state;
        end if;
    end process char_write_sm_run;

    char_write_sm : process(curr_state,t_full) is
        variable i : integer;
        variable char_to_write : unsigned(7 downto 0);
        variable next_char_to_write : unsigned(7 downto 0);

    begin
        case curr_state is 
            when STATE_INIT =>
                next_state <= STATE_WRITE_CHAR;
                t_write_data <= X"ee";
                t_write_en <= '0';

                char_to_write := X"20";
                next_char_to_write := X"20";

            when STATE_WRITE_CHAR =>
                t_write_data <= X"44";
--                t_write_data <= char_to_write;
                t_write_en <= '1';
                next_state <= STATE_WAIT_1;

--                if char_to_write = X"7e" then
--                    next_char_to_write := X"20";
--                else
--                    next_char_to_write := char_to_write + X"01";
--                end if;

            when STATE_WAIT_1 =>
                next_state <= STATE_WAIT_NOT_FULL;
                t_write_data <= X"44";
--                t_write_data <= char_to_write;
                t_write_en <= '1';

            when STATE_WAIT_NOT_FULL =>
                t_write_en <= '0';
                t_write_data <= X"ee";

                if( t_full='0' ) then
--                    next_state <= STATE_WRITE_CHAR;
--                    char_to_write := next_char_to_write;
                else
                    next_state <= STATE_WAIT_NOT_FULL;
                end if;

            when others =>
                next_state <= STATE_INIT;
                t_write_en <= '0';
                t_write_data <= X"ee";

        end case;

--        for i in 16#20# to 16#7e# loop
--            t_write_en <= '1';
--            t_write_data <= to_unsigned(i,8);
----            wait for clk_period;
--
--            t_write_en <= '0';
----            wait for clk_period;
--
----            wait until t_full='0';
--        end loop;

--        wait;
    end process char_write_sm;

end architecture top_rs232_arch;

