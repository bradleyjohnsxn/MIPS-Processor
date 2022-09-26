library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity mips_tb is
end mips_tb;

architecture TB of mips_tb is

    signal clk    : std_logic             := '0';
    signal clkEn  : std_logic             := '1';

    signal switches   : std_logic_vector(9 downto 0) := (others => '0');
    signal buttons    : std_logic_vector(1 downto 0) := (others => '1');
    signal outport    : std_logic_vector(31 downto 0);


begin

    UUT_MIPS : entity work.mips
        
        port map (
            clk => clk,
            switches => switches,
            buttons => buttons,
            outport => outport
        );




    clk <= not clk and clkEn after 20 ns;

    process
    begin
        buttons(1) <= '0';

        switches <= "0000000100";
        buttons(0) <= '0';
        wait until clk'event and clk='1';
        buttons(0) <= '1';

        switches <= "1000000010";
        buttons(0) <= '0';
        wait until clk'event and clk='1';
        buttons(0) <= '1';

        wait for 5 ns;
        buttons(1) <= '1';

        wait for 15000 ns; -- 20000
        
        clkEn <= '0';
        report "Simulation Finished" severity note;
        wait;

    end process;

end TB;