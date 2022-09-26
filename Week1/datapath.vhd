library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity datapath is
    port (
        clk : in std_logic;

        -- controller
        pc_wr_cond, pc_wr : in std_logic;
        i_or_d : in std_logic;
        mem_read, mem_write : in std_logic;
        mem_to_reg : in std_logic;
        ir_wr : in std_logic;
        jump_and_link : in std_logic;
        is_signed : in std_logic;
        alu_src_a : in std_logic;
        alu_op : in std_logic_vector(1 downto 0);
        alu_src_b, pc_src : in std_logic_vector(1 downto 0);
        reg_wr, reg_dst : in std_logic;
        op_code, ir5_0 : out std_logic_vector(5 downto 0);

        -- top level / interface
        buttons : in std_logic_vector(1 downto 0);
        switches : in std_logic_vector(9 downto 0);
        outport : out std_logic_vector(31 downto 0)
    );
end datapath;

architecture dp of datapath is

    signal inport0_en, inport1_en : std_logic;
    signal inport : std_logic_vector(31 downto 0);
    signal pc_en, ir_wr_en : std_logic;

    signal branch_taken : std_logic;
    signal pc_in, pc_out, src_pc_mux_in3 : std_logic_vector(31 downto 0);
    signal alu_out : std_logic_vector(31 downto 0);
    signal address, mem_out : std_logic_vector(31 downto 0);
    signal ir_out, mdr_out : std_logic_vector(31 downto 0);
    signal reg_b_out, reg_a_out : std_logic_vector(31 downto 0);
    signal wr_addr : std_logic_vector(4 downto 0);
    signal wr_data, rd_data0, rd_data1 : std_logic_vector(31 downto 0);
    signal alu_in1, alu_in2 : std_logic_vector(31 downto 0);
    signal sign_ext_ir15_10, sign_ext_ir15_10_4x : std_logic_vector(31 downto 0);
    signal op_sel : std_logic_vector(5 downto 0);
    signal alu_result, alu_result_hi : std_logic_vector(31 downto 0);
    signal hi_en, lo_en : std_logic;
    signal alu_lo_hi : std_logic_vector(1 downto 0);
    signal hi_r, lo_r, alu_lo_hi_out : std_logic_vector(31 downto 0);
    signal ir20_16 : std_logic_vector(4 downto 0);

begin

    inport0_en <= '1' when (buttons(0) = '1' and switches(9) = '0') else '0';
    inport1_en <= '1' when (buttons(0) = '1' and switches(9) = '1') else '0';
    inport <= std_logic_vector(resize(unsigned(switches(8 downto 0)), 32));
    pc_en <= '1' when ((branch_taken = '1' and pc_wr_cond = '1') or pc_wr = '1') else '0';
    src_pc_mux_in3 <= (pc_out(31 downto 28) & std_logic_vector(shift_left(resize(unsigned(ir_out(25 downto 0)), 28), 2)));
    op_code <= ir_out(31 downto 26);
    ir5_0 <= ir_out(5 downto 0);
    ir_wr_en <= ir_wr and not hi_en;
    ir20_16 <= ir_out(20 downto 16);

    process(ir_out(15 downto 0), is_signed)
    begin
        if(is_signed = '1') then
            sign_ext_ir15_10 <= std_logic_vector(resize(signed(ir_out(15 downto 0)), 32));
        else
            sign_ext_ir15_10 <= std_logic_vector(resize(unsigned(ir_out(15 downto 0)), 32));
        end if;
    end process;

    sign_ext_ir15_10_4x <= std_logic_vector(shift_left(unsigned(sign_ext_ir15_10),2));

    U_PC : entity work.reg
        generic map (WIDTH => 32)
        port map(
            clk => clk,
            rst => buttons(1),
            en => pc_en,
            input => pc_in,
            output => pc_out
        );

    U_ADDR_MUX : entity work.mux2x1
        generic map (WIDTH => 32)
        port map(
            in1 => pc_out,
            in2 => alu_out,
            sel => i_or_d,
            output => address
        );

    U_MEMORY : entity work.memory
        port map(
            clk => clk,
            rst => buttons(1),
            inport => inport,
            inport0_en => inport0_en,
            inport1_en => inport1_en,
            mem_read => mem_read,
            mem_write => mem_write,
            address => address,
            data => reg_b_out,
            outport => outport,
            output => mem_out
        );

    U_IR : entity work.reg
        generic map(WIDTH => 32)
        port map(
            clk => clk,
            rst => buttons(1),
            en => ir_wr_en,
            input => mem_out,
            output => ir_out
        );
    
    U_MEM_DATA_R : entity work.reg
        generic map(WIDTH => 32)
        port map(
            clk => clk,
            rst => buttons(1),
            en => '1',
            input => mem_out,
            output => mdr_out
        );

    U_W_REG_MUX : entity work.mux2x1
        generic map (WIDTH => 5)
        port map(
            in1 => ir_out(20 downto 16),
            in2 => ir_out(15 downto 11),
            sel => reg_dst,
            output => wr_addr
        );

    U_W_DATA_MUX : entity work.mux2x1
        generic map (WIDTH => 32)
        port map(
            in1 => alu_lo_hi_out,
            in2 => mdr_out,
            sel => mem_to_reg,
            output => wr_data
        );

    U_REG_FILE : entity work.register_file
        generic map(WIDTH => 32,
            NUM_DATA_BITS => 32)
        port map(
            clk => clk,
            rst => buttons(1),
            rd_addr0 => ir_out(25 downto 21),
            rd_addr1 => ir_out(20 downto 16),
            wr_addr => wr_addr,
            wr_en => reg_wr,
            jump_and_link => jump_and_link,
            wr_data => wr_data,
            rd_data0 => rd_data0,
            rd_data1 => rd_data1
        );

    U_REG_A : entity work.reg
        generic map(WIDTH => 32)
        port map(
            clk => clk,
            rst => buttons(1),
            en => '1',
            input => rd_data0,
            output => reg_a_out
        );
    
    U_REG_B : entity work.reg
        generic map(WIDTH => 32)
        port map(
            clk => clk,
            rst => buttons(1),
            en => '1',
            input => rd_data1,
            output => reg_b_out
        );

    U_SRC_A_MUX : entity work.mux2x1
        generic map (WIDTH => 32)
        port map(
            in1 => pc_out,
            in2 => reg_a_out,
            sel => alu_src_a,
            output => alu_in1
        );

    U_SRC_B_MUX : entity work.mux4x1
        generic map (WIDTH => 32)
        port map(
            in1 => reg_b_out,
            in2 => std_logic_vector(to_unsigned(4, 32)),
            in3 => sign_ext_ir15_10,
            in4 => sign_ext_ir15_10_4x,
            sel => alu_src_b,
            output => alu_in2
        );

    U_ALU : entity work.alu
        generic map(WIDTH => 32)
        port map(
            in1 => alu_in1,
            in2 => alu_in2,
            op_sel => op_sel,
            ir10_6 => ir_out(10 downto 6),
            branch => branch_taken,
            result => alu_result,
            result_hi => alu_result_hi
        );
    
    U_ALU_OUT : entity work.reg
        generic map(WIDTH => 32)
        port map(
            clk => clk,
            rst => buttons(1),
            en => '1',
            input => alu_result,
            output => alu_out
        );

    U_HI : entity work.reg
        generic map(WIDTH => 32)
        port map(
            clk => clk,
            rst => buttons(1),
            en => hi_en,
            input => alu_result_hi,
            output => hi_r
        );

    U_LO : entity work.reg
        generic map(WIDTH => 32)
        port map(
            clk => clk,
            rst => buttons(1),
            en => lo_en,
            input => alu_result,
            output => lo_r
        );

    U_SRC_PC_MUX : entity work.mux4x1
        generic map (WIDTH => 32)
        port map(
            in1 => alu_result,
            in2 => alu_out,
            in3 => src_pc_mux_in3,
            in4 => (others => '0'),
            sel => pc_src,
            output => pc_in
        );

    U_ALU_LO_HI_MUX : entity work.mux4x1
        generic map (WIDTH => 32)
        port map(
            in1 => alu_out,
            in2 => lo_r,
            in3 => hi_r,
            in4 => (others => '0'),
            sel => alu_lo_hi,
            output => alu_lo_hi_out
        );

    U_ALU_CONTROL : entity work.alu_control
        port map(
            alu_op => alu_op,
            ir5_0 => ir_out(5 downto 0),
            hi_en => hi_en,
            lo_en => lo_en,
            alu_lo_hi => alu_lo_hi,
            op_sel => op_sel,
            op_code => ir_out(31 downto 26),
            ir20_16 => ir20_16
        );
    
end dp;