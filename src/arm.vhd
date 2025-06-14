library ieee;
use ieee.std_logic_1164.all;

entity arm is
port(
    clk         : in std_logic;
    rst         : in std_logic;
    irq0,irq1   : in std_logic;
    resultat    : out std_logic_vector(31 downto 0)
);
end arm;
  
architecture arc_arm of arm is

-- Declaration des composants MAE Et Chemin de Donnees
component DataPath is
port(
    clk,rst     : in std_logic;
    
    -- Gestion des Interruptions
    irq0,irq1   : in std_logic;
    irq         : out std_logic;
    irq_serv    : in std_logic;
    
    -- Instructions
    Inst_Mem    : out std_logic_vector(31 downto 0);
    Inst_Reg    : out std_logic_vector(31 downto 0);
    N           : out std_logic;
    
    -- Memoire Interne
    AdrSel      : in std_logic;
    MemRdEn     : in std_logic;
    MemWrEn     : in std_logic;
    
    -- Registre Instruction
    IrWrEn      : in std_logic;
    
    -- Banc de Registres
    WSel        : in std_logic;
    RegWrEn     : in std_logic;
    RbSel       : in std_logic;
    
    -- Signaux de controle pour l'ALU
    AluSelA     : in std_logic;
    AluSelB     : in std_logic_vector(1 downto 0);
    AluOP       : in std_logic_vector(1 downto 0);
    
    -- Registres d'Etat (CPSR, SPSR)
    CpsrSel     : in std_logic;
    CpsrWrEn    : in std_logic;
    SpsrWrEn    : in std_logic;
    
    -- Registres PC et LR      
    PCSel       : in std_logic_vector(1 downto 0);
    PCWrEn      : in std_logic;
    LRWrEn      : in std_logic;
    
    -- Registre Resultat
    Res         : out std_logic_vector(31 downto 0);
    ResWrEn     : in std_logic
);
end component DataPath;

component MAE is
port(
    clk         : in  std_logic;
    rst         : in  std_logic;
    
    -- Gestion des Interruptions
    irq         : in std_logic;
    irq_serv    : out std_logic;
    
    -- Gestion des Instructions
    inst_mem    : in std_logic_vector(31 downto 0);
    inst_reg    : in std_logic_vector(31 downto 0);
    N           : in std_logic;
    
    -- Memoire Interne
    AdrSel      : out std_logic;
    memRdEn     : out std_logic;
    memWrEn     : out std_logic;
    
    -- Registre Instruction
    irWrEn      : out std_logic;
    
    -- Banc de Registres
    WSel        : out std_logic;
    RegWrEn     : out std_logic;
    RbSel       : out std_logic;
    
    -- ALU
    AluSelA     : out std_logic;
    AluSelB     : out std_logic_vector(1 downto 0);
    AluOP       : out std_logic_vector(1 downto 0);
    
    -- Registres d'Etat CPSR et SPSR
    CpsrSel     : out std_logic;
    CpsrWrEn    : out std_logic;
    SpsrWrEn    : out std_logic;
    
    -- Registres PC et LR      
    PCSel       : out std_logic_vector(1 downto 0);
    PCWrEn      : out std_logic;
    LRWrEn      : out std_logic;
    
    -- Registre Resultat
    ResWrEn     : out std_logic
);
end component MAE;

-- Signaux Internes
signal inst_mem         : std_logic_vector(31 downto 0);
signal inst_reg         : std_logic_vector(31 downto 0);
signal N                : std_logic;
signal AdrSel           : std_logic;
signal MemRdEn          : std_logic;
signal MemWrEn          : std_logic;
signal IrWrEn           : std_logic;              
signal WSel             : std_logic;
signal RegWrEn          : std_logic;
signal RbSel            : std_logic;       
signal AluSelA          : std_logic;
signal AluSelB          : std_logic_vector(1 downto 0);
signal AluOP            : std_logic_vector(1 downto 0);
signal CpsrSel          : std_logic; 
signal CpsrWrEn         : std_logic;
signal SpsrWrEn         : std_logic;
signal PCSel            : std_logic_vector(1 downto 0);
signal PCWrEn           : std_logic;
signal LRWrEn           : std_logic;
signal ResWrEn          : std_logic;
signal irq, irq_serv    : std_logic;

begin
 
-- Instanciation MAE
MAE1: MAE port map(
    clk         => clk,
    rst         => rst,
    irq         => irq,
    irq_serv    => irq_serv,
    inst_mem    => inst_mem,
    inst_reg    => inst_reg,
    N           => N,
    AdrSel      => AdrSel,
    memRdEn     => MemRdEn,
    memWrEn     => MemWrEn,
    IrWrEn      => IrWrEn,
    WSel        => WSel,
    RegWrEn     => RegWrEn,
    RbSel       => RbSel,
    AluSelA     => AluSelA,
    AluSelB     => AluSelB,
    AluOP       => AluOP,
    CpsrSel     => CpsrSel,
    CpsrWrEn    => CpsrWrEn,
    SpsrWrEn    => SpsrWrEn,
    PCSel       => PCSel,
    PCWrEn      => PCWrEn,
    LRWrEn      => LRWrEn,
    ResWrEn     => ResWrEn
);
  
-- Instanciation DataPath
DataPath1: DataPath port map(
    clk         => clk,
    rst         => rst,
    irq0        => irq0,
    irq1        => irq1,
    irq         => irq,
    irq_serv    => irq_serv,
    inst_mem    => inst_mem,
    inst_reg    => inst_reg,
    N           => N,
    AdrSel      => AdrSel,
    memRdEn     => MemRdEn,
    memWrEn     => MemWrEn,
    IrWrEn      => IrWrEn,
    WSel        => WSel,
    RegWrEn     => RegWrEn,
    RbSel       => RbSel,       
    AluSelA     => AluSelA,
    AluSelB     => AluSelB,
    AluOP       => AluOP,
    CpsrSel     => CpsrSel,
    CpsrWrEn    => CpsrWrEn,
    SpsrWrEn    => SpsrWrEn,
    PCSel       => PCSel,
    PCWrEn      => PCWrEn,
    LRWrEn      => LRWrEn,
    Res         => resultat,
    ResWrEn     => ResWrEn
);
    
end architecture arc_arm;