------------------------------------------------------------------
--																--
--					PROCESSEUR MULTI-CYCLES						--
--						CHEMIN DE DONNEES						--
--																--
---						(c) 2010-2022      						--
-- 		A.Mocco, N.Hamila, M.Fonseca, J.Denoulet, P.Garda	    --
--      Modifié par Y Douze              						--
-----------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_numeric_std.all;

entity DataPath is 
port(
		clk,rst		: in std_logic;								-- Horloge + Reset Asynchrone
        
		-- Gestion des Interruptions
		irq0,irq1	: in std_logic;								-- Boutons Interruptions Externes
		irq     		: out std_logic;								-- Requete Interruption Transmise par le VIC
		irq_serv		: in std_logic;  								-- Acquittement Interruption
        
		-- Instructions
		Inst_Mem   	: out std_logic_vector(31 downto 0);	-- Instruction a Decoder (MEMOIRE)
		Inst_Reg    : out std_logic_vector(31 downto 0);	-- Instruction a Decoder (REG INST)
		N        	: out std_logic; 								-- Flag N memorise dans Registre d'Etat
        
		-- Memoire Interne
		AdrSel 		: in std_logic; 								-- Commande Mux Bus Adresses
		MemRdEn   	: in std_logic;								-- Read Enable
		MemWrEn    	: in std_logic;								-- Write Enable
	
		-- Registre Instruction
		IrWrEn     	: in std_logic;								-- Write Enable              
        
		-- Banc de Registres
		WSel			: in std_logic;								-- Commande Mux Bus W
		RegWrEn 		: in std_logic;								-- Write Enable  
        
		--signaux de controle pour l'alu
		AluSelA 		: in std_logic;								-- Selection Entree A ALU
		AluSelB  	: in std_logic_vector(1 downto 0);		-- Selection Entree B ALU
		AluOP    	: in std_logic_vector(1 downto 0);		-- Selecttion Operation ALU
        
		-- Registres d'Etat (CPSR, SPSR)
		CpsrSel		: in std_logic; 								-- Mux Selection Entree CPSR
		CpsrWrEn		: in std_logic;								-- Write Enable CPSR
		SpsrWrEn		: in std_logic;								-- Write Enable SPSR
        
		-- Registres PC et LR      
		PCSel 		: in std_logic_vector(1 downto 0);		-- Selection Entree Registre PC
		PCWrEn 		: in std_logic;								-- Write Enable PC
		LRWrEn 		: in std_logic;								-- Write Enable LR
        
		-- Registre Resultat
		Res    		: out std_logic_vector(31 downto 0);	-- Sortie Registre Resultat
		ResWrEn		: in std_logic									-- Write Enable
  );
end DataPath;


architecture archi of DataPath is

begin

end architecture;
