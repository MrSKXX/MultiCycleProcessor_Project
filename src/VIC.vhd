library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity VIC is
    port (
        CLK : in std_logic;
        RESET : in std_logic;
        IRQ_SERV : in std_logic;
        IRQ0, IRQ1 : in std_logic;
        IRQ : out std_logic;
        VICPC : out std_logic_vector(31 downto 0)
    );
end entity VIC;

architecture behavioral of VIC is
    signal IRQ0_prev, IRQ1_prev : std_logic;
    signal IRQ0_memo, IRQ1_memo : std_logic;
begin
    
    process(CLK, RESET)
    begin
        if RESET = '1' then
            IRQ0_prev <= '0';
            IRQ1_prev <= '0';
            IRQ0_memo <= '0';
            IRQ1_memo <= '0';
        elsif rising_edge(CLK) then
            IRQ0_prev <= IRQ0;
            IRQ1_prev <= IRQ1;
            
            if IRQ0 = '1' and IRQ0_prev = '0' then
                IRQ0_memo <= '1';
            elsif IRQ_SERV = '1' then
                IRQ0_memo <= '0';
            end if;
            
            if IRQ1 = '1' and IRQ1_prev = '0' then
                IRQ1_memo <= '1';
            elsif IRQ_SERV = '1' then
                IRQ1_memo <= '0';
            end if;
        end if;
    end process;
    
    IRQ <= IRQ0_memo or IRQ1_memo;
    
    process(IRQ0_memo, IRQ1_memo)
    begin
        if IRQ0_memo = '1' then
            VICPC <= x"00000009";
        elsif IRQ1_memo = '1' then
            VICPC <= x"00000015";
        else
            VICPC <= x"00000000";
        end if;
    end process;
    
end architecture behavioral;