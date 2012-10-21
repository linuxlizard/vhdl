--
-- David Poole 21-Oct-2012

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity subway_tickets is 
    port(  mclk : in std_logic;
            btn : in std_logic_vector(3 downto 0);
             sw : in std_logic_vector(7 downto 0);
            led : out std_logic_vector( 7 downto 0 );
            seg : out std_logic_vector( 6 downto 0 );
             an : out std_logic_vector( 3 downto 0 );
             dp : out std_logic
        ); 
end entity subway_tickets;

architecture subway_tickets_arch of subway_tickets is 
    type state_type is (
        STATE_START,
        STATE_ENTER_MONEY,
        STATE_CHOOSE_ZONE,
        STATE_TICKET_COUNTER,
        STATE_MONEY_CHECK,
        STATE_TICKET_DISPENSE,
        STATE_CHANGE_DISPENSE,
       
        STATE_RESET_0,
        STATE_RESET_1,
        STATE_RESET_2
        
        );

    signal current_state, next_state : state_type := STATE_START;
    
    signal reset : std_logic := '0';

    signal btn_3_pushed : std_logic;

    signal user_total_money : std_logic_vector(15 downto 0);
    signal user_zone_choice : std_logic_vector(1 downto 0 );
    signal user_ticket_count : std_logic_vector (2 downto 0) := (others=>'0');

    type basys2_io is record
            reset : std_logic;
            btn : std_logic_vector(3 downto 0);
             sw : std_logic_vector(7 downto 0);
            led : std_logic_vector( 7 downto 0 );
            seg : std_logic_vector( 6 downto 0 );
             an : std_logic_vector( 3 downto 0 );
             dp : std_logic;
    end record basys2_io;

    signal coin_counter_io : basys2_io;
    signal ticket_chooser_io: basys2_io;
    signal ticket_counter_io: basys2_io;
    signal ticket_dispense_io: basys2_io;

    component edge_to_pulse is
        Port ( CLK : in  STD_LOGIC;
               Reset : in  STD_LOGIC;
               Edge_in : in  STD_LOGIC;
               Pulse_out : out  STD_LOGIC);
    end component;

    component coin_counter is
        port( reset : in std_logic; 
                mclk : in std_logic;
                btn : in std_logic_vector(3 downto 0);
                seg : out std_logic_vector( 6 downto 0 );
                an : out std_logic_vector( 3 downto 0 );
                dp : out std_logic;
                total_money : out std_logic_vector(15 downto 0 )
            ); 
    end component coin_counter;

    component ticket_display is
        port( reset : in std_logic; 
                mclk : in std_logic;
                btn : in std_logic_vector(3 downto 0);
                seg : out std_logic_vector( 6 downto 0 );
                an : out std_logic_vector( 3 downto 0 );
                dp : out std_logic;
                zone_choice : out std_logic_vector(1 downto 0 )
            ); 
    end component ticket_display;

    component ticket_counter is
        port( reset : in std_logic; 
                mclk : in std_logic;
                btn : in std_logic_vector(3 downto 0);
                led: out std_logic_vector(7 downto 0);
                seg : out std_logic_vector( 6 downto 0 );
                an : out std_logic_vector( 3 downto 0 );
                dp : out std_logic;
                ticket_count : out std_logic_vector(2 downto 0 )
            ); 
    end component ticket_counter;

    component ticket_dispense is
        port( reset : in std_logic; 
                mclk : in std_logic;
                zone_choice : in std_logic_vector (1 downto 0 );
                ticket_count : in unsigned (2 downto 0);

                seg : out std_logic_vector( 6 downto 0 );
                an : out std_logic_vector( 3 downto 0 );
                dp : out std_logic
            ); 
    end component ticket_dispense;

begin
    btn_3_edge_to_pulse : edge_to_pulse
        port map ( CLK => mclk,
                   Reset => reset,
                   Edge_in => btn(3),
                   Pulse_out => btn_3_pushed );

    run_coin_counter : coin_counter
        port map (
            reset => coin_counter_io.reset,
            mclk => mclk,
            btn => coin_counter_io.btn,
            seg => coin_counter_io.seg,
            an => coin_counter_io.an,
            dp => coin_counter_io.dp,
            total_money => user_total_money );

    run_ticket_chooser : ticket_display
        port map (
            reset => ticket_chooser_io.reset,
            mclk => mclk,
            btn => ticket_chooser_io.btn,
            seg => ticket_chooser_io.seg,
            an => ticket_chooser_io.an,
            dp => ticket_chooser_io.dp,
            zone_choice => user_zone_choice );

    run_ticket_counter : ticket_counter
        port map (
            reset => ticket_counter_io.reset,
            mclk => mclk,

            btn => ticket_counter_io.btn,
            seg => ticket_counter_io.seg,
            an => ticket_counter_io.an,
            dp => ticket_counter_io.dp,
            
            ticket_count => user_ticket_count );

    reset <= sw(0);

    state_proc : process( mclk, reset )
    begin
        if reset='1' then
            current_state <= STATE_START;
        elsif rising_edge(mclk) then
            current_state <= next_state;
        end if;
    end process;

    run_subway_tickets : process(mclk,reset) 
    begin
        if reset='1' then
            coin_counter_io.reset <= '1';
            ticket_chooser_io.reset <= '1';
            ticket_counter_io.reset <= '1';
            ticket_dispense_io.reset <= '1';

        elsif rising_edge(mclk) then
            case current_state is
                when STATE_START =>
                    coin_counter_io.reset <= '0';
                    ticket_chooser_io.reset <= '0';
                    ticket_counter_io.reset <= '0';
                    ticket_dispense_io.reset <= '0';
                    next_state <= STATE_ENTER_MONEY;

                when STATE_ENTER_MONEY =>
                    -- inputs
                    coin_counter_io.btn <= btn;
                    coin_counter_io.sw <= "00000000";
                    --outputs
                    led <= "00000000";
                    seg <= coin_counter_io.seg;
                    an <= coin_counter_io.an;
                    dp <= coin_counter_io.dp;

                    if btn_3_pushed='1' then
                        next_state <= STATE_CHOOSE_ZONE;
                    end if;

                when STATE_CHOOSE_ZONE =>
                    -- inputs
                    ticket_chooser_io.btn <= btn;
                    ticket_chooser_io.sw <= "00000000";
                    -- outputs
                    led <= "00000000";
                    seg <= ticket_chooser_io.seg;
                    an <= ticket_chooser_io.an;
                    dp <= ticket_chooser_io.dp;

                    if btn_3_pushed='1' then
                        next_state <= STATE_TICKET_COUNTER;
                    end if;

                when STATE_TICKET_COUNTER =>
                    -- inputs
                    ticket_counter_io.btn <= btn;
                    ticket_counter_io.sw <= "00000000";
                    --  outputs
                    led <= ticket_counter_io.led;
                    seg <= ticket_counter_io.seg;
                    an <= ticket_counter_io.an;
                    dp <= ticket_counter_io.dp;

                    if btn_3_pushed='1' then
                        next_state <= STATE_MONEY_CHECK;
                    end if;

                when STATE_MONEY_CHECK =>
                    next_state <= STATE_TICKET_DISPENSE;

                when STATE_TICKET_DISPENSE =>
                    next_state <= STATE_CHANGE_DISPENSE;

                when STATE_CHANGE_DISPENSE =>
                    
                    next_state <= STATE_RESET_0;
                    
                when STATE_RESET_0 =>
                    coin_counter_io.reset <= '1';
                    ticket_chooser_io.reset <= '1';
                    ticket_counter_io.reset <= '1';
                    ticket_dispense_io.reset <= '1';
                    next_state <= STATE_RESET_1;

                when STATE_RESET_1 =>
                    next_state <= STATE_RESET_2;

                when STATE_RESET_2 =>
                    next_state <= STATE_START;

            end case;
        end if;
    end process run_subway_tickets;

end architecture subway_tickets_arch;

