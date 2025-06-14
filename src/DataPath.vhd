library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DataPath is 
port(
    clk,rst     : in std_logic;
    
    -- Gestion des Interruptions
    irq0,irq1   : in std_logic;
    irq         : out std_logic;
    irq_serv    : in std_logic;
    
    -- Instructions
    Inst_Mem   : out std_logic_vector(31 downto 0);
    Inst_Reg   : out std_logic_vector(31 downto 0);
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
end DataPath;

architecture archi of DataPath is

    -- Declaration des composants
    component VIC is
        port (
            CLK : in std_logic;
            RESET : in std_logic;
            IRQ_SERV : in std_logic;
            IRQ0, IRQ1 : in std_logic;
            IRQ : out std_logic;
            VICPC : out std_logic_vector(31 downto 0)
        );
    end component;

    component Mux4v1 is
        port (
            A, B, C, D : in std_logic_vector(31 downto 0);
            COM : in std_logic_vector(1 downto 0);
            S : out std_logic_vector(31 downto 0)
        );
    end component;

    component Mux2v1 is
        generic (N : integer := 32);
        port (
            A, B : in std_logic_vector(N-1 downto 0);
            COM : in std_logic;
            S : out std_logic_vector(N-1 downto 0)
        );
    end component;

    component Reg32_WrEn is
        port (
            CLK : in std_logic;
            RST : in std_logic;
            WrEn : in std_logic;
            DATAIN : in std_logic_vector(31 downto 0);
            DATAOUT : out std_logic_vector(31 downto 0)
        );
    end component;

    component Reg32 is
        port (
            CLK : in std_logic;
            RST : in std_logic;
            DATAIN : in std_logic_vector(31 downto 0);
            DATAOUT : out std_logic_vector(31 downto 0)
        );
    end component;

    component DualPortRAM is
        port (
            clock, rst : in std_logic;
            data : in std_logic_vector(31 downto 0);
            q : out std_logic_vector(31 downto 0);
            rdaddress, wraddress : in std_logic_vector(5 downto 0);
            rden, wren : in std_logic
        );
    end component;

    component RegisterBank is
        port (
            CLK : in std_logic;
            Reset : in std_logic;
            W : in std_logic_vector(31 downto 0);
            RA : in std_logic_vector(3 downto 0);
            RB : in std_logic_vector(3 downto 0);
            RW : in std_logic_vector(3 downto 0);
            WE : in std_logic;
            A : out std_logic_vector(31 downto 0);
            B : out std_logic_vector(31 downto 0)
        );
    end component;

    component ALU is
        port (
            OP : in std_logic_vector(1 downto 0);
            A, B : in std_logic_vector(31 downto 0);
            S : out std_logic_vector(31 downto 0);
            N : out std_logic;
            Z : out std_logic
        );
    end component;

    component SignExtender is
        generic (N : integer := 8);
        port (
            E : in std_logic_vector(N-1 downto 0);
            S : out std_logic_vector(31 downto 0)
        );
    end component;

    -- Signaux internes
    signal VICPC_out : std_logic_vector(31 downto 0);
    signal PC_out, LR_out : std_logic_vector(31 downto 0);
    signal PC_next : std_logic_vector(31 downto 0);
    signal mem_addr : std_logic_vector(5 downto 0);
    signal mem_data_out : std_logic_vector(31 downto 0);
    signal IR_out, DR_out : std_logic_vector(31 downto 0);
    signal reg_A, reg_B : std_logic_vector(31 downto 0);
    signal reg_BusA, reg_BusB : std_logic_vector(31 downto 0);
    signal reg_W : std_logic_vector(31 downto 0);
    signal reg_RB_addr : std_logic_vector(3 downto 0);
    signal ALU_out : std_logic_vector(31 downto 0);
    signal ALU_reg_out : std_logic_vector(31 downto 0);
    signal ALU_A, ALU_B : std_logic_vector(31 downto 0);
    signal ALU_N, ALU_Z : std_logic;
    signal EXT8_out, EXT24_out : std_logic_vector(31 downto 0);
    signal CPSR_in, CPSR_out : std_logic_vector(31 downto 0);
    signal SPSR_out : std_logic_vector(31 downto 0);

begin

    -- VIC : Controleur d'interruption vectorise
    VIC_inst: VIC port map (
        CLK => clk,
        RESET => rst,
        IRQ_SERV => irq_serv,
        IRQ0 => irq0,
        IRQ1 => irq1,
        IRQ => irq,
        VICPC => VICPC_out
    );

    -- MUX_PC: Multiplexeur d'entree du registre PC
    MUX_PC: Mux4v1 port map (
        A => ALU_out,           -- Sortie ALU
        B => ALU_reg_out,       -- Sortie registre ALUOUT
        C => LR_out,            -- Sortie registre LR
        D => VICPC_out,         -- Sortie VIC
        COM => PCSel,
        S => PC_next
    );

    -- PC: Registre PC
    PC_reg: Reg32_WrEn port map (
        CLK => clk,
        RST => rst,
        WrEn => PCWrEn,
        DATAIN => PC_next,
        DATAOUT => PC_out
    );

    -- LR: Link Register
    LR_reg: Reg32_WrEn port map (
        CLK => clk,
        RST => rst,
        WrEn => LRWrEn,
        DATAIN => PC_out,
        DATAOUT => LR_out
    );

    -- Mux_MEM : Multiplexeur du Bus d'adresses de la memoire
    MUX_MEM: Mux2v1 
        generic map (N => 6)
        port map (
            A => PC_out(5 downto 0),
            B => ALU_reg_out(5 downto 0),
            COM => AdrSel,
            S => mem_addr
        );

    -- MEMORY: Memoire interne du processeur
    MEMORY: DualPortRAM port map (
        clock => clk,
        rst => rst,
        data => reg_BusB,
        q => mem_data_out,
        rdaddress => mem_addr,
        wraddress => mem_addr,
        rden => MemRdEn,
        wren => MemWrEn
    );

    -- IR : Registre Instruction
    IR_reg: Reg32_WrEn port map (
        CLK => clk,
        RST => rst,
        WrEn => IrWrEn,
        DATAIN => mem_data_out,
        DATAOUT => IR_out
    );

    -- DR : Registre de Donnees Memoire
    DR_reg: Reg32 port map (
        CLK => clk,
        RST => rst,
        DATAIN => mem_data_out,
        DATAOUT => DR_out
    );

    -- MUX_REG_RB : Multiplexeur du Bus d'adresses RB du banc de registres
    MUX_REG_RB: Mux2v1 
        generic map (N => 4)
        port map (
            A => IR_out(3 downto 0),
            B => IR_out(15 downto 12),
            COM => RbSel,
            S => reg_RB_addr
        );

    -- MUX_REG_BUSW : Multiplexeur du Bus des donnees W du banc de registres
    MUX_REG_BUSW: Mux2v1 port map (
        A => DR_out,
        B => ALU_reg_out,
        COM => WSel,
        S => reg_W
    );

    -- Register File : Banc de registres
    REG_FILE: RegisterBank port map (
        CLK => clk,
        Reset => rst,
        W => reg_W,
        RA => IR_out(19 downto 16), -- Rn
        RB => reg_RB_addr,
        RW => IR_out(15 downto 12), -- Rd
        WE => RegWrEn,
        A => reg_A,
        B => reg_B
    );

    -- Ext_8 : Extension de donnees 8 a 32
    EXT_8: SignExtender 
        generic map (N => 8)
        port map (
            E => IR_out(7 downto 0),
            S => EXT8_out
        );

    -- Ext_24 : Extension de donnees 24 a 32
    EXT_24: SignExtender 
        generic map (N => 24)
        port map (
            E => IR_out(23 downto 0),
            S => EXT24_out
        );

    -- A : Registre de sortie du port A du banc de registres
    A_reg: Reg32 port map (
        CLK => clk,
        RST => rst,
        DATAIN => reg_A,
        DATAOUT => reg_BusA
    );

    -- B : Registre de sortie du port B du banc de registres
    B_reg: Reg32 port map (
        CLK => clk,
        RST => rst,
        DATAIN => reg_B,
        DATAOUT => reg_BusB
    );

    -- Mux_ALU_A : Multiplexeur entree A de l'ALU
    MUX_ALU_A: Mux2v1 port map (
        A => PC_out,
        B => reg_BusA,
        COM => AluSelA,
        S => ALU_A
    );

    -- Mux_ALU_B : Multiplexeur entree B de l'ALU
    MUX_ALU_B: Mux4v1 port map (
        A => reg_BusB,
        B => EXT8_out,
        C => EXT24_out,
        D => x"00000001", -- Valeur constante 1
        COM => AluSelB,
        S => ALU_B
    );

    -- ALU : Unite Arithmetique et Logique
    ALU_inst: ALU port map (
        OP => AluOP,
        A => ALU_A,
        B => ALU_B,
        S => ALU_out,
        N => ALU_N,
        Z => ALU_Z
    );

    -- ALU_Out : Registre de sortie de l'ALU
    ALU_Out_reg: Reg32 port map (
        CLK => clk,
        RST => rst,
        DATAIN => ALU_out,
        DATAOUT => ALU_reg_out
    );

    -- Mux_CPSR : Multiplexeur d'entree du Registre CPSR
    MUX_CPSR: Mux2v1 port map (
        A(31) => ALU_N,
        A(30) => ALU_Z,
        A(29 downto 0) => CPSR_out(29 downto 0),
        B => SPSR_out,
        COM => CpsrSel,
        S => CPSR_in
    );

    -- CPSR : Current Processor Status Register
    CPSR_reg: Reg32_WrEn port map (
        CLK => clk,
        RST => rst,
        WrEn => CpsrWrEn,
        DATAIN => CPSR_in,
        DATAOUT => CPSR_out
    );

    -- SPSR : Saved Processor Status Register
    SPSR_reg: Reg32_WrEn port map (
        CLK => clk,
        RST => rst,
        WrEn => SpsrWrEn,
        DATAIN => CPSR_out,
        DATAOUT => SPSR_out
    );

    -- RESULTAT: Registre Resultat
    RESULTAT_reg: Reg32_WrEn port map (
        CLK => clk,
        RST => rst,
        WrEn => ResWrEn,
        DATAIN => reg_BusB,
        DATAOUT => Res
    );

    -- Assignation des sorties
    Inst_Mem <= mem_data_out;
    Inst_Reg <= IR_out;
    N <= CPSR_out(31);

end architecture;