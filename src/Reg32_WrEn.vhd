library IEEE;
use IEEE.std_logic_1164.all;

entity Reg32_WrEn is
    port (
        CLK : in std_logic;
        RST : in std_logic;
        WrEn : in std_logic;
        DATAIN : in std_logic_vector(31 downto 0);
        DATAOUT : out std_logic_vector(31 downto 0)
    );
end entity Reg32_WrEn;

architecture behavioral of Reg32_WrEn is
    signal reg_data : std_logic_vector(31 downto 0);
begin
    process(CLK, RST)
    begin
        if RST = '1' then
            reg_data <= (others => '0');
        elsif rising_edge(CLK) then
            if WrEn = '1' then
                reg_data <= DATAIN;
            end if;
        end if;
    end process;
    
    DATAOUT <= reg_data;
    
end architecture behavioral;