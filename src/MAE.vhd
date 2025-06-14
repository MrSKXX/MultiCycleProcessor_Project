
library ieee;
use ieee.std_logic_1164.all;

entity MAE is
  port(
        clk    	: in  std_logic;					-- Horloge
        rst     : in  std_logic;					-- Reset Asynchrone
        
		-- Gestion des Interruptions
		irq     : in std_logic ;					-- Requete d'Interruption
        irq_serv: out std_logic;					-- Acquittement Inerruption
        
		-- Gestion des Instructions
		inst_mem: in std_logic_vector(31 downto 0);	-- Instruction sortant de la mémoire
        inst_reg: in std_logic_vector(31 downto 0);	-- Instruction a Decoder (REG INST)
        N   	: in std_logic; -- Drapeaux de l'ALU
        
		  
		-- Memoire Interne
        AdrSel	: out std_logic;					-- Commande Mux Bus Adresses
        memRdEn	: out std_logic;					-- Read Enable
        memWrEn : out std_logic;					-- Write Enable
        
        -- Registre Instruction
        irWrEn  : out std_logic;					-- Write Enable              
        
        -- Banc de Registres
        WSel    : out std_logic;					-- Commande Mux Bus W
        RegWrEn	: out std_logic;       				-- Write Enable
        
        -- ALU
        AluSelA : out std_logic;					-- Selection Entree A ALU
        AluSelB	: out std_logic_vector(1 downto 0);	-- Selection Entree B ALU
        AluOP 	: out std_logic_vector(1 downto 0);	-- Selection Operation ALU
        
        --Registres d'Etat CPSR et SPSR
        CpsrSel	: out std_logic; 					-- Mux Selection Entree CPSR
        CpsrWrEn: out std_logic;					-- Write Enable CPSR
        SpsrWrEn: out std_logic;					-- Write Enable SPSR
        
        -- Registres PC et LR      
        PCSel 	: out std_logic_vector(1 downto 0);	-- Selection Entree Registre PC
        PCWrEn 	: out std_logic;					-- Write Enable PC
        LRWrEn 	: out std_logic;					-- Write Enable LR
        
        -- Registre Resultat
        ResWrEn	: out std_logic						-- Write Enable Registre Resultat
      );
  end entity ;
  
  architecture archi of MAE is



begin 
  


end architecture;

