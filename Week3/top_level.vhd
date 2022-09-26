library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_level is
    port (
        clk : in  std_logic;
        switches           : in std_logic_vector(9 downto 0);
        buttons           : in std_logic_vector(1 downto 0);
        led0    : out std_logic_vector(6 downto 0);
        led0_dp : out std_logic;
        led1    : out std_logic_vector(6 downto 0);
        led1_dp : out std_logic;
        led2    : out std_logic_vector(6 downto 0);
        led2_dp : out std_logic;
        led3    : out std_logic_vector(6 downto 0);
        led3_dp : out std_logic;
        led4    : out std_logic_vector(6 downto 0);
        led4_dp : out std_logic;
        led5    : out std_logic_vector(6 downto 0);
        led5_dp : out std_logic);
end top_level;

architecture STR of top_level is
    
    constant C0 : std_logic_vector(3 downto 0) := "0000";
    signal outport : std_logic_vector(31 downto 0);

begin

    

    -- MIPS
    UUT_MIPS : entity work.mips
        port map (
            clk => clk,
            switches => switches,
            buttons => buttons,
            outport => outport
        );
        
    -- LEDs
    U_LED0 : entity work.decoder7seg 
        port map(
            input  => outport(3 downto 0),
            output => led0
        );
    
    U_LED1 : entity work.decoder7seg 
        port map(
            input  => outport(7 downto 4),
            output => led1
        );
    
    U_LED2 : entity work.decoder7seg 
        port map(
            input  => outport(11 downto 8),
            output => led2
        );
    U_LED3 : entity work.decoder7seg 
        port map(
            input  => outport(15 downto 12),
            output => led3
        );
        
    U_LED4 : entity work.decoder7seg 
        port map(
            input  => C0,
            output => led4
        );
    
    U_LED5 : entity work.decoder7seg 
        port map(
            input  => C0,
            output => led5
        );

    led0_dp <= '1';
    led1_dp <= '1';
    led2_dp <= '1';
    led3_dp <= '1';
    led4_dp <= '1';
    led5_dp <= '1';

    
end STR;