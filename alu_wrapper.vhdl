library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;
use std.textio.all;

entity alu_wrapper is
    port ( mclk : in std_logic;
            btn : in std_logic_vector(3 downto 0);
             sw : in std_logic_vector(7 downto 0);

            wreg_out : out std_logic_vector (7 downto 0 );
            freg_out : out std_logic_vector (7 downto 0 );
--            result : out std_logic_vector (7 downto 0 );
            led : out std_logic_vector (7 downto 0 )
         );
end entity alu_wrapper;

architecture alu_wrapper_arch of alu_wrapper is

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

    signal opcode_reg_output : std_logic_vector( 4 downto 0 ) := (others=>'0');
    signal regw_to_alu : std_logic_vector( 7 downto 0 ) := (others=>'0');
    signal regf_to_alu : std_logic_vector( 7 downto 0 ) := (others=>'0');

    signal regw_output : std_logic_vector( 7 downto 0 ) := (others=>'0');
    signal regf_output : std_logic_vector( 7 downto 0 ) := (others=>'0');

    signal alu_result : std_logic_vector( 7 downto 0 ) := (others=>'0');
    signal alu_dest : std_logic := '0';
begin
    opcode_register : d_register
       generic map( width => 5)
       port map( clk => mclk,
                 reset => '0',
                 input_enable => btn(0),
                 output_enable => btn(3),
                 data_in => sw(4 downto 0),
                 data_out => opcode_reg_output);

    W_register : d_register
       generic map( width => 8)
       port map( clk => mclk,
                 reset => '0',
                 input_enable => btn(1),
                 output_enable => btn(3),
                 data_in => sw,
                 data_out => regw_to_alu);

    F_register : d_register
       generic map( width => 8)
       port map( clk => mclk,
                 reset => '0',
                 input_enable => btn(2),
                 output_enable => btn(3),
                 data_in => sw,
                 data_out => regf_to_alu );

    run_alu : alu 
        port map( W_Reg => regw_to_alu,
                  F_Reg => regf_to_alu,
                  Op_Code => opcode_reg_output,
                  Rslt => alu_result,
                  Dst => alu_dest,
                  C_Flag => led(1),
                  Z_Flag => led(2),
                  V_Flag => led(3) );

    led(0) <= alu_dest;

    run_alu_wrapper : process(mclk) is
    begin
        if rising_edge(mclk) then
            if alu_dest='1' then
                -- output to freg
                regw_output <= regw_to_alu;
                regf_output <= alu_result;
            else  
                -- output to wreg
                regw_output <= alu_result;
                regf_output <= regf_to_alu;
            end if;
        end if;
    end process run_alu_wrapper;

    wreg_out <= regw_output;
    freg_out <= regf_output;

end architecture alu_wrapper_arch;

