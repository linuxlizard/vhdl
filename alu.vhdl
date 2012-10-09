-- davep 13-Sep-2012
-- ECE530 Assign-01  PIC Micro

library ieee;
use ieee.std_logic_1164.all;
library work;
use work.opcodes.all;


entity alu is
  port( W_Reg : in std_logic_vector(7 downto 0);
        F_Reg : in std_logic_vector(7 downto 0);
        Op_Code : in std_logic_vector(4 downto 0);
        Rslt : out std_logic_vector(7 downto 0);
        Dst : out std_logic;
        C_Flag : out std_logic;
        Z_Flag : out std_logic;
        V_Flag : out std_logic );
end alu;
  
  
architecture alu_arch of alu is
 
    constant DST_W : std_logic := '0';
    constant DST_F : std_logic := '1';

  -- internal copy of the Carry flag used during rotate functions
  signal int_c_flag : std_logic := '0';
  signal tmp_add_result : std_logic_vector(8 downto 0 );
  signal tmp_result : std_logic_vector(7 downto 0 );
--  signal c_flag_out : std_logic;
  
  subtype bbyte is std_logic_vector(7 downto 0);
  -- function can only return one value so encode with Carry in MSB, 
  -- data is remaining 8 bits. (Terrible design showing my thundering ignorance.)
  subtype carry_and_byte is std_logic_vector(8 downto 0);
  subtype two_bits is std_logic_vector(1 downto 0 );

  function half_adder( A, B : std_logic ) return two_bits is
  begin
    --  return fields (1) = Sum
    --                (0) = Carry
    return ( A xor B, A and B );
  end;

  function full_adder( A, B, Cin : std_logic ) return two_bits is
    variable tmp : two_bits;
    variable Sum, Carry, Sum2, Carry2 : std_logic;
  begin
    tmp := half_adder( A, B );
    Sum := tmp(1);
    Carry := tmp(0);
    tmp := half_adder( Sum, Cin );
    Sum2 := tmp(1);
    Carry2 := tmp(0);
    
    -- return fields are (1) = Sum
    --                   (0) = Carry
    return ( Sum2, Carry2 or Carry );
  end;

  -- TODO implement this function as an entity, bring into my ALU as a component
  function ripple_adder( A, B, CarryIn : bbyte ) return carry_and_byte is
      variable S0, S1, S2, S3, S4, S5, S6, S7 : std_logic;
      variable carry : std_logic;
      variable tmp :two_bits;
  begin
      -- "When in doubt, use brute force."
      --     Ken Thompson
      -- I don't think a loop can be synthesized. (???)  So unroll it 
      -- in my eternal shame and ignorance.
      S0:='0'; S1:='0'; S2:='0'; S3:='0'; S4:='0'; S5:='0'; S6:='0'; S7:='0';
      tmp := full_adder( A(0), B(0), '0' );
      S0 := tmp(1);
      carry := tmp(0);    

      tmp := full_adder( A(1), B(1), carry );
      S1 := tmp(1);
      carry := tmp(0); 

      tmp := full_adder( A(2), B(2), carry );
      S2 := tmp(1);
      carry := tmp(0); 

      tmp := full_adder( A(3), B(3), carry );
      S3 := tmp(1);
      carry := tmp(0); 

      tmp := full_adder( A(4), B(4), carry );
      S4 := tmp(1);
      carry := tmp(0); 

      tmp := full_adder( A(5), B(5), carry );
      S5 := tmp(1);
      carry := tmp(0); 

      tmp := full_adder( A(6), B(6), carry );
      S6 := tmp(1);
      carry := tmp(0); 

      tmp := full_adder( A(7), B(7), carry );
      S7 := tmp(1);
      carry := tmp(0); 

      return ( carry, S7, S6, S5, S4, S3, S2, S1, S0 );
  end function ripple_adder;

begin

    RunALU : process( W_Reg, F_Reg, Op_Code )

      variable op_msb : std_logic;
      variable op : std_logic_vector(4 downto 0);
      variable int_result : std_logic_vector(7 downto 0);
      variable add_result : carry_and_byte;
--      variable twos_compliment : std_logic_vector(7 downto 0);
        
      variable prev_int_c_flag : std_logic := '0';
    begin
        report "opcode";

        -- strip the MSB for reasons I'm not too sure of yet
        op_msb := OP_Code(4);
        op := Op_Code and "01111";
        
        case op is
        when NOP =>
          -- do nothing

        when ADDWF =>
--          prev_int_c_flag := int_c_flag;

          -- http://dev.code.ultimater.net/electronics/8-bit-full-adder-and-subtractor/
          -- https://en.wikipedia.org/wiki/Adder_(electronics)
          -- http://books.google.com/books?id=PZkDpS4m0fMC&pg=PA180#v=onepage&q&f=false
          add_result := ripple_adder( W_Reg, F_Reg, ( 0=>int_c_flag, others=>'0' ) );
          int_result := add_result(7 downto 0);
          tmp_add_result <= add_result;

--          V_Flag <=  prev_int_c_flag and int_c_flag;

          C_Flag <= add_result(8);         
          int_c_flag <= add_result(8);  
          if int_result="00000000" then
            Z_Flag <= '1';
          else   
            Z_Flag <= '0';
          end if;
          Rslt <= int_result;
          Dst <= DST_F;
                
        when SUBWF =>
          -- two's compliment of W = (~W)+1
          int_result := not W_Reg;
          add_result := ripple_adder( int_result, "00000001", (others=>'0') );
          int_result := add_result(7 downto 0);
          -- int_result now contains two's compliment of W_Reg
          -- add W_Reg, F_Reg
          add_result := ripple_adder( int_result, F_reg, (others=>'0') );
          -- laboriously extract the results 
          int_result := add_result(7 downto 0);
          --C_Flag <= add_result(8);
          C_Flag <= '0'; -- not sure what carry means in subtraction
          if int_result="00000000" then
            Z_Flag <= '1';
          else   
            Z_Flag <= '0';
          end if;
          Rslt <= int_result;
          Dst <= DST_F;
                
        when SWAPF =>
          int_result := ( F_Reg(3), F_Reg(2), F_Reg(1), F_Reg(0),
                   F_Reg(7), F_Reg(6), F_Reg(5), F_Reg(4) );
          Rslt <= int_result;
          Dst <= DST_F;
          
        when PASW =>
          int_result := W_reg;
          -- PASW doesn't touch the Z_Flag
          Rslt <= int_result;
          Dst <= DST_W;
                  
        when PASF =>
          int_result := F_reg;
          if int_result="00000000" then
            Z_Flag <= '1';
          else   
            Z_Flag <= '0';
          end if;
          Rslt <= int_result;
          Dst <= DST_F;
            
        when INCF =>
          add_result := ripple_adder( "00000001", F_Reg, ( others=>'0' ) );
          int_result := add_result(7 downto 0);
          if int_result="00000000" then
            Z_Flag <= '1';
          else   
            Z_Flag <= '0';
          end if;
          Rslt <= int_result;
          Dst <= DST_F;

        when DECF =>
          add_result := ripple_adder( "11111111", F_Reg, ( others=>'0' ) );
          int_result := add_result(7 downto 0);
          if int_result="00000000" then
            Z_Flag <= '1';
          else   
            Z_Flag <= '0';
          end if;
          Rslt <= int_result;
          Dst <= DST_F;
                        
        when ANDWF =>
          int_result := W_Reg and F_reg;  
          if int_result="00000000" then
            Z_Flag <= '1';
          else   
            Z_Flag <= '0';
          end if;
          Rslt <= int_result;
          Dst <= DST_F;

        when IORWF =>
          int_result := W_Reg or F_reg;
          if int_result="00000000" then
            Z_Flag <= '1';
          else   
            Z_Flag <= '0';
          end if;
--          Rslt <= W_Reg or F_reg;
          Rslt <= int_result;
          Dst <= DST_F;

        when XORWF =>
          int_result := W_Reg xor F_reg;
          if int_result="00000000" then
            Z_Flag <= '1';
          else   
            Z_Flag <= '0';
          end if;
          Rslt <= int_result;
          Dst <= DST_F;

        when COMF =>
          int_result := not F_Reg;
          if int_result="00000000" then
            Z_Flag <= '1';
          else   
            Z_Flag <= '0';
          end if;
          Rslt <= int_result;
          Dst <= DST_F;
          
        when RLCF =>
          -- rotate left through carry flag
          if F_Reg(7)='1' then
              C_Flag <= '1';
          else 
              C_Flag <= '0';
          end if;     
          -- assignment statement will use the previous value of int_c_flag because the above 
          -- signal assignment takes effect at the end of the process.
--          int_result := ( F_Reg(6), F_Reg(5), F_Reg(4), F_Reg(3), F_Reg(2), F_Reg(1), F_Reg(0),
 --                          int_c_flag );
          Rslt <= ( F_Reg(6), F_Reg(5), F_Reg(4), F_Reg(3), F_Reg(2), F_Reg(1), F_Reg(0),
                           int_c_flag );
          int_c_flag <= F_Reg(7);
--          Rslt <= int_result;
          Dst <= DST_F;
                
        when RRCF =>
          -- rotate right through carry flag
          int_c_flag <= F_Reg(0);
         
          if F_Reg(0)='1' then
              C_Flag <= '1';
          else 
              C_Flag <= '0';
          end if;     
          Dst <= DST_F;
       
          -- assignment statement will use the previous value of int_c_flag because the above 
          -- signal assignment takes effect at the end of the process.
--          int_result := ( int_c_flag, 
--                         F_Reg(7), F_Reg(6), F_Reg(5), F_Reg(4), F_Reg(3), F_Reg(2), F_Reg(1) );
          Rslt <= ( int_c_flag, 
                         F_Reg(7), F_Reg(6), F_Reg(5), F_Reg(4), F_Reg(3), F_Reg(2), F_Reg(1) );
          int_c_flag <= F_Reg(0);
--          Rslt <= int_result;
          Dst <= DST_F;
                                    
        when SARF =>
          -- shift arithmetic right (preserves sign bit)
          -- XXX how does the carry flag get used here?
          -- http://stackoverflow.com/questions/4174473/universal-shift-arithmetic-right-in-vhdl?rq=1
          int_result := ( F_Reg(7), -- preserve highest bit
                   F_Reg(7), F_Reg(6), F_Reg(5), F_Reg(4), F_Reg(3), F_Reg(2), F_Reg(1) );
          if int_result="00000000" then
            Z_Flag <= '1';
          else   
            Z_Flag <= '0';
          end if;            
          Rslt <= int_result;
          Dst <= DST_F;
        
        when CLR =>
          Z_Flag <= '0';
          C_Flag <= '0';
          V_Flag <= '0';
          Rslt <= (others=>'0');
          Dst <= '0';
          int_c_flag <= '0';

        when others => 
    --      report "unknown opcodeopcode?" severity FAILURE;
          int_result := "01010101";
        end case;
     
    end process RunALU;
 
end alu_arch;
  
