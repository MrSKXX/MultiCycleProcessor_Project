library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ARM_testbench is
end entity ARM_testbench;

architecture test of ARM_testbench is
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

begin
    UUT: arm port map (
        clk => clk_tb,
        rst => rst_tb,
        irq0 => irq0_tb,
        irq1 => irq1_tb,
        resultat => resultat_tb
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
        report "=== TEST PROCESSEUR ARM COMPLET ===";
        
        rst_tb <= '1';
        wait for CLK_PERIOD*5;
        rst_tb <= '0';
        wait for CLK_PERIOD;
        
        report "Execution du programme principal...";
        report "Programme: somme 1+2+...+10 = 55 (0x37)";
        
        -- Laisser le processeur exécuter
        for i in 1 to 100 loop
            wait for CLK_PERIOD;
            
            -- Surveiller le résultat
            if resultat_tb /= x"00000000" then
                report "RESULTAT DETECTE: " & integer'image(to_integer(unsigned(resultat_tb)));
                exit;
            end if;
            
            -- Affichage périodique
            if i mod 20 = 0 then
                report "Cycle " & integer'image(i) & ", résultat = " & 
                       integer'image(to_integer(unsigned(resultat_tb)));
            end if;
        end loop;
        
        -- Verification finale
        wait for CLK_PERIOD*10;
        
        if resultat_tb = x"00000037" then
            report "SUCCES: Resultat correct = 55 (0x37)";
        elsif resultat_tb = x"00000000" then
            report "ECHEC: Resultat reste a 0 - STR pas execute";
        else
            report "ATTENTION: Resultat = " & 
                   integer'image(to_integer(unsigned(resultat_tb))) & 
                   " (attendu 55)";
        end if;
        
        -- Test interruption
        report "Test interruption IRQ0 (+1)...";
        irq0_tb <= '1';
        wait for CLK_PERIOD;
        irq0_tb <= '0';
        wait for CLK_PERIOD*20;
        
        if resultat_tb = x"00000038" then
            report "INTERRUPTION OK: +1 detecte";
        else
            report "INTERRUPTION ECHEC: Pas d'effet visible";
        end if;
        
        -- Test interruption IRQ1
        report "Test interruption IRQ1 (+2)...";
        irq1_tb <= '1';
        wait for CLK_PERIOD;
        irq1_tb <= '0';
        wait for CLK_PERIOD*20;
        
        if resultat_tb = x"0000003A" then
            report "INTERRUPTION OK: +2 detecte";
        else
            report "INTERRUPTION ECHEC: Pas d'effet visible";
        end if;
        
        report "=== FIN TEST ARM ===";
        wait;
    end process;
    
    -- Moniteur continu du resultat
    monitor: process(resultat_tb)
    begin
        if resultat_tb /= x"00000000" then
            report "CHANGEMENT RESULTAT: " & integer'image(to_integer(unsigned(resultat_tb)));
        end if;
    end process;
    
end architecture test;