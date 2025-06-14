library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity VIC_testbench is
end entity VIC_testbench;

architecture test of VIC_testbench is
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
    
    signal CLK_tb : std_logic := '0';
    signal RESET_tb : std_logic := '0';
    signal IRQ_SERV_tb : std_logic := '0';
    signal IRQ0_tb, IRQ1_tb : std_logic := '0';
    signal IRQ_tb : std_logic;
    signal VICPC_tb : std_logic_vector(31 downto 0);
    
    constant CLK_PERIOD : time := 10 ns;

begin
    UUT: VIC port map (
        CLK => CLK_tb,
        RESET => RESET_tb,
        IRQ_SERV => IRQ_SERV_tb,
        IRQ0 => IRQ0_tb,
        IRQ1 => IRQ1_tb,
        IRQ => IRQ_tb,
        VICPC => VICPC_tb
    );
    
    clk_process: process
    begin
        CLK_tb <= '0';
        wait for CLK_PERIOD/2;
        CLK_tb <= '1';
        wait for CLK_PERIOD/2;
    end process;
    
    stimulus: process
    begin
        report "=== TEST VIC ===";
        
        RESET_tb <= '1';
        wait for CLK_PERIOD*2;
        RESET_tb <= '0';
        wait for CLK_PERIOD;
        
        assert IRQ_tb = '0' report "Reset: IRQ devrait etre 0" severity error;
        assert VICPC_tb = x"00000000" report "Reset: VICPC devrait etre 0" severity error;
        
        report "Test transition montante IRQ0";
        IRQ0_tb <= '1';
        wait for CLK_PERIOD;
        IRQ0_tb <= '0';
        wait for CLK_PERIOD;
        
        assert IRQ_tb = '1' report "IRQ0: IRQ devrait etre 1" severity error;
        assert VICPC_tb = x"00000009" report "IRQ0: VICPC devrait etre 0x9" severity error;
        
        report "Test acquittement IRQ0";
        IRQ_SERV_tb <= '1';
        wait for CLK_PERIOD;
        IRQ_SERV_tb <= '0';
        wait for CLK_PERIOD;
        
        assert IRQ_tb = '0' report "SERV: IRQ devrait etre 0" severity error;
        assert VICPC_tb = x"00000000" report "SERV: VICPC devrait etre 0" severity error;
        
        report "Test transition montante IRQ1";
        IRQ1_tb <= '1';
        wait for CLK_PERIOD;
        IRQ1_tb <= '0';
        wait for CLK_PERIOD;
        
        assert IRQ_tb = '1' report "IRQ1: IRQ devrait etre 1" severity error;
        assert VICPC_tb = x"00000015" report "IRQ1: VICPC devrait etre 0x15" severity error;
        
        report "Test priorite IRQ0 > IRQ1";
        IRQ0_tb <= '1';
        wait for CLK_PERIOD;
        IRQ0_tb <= '0';
        wait for CLK_PERIOD;
        
        assert VICPC_tb = x"00000009" report "PRIORITE: IRQ0 devrait etre prioritaire" severity error;
        
        report "=== VIC TEST COMPLETE ===";
        wait;
    end process;
    
end architecture test;