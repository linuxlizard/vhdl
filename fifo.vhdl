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

--    signal wr_debug_count, rd_debug_count : integer;

    type mem_array is array (0 to depth-1) of unsigned(7 downto 0 );
    signal RAM : mem_array;

    signal wr_idx_sync : unsigned( numbits-1 downto 0 );
    signal rd_idx_sync : unsigned( numbits-1 downto 0 );

    signal rd_idx_1 : unsigned(numbits-1 downto 0 );
    signal rd_idx_2 : unsigned(numbits-1 downto 0 );
    signal wr_idx_1 : unsigned(numbits-1 downto 0 );
    signal wr_idx_2 : unsigned(numbits-1 downto 0 );

    signal rd_full, rd_empty, wr_full, wr_empty : std_logic;
begin
    full <= rd_full or wr_full;
    empty <= rd_empty or wr_empty;

    read_ctl : process( read_clk, reset ) is
        variable rd_idx : unsigned( numbits-1 downto 0 ) := (others=>'0');
--        variable debug_read_counter : integer := 0;
    begin
        -- synchronizer gets our read idx
        rd_idx_1 <= rd_idx;

--        rd_debug_count <= debug_read_counter;

        if( reset='1' ) then
            -- block outputs
            read_valid <= '0';
            -- internal variables
            rd_idx := (others=>'0');
--            debug_read_counter := 0;

            rd_full <= '0';
            rd_empty <= '1';
        elsif( rising_edge(read_clk) ) then
--            read_data <= RAM(to_integer(rd_idx));

            if( rd_idx/=wr_idx_sync and pop='1' ) then
                read_data <= RAM(to_integer(rd_idx));
                read_valid <= '1';
                -- modulo math will cause rd_idx to rollover
                rd_idx := rd_idx+1;
--                debug_read_counter := debug_read_counter + 1;
            else
                read_data <= X"ee";
                read_valid <= '0';
            end if;

            -- adjust full/empty signal
            if( rd_idx=wr_idx_sync+1 ) then
                rd_full <= '1';
            else
                rd_full <= '0';
            end if;
            if( rd_idx=wr_idx_sync ) then
                rd_empty <= '1';
            else
                rd_empty <= '0';
            end if;

        end if;
    end process read_ctl;

    --
    -- clock synchronizer from read domain to write domain
    --
    read_sync_1 : d_ff
        generic map(data_width => numbits)
        port map( clk=>write_clk,
                  reset => reset,
                  d => rd_idx_1,
                  q => rd_idx_2
                );
    read_sync_2 : d_ff
        generic map(data_width => numbits)
        port map( clk=>write_clk,
                  reset => reset,
                  d => rd_idx_2,
                  q => rd_idx_sync );

    --
    -- Write Controller
    --
    write_ctl : process( write_clk, reset ) is
        variable wr_idx : unsigned( numbits-1 downto 0 ) := (others=>'0');
--        variable debug_write_counter : integer := 0;
    begin
        -- synchronizer gets our write count
        wr_idx_1 <= wr_idx;

--        wr_debug_count <= debug_write_counter;

        if( reset='1' ) then
            -- block output
            -- internal variables
            wr_idx := (others=>'0');
--            debug_write_counter := 0;
            
            wr_full <= '0';
            wr_empty <= '1';
        elsif( rising_edge(write_clk) ) then

            if( wr_idx+1 /= rd_idx_sync and push='1' ) then
                RAM(to_integer(wr_idx)) <= write_data;

                -- modulo math will cause wr_idx to rollover
                wr_idx := wr_idx+1;

--                debug_write_counter := debug_write_counter + 1;
            end if;

            -- adjust full/empty signal
            if( wr_idx+1=rd_idx_sync ) then
                wr_full <= '1';
            else
                wr_full <= '0';
            end if;
            if( wr_idx=rd_idx_sync ) then
                wr_empty <= '1';
            else
                wr_empty <= '0';
            end if;

        end if;
    end process write_ctl;

    --
    -- clock synchronizer from write domain to read domain
    --
    write_sync_1 : d_ff
        generic map(data_width => numbits)
        port map( clk=>read_clk,
                  reset => reset,
                  d => wr_idx_1,
                  q => wr_idx_2 );
    write_sync_2 : d_ff
        generic map(data_width => numbits)
        port map( clk=>read_clk,
                  reset => reset,
                  d => wr_idx_2,
                  q => wr_idx_sync );

end architecture fifo_arch;

