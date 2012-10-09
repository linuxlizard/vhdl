-- David Poole 13-Sep-2012
-- Testbench. Based on code from the textbook.
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;
use std.textio.all;

library work;
use work.opcodes.all;

entity test_alu is
end test_alu;

architecture test_alu_arch of test_alu is
    component alu 
        port( W_Reg : in std_logic_vector(7 downto 0);
            F_Reg : in std_logic_vector(7 downto 0);
            Op_Code : in std_logic_vector(4 downto 0);
            Rslt : out std_logic_vector(7 downto 0);
            Dst : out std_logic;
            C_Flag : out std_logic;
            Z_Flag : out std_logic;
            V_Flag : out std_logic );
    end component alu;

--    component d_register is
--        generic (width : integer);
--        port (clk : in std_logic;
--              reset : in std_logic;
--              input_enable : in std_logic;
--              output_enable : in std_logic;
--              data_in : in std_logic_vector( width-1 downto 0 );
--              data_out : out std_logic_vector( width-1 downto 0 )
--        );
--    end component d_register;

    signal t_clk : std_logic := '0';   
    signal reset : std_logic := '1';
    signal t_opcode : std_logic_vector(4 downto 0);

--  signal t_wreg_in : std_logic_vector(7 downto 0 );
--  signal t_freg_in : std_logic_vector(7 downto 0 );
    signal t_wreg_in : std_logic_vector(7 downto 0 );
    signal t_freg_in : std_logic_vector(7 downto 0 );
--    signal t_freg_input_enable : std_logic := '0';
--    signal t_freg_output_enable : std_logic := '0';
--    signal t_wreg_input_enable : std_logic := '0';
--    signal t_wreg_output_enable : std_logic := '0';
--    signal t_wreg_out : std_logic_vector(7 downto 0 );
--    signal t_freg_out : std_logic_vector(7 downto 0 );

    signal t_result : std_logic_vector(7 downto 0 );

    signal t_dst : std_logic;
    signal t_cflag : std_logic;
    signal t_zflag : std_logic;
    signal t_vflag : std_logic;
--  signal t_ready_in : std_logic := '0';
  
    procedure dbgdump( opcode : std_logic_vector(4 downto 0);
                       wreg : std_logic_vector(7 downto 0);
                       freg : std_logic_vector(7 downto 0);
                       result : std_logic_vector(7 downto 0);
                        D : std_logic;
                        C : std_logic;
                        Z : std_logic;
                        V : std_logic ) is
        variable str : line;
    begin
        write( str, string'("op=") );
        write( str, opcode );
        write( str, string'(" wreg=") );
        hwrite( str, wreg);
        write( str, string'(" freg=") );
        hwrite( str, freg);
        write( str, string'(" result=") );
        hwrite( str, result );
        write( str, string'(" D=") );
        write( str, D );
        write( str, string'(" C=") );
        write( str, C );
        write( str, string'(" Z=") );
        write( str, Z );
        write( str, string'(" V=") );
        write( str, V );
        writeline( output, str );
    end procedure dbgdump;

    procedure assertflags( flags : std_logic_vector(3 downto 0);
                        D : std_logic;
                        C : std_logic;
                        Z : std_logic;
                        V : std_logic ) is

    begin
        assert D=flags(3) report "D flag mismatch" severity FAILURE;
        assert C=flags(2) report "C flag mismatch" severity FAILURE;
        assert Z=flags(1) report "Z flag mismatch" severity FAILURE;
        assert V=flags(0) report "V flag mismatch" severity FAILURE;
    end;

begin
      
    run_alu : alu 
        port map( t_wreg_in,
                  t_freg_in,
                  t_opcode,
                  t_result,
                  t_dst, t_cflag, t_zflag, t_vflag );

--    F_Register : d_register 
--       generic map( width => 8)
--        port map( 
--                clk => t_clk, 
--                reset => reset, 
--                input_enable => t_freg_input_enable,
--                output_enable => t_freg_output_enable,
--                data_in => t_freg_in, 
--                data_out => t_freg_out );
--
--    W_Register : d_register 
--       generic map( width => 8)
--        port map( 
--                clk => t_clk, 
--                reset => reset, 
--                input_enable => t_wreg_input_enable,
--                output_enable => t_wreg_output_enable,
--                data_in => t_wreg_in, 
--                data_out => t_wreg_out );

    clock : process is
    begin
       t_clk <= '0'; wait for 10 ns;
       t_clk <= '1'; wait for 10 ns;
    end process clock;
                            
    stimulus: process 
        variable str : line;
    
    begin
        write( output, string'("hello, world") );
    --      wait for 100 ns;
        reset <= '1';
    --    t_freg_in <= "00000000";
    --    t_wreg_in <= "00000000";
        t_opcode <= "00000";

        t_freg_in <= "00000000";
        t_wreg_in <= "00000000";    
        wait for 15 ns;

        reset <= '0';
        t_freg_in <= "00000001";
        t_wreg_in <= "00000010";
        wait for 10 ns;
       
        t_opcode <= CLR;
        wait for 10 ns;
           
        ---
        --- NOP Test
        ---
    --    t_opcode <= NOP;
    --    wait for 10 ns;
    --    wait for 10 ns;
       
        --- 
        --- Addition Tests
        ---
        report "addwf";
        t_wreg_in <= "00000101";  --  5
        t_freg_in <= "00000011";  -- +3
        t_opcode <= ADDWF;
        wait for 10 ns;
        dbgdump( t_opcode, t_wreg_in, t_freg_in, t_result, t_dst, t_cflag, t_zflag, t_vflag );
        assertflags("1000",t_dst,t_cflag,t_zflag,t_vflag);
        assert t_result="00001000" report "5+3 failed" severity FAILURE;

        -- add 1 to 1. Result should be two an no flags set. 
        t_wreg_in <= "00000001";
        t_freg_in <= "00000001";
        t_opcode <= ADDWF;
        wait for 10 ns;
        dbgdump( t_opcode, t_wreg_in, t_freg_in, t_result, t_dst, t_cflag, t_zflag, t_vflag );
        assertflags("1000",t_dst,t_cflag,t_zflag,t_vflag);
        assert t_result="00000010" report "1+1 failed";
    
        -- add 0 to 0. Result should be zero and Z_flag set;
        t_wreg_in <= "00000000";
        t_freg_in <= "00000000";
        t_opcode <= ADDWF;
        wait for 10 ns;
        assertflags("1010",t_dst,t_cflag,t_zflag,t_vflag);
        dbgdump( t_opcode, t_wreg_in, t_freg_in, t_result, t_dst, t_cflag, t_zflag, t_vflag );
        assert t_result="00000000" report "0+0 failed" severity FAILURE;
       
        t_opcode <= CLR;
        wait for 10 ns;
        dbgdump( t_opcode, t_wreg_in, t_freg_in, t_result, t_dst, t_cflag, t_zflag, t_vflag );

        report "addwf trigger error (carry when carry already set)";
        t_wreg_in <= "10011111";
        t_freg_in <= "01111111";
        t_opcode <= ADDWF;
        wait for 10 ns;
        dbgdump( t_opcode, t_wreg_in, t_freg_in, t_result, t_dst, t_cflag, t_zflag, t_vflag );
        assertflags("1100",t_dst,t_cflag,t_zflag,t_vflag);
        assert t_result="00011110" report "0x9f+0x7f failed" severity FAILURE;

        report "addwf trigger error (wherefore art though V_Flag?)";
        t_wreg_in <= "11111111";
        t_freg_in <= "00001111";
        t_opcode <= ADDWF;
        wait for 10 ns;
        dbgdump( t_opcode, t_wreg_in, t_freg_in, t_result, t_dst, t_cflag, t_zflag, t_vflag );
        assertflags("1100",t_dst,t_cflag,t_zflag,t_vflag);
--        assertflags("1101",t_dst,t_cflag,t_zflag,t_vflag);
--        assert t_result="00011110" report "0x9f+0x7f failed" severity FAILURE;

        t_opcode <= CLR;
        wait for 10 ns;
        dbgdump( t_opcode, t_wreg_in, t_freg_in, t_result, t_dst, t_cflag, t_zflag, t_vflag );
        assertflags("0000",t_dst,t_cflag,t_zflag,t_vflag);

        report "addwf";
        t_wreg_in <= "10000000";
        t_freg_in <= "10000000";
        t_opcode <= ADDWF;
        wait for 10 ns;
        dbgdump( t_opcode, t_wreg_in, t_freg_in, t_result, t_dst, t_cflag, t_zflag, t_vflag );
        assert t_vflag='0';
        assertflags("1110",t_dst,t_cflag,t_zflag,t_vflag);
        assert t_result="00000000" report "128+128 failed" severity FAILURE;

        t_opcode <= CLR;
        wait for 10 ns;
        dbgdump( t_opcode, t_wreg_in, t_freg_in, t_result, t_dst, t_cflag, t_zflag, t_vflag );

        --
        -- Subtraction Tests
        --
        report "subwf";
        t_freg_in <= "00000101"; --  5
        t_wreg_in <= "00000011"; -- -3
        t_opcode <= SUBWF;
        wait for 10 ns;
        dbgdump( t_opcode, t_wreg_in, t_freg_in, t_result, t_dst, t_cflag, t_zflag, t_vflag );
        assertflags("1000",t_dst,t_cflag,t_zflag,t_vflag);
        assert t_result="00000010" report "5-3 failed" severity FAILURE;
     
        report "subwf";
        t_freg_in <= "00000011"; --  3
        t_wreg_in <= "00000101"; -- -5
        t_opcode <= SUBWF;
        wait for 10 ns;
        dbgdump( t_opcode, t_wreg_in, t_freg_in, t_result, t_dst, t_cflag, t_zflag, t_vflag );
        assertflags("1000",t_dst,t_cflag,t_zflag,t_vflag);
        assert t_result="11111110" report "5-3 failed" severity FAILURE;

        report "subwf";
        t_freg_in <= "01111111";
        t_wreg_in <= "01111100";
        t_opcode <= SUBWF;
        wait for 10 ns;
        dbgdump( t_opcode, t_wreg_in, t_freg_in, t_result, t_dst, t_cflag, t_zflag, t_vflag );
        assertflags("1000",t_dst,t_cflag,t_zflag,t_vflag);
        assert t_result="00000011" report "0x7f-0x7c failed"severity FAILURE;
    
        report "subwf";
        t_freg_in <= "00000000";
        t_wreg_in <= "00000000";
        t_opcode <= SUBWF;
        wait for 10 ns;
        dbgdump( t_opcode, t_wreg_in, t_freg_in, t_result, t_dst, t_cflag, t_zflag, t_vflag );
        assertflags("1010",t_dst,t_cflag,t_zflag,t_vflag);
        assert t_result="00000000" report "0-0 failed"severity FAILURE;  
    
        report "subwf";
        t_freg_in <= "11111111";
        t_wreg_in <= "11111111";
        t_opcode <= SUBWF;
        wait for 10 ns;
        dbgdump( t_opcode, t_wreg_in, t_freg_in, t_result, t_dst, t_cflag, t_zflag, t_vflag );
        assertflags("1010",t_dst,t_cflag,t_zflag,t_vflag);
        assert t_result="00000000" report "-1--1 failed" severity FAILURE;     

        t_opcode <= CLR;
        wait for 10 ns;
        dbgdump( t_opcode, t_wreg_in, t_freg_in, t_result, t_dst, t_cflag, t_zflag, t_vflag );

        -- 
        -- Swap Tests
        --
        -- swap 11110000 to 00001111 then back to 11110000
--        write( str, string'("result=") );
--        write( str, run( SWAPF, "00110000", "00000000" ) );
--        writeline( output, str );
         
        t_freg_in <= "11110000";
        t_opcode <= SWAPF;
        wait for 20 ns;
        dbgdump( t_opcode, t_wreg_in, t_freg_in, t_result, t_dst, t_cflag, t_zflag, t_vflag );
        assert t_result="00001111" report "swapf failed" severity FAILURE;

        --
        -- PAS[FW] Tests
        --      
        report "pasw";
        t_wreg_in <= "00000001";
        t_freg_in <= "10000000";
        t_opcode <= PASW;
        wait for 20 ns;
        dbgdump( t_opcode, t_wreg_in, t_freg_in, t_result, t_dst, t_cflag, t_zflag, t_vflag );
        assertflags("0000",t_dst,t_cflag,t_zflag,t_vflag);
        assert t_result="00000001" report "pasw failed" severity FAILURE;

        report "pasf";
        t_wreg_in <= "00000001";
        t_freg_in <= "10000000";
        t_opcode <= PASF;
        wait for 20 ns;
        dbgdump( t_opcode, t_wreg_in, t_freg_in, t_result, t_dst, t_cflag, t_zflag, t_vflag );
        assertflags("1000",t_dst,t_cflag,t_zflag,t_vflag);
        assert t_result="10000000" report "pasf failed" severity FAILURE;

        t_wreg_in <= "00000000";
        t_freg_in <= "11111111";
        t_opcode <= PASW;
        wait for 20 ns;
        dbgdump( t_opcode, t_wreg_in, t_freg_in, t_result, t_dst, t_cflag, t_zflag, t_vflag );
        -- PASW doesn't touch the Z_Flag
        assertflags("0000",t_dst,t_cflag,t_zflag,t_vflag);
        assert t_result="00000000" report "pasw failed" severity FAILURE;

        t_wreg_in <= "11111111";
        t_freg_in <= "00000000";
        t_opcode <= PASF;
        wait for 20 ns;
        dbgdump( t_opcode, t_wreg_in, t_freg_in, t_result, t_dst, t_cflag, t_zflag, t_vflag );
        assertflags("1010",t_dst,t_cflag,t_zflag,t_vflag);
        assert t_result="00000000" report "pasf failed" severity FAILURE;
        wait for 20 ns;
        dbgdump( t_opcode, t_wreg_in, t_freg_in, t_result, t_dst, t_cflag, t_zflag, t_vflag );
      
        --
        -- INCF / DECF Tests
        --
        report "incf 1";
        t_freg_in <= "00000001";
        t_opcode <= INCF;
        wait for 10 ns;
        dbgdump( t_opcode, t_wreg_in, t_freg_in, t_result, t_dst, t_cflag, t_zflag, t_vflag );
        assertflags("1000",t_dst,t_cflag,t_zflag,t_vflag);
        assert t_result="00000010" report "incf 1 failed" severity FAILURE;

        report "incf 2";
        t_freg_in <= "11111111";
        t_opcode <= INCF;
        wait for 10 ns;
        dbgdump( t_opcode, t_wreg_in, t_freg_in, t_result, t_dst, t_cflag, t_zflag, t_vflag );
        assertflags("1010",t_dst,t_cflag,t_zflag,t_vflag);
        assert t_result="00000000" report "incf 2 failed" severity FAILURE;

        report "decf";
        t_freg_in <= "00000001";
        t_opcode <= DECF;
        wait for 10 ns;
        dbgdump( t_opcode, t_wreg_in, t_freg_in, t_result, t_dst, t_cflag, t_zflag, t_vflag );
        assertflags("1010",t_dst,t_cflag,t_zflag,t_vflag);
        assert t_result="00000000" report "decf failed" severity FAILURE;

        t_freg_in <= "00000000";
        t_opcode <= DECF;
        wait for 10 ns;
        dbgdump( t_opcode, t_wreg_in, t_freg_in, t_result, t_dst, t_cflag, t_zflag, t_vflag );
        assertflags("1000",t_dst,t_cflag,t_zflag,t_vflag);
        assert t_result="11111111" report "decf failed" severity FAILURE;


        -- 
        -- AND/OR Tests
        --
    --    t_wreg_in <= "10101011";
    --    t_freg_in <= "11010001";
    --    t_opcode <= ANDWF;
    --    wait for 10 ns;
    --    wait for 10 ns;
    --    if t_dst='1' then 
    --      t_wreg_in<=t_result; 
    --    else 
    --      t_freg_in<=t_result; 
    --    end if;
    --    wait for 10 ns;
    --    wait for 10 ns;   
    --    
    --    -- AND with zero result (Z_Flag should be set)
    --    t_wreg_in <= "10101011";
    --    t_freg_in <= "00000000";
    --    t_opcode <= ANDWF;
    --    wait for 10 ns;
    --    wait for 10 ns;    
    --    
    --    t_wreg_in <= "10101011";
    --    t_freg_in <= "11010001";
    --    t_opcode <= ANDWF;
    --    wait for 10 ns;
    --    wait for 10 ns;
        
        --
        -- OR tests
        --
    --    t_wreg_in <= "10101011";
    --    t_freg_in <= "01010101";
    --    t_opcode <= IORWF;
    --    wait for 10 ns;
    --    wait for 10 ns;
    --
    --    t_wreg_in <= "10101011";
    --    t_freg_in <= "01010101";
    --    t_opcode <= IORWF;
    --    wait for 10 ns;
    --    wait for 10 ns;
    --    -- OR with zero result (Z_flag should be set)
    --    t_wreg_in <= "00000000";
    --    t_freg_in <= "00000000";
    --    t_opcode <= IORWF;
    --    wait for 10 ns;
    --    wait for 10 ns;   

    --    -- AND with zero result (Z_Flag should be set)
    --    t_wreg_in <= "10101011";
    --    t_freg_in <= "00000000";
    --    t_opcode <= ANDWF;
    --    wait for 10 ns;
    --    wait for 10 ns;
     
    --    t_wreg_in <= "10101011";
    --    t_freg_in <= "11010001";
    --    t_opcode <= ANDWF;
    --    wait for 10 ns;
    --    wait for 10 ns;
    --    -- OR with zero result (Z_flag should be set)
    --    t_wreg_in <= "00000000";
    --    t_freg_in <= "00000000";
    --    t_opcode <= IORWF;
    --    wait for 10 ns;
    --    wait for 10 ns;    
    --    t_wreg_in <= "10101011";
    --    t_freg_in <= "11010001";
    --    t_opcode <= ANDWF;
    --    wait for 10 ns;
    --    wait for 10 ns;
    --   
    --    t_wreg_in <= "10101011";
    --    t_freg_in <= "01010101";
    --    t_opcode <= IORWF;
    --    wait for 10 ns;
    --    wait for 10 ns;
    --    -- AND with zero result (Z_Flag should be set)
    --    t_wreg_in <= "10101011";
    --    t_freg_in <= "00000000";
    --    t_opcode <= ANDWF;
    --    wait for 10 ns;
    --    wait for 10 ns;
    --    -- OR with zero result (Z_flag should be set)
    --    t_wreg_in <= "00000000";
    --    t_freg_in <= "00000000";
    --    t_opcode <= IORWF;
    --    wait for 10 ns;
    --    wait for 10 ns;

        ---
        --- XOR test via XOR Swap
        ---    XORWF W,F  
        ---    W <- result
        ---    XORWF W,F
        ---    F <- result
        ---    XORWF W,F
        ---    W <- result
        --- result should be original F in W and W in result
    --    t_wreg_in <= "00001100"; -- 12
    --    t_freg_in <= "00101010"; -- 42
    --    t_opcode <= XORWF;
    --    wait for 10 ns;
    --    wait for 10 ns;
    --    
    --    t_wreg_in <= t_result;  -- put result into W register. Run XOR again.
    --    wait for 10 ns;
    --    wait for 10 ns;
    --
    --    t_freg_in <= t_result;  -- put result into F register. Run XOR again.
    --    wait for 10 ns;
    --    wait for 10 ns;
    --    
    --    -- XOR value with itself should give zero and set Z flag
    --    t_wreg_in <= t_result;
    --    t_freg_in <= t_result;
    --    wait for 10 ns;
    --    wait for 10 ns;
          
        ---
        ---  Complement Tests
        ---  
    --    t_freg_in <= "00000000";
    --    t_opcode <= COMF;
    --    wait for 10 ns;
    --    wait for 10 ns;
    --        
    --    t_freg_in <= "11111111";
    --    t_opcode <= COMF;
    --    wait for 10 ns;
    --    wait for 10 ns;
    --
    --    t_freg_in <= "01010101";
    --    t_opcode <= COMF;
    --    wait for 10 ns;
    --    wait for 10 ns;

        t_opcode <= CLR;
        wait for 10 ns;

        --- 
        --- Shift Right Tests
        ---
        report "sarf";
        t_freg_in <= "10000000";
        t_opcode <= SARF;
        wait for 10 ns;
        dbgdump( t_opcode, t_wreg_in, t_freg_in, t_result, t_dst, t_cflag, t_zflag, t_vflag );
        assertflags("1000",t_dst,t_cflag,t_zflag,t_vflag);
        assert t_result="11000000" report "sarf failed" severity FAILURE;
    
        t_freg_in <= "01000000";
        t_opcode <= SARF;
        wait for 10 ns;
        dbgdump( t_opcode, t_wreg_in, t_freg_in, t_result, t_dst, t_cflag, t_zflag, t_vflag );
        assertflags("1000",t_dst,t_cflag,t_zflag,t_vflag);
        assert t_result="00100000" report "sarf failed" severity FAILURE;

        t_opcode <= CLR;
        wait for 10 ns;

        ---
        --- Rotate Left Tests
        ---
        report "rlcf 1";
        t_freg_in <= "10000000";
        t_wreg_in <= "00000000";
        t_opcode <= RLCF;
        wait for 10 ns;    
        dbgdump( t_opcode, t_wreg_in, t_freg_in, t_result, t_dst, t_cflag, t_zflag, t_vflag );
        assertflags("1100",t_dst,t_cflag,t_zflag,t_vflag);
        assert t_result="00000000" report "rlcf 1 failed" severity FAILURE;

        report "rlcf 2";
        t_freg_in <= "00000000";
        t_opcode <= RLCF;
        wait for 10 ns;    
        dbgdump( t_opcode, t_wreg_in, t_freg_in, t_result, t_dst, t_cflag, t_zflag, t_vflag );
        assertflags("1000",t_dst,t_cflag,t_zflag,t_vflag);
        assert t_result="00000001" report "rlcf 2 failed" severity FAILURE;
            
        report "rlcf 3";
        t_freg_in <= "00000001";
        t_opcode <= RLCF;
        wait for 10 ns;    
        dbgdump( t_opcode, t_wreg_in, t_freg_in, t_result, t_dst, t_cflag, t_zflag, t_vflag );
        assertflags("1000",t_dst,t_cflag,t_zflag,t_vflag);
        assert t_result="00000010" report "rlcf 3 failed" severity FAILURE;

        t_opcode <= CLR;
        wait for 10 ns;

        ---
        --- Rotate Right Tests
        ---
        report "rrcf 1";
        t_freg_in <= "00000001";
        t_opcode <= RRCF;
        wait for 10 ns;    
        dbgdump( t_opcode, t_wreg_in, t_freg_in, t_result, t_dst, t_cflag, t_zflag, t_vflag );
        assertflags("1100",t_dst,t_cflag,t_zflag,t_vflag);
        assert t_result="00000000" report "rrcf 1 failed" severity FAILURE;

        report "rrcf 2";
        t_freg_in <= "00000000";
        t_opcode <= RRCF;
        wait for 10 ns;    
        dbgdump( t_opcode, t_wreg_in, t_freg_in, t_result, t_dst, t_cflag, t_zflag, t_vflag );
        assertflags("1000",t_dst,t_cflag,t_zflag,t_vflag);
        assert t_result="10000000" report "rrcf 2 failed" severity FAILURE;
        
        t_opcode <= CLR;
        wait for 10 ns;

        reset <= '1';
        wait for 10 ns;
            
        report "test done";  
        wait;
    end process stimulus;
  
end architecture test_alu_arch;

