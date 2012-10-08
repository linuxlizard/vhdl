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

    component d_register is
        generic (width : integer);
        port (clk : in std_logic;
              reset : in std_logic;
              input_enable : in std_logic;
              output_enable : in std_logic;
              data_in : in std_logic_vector( width-1 downto 0 );
              data_out : out std_logic_vector( width-1 downto 0 )
        );
    end component d_register;

    signal t_clk : std_logic := '0';   
    signal reset : std_logic := '1';
    signal t_opcode : std_logic_vector(4 downto 0);

--  signal t_wreg_in : std_logic_vector(7 downto 0 );
--  signal t_freg_in : std_logic_vector(7 downto 0 );
    signal t_wreg_in : std_logic_vector(7 downto 0 );
    signal t_freg_in : std_logic_vector(7 downto 0 );
    signal t_freg_input_enable : std_logic := '0';
    signal t_freg_output_enable : std_logic := '0';
    signal t_wreg_input_enable : std_logic := '0';
    signal t_wreg_output_enable : std_logic := '0';
    signal t_wreg_out : std_logic_vector(7 downto 0 );
    signal t_freg_out : std_logic_vector(7 downto 0 );

    signal t_result : std_logic_vector(7 downto 0 );

    signal t_dst : std_logic;
    signal t_cflag : std_logic;
    signal t_zflag : std_logic;
    signal t_vflag : std_logic;
--  signal t_ready_in : std_logic := '0';
  
begin
      
    uut : alu 
    port map( t_wreg_out,
              t_freg_out,
              t_opcode,
              t_result,
              t_dst, t_cflag, t_zflag, t_vflag );

    F_Register : d_register 
       generic map( width => 8)
        port map( 
                clk => t_clk, 
                reset => reset, 
                input_enable => t_freg_input_enable,
                output_enable => t_freg_output_enable,
                data_in => t_freg_in, 
                data_out => t_freg_out );

    W_Register : d_register 
       generic map( width => 8)
        port map( 
                clk => t_clk, 
                reset => reset, 
                input_enable => t_wreg_input_enable,
                output_enable => t_wreg_output_enable,
                data_in => t_wreg_in, 
                data_out => t_wreg_out );

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
--        t_wreg_in <= "00000101";  --  5
--        t_freg_in <= "00000011";  -- +3
--        t_opcode <= ADDWF;
--        assert t_result="00001000" report "5+3 failed" severity FAILURE;
    -- 
    --    -- add 1 to -1. Result should be zero and Z_Flag set. 
    --    t_wreg_in <= "11111111";
    --    t_freg_in <= "00000001";
    --    assert t_result="00000000" report "1+-1 failed";
    --    assert t_zflag='1' report "1+-1 zflag wrong" severity FAILURE;
    --
    --    t_wreg_in <= "00000000";
    --    t_freg_in <= "00000000";
    --    assert t_result="00000000" report "0+0 failed" severity FAILURE;
       
        --
        -- Subtraction Tests
        --
    --    t_freg_in <= "00000101"; --   5
    --    t_wreg_in <= "00000011"; --  -3
    --    t_opcode <= SUBWF;
    --    assert t_result="00000010" report "5-3 failed"severity FAILURE;
    -- 
    --    t_freg_in <= "01111111";
    --    t_wreg_in <= "01111100";
    --    t_opcode <= SUBWF;
    --    assert t_result="00000011" report "0x7f-0x7c failed"severity FAILURE;
    --
    --    t_freg_in <= "00000000";
    --    t_wreg_in <= "00000000";
    --    t_opcode <= SUBWF;
    --    assert t_result="00000000" report "0-0 failed"severity FAILURE;  
    --
    --    t_freg_in <= "11111111";
    --    t_wreg_in <= "11111111";
    --    t_opcode <= SUBWF;
    --    assert t_result="00000000" report "-1--1 failed" severity FAILURE;     

        -- 
        -- Swap Tests
        --
        -- swap 11110000 to 00001111 then back to 11110000
--        write( str, string'("result=") );
--        write( str, run( SWAPF, "00110000", "00000000" ) );
--        writeline( output, str );
         
        t_freg_input_enable <= '1';
        t_freg_in <= "11110000";
        wait for 20 ns;

        t_opcode <= SWAPF;
        t_freg_input_enable <= '0';
        t_freg_output_enable <= '1';
        wait for 20 ns;

        t_freg_input_enable <= '0';
        t_freg_output_enable <= '0';
        wait for 20 ns;

        write( str, string'("swapf result=") );
        write( str, t_result );
        writeline( output, str );

        --
        -- PAS[FW] Tests
        --      
        t_freg_input_enable <= '1';
        t_wreg_input_enable <= '1';
        t_freg_output_enable <= '0';
        t_wreg_output_enable <= '0';
        t_wreg_in <= "00000001";
        t_freg_in <= "10000000";
        wait for 20 ns;

        t_opcode <= PASW;
        t_freg_input_enable <= '0';
        t_wreg_input_enable <= '0';
        t_freg_output_enable <= '1';
        t_wreg_output_enable <= '1';
        wait for 20 ns;

        t_freg_output_enable <= '0';
        t_wreg_output_enable <= '0';
        wait for 20 ns;

        write( str, string'("swapf result=") );
        write( str, t_result );
        writeline( output, str );
    
        t_wreg_in <= "00000001";
        t_freg_in <= "10000000";
        t_opcode <= PASF;
        wait for 20 ns;
        wait for 20 ns;
      
        --
        -- INCF / DECF Tests
        --
    --    t_freg_in <= "00000001";
    --    t_opcode <= INCF;
    --    for i in 10 downto 0 loop
    --      wait for 10 ns;
    --      wait for 10 ns;
    --      -- output of INCF is our new input; want to watch the output
    --      -- increase from 1 to 12
    --      t_freg_in <= t_result;
    --    end loop;
    --    t_freg_in <= "11111111";
    --    assert t_result="00000000" report "incf max failed";
        
    --    t_opcode <= DECF;
    --    for i in 15 downto 0 loop
    --      wait for 10 ns;
    --      wait for 10 ns;
    --      -- output of DECF is our new input; want to watch the output
    --      -- increase from 12 to <0
    --      t_freg_in <= t_result;
    --    end loop;  
    --    t_freg_in <= "00000001";
        

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

        --- 
        --- Shift Right Tests
        ---
    --    t_freg_in <= "10000000";
    --    t_opcode <= SARF;
    --    for i in 7 downto 0 loop 
    --      wait for 10 ns;
    --      wait for 10 ns;
    --      -- output of this iteration becomes input for the next iteration; 
    --      -- want to watch the value fill to "11111111"
    --      t_freg_in <= t_result;
    --    end loop;
    --
    --    t_freg_in <= "01000000";
    --    t_opcode <= SARF;
    --    for i in 7 downto 0 loop 
    --      wait for 10 ns;
    --      wait for 10 ns;
    --      -- output of this iteration becomes input for the next iteration; 
    --      -- want to watch the value fill to "00000001"
    --      t_freg_in <= t_result;
    --    end loop;

        ---
        --- Rotate Left Tests
        ---
    --    t_freg_in <= "10000000";
    --    t_opcode <= RLCF;
    --    for i in 7 downto 0 loop 
    --      wait for 10 ns;    
    --      wait for 10 ns;
    --      -- output of this iteration becomes input for next iteration; 
    --      -- should see our original bit march across the t_result
    --      t_freg_in <= t_result;
    --    end loop;
            
        ---
        --- Rotate Right Tests
        ---
        t_freg_in <= "00000001";
        t_opcode <= RRCF;
        for i in 7 downto 0 loop 

          wait for 10 ns;    

          wait for 10 ns;
          -- output of this iteration becomes input for next iteration; 
          -- should see our original bit march across the t_result
          t_freg_in <= t_result;
        end loop;
        
        t_opcode <= CLR;

        wait for 10 ns;

        wait for 10 ns;
            
        report "test done";  
        wait;
    end process stimulus;
  
end architecture test_alu_arch;

