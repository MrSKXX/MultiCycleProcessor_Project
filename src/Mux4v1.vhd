library IEEE;
use IEEE.std_logic_1164.all;

entity Mux4v1 is
    port (
        A, B, C, D : in std_logic_vector(31 downto 0);
        COM : in std_logic_vector(1 downto 0);
        S : out std_logic_vector(31 downto 0)
    );
end entity Mux4v1;

architecture behavioral of Mux4v1 is
begin
    process(A, B, C, D, COM)
    begin
        case COM is
            when "00" => S <= A;
            when "01" => S <= B;
            when "10" => S <= C;
            when "11" => S <= D;
            when others => S <= (others => '0');
        end case;
    end process;
end architecture behavioral;