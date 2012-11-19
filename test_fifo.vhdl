-- RAM read/write
-- ECE530 Fall 2012
--
-- David Poole
-- 17-Nov-2012

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use std.textio.all;
use ieee.numeric_std.all;

entity test_fifo is
end entity test_fifo;

architecture test_fifo_arch of test_fifo is
    constant fifo_depth : integer := 32;

    component fifo is
        generic ( depth : integer );
        port( clk : in std_logic;
                reset : in std_logic;
                push : in std_logic;
                write_data : in unsigned ( 7 downto 0 );

                pop : in std_logic;
                read_data : out unsigned ( 7 downto 0 );

                full : out std_logic;
                empty : out std_logic );
    end component fifo;

    signal mclk :  std_logic := '0';
    signal reset : std_logic := '1';
    signal t_push : std_logic := '0';
    signal t_pop : std_logic := '0';
    signal t_write_data : unsigned (7 downto 0 ) := (others=>'0');

    -- outputs 
    signal t_read_data : unsigned (7 downto 0 );
    signal t_full : std_logic;
    signal t_empty : std_logic;

begin
    run_fifo : fifo
        generic map(depth=>fifo_depth)
        port map ( clk=>mclk,
                    reset => reset,
                    push => t_push,
                    write_data => t_write_data,

                    pop => t_pop,
                    read_data => t_read_data,

                    full => t_full,
                    empty => t_empty );

    clock : process is
    begin
       mclk <= '0'; wait for 10 ns;
       mclk <= '1'; wait for 10 ns;
    end process clock;

    -- Watch the full flag, print a status when the flag changes
    watch_full: process(t_full)
        variable str : line;
    begin
        if t_full='1' then
            write( str, string'("fifo full at ") );
        else
            write( str, string'("fifo not full at "));
        end if;
        write( str, NOW );
        writeline( output, str );
    end process watch_full;

    -- Watch the empty flag, print a status when the flag changes
    watch_empty : process(t_empty)
        variable str : line;
    begin
        if t_empty='1' then
            write( str, string'("fifo empty at "));
        else
            write( str, string'("fifo not empty at "));
        end if;
        write( str, NOW );
        writeline( output, str );
    end process watch_empty;

    -- watch the read bus 
    watch_read : process(t_read_data) 
        variable str : line;
    begin
        write( str, string'("read_data=0x") );
        hwrite( str, std_logic_vector(t_read_data) );
        write( str, string'(" at ") );
        write( str, NOW );
        writeline( output, str );
    end process watch_read;

    stimulus : process 
        variable i : integer;
        variable str : line;
    begin
        write( str, string'("hello, world") );
        writeline( output, str );
        wait for 5 ns;

        reset <= '0';
        wait for 10 ns;

        -- Fill the FIFO
        t_push <= '1';
        for i in 0 to fifo_depth-1 loop 
            write( str, string'("i=") & integer'image(i) );
            writeline( output, str );

            t_write_data <= to_unsigned(i+10,8);
            wait for 20 ns;
        end loop;
        t_push <= '0';
        wait for 20 ns;
        assert t_full='1' severity failure;
        assert t_empty='0' severity failure;

        -- Empty the FIFO
        t_pop <= '1';
        for i in 0 to fifo_depth-1 loop 
            write( str, string'("i=") & integer'image(i) );
            write( str, string'(" read=0x") );
            hwrite( str, std_logic_vector(t_read_data) );
            writeline( output, str );

            wait for 20 ns;

--            assert t_read_data=to_unsigned(i+10,8) 
--                    report integer'image(to_integer(t_read_data))
--                    severity failure;

        end loop;
        assert t_empty='1' severity failure;
        assert t_full='0' severity failure;
        t_pop <= '0';
        wait for 20 ns;

        wait for 100 ns;

        -- push/pop with delays between
        t_push <= '1';
        t_write_data <= X"dd";
        wait for 20 ns;
        t_push <= '0';

        wait for 60 ns;
        t_pop <= '1';
        wait for 20 ns;
        t_pop <= '0';
        wait for 20 ns;

        wait for 100 ns;

        -- push/pop simultaneously
        t_push <= '1';
        t_write_data <= X"ab";
        wait for 20 ns;

        t_pop <= '1';
        t_push <= '1';
        t_write_data <= X"cd";
        wait for 20 ns;

        t_push <= '0';
        t_pop <= '0';
        wait for 20 ns;

        report "test done";  
        wait;
    end process stimulus;

end architecture test_fifo_arch;

