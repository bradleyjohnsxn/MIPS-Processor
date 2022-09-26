library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity controller is
    port (
        clk, rst : in std_logic;
        addr : in std_logic_vector(31 downto 0);
        op_code, ir5_0 : in std_logic_vector(5 downto 0);

        pc_wr_cond, pc_wr : out std_logic;
        i_or_d : out std_logic;
        mem_read, mem_write : out std_logic;
        mem_to_reg : out std_logic;
        ir_wr : out std_logic;
        jump_and_link : out std_logic;
        is_signed : out std_logic;
        alu_src_a : out std_logic;
        alu_op : out std_logic_vector(1 downto 0);
        alu_src_b, pc_src : out std_logic_vector(1 downto 0);
        reg_wr, reg_dst : out std_logic;
        addr_en : out std_logic);
end controller;

architecture bhv of controller is
    type state_t is (fetch1, fetch2, decode_rfetch, rtype1, rtype2, itype1, itype2, lw_sw, lw1, sw1, lw2, lw3, j, link, link2, branch0, branch1, halt);
    signal state_r, next_state : state_t;

    constant ADD : std_logic_vector(1 downto 0) := "00";
    constant R_TYPE : std_logic_vector(1 downto 0) := "01";
    constant I_TYPE : std_logic_vector(1 downto 0) := "10";
    constant BRANCH : std_logic_vector(1 downto 0) := "11";

begin

    -- state register
    process (clk, rst)
    begin
        if (rst = '1') then
            state_r  <= fetch1;
    
        elsif (rising_edge(clk)) then
            state_r <= next_state;
    
        end if;
    end process;

    -- next state + controls
    process(state_r, op_code, ir5_0, addr)

    begin
        -- default values
        next_state <= state_r;
        pc_wr_cond <= '0';
        pc_wr <= '0';
        i_or_d <= '0';
        mem_read <= '0';
        mem_write <= '0';
        mem_to_reg <= '0';
        ir_wr <= '0';
        jump_and_link <= '0';
        is_signed <= '0';
        alu_src_a <= '0';
        alu_op <= (others => '0');
        alu_src_b <= "00";
        pc_src <= "00";
        reg_wr <= '0'; 
        reg_dst <= '0';
        addr_en <= '0';
  
        case state_r is
          
            -- INSTRUCTION FETCH
            when fetch1 =>
                i_or_d <= '0';      -- mem[PC]
                alu_src_a <= '0';   -- PC + 4
                alu_src_b <= "01";
                alu_op <= ADD;
                pc_src <= "00";     -- PC = PC + 4
                pc_wr <= '1';
                next_state <= fetch2;

            when fetch2 =>
                ir_wr <= '1';       -- IR = mem[PC]
                next_state <= decode_rfetch;

            -- INSTRUCTION DECODE / REGISTER FETCH
            when decode_rfetch =>
                if(op_code = "000000") then
                    alu_op <= R_TYPE;
                    next_state <= rtype1;
                elsif(op_code = "100011" or op_code = "101011") then -- lw/sw
                    next_state <= lw_sw;
                    i_or_d <= '1';
                elsif(op_code = "001111") then -- halt
                        next_state <= halt;
                elsif(op_code = "000100" or op_code = "000101" or op_code="000110"
                    or op_code = "000111" or op_code="000001") then
                    next_state <= branch0;
                elsif(op_code /= "000010" and op_code /= "000011") then
                    alu_op <= I_TYPE;
                    next_state <= itype1;
                else
                    next_state <= j;
        
                end if;
                
            -- R TYPE States.
            when rtype1 =>
                alu_op <= R_TYPE;
                alu_src_a <= '1';
                alu_src_b <= "00";
                if(ir5_0 = "001000") then -- jr
                    pc_wr <= '1';
                    next_state <= rtype2;
                elsif (ir5_0 = "011000" or ir5_0 = "011001") then -- mult/multu
                    next_state <= fetch1;
                else
                    next_state <= rtype2;
                end if;

            when rtype2 =>
                alu_op <= R_TYPE;
                mem_to_reg <= '0';
                reg_dst <= '1';
                reg_wr <= '1';
                if(ir5_0 = "001000") then
                    next_state <= fetch2;
                else
                    next_state <= fetch1;
                end if;

            -- I TYPE States.
            when itype1 =>
                alu_op <= I_TYPE;
                alu_src_a <= '1';
                alu_src_b <= "10";
                if(op_code /= "001100" and op_code /= "001101" and op_code /= "001110") then
                    is_signed <= '1';
                end if;

                next_state <= itype2;
                

            when itype2 =>
                alu_op <= I_TYPE;
                mem_to_reg <= '0';
                reg_dst <= '0';
                reg_wr <= '1';
                next_state <= fetch1;

            -- LOAD WORD / STORE WORD
            when lw_sw =>
                alu_op <= I_TYPE;
                alu_src_a <= '1';
                alu_src_b <= "10";
                if(op_code = "100011") then
                    next_state <= lw1;
                else
                    next_state <= sw1;
                end if;

            when lw1 =>
                i_or_d <= '1';
                addr_en <= '1';
                next_state <= lw2;

            when sw1 =>
                i_or_d <= '1';
                mem_write <= '1';
                next_state <= fetch1;

            when lw2 =>
                if(addr = x"0000FFF8" or addr=x"0000FFFC") then
                    mem_to_reg <= '1';
                    reg_wr <= '1';
                    reg_dst <= '0';
                    next_state <= fetch1;
                else
                    next_state <= lw3;
                end if;

            when lw3 =>
                mem_to_reg <= '1';
                reg_wr <= '1';
                reg_dst <= '0';
                next_state <= fetch1;

            -- J TYPE INSTRUCTIONS
            when j =>
                if(op_code = "000011") then
                    alu_src_a <= '0';
                    alu_src_b <= "01";
                    alu_op <= BRANCH;
                    next_state <= link;
                else
                    pc_src <= "10";
                    pc_wr <= '1';
                    next_state <= fetch1;
                end if;

            when link =>
                pc_src <= "10";
                pc_wr <= '1';
                next_state <= link2;
                
            when link2 =>
                mem_to_reg <= '0';
                jump_and_link <= '1';
                next_state <= fetch1;

            -- BRANCH INSTRUCTIONS
            when branch0 =>
                is_signed <= '1';
                alu_src_a <= '0';
                alu_src_b <= "11";
                alu_op <= ADD;
                next_state <= branch1;

            when branch1 =>
                alu_op <= BRANCH;
                alu_src_a <= '1';
                pc_wr_cond <= '1';
                pc_src <= "01";
                next_state <= fetch1;
            
            when halt =>
                next_state <= halt;
                
            when others =>
                next_state <= fetch1;

        end case;
    end process;
end bhv;