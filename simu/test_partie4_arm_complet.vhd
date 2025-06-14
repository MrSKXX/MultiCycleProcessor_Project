-- Test PARTIE 4 : ARM Complet avec MAE corrigée
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity test_partie4_arm_complet is
end entity test_partie4_arm_complet;

architecture test of test_partie4_arm_complet is

    component arm is
        port(
            clk         : in std_logic;
            rst         : in std_logic;
            irq0,irq1   : in std_logic;
            resultat    : out std_logic_vector(31 downto 0)
        );
    end component;
    
    signal clk_tb : std_logic := '0';
    signal rst_tb : std_logic := '0';
    signal irq0_tb, irq1_tb : std_logic := '0';
    signal resultat_tb : std_logic_vector(31 downto 0);
    
    constant CLK_PERIOD : time := 20 ns;
    signal cycle_count : integer := 0;

begin

    UUT: arm port map (
        clk => clk_tb,
        rst => rst_tb,
        irq0 => irq0_tb,
        irq1 => irq1_tb,
        resultat => resultat_tb
    );
    
    -- Générateur d'horloge
    clk_tb <= not clk_tb after CLK_PERIOD/2;
    
    -- Compteur de cycles
    process(clk_tb)
    begin
        if rising_edge(clk_tb) then
            cycle_count <= cycle_count + 1;
        end if;
    end process;
    
    -- Processus de test principal
    test_process: process
    begin
        report "=== DEBUT TEST PARTIE 4 - ARM COMPLET ===";
        
        -- Reset initial
        report "--- RESET INITIAL ---";
        rst_tb <= '1';
        wait for CLK_PERIOD*5;
        rst_tb <= '0';
        wait for CLK_PERIOD*2;
        
        report "Processeur demarre, execution du programme...";
        report "Programme: MOV R1,#0x20; MOV R2,#0; boucle sum 1+2+...+10";
        report "Resultat attendu: 55 (0x37)";
        
        -- Surveillance pendant l'exécution
        for i in 1 to 150 loop
            wait for CLK_PERIOD;
            
            -- Affichage périodique des états
            if i mod 20 = 0 then
                report "Cycle " & integer'image(i) & 
                       " - Resultat = " & integer'image(to_integer(unsigned(resultat_tb)));
            end if;
            
            -- Arrêt anticipé si résultat trouvé
            if resultat_tb /= x"00000000" then
                report "RESULTAT DETECTE au cycle " & integer'image(i);
                report "Valeur = " & integer'image(to_integer(unsigned(resultat_tb)));
                exit;
            end if;
        end loop;
        
        -- Vérification finale
        wait for CLK_PERIOD*10;
        
        report "=== VERIFICATION FINALE ===";
        if resultat_tb = x"00000037" then
            report "SUCCES COMPLET: Resultat = 55 (0x37)" severity note;
            report "Le programme calcule correctement 1+2+...+10 = 55";
            report "ARM MULTI-CYCLE FONCTIONNE PARFAITEMENT !";
        elsif resultat_tb = x"00000000" then
            report "ECHEC: Resultat reste a 0" severity error;
            report "Instruction STR jamais executee ou probleme calcul";
        else
            report "RESULTAT INATTENDU: " & integer'image(to_integer(unsigned(resultat_tb))) severity warning;
            report "Verifiez la logique du programme ou les interruptions";
        end if;
        
        -- Test interruptions
        report "--- TEST INTERRUPTIONS ---";
        
        -- Test IRQ0 (+1)
        report "Test IRQ0 - Devrait ajouter +1 au resultat";
        irq0_tb <= '1';
        wait for CLK_PERIOD;
        irq0_tb <= '0';
        wait for CLK_PERIOD*30; -- Laisser le temps au traitement
        
        if resultat_tb = x"00000038" then
            report "SUCCES IRQ0: +1 detecte, nouveau resultat = 56";
        else
            report "IRQ0: Resultat = " & integer'image(to_integer(unsigned(resultat_tb)));
        end if;
        
        -- Test IRQ1 (+2)
        report "Test IRQ1 - Devrait ajouter +2 au resultat";
        irq1_tb <= '1';
        wait for CLK_PERIOD;
        irq1_tb <= '0';
        wait for CLK_PERIOD*30;
        
        if resultat_tb = x"0000003A" then
            report "SUCCES IRQ1: +2 detecte, nouveau resultat = 58";
        else
            report "IRQ1: Resultat = " & integer'image(to_integer(unsigned(resultat_tb)));
        end if;
        
        -- Résumé final
        report "=== RESUME FINAL ARM COMPLET ===";
        if resultat_tb >= x"00000037" then
            report "1. Programme principal: SUCCES";
        else
            report "1. Programme principal: ECHEC";
        end if;
        
        if resultat_tb > x"00000037" then
            report "2. Gestion interruptions: FONCTIONNELLE";
        else
            report "2. Gestion interruptions: A VERIFIER";
        end if;
        
        report "3. Resultat final: " & integer'image(to_integer(unsigned(resultat_tb)));
        
        if resultat_tb >= x"00000037" then
            report "CONCLUSION: PROJET ARM MULTI-CYCLE REUSSI !";
        else
            report "CONCLUSION: Problemes detectes - Debug necessaire";
        end if;
        
        report "=== FIN TEST PARTIE 4 ===";
        wait;
    end process;

end architecture test;