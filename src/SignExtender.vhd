library IEEE;
use IEEE.std_logic_1164.all;

entity SignExtender is
    generic (
        N : integer := 8  
    );
    port (
        E : in std_logic_vector(N-1 downto 0);
        S : out std_logic_vector(31 downto 0)
    );
end entity SignExtender;

architecture behavioral of SignExtender is
begin
    process(E)
    begin
        S(N-1 downto 0) <= E;
        for i in 31 downto N loop
            S(i) <= E(N-1);  
        end loop;
    end process;
end architecture behavioral;