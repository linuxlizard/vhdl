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
        STATE_WAIT_3_SECONDS,
        STATE_RETURN_CHANGE,

        STATE_RESET_0,
        STATE_RESET_1,
        STATE_RESET_2
        
        );

    signal current_state, next_state : state_type := STATE_START;
    
    signal reset : std_logic := '1';

    signal btn_3_pushed : std_logic := '0';

    signal user_total_money : std_logic_vector(15 downto 0) := (others=>'0');
    signal user_zone_choice : std_logic_vector(1 downto 0 ) := (others=>'0');
    signal user_ticket_count : std_logic_vector (2 downto 0) := (others=>'0');
    signal user_change_due : std_logic_vector(15 downto 0) := (others=>'0');

    signal state_debug : std_logic_vector (7 downto 0 );

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

    function integer_to_vector( in_num : in integer ) return std_logic_vector is
        variable i : integer;
        variable num : integer;
        variable str : line;
        variable vec : std_logic_vector (15 downto 0 );
        variable tmp : integer;
        variable tmp2 : integer;
    begin
        num := in_num;
        vec := X"0000";
        for i in 0 to 15 loop
            write( str, string'("i="));
            write( str, i );
            writeline(output,str);

            -- no logical operations on integers so we'll do it the hard way
            -- because we need to test if LSb is '1' or '0'
            tmp := num / 2;
            tmp2 := tmp * 2;

            write( str, tmp );
            write( str, string'(" ") );
            write( str, tmp2 );
            writeline(output,str);

            if num /= tmp2 then
                vec(i) := '1';
            end if;

            -- can't figure out how to shift an integer so we'll do it the 
            -- hard way
            num := num / 2;
        end loop;
        return vec;
    end;

    function vector_to_integer( vec : in std_logic_vector ) return integer is
        variable i : integer;
        variable sum : integer;
        variable adder : integer;
        variable str : line;
    begin
--        write( str, string'("len="));
--        write( str, vec'length );
--        writeline( output, str );

        sum := 0;
        adder := 1;
        for i in 1 to (vec'length) loop
--            write( str, string'("i="));
--            write( str, i );
--            writeline(output,str);

            if vec(i-1)='1' then
                sum := sum + adder;
            end if;
            -- can't figure out how to shift an integer so we'll do it the 
            -- hard way
            adder := adder * 2;
        end loop;
        return sum;
    end;

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

    state_proc : process( mclk, reset )
    begin
        if reset='1' then
            current_state <= STATE_START;
        elsif rising_edge(mclk) then
            current_state <= next_state;
        end if;
    end process;

    run_subway_tickets : process(mclk,reset) 
        variable ticket_cost : integer := 0;
        variable required_cost : integer := 0;
        variable cash_entered : integer := 0;
        variable timer_countdown : integer := 0;
        variable change_due : integer := 0;
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

            ticket_cost := 0;
            required_cost := 0;
            cash_entered := 0;
            timer_countdown := 0;
            change_due := 0;

        elsif rising_edge(mclk) then
            case current_state is
                when STATE_START =>
                    state_debug <= X"00";
                    coin_counter_io.reset <= '0';
                    ticket_chooser_io.reset <= '0';
                    ticket_counter_io.reset <= '0';
                    ticket_dispense_io.reset <= '0';
                    display_change_io.reset <= '0';
                    led <= "00000000";
                    next_state <= STATE_ENTER_MONEY;

                when STATE_ENTER_MONEY =>
                    state_debug <= X"01";
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
                    state_debug <= X"02";
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

                when STATE_MONEY_CHECK =>
                    state_debug <= X"08";

                    if user_zone_choice=zone_a then
                        ticket_cost := 100;
                    elsif user_zone_choice=zone_b then
                        ticket_cost := 135;
                    elsif user_zone_choice=zone_c then
                        ticket_cost := 245;
                    else 
                        ticket_cost := 999;
                    end if;
                    required_cost := 0;

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

                    cash_entered := vector_to_integer( user_total_money );

                    if cash_entered < required_cost then
                        next_state <= STATE_ENTER_MONEY;
                        led <= "00000010";
                    else 
                        change_due := cash_entered - required_cost;
                        user_change_due <= integer_to_vector(change_due);
                        next_state <= STATE_TICKET_DISPENSE;
                        write( str, string'("required="));
                        write(str,required_cost);
                        write(str,string'(" entered="));
                        write(str,cash_entered);
                        write(str,string'(" change="));
                        write(str,change_due);
                        writeline(output,str);
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
                    next_state <= STATE_WAIT_3_SECONDS;

                when STATE_WAIT_3_SECONDS =>
                    state_debug <= X"20";
                    timer_countdown := timer_countdown - 1;
                    if timer_countdown=0 then
                        next_state <= STATE_RETURN_CHANGE;
                    end if;

                when STATE_RETURN_CHANGE =>
                    state_debug <= X"40";
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

