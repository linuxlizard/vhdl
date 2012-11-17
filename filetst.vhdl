-- VHDL file I/O (and some string IO)
-- ECE 530 Fall 2012
--
-- David Poole
-- 17-Nov-2012

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use std.textio.all;
use ieee.numeric_std.all;

entity filetst is
begin
end entity filetst;

architecture filetst_arch of filetst is
begin
    run_filetst : process is
        file fin : text;
        variable s : line;
        variable str, hstr : line;
        variable op : string(1 to 4);
        variable wait_clock : string(1 to 3);
        variable wait_cycles : integer;
        variable word_count : integer;
        variable word_value : std_logic_vector(7 downto 0);
        variable num : integer;
    begin
        file_open( fin, "test.dat", READ_MODE );
        while not endfile( fin ) loop
            readline( fin, s );

            write( str, string'("str=") );
--            write( str, string(s) );
            writeline( output, str );

            write( str, string'("len=") );
            write( str, s'length );
            writeline( output, str );

            read( s, op );

            write( str, string'("op=") );
            write( str, op );
            writeline( output, str );

            if( op = "WWRD" or op = "RWRD" ) then
                report "found WWRD";

                read( s, word_count );
                hread( s, word_value );

                num := to_integer(unsigned(word_value));

                write( str, string'("op=") );
                write( str, op );
                write( str, string'(" count=") );
                write( str, word_count );
                write( str, string'(" value=") );
                write( str, word_value );
                write( str, string'(" num=") );
                write( str, num );
                writeline( output, str );

                write( hstr, word_value );
                write( str, string'("op=") & op & 
                            string'(" count=") & integer'image(word_count) & 
                            string'(" value=") & integer'image(num)
--                            integer'image(to_integer(unsigned(word_value)))
                            );
                writeline( output, str );


            elsif ( op="WAIT" ) then
                report "found WAIT";
                
                read( s, wait_clock );
                read( s, wait_cycles );

                write( str, string'("op=") );
                write( str, op );
                write( str, string'(" clock=") );
                write( str, wait_clock );
                write( str, string'(" cycles=") );
                write( str, wait_cycles);
                writeline( output, str );
            end if;
                
--            read( s, op, good );
--            if( good /= True ) then
--                report "bad string" severity failure;
--            end if;

--            writeline( output, op );
        end loop;

        file_close( fin );

        wait;
    end process run_filetst;

end architecture filetst_arch;

