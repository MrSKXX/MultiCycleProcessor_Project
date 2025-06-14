# Debug complet avec waveforms - style monocycle
# debug_waveforms_complet.do

vlib work

# Compilation complete
echo "=== COMPILATION ==="
vcom -93 -work work ALU.vhd
vcom -93 -work work RegisterBank.vhd
vcom -93 -work work Mux2v1.vhd
vcom -93 -work work Mux4v1.vhd
vcom -93 -work work SignExtender.vhd
vcom -93 -work work Reg32.vhd
vcom -93 -work work Reg32_WrEn.vhd
vcom -93 -work work VIC.vhd
vcom -93 -work work DualPortRAM.vhd
vcom -93 -work work DataPath.vhd
vcom -93 -work work MAE.vhd
vcom -93 -work work arm.vhd

# Simulation avec interface graphique
vsim -t 1ns work.arm

# Configuration de la fenetre des signaux
configure wave -namecolwidth 350
configure wave -valuecolwidth 120
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0

# SIGNAUX PRINCIPAUX
add wave -divider "=== SIGNAUX PRINCIPAUX ==="
add wave -position insertpoint \
sim:/arm/clk \
sim:/arm/rst

# ETATS MAE - CRITIQUE
add wave -divider "=== ETATS MAE (CRITIQUE) ==="
add wave -position insertpoint \
sim:/arm/MAE1/current_state \
sim:/arm/MAE1/next_state \
sim:/arm/MAE1/ISR

# INSTRUCTIONS - VERIFICATION PROGRAMME
add wave -divider "=== INSTRUCTIONS ==="
add wave -position insertpoint -radix hexadecimal \
sim:/arm/inst_mem \
sim:/arm/inst_reg

# CONTROLE MEMOIRE
add wave -divider "=== CONTROLE MEMOIRE ==="
add wave -position insertpoint \
sim:/arm/AdrSel \
sim:/arm/MemRdEn \
sim:/arm/MemWrEn \
sim:/arm/IrWrEn

# PC ET ADRESSAGE
add wave -divider "=== PC ET ADRESSAGE ==="
add wave -position insertpoint -radix hexadecimal \
sim:/arm/DataPath1/PC_out \
sim:/arm/DataPath1/PC_next \
sim:/arm/DataPath1/mem_addr \
sim:/arm/PCWrEn \
sim:/arm/PCSel

# CONTROLE REGISTRES
add wave -divider "=== CONTROLE REGISTRES ==="
add wave -position insertpoint \
sim:/arm/RegWrEn \
sim:/arm/WSel \
sim:/arm/RbSel

# ALU ET DRAPEAUX
add wave -divider "=== ALU ET DRAPEAUX ==="
add wave -position insertpoint \
sim:/arm/AluSelA \
sim:/arm/AluSelB \
sim:/arm/AluOP \
sim:/arm/N

# DONNEES MEMOIRE
add wave -divider "=== DONNEES MEMOIRE ==="
add wave -position insertpoint -radix hexadecimal \
sim:/arm/DataPath1/mem_data_out \
sim:/arm/DataPath1/IR_out \
sim:/arm/DataPath1/DR_out

# REGISTRES IMPORTANTS
add wave -divider "=== REGISTRES (R1, R2) ==="
add wave -radix decimal -position insertpoint \
sim:/arm/DataPath1/REG_FILE/Banc(1) \
sim:/arm/DataPath1/REG_FILE/Banc(2)

# BUS DE DONNEES
add wave -divider "=== BUS DE DONNEES ==="
add wave -position insertpoint -radix hexadecimal \
sim:/arm/DataPath1/reg_BusA \
sim:/arm/DataPath1/reg_BusB \
sim:/arm/DataPath1/ALU_out \
sim:/arm/DataPath1/ALU_reg_out

# INTERRUPTIONS
add wave -divider "=== INTERRUPTIONS ==="
add wave -position insertpoint \
sim:/arm/irq0 \
sim:/arm/irq1 \
sim:/arm/irq \
sim:/arm/irq_serv

# RESULTAT FINAL
add wave -divider "=== RESULTAT FINAL ==="
add wave -position insertpoint -radix hexadecimal \
sim:/arm/resultat \
sim:/arm/ResWrEn

# MEMOIRE PROGRAMME (CRITIQUE)
add wave -divider "=== MEMOIRE PROGRAMME ==="
add wave -position insertpoint -radix hexadecimal \
sim:/arm/DataPath1/MEMORY/ram_block(0) \
sim:/arm/DataPath1/MEMORY/ram_block(1) \
sim:/arm/DataPath1/MEMORY/ram_block(2) \
sim:/arm/DataPath1/MEMORY/ram_block(7)

# MEMOIRE DONNEES
add wave -divider "=== MEMOIRE DONNEES ==="
add wave -position insertpoint -radix decimal \
sim:/arm/DataPath1/MEMORY/ram_block(32) \
sim:/arm/DataPath1/MEMORY/ram_block(33) \
sim:/arm/DataPath1/MEMORY/ram_block(34) \
sim:/arm/DataPath1/MEMORY/ram_block(35) \
sim:/arm/DataPath1/MEMORY/ram_block(36)

# Configuration des entrees
force clk 0 0, 1 10ns -repeat 20ns
force rst 1 0, 0 50ns
force irq0 0
force irq1 0

echo "=== DEMARRAGE SIMULATION ==="
run 1000ns

# Zoom pour voir tous les signaux
wave zoom full

echo "=========================================="
echo "   VERIFICATION CRITIQUE"
echo "=========================================="
echo "REGARDEZ LES WAVEFORMS POUR:"
echo ""
echo "1. ETATS MAE:"
echo "   - current_state change-t-il de E1 vers E2 ?"
echo "   - Reste-t-il bloque sur E1 ?"
echo ""
echo "2. PC ET INSTRUCTIONS:"
echo "   - PC_out s'incremente-t-il ?"
echo "   - inst_mem contient-il E3A01020 ?"
echo "   - inst_reg se charge-t-il ?"
echo ""
echo "3. SIGNAUX DE CONTROLE:"
echo "   - MemRdEn s'active-t-il en E1 ?"
echo "   - IrWrEn s'active-t-il en E2 ?"
echo "   - PCWrEn s'active-t-il ?"
echo ""
echo "4. MEMOIRE PROGRAMME:"
echo "   - ram_block(0) = E3A01020 ?"
echo "   - ram_block(1) = E3A02000 ?"
echo "   - ram_block(7) = E4012000 ?"
echo ""
echo "5. MEMOIRE DONNEES:"
echo "   - ram_block(32) = 1 ?"
echo "   - ram_block(33) = 2 ?"
echo "   - ram_block(34) = 3 ?"
echo ""
echo "6. RESULTAT:"
echo "   - resultat change-t-il de 0 ?"
echo "   - ResWrEn s'active-t-il pour STR ?"
echo ""
echo "=========================================="
echo "DIAGNOSTIC POSSIBLE:"
echo "- Si MAE reste en E1: Probleme next_state"
echo "- Si PC ne bouge pas: Probleme PCWrEn"
echo "- Si inst_mem = 0: Probleme memoire/adressage"
echo "- Si ResWrEn jamais a 1: STR jamais execute"
echo "=========================================="

# Commandes utiles pour debug
echo "=== COMMANDES UTILES ==="
echo "Pour relancer: restart -f; run 1000ns"
echo "Pour voir registres:"
echo "examine sim:/arm/DataPath1/REG_FILE/Banc"
echo "Pour voir memoire programme:"
echo "examine sim:/arm/DataPath1/MEMORY/ram_block"