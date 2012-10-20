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
        STATE_ENTER_MONEY,
        STATE_CHOOSE_ZONE,
        STATE_TICKET_COUNTER,
        STATE_MONEY_CHECK,
        STATE_TICKET_DISPENSE,
        STATE_CHANGE_DISPENSE );

    signal current_state, next_state : state_type;

    signal user_total_money : std_logic_vector(15 downto 0);
    signal user_zone_choice : std_logic_vector(1 downto 0 );
    signal user_ticket_count : std_logic_vector (2 downto 0) := (others=>'0');

    type basys2_io is record
            mclk : std_logic;
            btn : std_logic_vector(3 downto 0);
             sw : std_logic_vector(7 downto 0);
            led : std_logic_vector( 7 downto 0 );
            seg : std_logic_vector( 6 downto 0 );
             an : std_logic_vector( 3 downto 0 );
             dp : std_logic;
    end record basys2_io;

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

end architecture subway_tickets_arch;

