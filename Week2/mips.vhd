library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mips is
    port (
        clk : in  std_logic;
        switches           : in std_logic_vector(9 downto 0);
        buttons           : in std_logic_vector(1 downto 0);
        outport    : out std_logic_vector(31 downto 0));
end mips;

architecture STR of mips is
    
    signal op_code : std_logic_vector(5 downto 0);
    signal pc_wr_cond, pc_wr : std_logic;
    signal i_or_d : std_logic;
    signal mem_read, mem_write : std_logic;
    signal mem_to_reg : std_logic;
    signal ir_wr : std_logic;
    signal jump_and_link : std_logic;
    signal is_signed : std_logic;
    signal alu_src_a : std_logic;
    signal alu_op : std_logic_vector(1 downto 0);
    signal alu_src_b, pc_src : std_logic_vector(1 downto 0);
    signal reg_wr, reg_dst : std_logic;
    signal ir5_0 : std_logic_vector(5 downto 0);
    signal addr : std_logic_vector(31 downto 0);

    signal inv_buttons : std_logic_vector(1 downto 0);

begin  -- STR

    inv_buttons(1) <= not buttons(1);
    inv_buttons(0) <= not buttons(0);

    U_CONTROLLER : entity work.controller
        port map(
            clk => clk,
            rst => inv_buttons(1),
            op_code => op_code,
            ir5_0 => ir5_0,
            pc_wr_cond => pc_wr_cond, 
            pc_wr => pc_wr,
            i_or_d => i_or_d,
            mem_read => mem_read, 
            mem_write => mem_write,
            mem_to_reg => mem_to_reg,
            ir_wr => ir_wr,
            jump_and_link => jump_and_link,
            is_signed => is_signed,
            alu_src_a => alu_src_a,
            alu_op => alu_op,
            alu_src_b => alu_src_b, 
            pc_src => pc_src,
            reg_wr => reg_wr, 
            reg_dst => reg_dst,
            addr => addr
        );

    U_DATAPATH : entity work.datapath
        port map (
            clk => clk,
            pc_wr_cond => pc_wr_cond, 
            pc_wr => pc_wr,
            i_or_d => i_or_d,
            mem_read => mem_read, 
            mem_write => mem_write,
            mem_to_reg => mem_to_reg,
            ir_wr => ir_wr,
            jump_and_link => jump_and_link,
            is_signed => is_signed,
            alu_src_a => alu_src_a,
            alu_op => alu_op,
            ir5_0 => ir5_0,
            op_code => op_code,
            alu_src_b => alu_src_b, 
            pc_src => pc_src,
            reg_wr => reg_wr, 
            reg_dst => reg_dst,
            buttons => inv_buttons,
            switches => switches,
            outport => outport,
            addr => addr
        );

    
end STR;