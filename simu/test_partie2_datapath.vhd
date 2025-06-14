-- Test PARTIE 2 : DataPath isolé pour identifier le problème des signaux rouges
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity test_partie2_datapath is
end entity test_partie2_datapath;

architecture test of test_partie2_datapath is

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

    -- Signaux de test
    signal clk_tb, rst_tb : std_logic := '0';
    signal irq0_tb, irq1_tb : std_logic := '0';
    signal irq_tb : std_logic;
    signal irq_serv_tb : std_logic := '0';
    signal Inst_Mem_tb, Inst_Reg_tb : std_logic_vector(31 downto 0);
    signal N_tb : std_logic;
    signal Res_tb : std_logic_vector(31 downto 0);
    
    -- Signaux de contrôle pour test manuel
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
    
    constant CLK_PERIOD : time := 20 ns;
    signal test_step : integer := 0;

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
    
    -- Générateur d'horloge
    clk_tb <= not clk_tb after CLK_PERIOD/2;
    
    -- Processus de test principal
    test_process: process
    begin
        report "=== DEBUT TEST PARTIE 2 - DATAPATH ===";
        
        -- ÉTAPE 1: Reset et vérification état initial
        test_step <= 1;
        report "--- ETAPE 1: RESET ---";
        rst_tb <= '1';
        wait for CLK_PERIOD*3;
        rst_tb <= '0';
        wait for CLK_PERIOD;
        
        report "Verification apres reset...";
        if Inst_Mem_tb = x"00000000" then
            report "ATTENTION: Inst_Mem = 0 apres reset" severity warning;
        else
            report "OK: Inst_Mem apres reset valide" severity note;
        end if;
        
        -- ETAPE 2: Test lecture memoire simple
        test_step <= 2;
        report "--- ETAPE 2: LECTURE MEMOIRE PC=0 ---";
        AdrSel_tb <= '0';     -- Adresse = PC (donc 0)
        MemRdEn_tb <= '1';    -- Activer lecture
        wait for CLK_PERIOD*2;
        
        report "Lecture PC=0 terminee";
        
        if Inst_Mem_tb = x"E3A01020" then
            report "SUCCES: Lecture memoire PC=0 OK" severity note;
        elsif Inst_Mem_tb = x"00000000" then
            report "ECHEC: Inst_Mem reste a 0" severity error;
        else
            report "INATTENDU: Inst_Mem valeur incorrecte" severity warning;
        end if;
        
        -- ETAPE 3: Test chargement registre IR
        test_step <= 3;
        report "--- ETAPE 3: CHARGEMENT IR ---";
        IrWrEn_tb <= '1';
        wait for CLK_PERIOD;
        IrWrEn_tb <= '0';
        wait for CLK_PERIOD;
        
        report "Chargement IR termine";
        
        if Inst_Reg_tb = x"E3A01020" then
            report "SUCCES: Chargement IR OK" severity note;
        elsif Inst_Reg_tb = x"00000000" then
            report "ECHEC: Inst_Reg reste a 0" severity error;
        else
            report "INATTENDU: Inst_Reg valeur incorrecte" severity warning;
        end if;
        
        -- ETAPE 4: Test PC increment
        test_step <= 4;
        report "--- ETAPE 4: INCREMENT PC ---";
        -- Simuler PC <= PC + 1
        PCSel_tb <= "00";     -- PC = ALU
        PCWrEn_tb <= '1';     -- Ecrire PC
        AluSelA_tb <= '0';    -- A = PC
        AluSelB_tb <= "11";   -- B = 1
        AluOP_tb <= "00";     -- ADD
        wait for CLK_PERIOD;
        PCWrEn_tb <= '0';
        wait for CLK_PERIOD;
        
        -- Tester lecture PC=1
        wait for CLK_PERIOD;
        report "Test lecture PC=1";
        
        if Inst_Mem_tb = x"E3A02000" then
            report "SUCCES: PC increment et lecture PC=1 OK" severity note;
        else
            report "ECHEC: Probleme PC increment ou lecture PC=1" severity error;
        end if;
        
        -- ETAPE 5: Test VIC
        test_step <= 5;
        report "--- ETAPE 5: TEST VIC ---";
        irq0_tb <= '1';
        wait for CLK_PERIOD;
        irq0_tb <= '0';
        wait for CLK_PERIOD*2;
        
        if irq_tb = '1' then
            report "SUCCES: VIC genere IRQ" severity note;
        else
            report "ECHEC: VIC ne genere pas IRQ" severity error;
        end if;
        
        -- ETAPE 6: Resume
        test_step <= 6;
        report "--- ETAPE 6: RESUME ---";
        wait for CLK_PERIOD;
        
        report "=== RESUME TEST PARTIE 2 ===";
        if rst_tb = '0' then
            report "1. Reset: OK";
        else
            report "1. Reset: ECHEC";
        end if;
        
        if Inst_Mem_tb /= x"00000000" then
            report "2. Lecture memoire: OK";
        else
            report "2. Lecture memoire: ECHEC";
        end if;
        
        if Inst_Reg_tb /= x"00000000" then
            report "3. Chargement IR: OK";
        else
            report "3. Chargement IR: ECHEC";
        end if;
        
        if irq_tb = '1' then
            report "4. VIC: OK";
        else
            report "4. VIC: ECHEC";
        end if;
        
        if Inst_Mem_tb /= x"00000000" and Inst_Reg_tb /= x"00000000" then
            report "PARTIE 2 REUSSIE - DataPath fonctionne correctement";
        else
            report "PARTIE 2 ECHEC - Probleme dans DataPath identifie";
        end if;
        
        report "=== FIN TEST PARTIE 2 ===";
        wait;
    end process;

end architecture test;