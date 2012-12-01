-- Test FIFO with file input 
-- ECE 530 Fall 2012
--
-- David Poole 20-Nov-2012
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use std.textio.all;
use ieee.numeric_std.all;

entity fifo_file is
begin
end entity fifo_file;

architecture fifo_file_arch of fifo_file is
    constant infilename : string := "test.dat";
    constant outfilename : string := "result.dat";

    constant fifo_depth : integer := 32;
    constant fifo_num_bits : integer := 5; -- 2**fifo_num_bits = fifo_depth

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

    procedure data_write( 
                    fout : inout text;
                    clock_type : in string;
                    data_wr : in string;
                    data_rd : in string;
                    empty_flag : in std_logic;
                    full_flag : in std_logic) is
        variable str : line;
    begin
        write( str, clock_type );
        write( str, data_wr, field => 12 );
        write( str, data_rd, field => 12 );
        write( str, empty_flag, field => 12 );
        write( str, full_flag, field => 12 );
        writeline( fout, str );
    end;

    signal reset : std_logic := '1';
    signal write_clk : std_logic := '0';
    signal read_clk : std_logic := '0';

    -- fifo data signals
    signal t_push : std_logic := '0';
    signal t_pop : std_logic := '0';
    signal t_write_data : unsigned (7 downto 0 ) := (others=>'0');

    -- fifo outputs 
    signal t_read_data : unsigned (7 downto 0 );
    signal t_read_valid : std_logic;
    signal t_full : std_logic;
    signal t_empty : std_logic;

    -- debugging
    signal test_file_line_number : integer := 0;

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
        port map ( write_clk=>write_clk,
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

    file_writer : process is
        file fout : text;
        variable str : line;
        variable empty_str, full_str : line;
    begin
        file_open( fout, outfilename, WRITE_MODE );
        write( str, string'("Clock Type   Data Wr    Data_rd    Empty_Flag    Full_Flag") );
        writeline( fout, str );

        wait until reset='0';

        loop 
            wait until read_clk='1' or write_clk='1';

            if( read_clk='1' and t_read_valid='1' ) then
                data_write( fout, string'("rr"),
                            -- leave the write field blank
                            string'("--"),
                            integer'image(to_integer(t_read_data)),
                            t_empty,
                            t_full  );
            end if;
            if( write_clk='1' and t_push='1' ) then
                data_write( fout, string'("ww"),
                            integer'image(to_integer(t_write_data)),
                            -- leave the read field blank
                            string'("--"),
                            t_empty,
                            t_full  );
            end if;

        end loop;

        file_close( fout );
    end process file_writer;

    run_filetst : process is
        file fin : text;
        variable s : line;
        variable str, hstr : line;
        variable op : string(1 to 4);
        variable wait_clock : string(1 to 3);
        variable wait_cycles : integer;
        variable word_count : integer;
        variable word_value : std_logic_vector(7 downto 0);
        variable i, line_number : integer;
    begin
        wait for write_clk_period*3;
        reset <= '0';

        line_number := 0;
        file_open( fin, infilename, READ_MODE );

        while not endfile( fin ) loop
            readline( fin, s );

            line_number := line_number + 1;
            test_file_line_number <= line_number;

            read( s, op );

            if( op = "WWRD" or op = "RWRD" ) then
                report "found WWRD";

                read( s, word_count );
                hread( s, word_value );

                if( op="WWRD" ) then
                    wait until write_clk='0';
                    t_push <= '1';
                    t_write_data <= unsigned(word_value);
                    for i in 0 to word_count-1 loop
                        wait until write_clk='0';
                    end loop;
                    t_push <= '0';
                else 
                    wait until read_clk='0';
                    t_pop <= '1';
                    for i in 0 to word_count-1 loop
                        wait until read_clk='0';

                        assert t_read_valid='1' severity failure;
                        assert t_read_data=unsigned(word_value)
                                report integer'image(to_integer(t_read_data))
                                severity failure;
                    end loop;
                    t_pop <= '0';

                end if;

            elsif ( op="WAIT" ) then
                report "found WAIT";
                
                read( s, wait_clock );
                read( s, wait_cycles );

                -- FIXME I'm getting " rr" and " ww" (note extra spaces)
                -- because the file read is getting the strings slightly off
                if wait_clock=" rr" then
                    -- wait on the read clock
                    wait until read_clk='0';
                    for i in 0 to wait_cycles-1 loop
                        wait until read_clk='0';
                    end loop;
                elsif wait_clock=" ww" then
                    -- wait on the the write clock 
                    wait until write_clk='0';
                    for i in 0 to wait_cycles-1 loop
                        wait until write_clk='0';
                    end loop;
                else
                    assert 1=0 
                        report "bad wait clock """ & wait_clock & """"
                        severity failure;
                end if;

            else 
                assert 1=0 
                    report "bad op " & op
                    severity failure;
            end if;

        end loop;

        file_close( fin );

        report "test done";  
        wait;
    end process run_filetst;

    
end architecture fifo_file_arch;

