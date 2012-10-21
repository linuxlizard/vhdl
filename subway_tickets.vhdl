--
-- David Poole 21-Oct-2012

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

library work;
use work.ticketzones.all;

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
        STATE_WAIT_SECONDS,
        STATE_RETURN_CHANGE,

        STATE_CANCEL,

        STATE_RESET_0,
        STATE_RESET_1,
        STATE_RESET_2
        
        );

    signal current_state, next_state : state_type := STATE_START;
    
    signal reset : std_logic := '1';
    signal cancel : std_logic := '0';

    signal btn_3_pushed : std_logic := '0';

    signal user_total_money : std_logic_vector(15 downto 0) := (others=>'0');
    signal user_zone_choice : std_logic_vector(1 downto 0 ) := (others=>'0');
    signal user_ticket_count : std_logic_vector (2 downto 0) := (others=>'0');
    signal user_change_due : std_logic_vector(15 downto 0) := (others=>'0');
    signal user_cancel : std_logic;

    signal state_debug : std_logic_vector (7 downto 0 );

    signal led_debug : std_logic_vector ( 7 downto 0 );

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
    signal display_change_io: basys2_io;

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
                cancel : in std_logic;
                zone_choice : in std_logic_vector (1 downto 0 );
                ticket_count : in std_logic_vector (2 downto 0);

                seg : out std_logic_vector( 6 downto 0 );
                an : out std_logic_vector( 3 downto 0 );
                dp : out std_logic
            ); 
    end component ticket_dispense;

    component money_to_7seg is
        port(  rst : in std_logic; 
                mclk : in std_logic;
                word_in : in std_logic_vector(15 downto 0 );
                seg : out std_logic_vector(6 downto 0 );
                an : out std_logic_vector(3 downto 0);
                dp : out std_logic
            ); 
    end component money_to_7seg;

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

            led => ticket_counter_io.led,
            seg => ticket_counter_io.seg,
            an => ticket_counter_io.an,
            dp => ticket_counter_io.dp,
            
            ticket_count => user_ticket_count );

    run_ticket_dispense : ticket_dispense
        port map (
            reset => ticket_dispense_io.reset,
            mclk => mclk,
            cancel => user_cancel,
            zone_choice => user_zone_choice,
            ticket_count => user_ticket_count,
            seg => ticket_dispense_io.seg,
            an => ticket_dispense_io.an,
            dp => ticket_dispense_io.dp);

    run_display_change : money_to_7seg 
        port map ( rst => display_change_io.reset,
                    mclk => mclk,
                    word_in => user_change_due,
                    seg => display_change_io.seg,
                    an => display_change_io.an,
                    dp => display_change_io.dp );

    reset <= sw(0);

    cancel <= sw(1);

    state_proc : process( mclk, reset )
    begin
        if reset='1' then
            current_state <= STATE_START;
        elsif rising_edge(mclk) then
            current_state <= next_state;
        end if;
    end process;

    run_subway_tickets : process(mclk,reset) 
        variable ticket_cost : unsigned(15 downto 0) := (others=>'0');
        variable required_cost : unsigned (15 downto 0) := (others=>'0');
        variable cash_entered : unsigned (15 downto 0 ) := (others=>'0');
        variable change_due : unsigned  (15 downto 0 ):= (others=>'0');
        variable timer_countdown : integer;
        variable str : line;
    begin
        if reset='1' then
            coin_counter_io.reset <= '1';
            ticket_chooser_io.reset <= '1';
            ticket_counter_io.reset <= '1';
            ticket_dispense_io.reset <= '1';
            display_change_io.reset <= '1';
            led <= "00000000";
            seg <= "0000000";
            an <= "1111";
            dp <= '1';
            user_cancel <= '0';

            ticket_cost := (others=>'0');
            required_cost := (others=>'0');
            cash_entered := (others=>'0');
            timer_countdown := 0;
            change_due := (others=>'0');

        elsif rising_edge(mclk) then
            case current_state is
                when STATE_START =>
                    state_debug <= X"00";
                    user_cancel <= '0';
                    coin_counter_io.reset <= '0';
                    ticket_chooser_io.reset <= '0';
                    ticket_counter_io.reset <= '0';
                    ticket_dispense_io.reset <= '0';
                    display_change_io.reset <= '0';

                    --- these modules don't drive the LEDs so add a load here
                    coin_counter_io.led <= X"00";
                    ticket_chooser_io.led <= X"00";
                    ticket_dispense_io.led <= X"00";
                    display_change_io.led <= X"00";
                    
                    next_state <= STATE_ENTER_MONEY;

                when STATE_ENTER_MONEY =>
                    state_debug <= X"01";
                    -- inputs
                    coin_counter_io.btn <= btn;
                    coin_counter_io.sw <= "00000000";
                    --outputs
                    led <= coin_counter_io.led;
                    seg <= coin_counter_io.seg;
                    an <= coin_counter_io.an;
                    dp <= coin_counter_io.dp;

                    if btn_3_pushed='1' then
                        next_state <= STATE_CHOOSE_ZONE;
                    end if;
                    if cancel='1' then
                        next_state <= STATE_CANCEL;
                    end if;

                when STATE_CHOOSE_ZONE =>
                    state_debug <= X"02";
                    -- inputs
                    ticket_chooser_io.btn <= btn;
                    ticket_chooser_io.sw <= "00000000";
                    -- outputs
                    led <= ticket_chooser_io.led;
                    seg <= ticket_chooser_io.seg;
                    an <= ticket_chooser_io.an;
                    dp <= ticket_chooser_io.dp;

                    if btn_3_pushed='1' then
                        next_state <= STATE_TICKET_COUNTER;
                    end if;
                    if cancel='1' then
                        next_state <= STATE_CANCEL;
                    end if;

                when STATE_TICKET_COUNTER =>
                    state_debug <= X"04";
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
                    if cancel='1' then
                        next_state <= STATE_CANCEL;
                    end if;

                when STATE_MONEY_CHECK =>
                    state_debug <= X"08";

                    if user_zone_choice=zone_a then
                        ticket_cost := X"0064"; -- 100
                    elsif user_zone_choice=zone_b then
                        ticket_cost := X"0087"; -- 135
                    elsif user_zone_choice=zone_c then
                        ticket_cost := X"00f5"; -- 245;
                    else 
                        ticket_cost := X"ffff";
                    end if;
                    required_cost := (others=>'0');

                    -- I'm caught in typecast hell so let's brute force it
                    if user_ticket_count="001" then
                        required_cost := ticket_cost;
                    elsif user_ticket_count="010" then
                        required_cost := ticket_cost+ticket_cost;
                    elsif user_ticket_count="011" then
                        required_cost := ticket_cost+ticket_cost+ticket_cost;
                    else 
                        required_cost := ticket_cost+ticket_cost+ticket_cost+ticket_cost;
                    end if;

                    cash_entered := unsigned(user_total_money);

                    if cash_entered < required_cost then
                        -- jump back to coin counter state and light up LED2
                        next_state <= STATE_ENTER_MONEY;
                        coin_counter_io.led <= "00000100";
                    else 
                        change_due := cash_entered - required_cost;
                        user_change_due <= std_logic_vector(change_due);
                        next_state <= STATE_TICKET_DISPENSE;
                        -- pragma synthesis off
                        write( str, string'("required="));
                        hwrite(str,std_logic_vector(required_cost));
                        write(str,string'(" entered="));
                        hwrite(str,std_logic_vector(cash_entered));
                        write(str,string'(" change="));
                        hwrite(str,std_logic_vector(change_due));
                        writeline(output,str);
                        -- pragma synthesis on
                    end if;

                when STATE_TICKET_DISPENSE =>
                    state_debug <= X"10";
                    led <= ticket_dispense_io.led;
                    seg <= ticket_dispense_io.seg;
                    an <= ticket_dispense_io.an;
                    dp <= ticket_dispense_io.dp;
                    timer_countdown := 125000000;
                    --pragma synthesis off
                    timer_countdown := 64;
                    --pragma synthesis on
                    next_state <= STATE_WAIT_SECONDS;

                when STATE_CANCEL =>
                    state_debug <= X"11";

                    -- setting to 1 makes the ticket_dispense display "--"
                    -- (ugly hack)
                    user_cancel <= '1';

                    -- led03 turned on 
                    ticket_dispense_io.led <= "00001000";
                    seg <= ticket_dispense_io.seg;
                    an <= ticket_dispense_io.an;
                    dp <= ticket_dispense_io.dp;
                    timer_countdown := 125000000;
                    --pragma synthesis off
                    timer_countdown := 128;
                    --pragma synthesis on
                    next_state <= STATE_WAIT_SECONDS;

                when STATE_WAIT_SECONDS =>
                    state_debug <= X"20";
                    led <= ticket_dispense_io.led;
                    seg <= ticket_dispense_io.seg;
                    an <= ticket_dispense_io.an;
                    dp <= ticket_dispense_io.dp;
                    timer_countdown := timer_countdown - 1;
                    if timer_countdown=0 then
                        next_state <= STATE_RETURN_CHANGE;
                    end if;

                when STATE_RETURN_CHANGE =>
                    state_debug <= X"40";
                    led <= display_change_io.led;
                    seg <= display_change_io.seg;
                    an <= display_change_io.an;
                    dp <= display_change_io.dp;
                    if btn_3_pushed='1' then
                        next_state <= STATE_RESET_0;
                    end if;
                    
                when STATE_RESET_0 =>
                    state_debug <= X"80";
                    coin_counter_io.reset <= '1';
                    ticket_chooser_io.reset <= '1';
                    ticket_counter_io.reset <= '1';
                    ticket_dispense_io.reset <= '1';
                    display_change_io.reset <= '1';
                    next_state <= STATE_RESET_1;

                when STATE_RESET_1 =>
                    next_state <= STATE_RESET_2;

                when STATE_RESET_2 =>
                    next_state <= STATE_START;

            end case;
        end if;
    end process run_subway_tickets;

end architecture subway_tickets_arch;

