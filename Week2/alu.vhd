library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
entity alu is
    generic (
        WIDTH : positive := 32
    );
    port (
        in1 : in std_logic_vector(WIDTH-1 downto 0);
        in2 : in std_logic_vector(WIDTH-1 downto 0);
        op_sel : in std_logic_vector(5 downto 0);
        ir10_6  : in std_logic_vector(4 downto 0);

        branch : out std_logic;
        result, result_hi : out std_logic_vector(WIDTH-1 downto 0)
    );
end alu;

architecture operations of alu is
    constant C0 : std_logic_vector(WIDTH-2 downto 0) := (others => '0');
begin

    process(in1,in2,ir10_6,op_sel)
        variable temp_mult  : std_logic_vector(2*WIDTH-1 downto 0);
        variable shift : integer range 0 to 31;
        variable rsl, lsl, rsa : std_logic_vector(WIDTH-1 downto 0);
    begin
            result <= (others => '0');
            result_hi <= (others => '0');
            branch <= '0';
            shift := to_integer(unsigned(ir10_6));
            rsl := std_logic_vector(shift_right(unsigned(in2), shift)); 
            lsl := std_logic_vector(shift_left(unsigned(in2), shift));
            rsa := std_logic_vector(shift_right(signed(in2), shift));
            

        case op_sel is

            -- addu/addiu (in1 + in2 unsigned)
            when "100001" =>--
                result <= std_logic_vector(signed(in1) + signed(in2));

            when "001001" =>--
                result <= std_logic_vector(signed(in1) + signed(in2));
            
            -- subu/subiu (in1 - in2 unsigned)
            when "100010" =>--
                result <= std_logic_vector(signed(in1) - signed(in2));

            when "111100" =>--
                result <= std_logic_vector(signed(in1) - signed(in2));

            -- mult (in1 * in2 signed)
            when "011000" =>--
                temp_mult := std_logic_vector(signed(in1) * signed(in2));
                result <= temp_mult(WIDTH-1 downto 0);
                result_hi <= temp_mult(WIDTH*2-1 downto WIDTH);

            -- multu (in1 * in2 unsigned)
            when "011001" =>--
                temp_mult := std_logic_vector(unsigned(in1) * unsigned(in2));
                result <= temp_mult(WIDTH-1 downto 0);
                result_hi <= temp_mult(WIDTH*2-1 downto WIDTH);

            -- and/andi (in1 and in2)
            when "100100" =>--
                result <= in1 and in2;

            when "001100" =>--
                result <= in1 and in2;

            -- or/ori (in1 or in2)
            when "100101" =>--
                result <= in1 or in2;
                
            when "001101" =>--
                result <= in1 or in2;

            -- xor/xori (in1 xor in2)
            when "100110" =>--
                result <= in1 xor in2;

            when "001110" =>--
                result <= in1 xor in2;

            -- srl (in2 >> ir10_6 logical)
            when "000010" =>--
                result <= rsl;

            -- sll (in2 << ir10_6 logical)
            when "000000" =>--
                result <= lsl;

            -- sra (in2 >> ir10_6 arithmetic)
            when "000011" =>--
                result <= rsa;
        
            -- slt/slti ('1' when in1 < in2 else '0' signed)
            when "101010" =>--
                if(signed(in1) < signed(in2)) then
                    result <= C0 & '1';
                else
                    result <= C0 & '0';
                end if;

            when "001010" =>--
                if(signed(in1) < signed(in2)) then
                    result <= C0 & '1';
                else
                    result <= C0 & '0';
                end if;

            -- sltu/sltiu (result <= '1' when in1 < in2 else '0' unsigned)
            when "101011" =>--
                if(unsigned(in1) < unsigned(in2)) then
                    result <= C0 & '1';
                else
                    result <= C0 & '0';
                end if;

            when "001011" =>--
                if(unsigned(in1) < unsigned(in2)) then
                    result <= C0 & '1';
                else
                    result <= C0 & '0';
                end if;

            -- mfhi (result = in2)
            when "010000" =>--
                result <= in2;

            -- mflo (result = in2)
            when "010010" =>--
                result <= in2;

            -- beq (branch <= '1' when in1=in2 else '0')
            when "000100" =>
                if(in1 = in2) then
                    branch <= '1';
                end if;

            -- bne (branch <= '1' when in1/=in2 else '0')
            when "000101" =>
                if(in1 /= in2) then
                    branch <= '1';
                end if;

            -- blez (branch <= '1' when in1<=0 else '0')
            when "000110" =>
                if(signed(in1) <= signed(in2)) then
                    branch <= '1';
                end if;

            -- bgtz (branch <= '1' when in1>0 else '0')
            when "000111" =>
                if(signed(in1) > signed(in2)) then
                    branch <= '1';
                end if;

            -- bltz (branch <= '1' when in1<0 else '0')
            when "000001" =>
                if(signed(in1) < signed(in2)) then
                    branch <= '1';
                end if;

            -- bgez (branch <= '1' when in1>=0 else '0')
            when "111111" => -- diff
                if(signed(in1) >= signed(in2)) then
                    branch <= '1';
                end if;

            -- lw
            when "110000" =>--
                result <= std_logic_vector(signed(in1) + signed(in2));

            -- sw
            when "111000" =>--
                result <= std_logic_vector(signed(in1) + signed(in2));

            -- jr
            when "001000" =>
                result <= in1;

            -- result = 0 for all others
            when others =>
                result <= (others => '0');
        end case;

    end process;
end operations;