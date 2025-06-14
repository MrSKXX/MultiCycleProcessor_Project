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

    -- Signaux de test
    signal clk_tb, rst_tb : std_logic := '0';
    signal irq_tb : std_logic := '0';
    signal irq_serv_tb : std_logic;
    signal inst_mem_tb, inst_reg_tb : std_logic_vector(31 downto 0) := (others => '0');
    signal N_tb : std_logic := '0';
    
    -- Signaux de sortie MAE
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
    signal test_step : integer := 0;
    signal test_passed : boolean := true;

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
    
    -- Générateur d'horloge
    clk_tb <= not clk_tb after CLK_PERIOD/2;
    
    -- Processus de test principal
    test_process: process
    begin
        report "=== DEBUT TEST PARTIE 3 - MAE ===";
        
        -- ETAPE 1: Reset et état initial
        test_step <= 1;
        report "--- ETAPE 1: RESET ET ETAT INITIAL ---";
        rst_tb <= '1';
        wait for CLK_PERIOD*2;
        rst_tb <= '0';
        wait for CLK_PERIOD;
        
        -- Vérifier état E1
        if memRdEn_tb = '1' and AdrSel_tb = '0' then
            report "SUCCES: Etat E1 - Lecture memoire PC activee" severity note;
        else
            report "ECHEC: Etat E1 - Signaux incorrects" severity error;
            test_passed <= false;
        end if;
        
        -- ETAPE 2: Transition E1 -> E2
        test_step <= 2;
        report "--- ETAPE 2: TRANSITION E1 -> E2 ---";
        inst_mem_tb <= x"E3A01020"; -- MOV R1,#0x20
        wait for CLK_PERIOD;
        
        -- Vérifier état E2
        if irWrEn_tb = '1' and PCWrEn_tb = '1' then
            report "SUCCES: Etat E2 - Chargement IR et PC++" severity note;
        else
            report "ECHEC: Etat E2 - Signaux incorrects" severity error;
            test_passed <= false;
        end if;
        
        -- ETAPE 3: Décodage MOV
        test_step <= 3;
        report "--- ETAPE 3: DECODAGE MOV R1,#0x20 ---";
        inst_reg_tb <= x"E3A01020"; -- Charger instruction dans IR
        wait for CLK_PERIOD;
        
        -- Vérifier transition vers E7 (MOV immediate)
        -- État E7: AluOP="01" (pass B), AluSelB="01" (immediate)
        wait for CLK_PERIOD/4; -- Petit délai pour stabilisation
        
        if AluOP_tb = "01" and AluSelB_tb = "01" then
            report "SUCCES: Decodage MOV - Transition vers E7" severity note;
        else
            report "ECHEC: Decodage MOV - Mauvaise transition" severity error;
            report "AluOP attendu: 01, recu: " & std_logic'image(AluOP_tb(1)) & std_logic'image(AluOP_tb(0));
            report "AluSelB attendu: 01, recu: " & std_logic'image(AluSelB_tb(1)) & std_logic'image(AluSelB_tb(0));
            test_passed <= false;
        end if;
        
        -- ETAPE 4: État E13 (écriture registre)
        test_step <= 4;
        report "--- ETAPE 4: ETAT E13 - ECRITURE REGISTRE ---";
        wait for CLK_PERIOD;
        
        -- Vérifier E13: WSel='1', RegWrEn='1'
        if WSel_tb = '1' and RegWrEn_tb = '1' then
            report "SUCCES: Etat E13 - Ecriture registre OK" severity note;
        else
            report "ECHEC: Etat E13 - Signaux ecriture incorrects" severity error;
            test_passed <= false;
        end if;
        
        -- ETAPE 5: Retour à E1
        test_step <= 5;
        report "--- ETAPE 5: RETOUR E1 ---";
        wait for CLK_PERIOD;
        
        if memRdEn_tb = '1' and AdrSel_tb = '0' then
            report "SUCCES: Retour a E1 - Lecture memoire reactivee" severity note;
        else
            report "ECHEC: Retour E1 - Probleme cycle" severity error;
            test_passed <= false;
        end if;
        
        -- ETAPE 6: Test instruction ADD
        test_step <= 6;
        report "--- ETAPE 6: TEST ADD R2,R2,R0 ---";
        inst_mem_tb <= x"E0822000";
        inst_reg_tb <= x"E0822000";
        wait for CLK_PERIOD*3;
        
        -- Chercher état avec ADD: AluOP="00", AluSelA='1', AluSelB="00"
        if AluOP_tb = "00" and AluSelA_tb = '1' and AluSelB_tb = "00" then
            report "SUCCES: Decodage ADD correct" severity note;
        else
            report "ECHEC: Decodage ADD incorrect" severity error;
            test_passed <= false;
        end if;
        
        -- ETAPE 7: Test instruction STR  
        test_step <= 7;
        report "--- ETAPE 7: TEST STR R2,0(R1) ---";
        inst_mem_tb <= x"E6012000";
        inst_reg_tb <= x"E6012000";
        wait for CLK_PERIOD*3;
        
        -- Chercher état avec STR: memWrEn='1', ResWrEn='1'
        if memWrEn_tb = '1' and ResWrEn_tb = '1' then
            report "SUCCES: Decodage STR correct" severity note;
        else
            report "ECHEC: Decodage STR incorrect" severity error;
            test_passed <= false;
        end if;
        
        -- ETAPE 8: Test interruption
        test_step <= 8;
        report "--- ETAPE 8: TEST INTERRUPTION ---";
        irq_tb <= '1';
        wait for CLK_PERIOD*2;
        
        if SpsrWrEn_tb = '1' and LRWrEn_tb = '1' then
            report "SUCCES: Gestion interruption - Sauvegarde contexte" severity note;
        else
            report "ECHEC: Gestion interruption defaillante" severity error;
            test_passed <= false;
        end if;
        
        -- ETAPE 9: Résumé final
        test_step <= 9;
        report "--- ETAPE 9: RESUME FINAL ---";
        wait for CLK_PERIOD;
        
        report "=== RESUME TEST PARTIE 3 ===";
        if test_passed then
            report "PARTIE 3 REUSSIE - MAE fonctionne correctement";
            report "Tous les decodages d'instructions sont OK";
            report "Transitions d'etats correctes";
        else
            report "PARTIE 3 ECHEC - Problemes MAE identifies";
            report "Verifiez le decodage des instructions";
            report "Verifiez les transitions d'etats";
        end if;
        
        report "=== FIN TEST PARTIE 3 ===";
        wait;
    end process;

end architecture test;