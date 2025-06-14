library IEEE;
use IEEE.std_logic_1164.all;

entity Mux2v1 is
    generic (
        N : integer := 32 
    );
    port (
        A, B : in std_logic_vector(N-1 downto 0);
        COM : in std_logic;
        S : out std_logic_vector(N-1 downto 0)
    );
end entity Mux2v1;

architecture behavioral of Mux2v1 is
begin
    process(A, B, COM)
    begin
        if COM = '0' then
            S <= A;
        else
            S <= B;
        end if;
    end process;
end architecture behavioral;