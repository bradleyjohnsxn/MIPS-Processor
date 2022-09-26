library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity alu_tb is
end alu_tb;

architecture TB of alu_tb is

    component alu

        generic (
            WIDTH : positive := 32
            );
        port (
            in1   : in  std_logic_vector(WIDTH-1 downto 0);
            in2   : in  std_logic_vector(WIDTH-1 downto 0);
            op_sel      : in  std_logic_vector(5 downto 0);
            ir10_6      : in std_logic_vector(4 downto 0);
            result   : out std_logic_vector(WIDTH-1 downto 0);
            result_hi: out std_logic_vector(WIDTH-1 downto 0);
            branch : out std_logic
            );

    end component;

    constant WIDTH  : positive                           := 32;
    signal in1   : std_logic_vector(WIDTH-1 downto 0) := (others => '0');
    signal in2   : std_logic_vector(WIDTH-1 downto 0) := (others => '0');
    signal op_sel      : std_logic_vector(5 downto 0)       := (others => '0');
    signal ir10_6      : std_logic_vector(4 downto 0)       := (others => '0');
    signal result   : std_logic_vector(WIDTH-1 downto 0);
    signal result_hi   : std_logic_vector(WIDTH-1 downto 0);
    signal branch : std_logic;

begin  -- TB

    U_ALU : alu
        generic map (WIDTH => WIDTH)
        port map (
            in1   => in1,
            in2   => in2,
            op_sel      => op_sel,
            ir10_6      => ir10_6,
            result   => result,
            result_hi   => result_hi,
            branch => branch);

    process
    begin

        -- Addition: test 10 + 15
        op_sel    <= "100001";
        in1 <= std_logic_vector(to_unsigned(10, in1'length));
        in2 <= std_logic_vector(to_unsigned(15, in1'length));
        wait for 40 ns;
        assert(unsigned(result) = to_unsigned(25, result'length)) report "Error : 10+15 = " & integer'image(to_integer(unsigned(result))) & " instead of 25" severity warning;

        -- Subtraction: test 25 - 10
        op_sel    <= "100010";
        in1 <= std_logic_vector(to_unsigned(25, in1'length));
        in2 <= std_logic_vector(to_unsigned(10, in1'length));
        wait for 40 ns;
        assert(unsigned(result) = to_unsigned(15, result'length)) report "Error : 25-10 = " & integer'image(to_integer(unsigned(result))) & " instead of 15" severity warning;

        --Signed mult: test 10 * -4
        op_sel    <= "011000";
        in1 <= std_logic_vector(to_signed(10, in1'length));
        in2 <= std_logic_vector(to_signed(-4, in1'length));
        wait for 40 ns;
        assert(signed(result) = to_signed(-40, result'length)) report "Error : 10*-4 = " & integer'image(to_integer(unsigned(result))) & " instead of -40" severity warning;
        assert(signed(result_hi) = to_signed(-1, result_hi'length)) report "Error : result_hi = " & integer'image(to_integer(unsigned(result_hi))) & " instead of -1" severity warning;

        -- Unsigned mult: test 65536 * 131072
        op_sel    <= "011001";
        in1 <= std_logic_vector(to_unsigned(65536, in1'length));
        in2 <= std_logic_vector(to_unsigned(131072, in1'length));
        wait for 40 ns;
        assert(unsigned(result) = to_unsigned(65536 * 131072, result'length)) report "Error : 65536 * 131072 = " & integer'image(to_integer(unsigned(result))) & " instead of 65536 * 131072" severity warning;

        -- 0x0000FFFF and 0xFFFF1234
        op_sel    <= "100100";
        in1 <= "00000000000000001111111111111111";
        in2 <= "11111111111111110001001000110100";
        wait for 40 ns;
        assert(result = "00000000000000000001001000110100") report "Error : 0x0000FFFF and 0xFFFF1234 = " & integer'image(to_integer(unsigned(result))) & " instead of 0x00001234" severity warning;

        -- shift right logical of 0x0000000F by 4
        op_sel    <= "000010";
        ir10_6    <= "00100";
        in1 <= std_logic_vector(to_unsigned(0, in1'length));
        in2 <= std_logic_vector(to_unsigned(15, in1'length));
        wait for 40 ns;
        assert(unsigned(result) = to_unsigned(0, result'length)) report "Error : sll 0xF,4 = " & integer'image(to_integer(unsigned(result))) & " instead of 0" severity warning;


        -- shift right arithmetic of 0xF0000008 by 1
        op_sel    <= "000011";
        ir10_6    <= "00001";
        in1 <= std_logic_vector(to_unsigned(131072, in1'length));
        in2 <= "11110000000000000000000000001000";
        wait for 40 ns;
        assert(result = "11111000000000000000000000000100") report "Error : sra 0xF0000008, 1 = " & integer'image(to_integer(unsigned(result))) & " instead of 0xF8000004" severity warning;

        -- shift right arithmetic of 0x00000008 by 1
        in1 <= std_logic_vector(to_unsigned(131072, in1'length));
        in2 <= "00000000000000000000000000001000";
        wait for 40 ns;
        assert(result = "00000000000000000000000000000100") report "Error : sra 0x00000008, 1 = " & integer'image(to_integer(unsigned(result))) & " instead of 0x00000004" severity warning;

        -- set on less than using 10 and 15
        op_sel    <= "101010";
        in1 <= std_logic_vector(to_unsigned(10, in1'length));
        in2 <= std_logic_vector(to_unsigned(15, in1'length));
        wait for 40 ns;
        assert(unsigned(result) = to_unsigned(1, result'length)) report "Error : 10 < 15 = " & integer'image(to_integer(unsigned(result))) & " instead of 1" severity warning;

        -- set on less than using 15 and 10
        in1 <= std_logic_vector(to_unsigned(15, in1'length));
        in2 <= std_logic_vector(to_unsigned(10, in1'length));
        wait for 40 ns;
        assert(unsigned(result) = to_unsigned(0, result'length)) report "Error : 15 < 10 = " & integer'image(to_integer(unsigned(result))) & " instead of 0" severity warning;

        -- Branch Taken output = ‘0’ for for 5 <= 0
        op_sel <= "000110";
        in1 <= std_logic_vector(to_unsigned(5, in1'length));
        in2 <= std_logic_vector(to_unsigned(15, in1'length));
        wait for 40 ns;
        assert(branch = '0') report "Error : 5 <= 0 branch wrong" severity warning;

        -- Branch Taken output = ‘1’ for for 5 > 0
        op_sel <= "000111";
        in1 <= std_logic_vector(to_unsigned(5, in1'length));
        in2 <= std_logic_vector(to_unsigned(15, in1'length));
        wait for 40 ns;
        assert(branch = '1') report "Error : 5 > 0 branch wrong." severity warning;

        report "Simulation Finished.";
        wait;

    end process;



end TB;