-- Test complet PARTIE 1 : Tous les modules de base
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity test_partie1_complete is
end entity test_partie1_complete;

architecture test of test_partie1_complete is

    -- *** COMPOSANTS A TESTER ***
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

    -- *** SIGNAUX DE TEST ***
    signal clk_tb : std_logic := '0';
    signal rst_tb : std_logic := '0';
    
    -- Mux4v1
    signal mux4_A, mux4_B, mux4_C, mux4_D, mux4_S : std_logic_vector(31 downto 0);
    signal mux4_COM : std_logic_vector(1 downto 0);
    
    -- Mux2v1
    signal mux2_A, mux2_B, mux2_S : std_logic_vector(31 downto 0);
    signal mux2_COM : std_logic;
    
    -- Reg32_WrEn
    signal reg_wren_in, reg_wren_out : std_logic_vector(31 downto 0);
    signal reg_wren_en : std_logic;
    
    -- Reg32
    signal reg_in, reg_out : std_logic_vector(31 downto 0);
    
    -- VIC
    signal vic_irq_serv, vic_irq0, vic_irq1, vic_irq : std_logic;
    signal vic_pc : std_logic_vector(31 downto 0);
    
    constant CLK_PERIOD : time := 20 ns;
    signal test_ok : boolean := true;

begin

    -- *** INSTANCIATION DES COMPOSANTS ***
    UUT_MUX4: Mux4v1 port map (
        A => mux4_A, B => mux4_B, C => mux4_C, D => mux4_D,
        COM => mux4_COM, S => mux4_S
    );
    
    UUT_MUX2: Mux2v1 port map (
        A => mux2_A, B => mux2_B, COM => mux2_COM, S => mux2_S
    );
    
    UUT_REG_WREN: Reg32_WrEn port map (
        CLK => clk_tb, RST => rst_tb, WrEn => reg_wren_en,
        DATAIN => reg_wren_in, DATAOUT => reg_wren_out
    );
    
    UUT_REG: Reg32 port map (
        CLK => clk_tb, RST => rst_tb,
        DATAIN => reg_in, DATAOUT => reg_out
    );
    
    UUT_VIC: VIC port map (
        CLK => clk_tb, RESET => rst_tb, IRQ_SERV => vic_irq_serv,
        IRQ0 => vic_irq0, IRQ1 => vic_irq1,
        IRQ => vic_irq, VICPC => vic_pc
    );

    -- *** GENERATEUR D'HORLOGE ***
    clk_tb <= not clk_tb after CLK_PERIOD/2;

    -- *** PROCESSUS DE TEST PRINCIPAL ***
    test_process: process
    begin
        report "=== DEBUT TEST PARTIE 1 - MODULES DE BASE ===";
        
        -- Reset initial
        rst_tb <= '1';
        wait for CLK_PERIOD*2;
        rst_tb <= '0';
        wait for CLK_PERIOD;

        -- *** TEST 1: MUX4V1 ***
        report "--- TEST MUX4V1 ---";
        mux4_A <= x"AAAAAAAA";
        mux4_B <= x"BBBBBBBB";
        mux4_C <= x"CCCCCCCC";
        mux4_D <= x"DDDDDDDD";
        
        mux4_COM <= "00"; wait for 10 ns;
        assert mux4_S = x"AAAAAAAA" report "ERREUR MUX4V1: COM=00" severity error;
        if mux4_S /= x"AAAAAAAA" then test_ok <= false; end if;
        
        mux4_COM <= "01"; wait for 10 ns;
        assert mux4_S = x"BBBBBBBB" report "ERREUR MUX4V1: COM=01" severity error;
        if mux4_S /= x"BBBBBBBB" then test_ok <= false; end if;
        
        mux4_COM <= "10"; wait for 10 ns;
        assert mux4_S = x"CCCCCCCC" report "ERREUR MUX4V1: COM=10" severity error;
        if mux4_S /= x"CCCCCCCC" then test_ok <= false; end if;
        
        mux4_COM <= "11"; wait for 10 ns;
        assert mux4_S = x"DDDDDDDD" report "ERREUR MUX4V1: COM=11" severity error;
        if mux4_S /= x"DDDDDDDD" then test_ok <= false; end if;
        
        report "MUX4V1 : OK";

        -- *** TEST 2: MUX2V1 ***
        report "--- TEST MUX2V1 ---";
        mux2_A <= x"12345678";
        mux2_B <= x"87654321";
        
        mux2_COM <= '0'; wait for 10 ns;
        assert mux2_S = x"12345678" report "ERREUR MUX2V1: COM=0" severity error;
        if mux2_S /= x"12345678" then test_ok <= false; end if;
        
        mux2_COM <= '1'; wait for 10 ns;
        assert mux2_S = x"87654321" report "ERREUR MUX2V1: COM=1" severity error;
        if mux2_S /= x"87654321" then test_ok <= false; end if;
        
        report "MUX2V1 : OK";

        -- *** TEST 3: REG32_WREN ***
        report "--- TEST REG32_WREN ---";
        reg_wren_in <= x"DEADBEEF";
        reg_wren_en <= '0';
        wait for CLK_PERIOD;
        
        assert reg_wren_out = x"00000000" report "ERREUR REG32_WREN: Charge sans WrEn" severity error;
        if reg_wren_out /= x"00000000" then test_ok <= false; end if;
        
        reg_wren_en <= '1';
        wait for CLK_PERIOD;
        
        assert reg_wren_out = x"DEADBEEF" report "ERREUR REG32_WREN: Ne charge pas avec WrEn" severity error;
        if reg_wren_out /= x"DEADBEEF" then test_ok <= false; end if;
        
        reg_wren_en <= '0';
        reg_wren_in <= x"12345678";
        wait for CLK_PERIOD;
        
        assert reg_wren_out = x"DEADBEEF" report "ERREUR REG32_WREN: Change sans WrEn" severity error;
        if reg_wren_out /= x"DEADBEEF" then test_ok <= false; end if;
        
        report "REG32_WREN : OK";

        -- *** TEST 4: REG32 ***
        report "--- TEST REG32 ---";
        reg_in <= x"CAFEBABE";
        wait for CLK_PERIOD;
        
        assert reg_out = x"CAFEBABE" report "ERREUR REG32: Ne charge pas automatiquement" severity error;
        if reg_out /= x"CAFEBABE" then test_ok <= false; end if;
        
        report "REG32 : OK";

        -- *** TEST 5: VIC ***
        report "--- TEST VIC ---";
        vic_irq_serv <= '0';
        vic_irq0 <= '0';
        vic_irq1 <= '0';
        wait for CLK_PERIOD;
        
        assert vic_irq = '0' report "ERREUR VIC: IRQ actif sans requête" severity error;
        assert vic_pc = x"00000000" report "ERREUR VIC: VICPC non nul sans IRQ" severity error;
        if vic_irq /= '0' or vic_pc /= x"00000000" then test_ok <= false; end if;
        
        -- Test IRQ0
        vic_irq0 <= '1';
        wait for CLK_PERIOD;
        vic_irq0 <= '0';
        wait for CLK_PERIOD;
        
        assert vic_irq = '1' report "ERREUR VIC: IRQ non actif après IRQ0" severity error;
        assert vic_pc = x"00000009" report "ERREUR VIC: VICPC incorrect pour IRQ0" severity error;
        if vic_irq /= '1' or vic_pc /= x"00000009" then test_ok <= false; end if;
        
        -- Acquittement
        vic_irq_serv <= '1';
        wait for CLK_PERIOD;
        vic_irq_serv <= '0';
        wait for CLK_PERIOD;
        
        assert vic_irq = '0' report "ERREUR VIC: IRQ non acquitté" severity error;
        assert vic_pc = x"00000000" report "ERREUR VIC: VICPC non remis à 0" severity error;
        if vic_irq /= '0' or vic_pc /= x"00000000" then test_ok <= false; end if;
        
        -- Test IRQ1
        vic_irq1 <= '1';
        wait for CLK_PERIOD;
        vic_irq1 <= '0';
        wait for CLK_PERIOD;
        
        assert vic_irq = '1' report "ERREUR VIC: IRQ non actif après IRQ1" severity error;
        assert vic_pc = x"00000015" report "ERREUR VIC: VICPC incorrect pour IRQ1" severity error;
        if vic_irq /= '1' or vic_pc /= x"00000015" then test_ok <= false; end if;
        
        vic_irq_serv <= '1';
        wait for CLK_PERIOD;
        vic_irq_serv <= '0';
        wait for CLK_PERIOD;
        
        report "VIC : OK";

        -- *** RESULTAT FINAL ***
        wait for CLK_PERIOD;
        
        if test_ok then
            report "=== PARTIE 1 : TOUS LES TESTS REUSSIS ! ===" severity note;
        else
            report "=== PARTIE 1 : ECHECS DETECTES ===" severity error;
        end if;
        
        report "=== FIN TEST PARTIE 1 ===";
        wait;
    end process;

end architecture test;