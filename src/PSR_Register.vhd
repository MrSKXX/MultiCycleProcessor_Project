library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity PSR_Register is
    port (
        CLK : in std_logic;
        Reset : in std_logic;
        WE : in std_logic;
        DATAIN : in std_logic_vector(31 downto 0);
        DATAOUT : out std_logic_vector(31 downto 0)
    );
end entity PSR_Register;

architecture behavioral of PSR_Register is
    signal reg_data : std_logic_vector(31 downto 0);
begin
    process(CLK, Reset)
    begin
        if Reset = '1' then
            reg_data <= (others => '0');  
        elsif rising_edge(CLK) then
            if WE = '1' then
                reg_data <= DATAIN;
            end if;
        end if;
    end process;
    
    DATAOUT <= reg_data;
    
end architecture behavioral;