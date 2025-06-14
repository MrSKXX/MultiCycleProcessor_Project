library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity DataPath_testbench is
end entity DataPath_testbench;

architecture test of DataPath_testbench is
    component DataPath is
        port(
            clk,rst     : in std_logic;
            irq0,irq1   : in std_logic;
            irq         : out std_logic;
            irq_serv    : in std_logic;
            Inst_Mem   : out std_logic_vector(31 downto 0);
            Inst_Reg   : out std_logic_vector(31 downto 0);
            N           : out std_logic;
            AdrSel      : in std_logic;
            MemRdEn     : in std_logic;
            MemWrEn     : in std_logic;
            IrWrEn      : in std_logic;
            WSel        : in std_logic;
            RegWrEn     : in std_logic;
            RbSel       : in std_logic;
            AluSelA     : in std_logic;
            AluSelB     : in std_logic_vector(1 downto 0);
            AluOP       : in std_logic_vector(1 downto 0);
            CpsrSel     : in std_logic;
            CpsrWrEn    : in std_logic;
            SpsrWrEn    : in std_logic;
            PCSel       : in std_logic_vector(1 downto 0);
            PCWrEn      : in std_logic;
            LRWrEn      : in std_logic;
            Res         : out std_logic_vector(31 downto 0);
            ResWrEn     : in std_logic
        );
    end component;
    
    signal clk_tb, rst_tb : std_logic := '0';
    signal irq0_tb, irq1_tb : std_logic := '0';
    signal irq_tb : std_logic;
    signal irq_serv_tb : std_logic := '0';
    signal Inst_Mem_tb, Inst_Reg_tb : std_logic_vector(31 downto 0);
    signal N_tb : std_logic;
    signal Res_tb : std_logic_vector(31 downto 0);
    
    signal AdrSel_tb : std_logic := '0';
    signal MemRdEn_tb : std_logic := '0';
    signal MemWrEn_tb : std_logic := '0';
    signal IrWrEn_tb : std_logic := '0';
    signal WSel_tb : std_logic := '0';
    signal RegWrEn_tb : std_logic := '0';
    signal RbSel_tb : std_logic := '0';
    signal AluSelA_tb : std_logic := '0';
    signal AluSelB_tb : std_logic_vector(1 downto 0) := "00";
    signal AluOP_tb : std_logic_vector(1 downto 0) := "00";
    signal CpsrSel_tb : std_logic := '0';
    signal CpsrWrEn_tb : std_logic := '0';
    signal SpsrWrEn_tb : std_logic := '0';
    signal PCSel_tb : std_logic_vector(1 downto 0) := "00";
    signal PCWrEn_tb : std_logic := '0';
    signal LRWrEn_tb : std_logic := '0';
    signal ResWrEn_tb : std_logic := '0';
    
    constant CLK_PERIOD : time := 10 ns;

begin
    UUT: DataPath port map (
        clk => clk_tb,
        rst => rst_tb,
        irq0 => irq0_tb,
        irq1 => irq1_tb,
        irq => irq_tb,
        irq_serv => irq_serv_tb,
        Inst_Mem => Inst_Mem_tb,
        Inst_Reg => Inst_Reg_tb,
        N => N_tb,
        AdrSel => AdrSel_tb,
        MemRdEn => MemRdEn_tb,
        MemWrEn => MemWrEn_tb,
        IrWrEn => IrWrEn_tb,
        WSel => WSel_tb,
        RegWrEn => RegWrEn_tb,
        RbSel => RbSel_tb,
        AluSelA => AluSelA_tb,
        AluSelB => AluSelB_tb,
        AluOP => AluOP_tb,
        CpsrSel => CpsrSel_tb,
        CpsrWrEn => CpsrWrEn_tb,
        SpsrWrEn => SpsrWrEn_tb,
        PCSel => PCSel_tb,
        PCWrEn => PCWrEn_tb,
        LRWrEn => LRWrEn_tb,
        Res => Res_tb,
        ResWrEn => ResWrEn_tb
    );
    
    clk_process: process
    begin
        clk_tb <= '0';
        wait for CLK_PERIOD/2;
        clk_tb <= '1';
        wait for CLK_PERIOD/2;
    end process;
    
    stimulus: process
    begin
        report "=== TEST DATAPATH ===";
        
        rst_tb <= '1';
        wait for CLK_PERIOD*2;
        rst_tb <= '0';
        wait for CLK_PERIOD;
        
        report "Test lecture memoire PC=0";
        MemRdEn_tb <= '1';
        AdrSel_tb <= '0';
        wait for CLK_PERIOD;
        
        report "Test instruction en memoire";
        assert Inst_Mem_tb = x"E3A01020" report "PC=0: Instruction devrait etre MOV R1,#0x20" severity error;
        
        report "Test chargement IR";
        IrWrEn_tb <= '1';
        wait for CLK_PERIOD;
        IrWrEn_tb <= '0';
        
        assert Inst_Reg_tb = x"E3A01020" report "IR: Instruction devrait etre chargee" severity error;
        
        report "Test VIC - interruption IRQ0";
        irq0_tb <= '1';
        wait for CLK_PERIOD;
        irq0_tb <= '0';
        wait for CLK_PERIOD;
        
        assert irq_tb = '1' report "VIC: IRQ devrait etre active" severity error;
        
        report "Test ecriture resultat";
        ResWrEn_tb <= '1';
        wait for CLK_PERIOD;
        ResWrEn_tb <= '0';
        
        report "=== DATAPATH TEST COMPLETE ===";
        wait;
    end process;
    
end architecture test;