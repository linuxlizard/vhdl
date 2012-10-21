-- Ticket Counter. 
-- davep 20-Oct-2012

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity ticket_counter is
    port( reset : in std_logic; 
            mclk : in std_logic;
            btn : in std_logic_vector(3 downto 0);

            led: out std_logic_vector(7 downto 0);
            seg : out std_logic_vector( 6 downto 0 );
            an : out std_logic_vector( 3 downto 0 );
            dp : out std_logic;

            ticket_count : out std_logic_vector(2 downto 0 )
        ); 
end entity ticket_counter;

architecture ticket_counter_arch of ticket_counter is

    signal total_tickets_to_display : std_logic_vector(15 downto 0 ) := (others=>'0') ;

    signal btn_up_in : std_logic;
    signal btn_down_in : std_logic;

    component edge_to_pulse is
        Port ( CLK : in  STD_LOGIC;
               Reset : in  STD_LOGIC;
               Edge_in : in  STD_LOGIC;
               Pulse_out : out  STD_LOGIC);
    end component;

    component digits_to_7seg is
        -- signals in Basys2
        port( rst : in std_logic; 
                mclk : in std_logic;
                word_in : in std_logic_vector(15 downto 0 );
                seg : out std_logic_vector(6 downto 0 );
                an : out std_logic_vector(3 downto 0);
                dp : out std_logic
            ); 
    end component digits_to_7seg;

begin

    run_digits_to_7seg : digits_to_7seg 
        port map ( rst => reset,
                    mclk => mclk,
                    word_in => total_tickets_to_display,
                    seg => seg,
                    an => an,
                    dp => dp );

    increment_edge_to_pulse : edge_to_pulse
        port map ( CLK => mclk,
                   Reset => reset,
                   Edge_in => btn(0),
                   Pulse_out => btn_up_in );

    decrement_edge_to_pulse : edge_to_pulse
        port map ( CLK => mclk,
                   Reset => reset,
                   Edge_in => btn(1),
                   Pulse_out => btn_down_in );

    run_ticket_counter : process(mclk,reset) is
        variable value : unsigned(2 downto 0) := "001";
        variable str : line;
    begin
        if reset='1' then
            -- default to one
            ticket_count <= "001";
            value := "001";
            total_tickets_to_display <= X"0001";
            led <= (others=>'0');
        elsif rising_edge(mclk) then
            -- do stuff
            if btn_up_in = '1' then
                if value < 4 then
                    value := value + 1;
                    led <= X"00";
                else 
                    -- light up an error led
                    led <= X"01";
                end if;
            elsif btn_down_in = '1' then
                if value > 1 then
                    value := value - 1;
                    led <= X"00";
                else
                    led <= X"01";
                end if;
            end if;

            -- only need 3 bits
            ticket_count <= value(2) & value(1) & value(0);

            -- three bits of ticket counter converted to a 16-bit for the
            -- digits display; want the count in the rightmost digits of the
            -- display
            total_tickets_to_display <= X"000" & "0" & value(2) & value(1) & value(0);
        end if;
    end process run_ticket_counter;

end architecture ticket_counter_arch;

