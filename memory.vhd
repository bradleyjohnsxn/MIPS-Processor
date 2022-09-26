library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity memory is
    port (
        clk, rst : in std_logic;
        inport : in std_logic_vector(31 downto 0);
        inport0_en, inport1_en : in std_logic;
        mem_read, mem_write : in std_logic; -- memread not needed
        address, data : in std_logic_vector(31 downto 0);
        outport, addr : out std_logic_vector(31 downto 0);
        output : out std_logic_vector(31 downto 0)
    );
end memory;

architecture mem of memory is

    signal outport_en : std_logic;
    signal ram_wren : std_logic;
    signal inport0_r, inport1_r, ram_out : std_logic_vector(31 downto 0);
    signal mux_sel : std_logic_vector(1 downto 0);

begin
   
    U_RAM : entity work.ram256x32
        port map(
            address => address(9 downto 2),
            clock => clk,
            data => data,
            wren => ram_wren,
            q => ram_out
        );
    

    U_OUTPORT : entity work.reg
        generic map(width => 32)
        port map (
            clk => clk ,
            rst => rst,
            en => outport_en,
            input => data,
            output => outport
        );

    U_INPORT0 : entity work.reg
        generic map(width => 32)
        port map (
            clk => clk ,
            rst => '0',
            en => inport0_en,
            input => inport,
            output => inport0_r
        );

    U_INPORT1 : entity work.reg
        generic map(width => 32)
        port map (
            clk => clk ,
            rst => '0',
            en => inport1_en,
            input => inport,
            output => inport1_r
        );

    U_MUX4x1 : entity work.mux4x1
        generic map(width => 32)
        port map (
            in1 => inport0_r,
            in2 => inport1_r,
            in3 => ram_out,
            in4 => (others => '0'),
            sel => mux_sel,
            output => output
        );

    addr <= address;

    -- write enable logic
    process(address, mem_write)
    begin
        outport_en <= '0';
        ram_wren <= '0';

        if(mem_write = '1') then

            if(address = "00000000000000001111111111111100") then
                outport_en <= '1';
            elsif(unsigned(address(31 downto 10)) = 0) then
                ram_wren <= '1';
            end if;

        end if;

    end process;

    -- mux sel logic
    process(address)
    begin

        if(address = "00000000000000001111111111111000") then
            mux_sel <= "00";
            
        elsif(address = "00000000000000001111111111111100") then
            mux_sel <= "01";
    
        elsif(unsigned(address(31 downto 10)) = 0) then
            mux_sel <= "10";
        else
            mux_sel <= "11";
        end if;
    end process;

    
end mem;