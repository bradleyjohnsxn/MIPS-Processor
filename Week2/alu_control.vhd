library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
entity alu_control is
    
    port (
        alu_op : in std_logic_vector(1 downto 0);
        ir20_16 : in std_logic_vector(4 downto 0);
        ir5_0, op_code : in std_logic_vector(5 downto 0);
        hi_en, lo_en : out std_logic;
        alu_lo_hi : out std_logic_vector(1 downto 0);
        op_sel : out std_logic_vector(5 downto 0)
    );
end alu_control;

architecture ctrl of alu_control is
    constant ADD : std_logic_vector(1 downto 0) := "00";
    constant R_TYPE : std_logic_vector(1 downto 0) := "01";
    constant I_TYPE : std_logic_vector(1 downto 0) := "10";
    constant BRANCH : std_logic_vector(1 downto 0) := "11";
    
begin
    
    process(alu_op, ir5_0, ir20_16, op_code)
    begin
        hi_en <= '0';
        lo_en <= '0';
        alu_lo_hi <= "00";
        op_sel <= "100001";
        
        if(alu_op = ADD) then
            op_sel <= "100001";

        -- R TYPE INSTRUCTIONS
        elsif(alu_op = R_TYPE) then
            op_sel <= ir5_0;

            if(ir5_0 = "011000" or ir5_0 = "011001") then -- mult/multu
                hi_en <= '1';
                lo_en <= '1';

            elsif(ir5_0 = "010000") then -- mfhi
                alu_lo_hi <= "10";

            elsif(ir5_0 = "010010") then -- mflo
                alu_lo_hi <= "01";
                
            elsif(ir5_0 = "100011") then -- sub
                op_sel <= "100010";

            end if;
        
        -- I TYPE INSTRUCTIONS
        elsif(alu_op = I_TYPE) then
            op_sel <= op_code;
            if(op_code = "100011") then
                op_sel <= "110000";
            elsif(op_code = "010000") then
                op_sel <= "111100";
            elsif(op_code = "101011") then
                op_sel <= "111000";
            end if;

        -- BRANCH INSTRUCTIONS
        elsif(alu_op = BRANCH) then
            op_sel <= op_code;
            if(ir20_16 = "00001") then
                op_sel <= "111111";
            end if;

        end if;

    end process;
    
end ctrl;