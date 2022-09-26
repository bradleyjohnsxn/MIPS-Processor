library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity memory_tb is
end memory_tb;

architecture TB of memory_tb is

    signal clk,rst    : std_logic             := '0';
    signal clkEn  : std_logic             := '1';

    signal inport : std_logic_vector(31 downto 0) := (others => '0');
    signal address : std_logic_vector(31 downto 0) := (others => '0');
    signal data : std_logic_vector(31 downto 0) := (others => '0');
    signal inport0_en : std_logic := '0';
    signal inport1_en : std_logic := '0';
    signal mem_read : std_logic := '0';
    signal mem_write : std_logic := '0';

    signal outport, output : std_logic_vector(31 downto 0);


begin

    UUT : entity work.memory
        
        port map (
            clk => clk,
            rst => rst,
            inport => inport,
            inport0_en => inport0_en,
            inport1_en => inport1_en,
            mem_read => mem_read,
            mem_write => mem_write,
            address => address,
            data => data,
            outport => outport,
            output => output
        );

    clk <= not clk and clkEn after 20 ns;

    process
    begin
        rst <= '1';
        wait for 60 ns;
        rst <= '0';

        -- Write 0x0A0A0A0A to byte address 0x00000000
        address <= "00000000000000000000000000000000";
        data <= "00001010000010100000101000001010";
        mem_write <= '1';
        for i in 0 to 2 loop
            wait until rising_edge(clk);
        end loop;
        mem_write <= '0';

        -- Write 0xF0F0F0F0 to byte address 0x00000004
        address <= "00000000000000000000000000000100";
        data <= "11110000111100001111000011110000";
        mem_write <= '1';
        for i in 0 to 2 loop
            wait until rising_edge(clk);
        end loop;
        mem_write <= '0';

        -- Read from byte address 0x00000000 (should show 0x0A0A0A0A on read data output)
        address <= "00000000000000000000000000000000";
        mem_read <= '1';
        for i in 0 to 2 loop
            wait until rising_edge(clk);
        end loop;
        mem_read <= '0';

        -- Read from byte address 0x00000001 (should show 0x0A0A0A0A on read data output)
        address <= "00000000000000000000000000000001";
        mem_read <= '1';
        for i in 0 to 2 loop
            wait until rising_edge(clk);
        end loop;
        mem_read <= '0';

        -- Read from byte address 0x00000004 (should show 0xF0F0F0F0 on read data output)
        address <= "00000000000000000000000000000100";
        mem_read <= '1';
        for i in 0 to 2 loop
            wait until rising_edge(clk);
        end loop;
        mem_read <= '0';

        -- Read from byte address 0x00000005 (should show 0xF0F0F0F0 on read data output)
        address <= "00000000000000000000000000000101";
        mem_read <= '1';
        for i in 0 to 2 loop
            wait until rising_edge(clk);
        end loop;
        mem_read <= '0';

        -- Write 0x00001111 to the outport (should see value appear on outport)
        address <= "00000000000000001111111111111100";
        data <= "00000000000000000001000100010001";
        mem_write <= '1';
        for i in 0 to 2 loop
            wait until rising_edge(clk);
        end loop;
        mem_write <= '0';

        -- Load 0x00010000 into inport 0
        inport <= "00000000000000010000000000000000";
        inport0_en <= '1';
        mem_write <= '1';
        for i in 0 to 2 loop
            wait until rising_edge(clk);
        end loop;
        mem_write <= '0';
        inport0_en <= '0';

        -- Load 0x00000001 into inport 1
        inport <= "00000000000000000000000000000001";
        inport1_en <= '1';
        mem_write <= '1';
        for i in 0 to 2 loop
            wait until rising_edge(clk);
        end loop;
        mem_write <= '0';
        inport1_en <= '0';

        -- Read from inport 0 (should show 0x00010000 on read data output)
        address <= "00000000000000001111111111111000";
        mem_read <= '1';
        for i in 0 to 2 loop
            wait until rising_edge(clk);
        end loop;
        mem_read <= '0';

        -- Read from inport 1 (should show 0x00000001 on read data output)
        address <= "00000000000000001111111111111100";
        mem_read <= '1';
        for i in 0 to 2 loop
            wait until rising_edge(clk);
        end loop;
        mem_read <= '0';

		
        clkEn <= '0';
        report "Simulation Finished" severity note;
        wait;

    end process;

end TB;