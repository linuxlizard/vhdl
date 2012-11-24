-- FIFO
-- ECE530 Fall 2012
--
-- David Poole
-- 17-Nov-2012
--
-- davep 20-Nov-2012 ; had the ram as a separate component but couldn't get the
--                      timing correct. The write would be delayed by one clock
--                      and I'd lose the first push.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.numeric_std.all;

entity fifo is
    -- depth is number of entries in the queue
    -- numbits is the number of bits in the index (2**numbits==numbits)
    generic ( depth : integer := 32;
              numbits : integer := 5 );
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

end entity fifo;

architecture fifo_arch of fifo is

    component d_ff is
        generic( data_width : integer := 8 );
        port (clk : in std_logic;
                reset : in std_logic;
                d : in unsigned(data_width-1 downto 0);
                q : out unsigned(data_width-1 downto 0) );
    end component d_ff;

    signal debug_count : integer;

    type mem_array is array (0 to depth-1) of unsigned(7 downto 0 );
    signal RAM : mem_array;

    signal wr_count_sync : unsigned( numbits-1 downto 0 );
    signal rd_count_sync : unsigned( numbits-1 downto 0 );

    signal rd_count_1 : unsigned(numbits-1 downto 0 );
    signal rd_count_2 : unsigned(numbits-1 downto 0 );
    signal wr_count_1 : unsigned(numbits-1 downto 0 );
    signal wr_count_2 : unsigned(numbits-1 downto 0 );
begin

    read_ctl : process( read_clk, reset ) is
        variable rd_count : unsigned( numbits-1 downto 0 ) := (others=>'0');
        variable rd_idx : integer := 0;
    begin
        -- synchronizer gets our read count
        rd_count_1 <= rd_count;

        if( reset='1' ) then
            rd_count := (others=>'0');
            rd_idx := 0;
            read_valid <= '0';
        elsif( rising_edge(read_clk)) then

            if( rd_count > 0 and pop='1' ) then
                read_valid <= '1';
                rd_count := rd_count-1;
                -- modulo math will cause rd_idx to rollover
                rd_idx := rd_idx+1;
            else
                read_valid <= '0';
            end if;

            read_data <= RAM(rd_idx);

            -- adjust my count by the synchronized write value
            rd_count := rd_count + wr_count_sync;

        end if;
    end process read_ctl;

    --
    -- clock synchronizer from read domain to write domain
    --
    read_sync_1 : d_ff
        generic map(data_width => numbits)
        port map( clk=>read_clk,
                  reset => reset,
                  d => rd_count_1,
                  q => rd_count_2
                );
    read_sync_2 : d_ff
        generic map(data_width => numbits)
        port map( clk=>read_clk,
                  reset => reset,
                  d => rd_count_2,
                  q => rd_count_sync );

    --
    -- Write Controller
    --
    write_ctl : process( write_clk, reset ) is
        variable wr_count : unsigned( numbits-1 downto 0 ) := (others=>'0');
        variable wr_idx : integer := 0;
    begin
        -- synchronizer gets our write count
        wr_count_1 <= wr_count;

        if( reset='1' ) then
            wr_count := (others=>'0');
            wr_idx := 0;
        elsif( rising_edge(write_clk)) then

            if( wr_count < depth and push='1' ) then
                RAM(wr_idx) <= write_data;
                wr_count := wr_count+1;
                -- modulo math will cause wr_idx to rollover
                wr_idx := wr_idx+1;
            end if;

            -- adjust my count by the synchronized write value
            wr_count := wr_count - rd_count_sync;

        end if;
    end process write_ctl;

    --
    -- clock synchronizer from write domain to read domain
    --
    write_sync_1 : d_ff
        generic map(data_width => 8)
        port map( clk=>write_clk,
                  reset => reset,
                  d => wr_count_1,
                  q => wr_count_2 );
    write_sync_2 : d_ff
        generic map(data_width => 8)
        port map( clk=>write_clk,
                  reset => reset,
                  d => wr_count_2,
                  q => wr_count_sync );


--    run_fifo : process(reset,clk) is
--        variable count : integer;
--        variable wr_idx : integer;
--        variable rd_idx : integer;
--
--        variable str : line;
--
--        constant max_idx : integer := depth-1;
--    begin
--        if( reset='1' ) then
--            full <= '0';
--            empty <= '1';
--
--            count := 0;
--            wr_idx := 0;
--            rd_idx := 0;
--        elsif( rising_edge(clk) ) then
--            full <= '0';
--            empty <= '0';
--            debug_count <= count;
--            
--            if( push='1' ) then
--                if( count < depth ) then
--                    write( str, string'("count=") & integer'image(count));
--                    write( str, string'(" depth=") & integer'image(depth));
--                    writeline(output,str);
--
----                    ram_write_addr <= to_unsigned(wr_idx,8);
----                    write_en <= '1';
----
----                    if( write_enable = '1' ) then
--                    RAM(to_integer(to_unsigned(wr_idx,8))) <= write_data;
----                    end if;
----                    data_out <= RAM(to_integer(read_addr));
--
--                    count := count + 1;
--                    if( wr_idx < max_idx ) then
--                        wr_idx := wr_idx + 1;
--                    else 
--                        wr_idx := 0;
--                    end if;
--                end if;
--
--                write( str, string'("count=") & integer'image(count));
--                write( str, string'(" depth=") & integer'image(depth));
--                writeline(output,str);
--            end if; -- push='1'
--
--            if( pop='1' ) then
--                if( count > 0 ) then
--                    write( str, string'("count=") & integer'image(count));
--                    writeline(output,str);
--
----                    ram_read_addr <= to_unsigned(rd_idx,8);
--                    read_data <= RAM(to_integer(to_unsigned(rd_idx,8)));
--
--                    count := count - 1;
--
--                    -- rd_idx := (rd_idx+1) % depth
--                    if( rd_idx < max_idx ) then
--                        rd_idx := rd_idx + 1;
--                    else 
--                        rd_idx := 0;
--                    end if;
--                end if; -- count > 0 
--            end if; -- pop='1'
--
--            if( count = depth ) then
--                full <= '1';
--            end if;
--            if( count = 0) then
--                empty <= '1';
--            end if;
--
--        end if; -- rising_edge(clk)
--
--    end process run_fifo;

end architecture fifo_arch;

