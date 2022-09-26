library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity register_file is
    generic (WIDTH : positive := 16;
        NUM_DATA_BITS : positive := 32);
    port (
        clk, rst : in std_logic;
        rd_addr0, rd_addr1, wr_addr : in std_logic_vector(integer(ceil(log2(real(WIDTH))))-1 downto 0);
        wr_en, jump_and_link : in std_logic;
        wr_data : in std_logic_vector(NUM_DATA_BITS-1 downto 0);
        rd_data0, rd_data1 : out std_logic_vector(NUM_DATA_BITS-1 downto 0)
    );
end register_file;

architecture async_read of register_file is
    type reg_array is array(0 to WIDTH-1) of std_logic_vector(NUM_DATA_BITS-1 downto 0);
    signal regs : reg_array;

begin
   
    process(clk, rst)
    begin
        if(rst = '1') then

            for i in regs'range loop
                regs(i) <= (others => '0');
            end loop;

        elsif(rising_edge(clk)) then

            if(jump_and_link = '1') then
                regs(31) <= wr_data;
            elsif(wr_en = '1' and unsigned(wr_addr) /= 0) then
                regs(to_integer(unsigned(wr_addr))) <= wr_data;
            end if;

        end if;    
    end process;

    rd_data0 <= regs(to_integer(unsigned(rd_addr0)));
    rd_data1 <= regs(to_integer(unsigned(rd_addr1)));
    
end async_read;