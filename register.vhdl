library ieee;
use ieee.std_logic_1164.all;

entity d_register is
    generic (width : integer);
    port (clk : in std_logic;
          reset : in std_logic;
          input_enable : in std_logic;
          output_enable : in std_logic;
          data_in : in std_logic_vector( width-1 downto 0 );
          data_out : out std_logic_vector( width-1 downto 0 )
    );
end entity d_register;

architecture behavioral of d_register is
   signal current_value : std_logic_vector(width-1 downto 0 );
begin
   behavior : process(clk, reset) is
   begin
      if reset='1' then
          data_out <= (others => '0');
          current_value <= (others => '0');
      elsif rising_edge(clk) then
          if input_enable='1' then
             current_value <= data_in;
          elsif output_enable='1' then
             data_out <= current_value;
          end if;

      end if;

   end process behavior;

end architecture behavioral;
