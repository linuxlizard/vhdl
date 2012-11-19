-- FIFO
-- ECE530 Fall 2012
--
-- David Poole
-- 17-Nov-2012

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.numeric_std.all;

entity fifo is
    generic ( depth : integer := 32 );
    port( clk : in std_logic;
            reset : in std_logic;
            push : in std_logic;
            write_data : in unsigned ( 7 downto 0 );

            pop : in std_logic;
            read_data : out unsigned ( 7 downto 0 );

            full : out std_logic;
            empty : out std_logic );

end entity fifo;

architecture fifo_arch of fifo is
    component memory8bit is
        generic ( depth : integer );
        port ( clk : in std_logic;
                write_enable : in std_logic;
                write_addr : in unsigned(7 downto 0 );
                read_addr : in unsigned(7 downto 0 );
                data_in : in unsigned( 7 downto 0 );
                data_out : out unsigned( 7 downto 0 )
             );
    end component memory8bit;

    signal write_en : std_logic := '0';
    signal ram_write_addr : unsigned(7 downto 0 ) := (others=>'0');
    signal ram_read_addr : unsigned(7 downto 0 ) := (others=>'0');

    signal debug_count : integer;

begin
    fifomem : memory8bit
        generic map( depth => depth )
        port map ( clk => clk,
                   write_enable => write_en,
                   write_addr => ram_write_addr,
                   data_in => write_data ,

                   read_addr => ram_read_addr,
                   data_out => read_data 
                );

    run_fifo : process(reset,clk) is
        variable count : integer;
        variable wr_idx : integer;
        variable rd_idx : integer;

        variable str : line;

        constant max_idx : integer := depth-1;
    begin
        if( reset='1' ) then
            write_en <= '0';
            ram_write_addr <= (others=>'0');
            ram_read_addr <= (others=>'0');
            full <= '0';
            empty <= '1';

            count := 0;
            wr_idx := 0;
            rd_idx := 0;
        elsif( rising_edge(clk) ) then
            write_en <= '0';
            full <= '0';
            empty <= '0';
            debug_count <= count;
            
            if( push='1' ) then
                if( count < depth ) then
                    write( str, string'("count=") & integer'image(count));
                    write( str, string'(" depth=") & integer'image(depth));
                    writeline(output,str);

                    ram_write_addr <= to_unsigned(wr_idx,8);
                    write_en <= '1';

                    count := count + 1;
                    if( wr_idx < max_idx ) then
                        wr_idx := wr_idx + 1;
                    else 
                        wr_idx := 0;
                    end if;
                end if;

                write( str, string'("count=") & integer'image(count));
                write( str, string'(" depth=") & integer'image(depth));
                writeline(output,str);
            end if; -- push='1'

            if( pop='1' ) then
                if( count > 0 ) then
                    write( str, string'("count=") & integer'image(count));
                    writeline(output,str);

                    ram_read_addr <= to_unsigned(rd_idx,8);

                    count := count - 1;

                    -- rd_idx := (rd_idx+1) % depth
                    if( rd_idx < max_idx ) then
                        rd_idx := rd_idx + 1;
                    else 
                        rd_idx := 0;
                    end if;
                end if; -- count > 0 
            end if; -- pop='1'

            if( count = depth ) then
                full <= '1';
            end if;
            if( count = 0) then
                empty <= '1';
            end if;

        end if; -- rising_edge(clk)

    end process run_fifo;

end architecture fifo_arch;

