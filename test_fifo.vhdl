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
    constant fifo_depth : integer := 16;
    constant fifo_num_bits : integer := 4; -- 2**fifo_num_bits = fifo_depth
--    constant half_period : time := 5 ns;

--    constant write_clk_period : time := 14 ns;
--    constant read_clk_period : time := 10 ns;
    constant write_clk_period : time := 10 ns;
    constant read_clk_period : time := 14 ns;

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

    signal mclk :  std_logic := '0';
    signal reset : std_logic := '1';
    signal t_push : std_logic := '0';
    signal t_pop : std_logic := '0';
    signal t_write_data : unsigned (7 downto 0 ) := (others=>'0');

    -- outputs 
    signal t_read_data : unsigned (7 downto 0 );
    signal t_read_valid : std_logic;
    signal t_full : std_logic;
    signal t_empty : std_logic;

    signal write_clk : std_logic := '0';
    signal read_clk : std_logic := '0';

    -- debugging
    signal test_num : integer := 0;
    signal t_write_counter : integer;
begin
    clock1 : process is
    begin
       write_clk <= '0'; wait for write_clk_period/2;
       write_clk <= '1'; wait for write_clk_period/2;
    end process clock1;

    clock2 : process is
    begin
       read_clk <= '0'; wait for read_clk_period/2;
       read_clk <= '1'; wait for read_clk_period/2;
    end process clock2;

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

--    clock : process is
--    begin
--       mclk <= '0'; wait for 10 ns;
--       mclk <= '1'; wait for 10 ns;
--    end process clock;

--    mclk <= write_clk;

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
        variable write_counter : integer := 0;
    begin
        write( str, string'("hello, world") );
        writeline( output, str );
        wait for write_clk_period;

        reset <= '0';
        wait for write_clk_period;

        assert t_full='0' severity failure;
        assert t_empty='1' severity failure;

        -- Fill the FIFO
        test_num <= 1;
        t_push <= '1';
        for i in 0 to fifo_depth-2 loop 
            write( str, string'("i=") & integer'image(i) );
            writeline( output, str );

            t_write_data <= to_unsigned(i+10,8);
            write_counter := write_counter + 1;
            t_write_counter <= write_counter;
            wait for write_clk_period;

            assert t_read_valid='0' severity failure;

--            assert t_full='0' severity failure;
--            assert t_empty='0' severity failure;
        end loop;
        t_push <= '0';
        wait for write_clk_period; 
        assert t_full='1' severity failure;
        assert t_empty='0' severity failure;
        assert t_read_valid='0' severity failure;
        wait for write_clk_period * 10; 

        -- Empty the FIFO (change the test stimulous to the 2nd clock)
        write( str, string'("starting to read from FIFO"));
        writeline(output,str);
        test_num <= 2;
        wait until read_clk='0';
        t_pop <= '1';
        wait until t_read_valid='1';
        for i in 0 to fifo_depth-2 loop 
            write( str, string'("i=") & integer'image(i) );
            write( str, string'(" read=0x") );
            hwrite( str, std_logic_vector(t_read_data) );
            writeline( output, str );

            wait for read_clk_period;
            assert t_read_data=to_unsigned(i+10,8) 
                    report integer'image(to_integer(t_read_data))
                    severity failure;
        end loop;

        assert t_empty='1' severity failure;
        assert t_full='0' severity failure;
        t_pop <= '0';
        wait for write_clk_period;
        assert t_read_valid='0' severity failure;

        wait for write_clk_period*10;

        -- push/pop with delays between
        test_num <= 3;
        t_push <= '1';
        t_write_data <= X"dd";
        wait for write_clk_period;
        t_push <= '0';
        wait for write_clk_period*3;
        t_pop <= '1';
--        wait for write_clk_period;
        wait until t_read_valid='1';

        t_pop <= '0';
        wait for write_clk_period;

        wait for write_clk_period*10;

        -- push/pop simultaneously
        -- first load the queue with a few elements so we have something to pop
        -- while we're pushing
        -- XXX the full/empty is currently delayed while the indexes clock
        -- between read/write sides
        test_num <= 4;
        t_push <= '1';
        t_write_data <= X"ab";
        wait for write_clk_period;
        t_push <= '0';
        wait until t_empty='0';
        wait until read_clk='0' and write_clk='0';

        -- The Big Enchilada! Simultaneous read/write
        test_num <= 5;
        t_pop <= '1';
        t_push <= '1';
        t_write_data <= X"cd";
        -- give system time to respond
        wait for write_clk_period;
        t_push <= '0';
        -- wait for falling edge of the read clock
        wait until read_clk='0';
        t_pop <= '0';

        assert t_read_valid='1' severity failure;
        assert t_read_data=X"ab"
                report integer'image(to_integer(t_read_data))
                severity failure;

        t_push <= '0';
        t_pop <= '0';
        wait for write_clk_period;

        wait until t_empty='0';

        -- pop the final value
        wait until read_clk='0';
        test_num <= 6;
        t_pop <= '1';
        wait for read_clk_period;
        t_pop <= '0';
--        wait for write_clk_period;
        -- wait for data
--        wait until t_read_valid='1';
        assert t_read_valid='1' 
                report string'("bad read valid flag")
                severity failure;
        assert t_read_data=X"cd"
                report integer'image(to_integer(t_read_data))
                severity failure;
        assert t_empty='1' severity failure;
        wait for write_clk_period;

        test_num <= 4242;

        report "test done";  
        wait;
    end process stimulus;

end architecture test_fifo_arch;

