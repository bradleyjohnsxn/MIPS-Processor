library ieee;
use ieee.std_logic_1164.all;

entity mux4x1 is
    generic (WIDTH : positive := 16);
    port(
        in1, in2, in3, in4    : in  std_logic_vector(width-1 downto 0);
        sel    : in  std_logic_vector(1 downto 0);
        output : out std_logic_vector(width-1 downto 0));
end mux4x1;

architecture IF_STATEMENT of mux4x1 is
begin

  process(in1, in2, in3, in4, sel)
  begin

    if (sel = "00") then
      output <= in1;
    elsif (sel = "01") then
      output <= in2;
    elsif (sel = "10") then
      output <= in3;
    else
      output <= in4;
    end if;
  end process;
  
end IF_STATEMENT;