library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity MAE_testbench is
end entity MAE_testbench;

architecture test of MAE_testbench is
    component MAE is
        port(
            clk         : in  std_logic;
            rst         : in  std_logic;
            irq         : in std_logic;
            irq_serv    : out std_logic;
            inst_mem    : in std_logic_vector(31 downto 0);
            inst_reg    : in std_logic_vector(31 downto 0);
            N           : in std_logic;
            AdrSel      : out std_logic;
            memRdEn     : out std_logic;
            memWrEn     : out std_logic;
            irWrEn      : out std_logic;
            WSel        : out std_logic;
            RegWrEn     : out std_logic;
            RbSel       : out std_logic;
            AluSelA     : out std_logic;
            AluSelB     : out std_logic_vector(1 downto 0);
            AluOP       : out std_logic_vector(1 downto 0);
            CpsrSel     : out std_logic;
            CpsrWrEn    : out std_logic;
            SpsrWrEn    : out std_logic;
            PCSel       : out std_logic_vector(1 downto 0);
            PCWrEn      : out std_logic;
            LRWrEn      : out std_logic;
            ResWrEn     : out std_logic
        );
    end component;
    
    signal clk_tb, rst_tb : std_logic := '0';
    signal irq_tb : std_logic := '0';
    signal irq_serv_tb : std_logic;
    signal inst_mem_tb, inst_reg_tb : std_logic_vector(31 downto 0) := (others => '0');
    signal N_tb : std_logic := '0';
    
    signal AdrSel_tb : std_logic;
    signal memRdEn_tb, memWrEn_tb : std_logic;
    signal irWrEn_tb : std_logic;
    signal WSel_tb, RegWrEn_tb, RbSel_tb : std_logic;
    signal AluSelA_tb : std_logic;
    signal AluSelB_tb : std_logic_vector(1 downto 0);
    signal AluOP_tb : std_logic_vector(1 downto 0);
    signal CpsrSel_tb, CpsrWrEn_tb, SpsrWrEn_tb : std_logic;
    signal PCSel_tb : std_logic_vector(1 downto 0);
    signal PCWrEn_tb, LRWrEn_tb : std_logic;
    signal ResWrEn_tb : std_logic;
    
    constant CLK_PERIOD : time := 10 ns;

begin
    UUT: MAE port map (
        clk => clk_tb,
        rst => rst_tb,
        irq => irq_tb,
        irq_serv => irq_serv_tb,
        inst_mem => inst_mem_tb,
        inst_reg => inst_reg_tb,
        N => N_tb,
        AdrSel => AdrSel_tb,
        memRdEn => memRdEn_tb,
        memWrEn => memWrEn_tb,
        irWrEn => irWrEn_tb,
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
        report "=== TEST MAE ===";
        
        rst_tb <= '1';
        wait for CLK_PERIOD*2;
        rst_tb <= '0';
        wait for CLK_PERIOD;
        
        report "Test 1: Etat initial E1";
        assert memRdEn_tb = '1' report "E1: memRdEn devrait etre 1" severity error;
        assert AdrSel_tb = '0' report "E1: AdrSel devrait etre 0 (PC)" severity error;
        
        wait for CLK_PERIOD;
        
        report "Test 2: Etat E2 - Chargement IR";
        inst_mem_tb <= x"E3A01010"; -- MOV R1,#0x10
        wait for CLK_PERIOD;
        
        assert irWrEn_tb = '1' report "E2: irWrEn devrait etre 1" severity error;
        assert PCWrEn_tb = '1' report "E2: PCWrEn devrait etre 1" severity error;
        
        inst_reg_tb <= x"E3A01010";
        wait for CLK_PERIOD;
        
        report "Test 3: Decodage MOV - Etat E6";
        assert AluOP_tb = "01" report "MOV: AluOP devrait etre 01" severity error;
        assert AluSelB_tb = "01" report "MOV: AluSelB devrait etre 01" severity error;
        
        wait for CLK_PERIOD;
        
        report "Test 4: Etat E13 - Ecriture registre";
        assert WSel_tb = '1' report "E13: WSel devrait etre 1" severity error;
        assert RegWrEn_tb = '1' report "E13: RegWrEn devrait etre 1" severity error;
        
        wait for CLK_PERIOD;
        
        report "Test 5: Retour E1";
        assert memRdEn_tb = '1' report "Retour E1: memRdEn devrait etre 1" severity error;
        
        report "Test 6: Instruction STR";
        inst_mem_tb <= x"E4012000"; -- STR R2,0(R1)
        inst_reg_tb <= x"E4012000";
        wait for CLK_PERIOD*2;
        
        wait for CLK_PERIOD*2; -- E9
        assert memWrEn_tb = '1' report "STR: memWrEn devrait etre 1" severity error;
        assert ResWrEn_tb = '1' report "STR: ResWrEn devrait etre 1" severity error;
        
        report "Test 7: Instruction BLT avec N=1";
        inst_mem_tb <= x"BAFFFFFB"; -- BLT
        inst_reg_tb <= x"BAFFFFFB";
        N_tb <= '1';
        wait for CLK_PERIOD*2;
        
        assert PCWrEn_tb = '1' report "BLT(N=1): PCWrEn devrait etre 1" severity error;
        assert AluSelB_tb = "10" report "BLT: AluSelB devrait etre 10 (Ext24)" severity error;
        
        report "Test 8: Interruption";
        irq_tb <= '1';
        wait for CLK_PERIOD*2;
        
        assert SpsrWrEn_tb = '1' report "IRQ: SpsrWrEn devrait etre 1" severity error;
        assert LRWrEn_tb = '1' report "IRQ: LRWrEn devrait etre 1" severity error;
        
        wait for CLK_PERIOD;
        assert PCSel_tb = "11" report "IRQ: PCSel devrait etre 11 (VIC)" severity error;
        assert irq_serv_tb = '1' report "IRQ: irq_serv devrait etre 1" severity error;
        
        report "=== MAE TEST COMPLET ===";
        wait;
    end process;
    
end architecture test;