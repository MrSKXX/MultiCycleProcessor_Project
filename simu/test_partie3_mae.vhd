-- Test PARTIE 3 : MAE isolée pour identifier le problème de décodage
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity test_partie3_mae is
end entity test_partie3_mae;

architecture test of test_partie3_mae is

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
    
    constant CLK_PERIOD : time := 20 ns;

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
    
    clk_tb <= not clk_tb after CLK_PERIOD/2;
    
    test_process: process
    begin
        report "=== DEBUT TEST PARTIE 3 - MAE ===";
        
        rst_tb <= '1';
        wait for CLK_PERIOD*2;
        rst_tb <= '0';
        wait for CLK_PERIOD;
        
        -- TEST 1: MOV R1,#0x20 = E3A01020
        report "--- TEST MOV R1,#32 ---";
        -- Attendre E1
        wait for CLK_PERIOD;
        -- Charger instruction
        inst_mem_tb <= x"E3A01020";
        -- Attendre E2 (chargement IR)
        wait for CLK_PERIOD;
        inst_reg_tb <= x"E3A01020";
        -- Attendre que la MAE decode et execute
        wait for CLK_PERIOD*3;
        
        if AluOP_tb = "01" and AluSelB_tb = "01" then
            report "SUCCES MOV: AluOP=01, AluSelB=01";
        else
            report "ECHEC MOV: Signaux incorrects";
        end if;
        
        wait for CLK_PERIOD;
        
        -- TEST 2: STR R2,0(R1) = E6012000 (CRITIQUE!)
        report "--- TEST STR R2,0(R1) - CRITIQUE ---";
        -- Reset pour nouveau test
        wait for CLK_PERIOD;
        -- Charger nouvelle instruction
        inst_mem_tb <= x"E6012000";
        wait for CLK_PERIOD;
        inst_reg_tb <= x"E6012000";
        -- Attendre execution complete
        wait for CLK_PERIOD*5;
        
        if memWrEn_tb = '1' and ResWrEn_tb = '1' and AdrSel_tb = '1' then
            report "SUCCES STR CRITIQUE: memWrEn=1, ResWrEn=1, AdrSel=1";
        else
            report "ECHEC STR CRITIQUE: ResWrEn pas a 1 !";
        end if;
        
        wait for CLK_PERIOD;
        
        -- TEST 3: ADD R2,R2,R0 = E0822000
        report "--- TEST ADD R2,R2,R0 ---";
        wait for CLK_PERIOD;
        inst_mem_tb <= x"E0822000";
        wait for CLK_PERIOD;
        inst_reg_tb <= x"E0822000";
        wait for CLK_PERIOD*4;
        
        if AluOP_tb = "00" and AluSelA_tb = '1' and AluSelB_tb = "00" then
            report "SUCCES ADD: AluOP=00, AluSelA=1, AluSelB=00";
        else
            report "ECHEC ADD: Signaux incorrects";
        end if;
        
        wait for CLK_PERIOD;
        
        -- TEST 4: CMP R1,0x2A = E351002A
        report "--- TEST CMP R1,42 ---";
        wait for CLK_PERIOD;
        inst_mem_tb <= x"E351002A";
        wait for CLK_PERIOD;
        inst_reg_tb <= x"E351002A";
        wait for CLK_PERIOD*3;
        
        if AluOP_tb = "10" and CpsrWrEn_tb = '1' then
            report "SUCCES CMP: AluOP=10, CpsrWrEn=1";
        else
            report "ECHEC CMP: Signaux incorrects";
        end if;
        
        wait for CLK_PERIOD;
        
        -- TEST 5: BLT avec N=1 = BAFFFFFC
        report "--- TEST BLT (N=1) ---";
        wait for CLK_PERIOD;
        inst_mem_tb <= x"BAFFFFFC";
        wait for CLK_PERIOD;
        inst_reg_tb <= x"BAFFFFFC";
        N_tb <= '1';
        wait for CLK_PERIOD*3;
        
        if PCWrEn_tb = '1' and AluSelB_tb = "10" then
            report "SUCCES BLT: PCWrEn=1, AluSelB=10";
        else
            report "ECHEC BLT: Signaux incorrects";
        end if;
        
        N_tb <= '0';
        wait for CLK_PERIOD*3;
        
        report "=== RESUME TEST PARTIE 3 ===";
        report "POINT CRITIQUE: ResWrEn doit etre a 1 pour STR";
        report "Verifiez waveforms pour transitions etats";
        
        wait;
    end process;

end architecture test;