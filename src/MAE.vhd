library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MAE is
  port(
        clk     : in  std_logic;
        rst     : in  std_logic;
        
        -- Gestion des Interruptions
        irq     : in std_logic;
        irq_serv: out std_logic;
        
        -- Gestion des Instructions
        inst_mem: in std_logic_vector(31 downto 0);
        inst_reg: in std_logic_vector(31 downto 0);
        N       : in std_logic;
        
        -- Memoire Interne
        AdrSel  : out std_logic;
        memRdEn : out std_logic;
        memWrEn : out std_logic;
        
        -- Registre Instruction
        irWrEn  : out std_logic;
        
        -- Banc de Registres
        WSel    : out std_logic;
        RegWrEn : out std_logic;
        RbSel   : out std_logic;
        
        -- ALU
        AluSelA : out std_logic;
        AluSelB : out std_logic_vector(1 downto 0);
        AluOP   : out std_logic_vector(1 downto 0);
        
        -- Registres d'Etat CPSR et SPSR
        CpsrSel : out std_logic;
        CpsrWrEn: out std_logic;
        SpsrWrEn: out std_logic;
        
        -- Registres PC et LR      
        PCSel   : out std_logic_vector(1 downto 0);
        PCWrEn  : out std_logic;
        LRWrEn  : out std_logic;
        
        -- Registre Resultat
        ResWrEn : out std_logic
      );
end entity;

architecture archi of MAE is

    -- Definition des etats
    type state_type is (E1, E2, E3, E4, E5, E6, E7, E8, E9, E10, E11, E12, E13, E15, E16, E17, E18);
    signal current_state, next_state : state_type;
    
    -- Signal ISR pour gestion interruptions
    signal ISR : std_logic;
    signal ISR_next : std_logic;
    
    -- Decodage instruction
    signal opcode : std_logic_vector(7 downto 0);
    signal instr_type : std_logic_vector(3 downto 0);
    
begin 

    -- Extraction du code operation
    opcode <= inst_reg(31 downto 24);
    instr_type <= inst_reg(27 downto 24);
    
    -- Processus sequentiel - Evolution des etats
    process(clk, rst)
    begin
        if rst = '1' then
            current_state <= E1;
            ISR <= '0';
        elsif rising_edge(clk) then
            current_state <= next_state;
            ISR <= ISR_next;
        end if;
    end process;
    
    -- Processus combinatoire - Calcul prochain etat
    process(current_state, irq, ISR, inst_reg, inst_mem, N, opcode, instr_type)
    begin
        -- Valeurs par defaut
        next_state <= current_state;
        ISR_next <= ISR;
        
        case current_state is
            when E1 => -- Lecture MEM[PC]
                next_state <= E2;
                
            when E2 => -- Chargement IR, Test interruption
                if irq = '1' and ISR = '0' then
                    next_state <= E16; -- Sauvegarde contexte
                else
                    -- Decodage instruction
                    if inst_reg(31 downto 28) = x"E" and inst_reg(27 downto 0) = x"B000000" then
                        next_state <= E18; -- BX instruction
                    else
                        case instr_type is
                            when x"E" => -- Instructions ARM normales
                                case opcode(7 downto 4) is
                                    when x"3" => next_state <= E6;  -- MOV immediate
                                    when x"0" => next_state <= E3;  -- ADD/SUB registres
                                    when x"2" => next_state <= E3;  -- ADD/SUB immediate
                                    when x"1" => next_state <= E8;  -- CMP
                                    when x"4" => next_state <= E9;  -- LDR/STR
                                    when x"5" => next_state <= E9;  -- LDR/STR
                                    when x"6" => next_state <= E9;  -- LDR/STR
                                    when others => next_state <= E1;
                                end case;
                            when x"B" => next_state <= E4;  -- BLT
                            when x"A" => next_state <= E15; -- BAL  
                            when others => next_state <= E1;
                        end case;
                    end if;
                end if;
                
            when E3 => -- PC <= PC + 1, A <= Reg[Rn], B <= Reg[Rm]
                next_state <= E5;
                
            when E4 => -- PC <= PC + Imm24
                next_state <= E1;
                
            when E5 => -- ALUOut <= A + Imm8
                next_state <= E13;
                
            when E6 => -- ALUOut <= A + B
                next_state <= E13;
                
            when E7 => -- ALUOut <= Imm8
                next_state <= E13;
                
            when E8 => -- Flag <= cmp(A,Imm8)
                next_state <= E1;
                
            when E9 => -- DR <= Mem[ALUOut]
                if inst_reg(20) = '1' then -- LDR
                    next_state <= E10;
                else -- STR
                    next_state <= E12;
                end if;
                
            when E10 => -- Pas de charge
                next_state <= E11;
                
            when E11 => -- Reg[Rd] <= DR
                next_state <= E1;
                
            when E12 => -- Mem[ALUOut] <= B
                next_state <= E1;
                
            when E13 => -- Reg[Rd] <= ALUOut
                next_state <= E1;
                
            when E15 => -- PC <= PC + 1
                next_state <= E1;
                
            when E16 => -- SPSR <= CPSR, LR <= PC
                ISR_next <= '1';
                next_state <= E17;
                
            when E17 => -- PC <= VIC, ISR <= 1
                next_state <= E1;
                
            when E18 => -- PC <= LR, CPSR <= SPSR
                ISR_next <= '0';
                next_state <= E1;
                
            when others =>
                next_state <= E1;
        end case;
    end process;
    
    -- Processus combinatoire - Signaux de commande
    process(current_state, inst_reg, N)
    begin
        -- Valeurs par defaut (desactivees)
        irq_serv <= '0';
        AdrSel <= '0';
        memRdEn <= '0';
        memWrEn <= '0';
        irWrEn <= '0';
        WSel <= '0';
        RegWrEn <= '0';
        RbSel <= '0';
        AluSelA <= '0';
        AluSelB <= "00";
        AluOP <= "00";
        CpsrSel <= '0';
        CpsrWrEn <= '0';
        SpsrWrEn <= '0';
        PCSel <= "00";
        PCWrEn <= '0';
        LRWrEn <= '0';
        ResWrEn <= '0';
        
        case current_state is
            when E1 => -- Lecture MEM[PC]
                memRdEn <= '1';
                AdrSel <= '0'; -- Adresse = PC
                
            when E2 => -- Chargement IR
                irWrEn <= '1';
                PCSel <= "00"; -- PC = ALU
                PCWrEn <= '1';
                AluSelA <= '0'; -- A = PC
                AluSelB <= "11"; -- B = 1
                AluOP <= "00"; -- ADD
                
            when E3 => -- PC <= PC + 1, Lecture registres
                PCSel <= "00";
                PCWrEn <= '1';
                AluSelA <= '0'; -- A = PC  
                AluSelB <= "11"; -- B = 1
                AluOP <= "00"; -- ADD
                
            when E4 => -- PC <= PC + Imm24 (BLT si N=1)
                if (inst_reg(31 downto 24) = x"BA" and N = '1') or 
                   inst_reg(31 downto 24) = x"EA" then -- BAL
                    PCSel <= "00";
                    PCWrEn <= '1';
                    AluSelA <= '0'; -- A = PC
                    AluSelB <= "10"; -- B = Ext24
                    AluOP <= "00"; -- ADD
                end if;
                
            when E5 => -- ALUOut <= A + Imm8
                AluSelA <= '1'; -- A = RegA
                AluSelB <= "01"; -- B = Ext8
                AluOP <= "00"; -- ADD
                
            when E6 => -- ALUOut <= A + B  
                AluSelA <= '1'; -- A = RegA
                AluSelB <= "00"; -- B = RegB
                AluOP <= "00"; -- ADD
                
            when E7 => -- ALUOut <= Imm8
                AluSelA <= '0'; -- A = PC (ignoré)
                AluSelB <= "01"; -- B = Ext8
                AluOP <= "01"; -- PASS B
                
            when E8 => -- Flag <= cmp(A,Imm8)
                AluSelA <= '1'; -- A = RegA
                AluSelB <= "01"; -- B = Ext8
                AluOP <= "10"; -- SUB/CMP
                CpsrWrEn <= '1';
                
            when E9 => -- DR <= Mem[ALUOut] ou Mem[ALUOut] <= B
                AdrSel <= '1'; -- Adresse = ALUOut
                if inst_reg(20) = '1' then -- LDR
                    memRdEn <= '1';
                else -- STR
                    memWrEn <= '1';
                    ResWrEn <= '1'; -- Affichage pour STR
                end if;
                
            when E10 => -- Pas de charge
                null;
                
            when E11 => -- Reg[Rd] <= DR
                WSel <= '0'; -- W = DR
                RegWrEn <= '1';
                
            when E12 => -- Mem[ALUOut] <= B
                null; -- Deja fait en E9
                
            when E13 => -- Reg[Rd] <= ALUOut
                WSel <= '1'; -- W = ALUOut
                RegWrEn <= '1';
                
            when E15 => -- PC <= PC + 1
                PCSel <= "00";
                PCWrEn <= '1';
                AluSelA <= '0'; -- A = PC
                AluSelB <= "11"; -- B = 1
                AluOP <= "00"; -- ADD
                
            when E16 => -- SPSR <= CPSR, LR <= PC
                SpsrWrEn <= '1';
                LRWrEn <= '1';
                
            when E17 => -- PC <= VIC
                PCSel <= "11"; -- PC = VIC
                PCWrEn <= '1';
                irq_serv <= '1';
                
            when E18 => -- PC <= LR, CPSR <= SPSR (BX)
                PCSel <= "10"; -- PC = LR
                PCWrEn <= '1';
                CpsrSel <= '1'; -- CPSR = SPSR
                CpsrWrEn <= '1';
                irq_serv <= '1';
                
            when others =>
                null;
        end case;
    end process;

end architecture;