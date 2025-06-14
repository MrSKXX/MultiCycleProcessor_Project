library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ALU is
    port (
        OP : in std_logic_vector(1 downto 0);  
        A, B : in std_logic_vector(31 downto 0); 
        S : out std_logic_vector(31 downto 0); 
        N : out std_logic;  
        Z : out std_logic   
    );
end entity ALU;

architecture behavioral of ALU is
    signal result : std_logic_vector(31 downto 0);
begin
    process(OP, A, B)
    begin
        case OP is
            when "00" => 
                result <= std_logic_vector(unsigned(A) + unsigned(B));  -- ADD
            when "01" => 
                result <= B;  -- MOV (passe B)
            when "10" => 
                result <= std_logic_vector(unsigned(A) - unsigned(B));  -- SUB/CMP
            when "11" => 
                result <= A;  -- Passe A
            when others => 
                result <= (others => '0');
        end case;
    end process;
    
    S <= result;
    
    process(OP, A, B, result)
    begin
        case OP is
            when "10" =>  
                if signed(A) < signed(B) then
                    N <= '1';
                else
                    N <= '0';
                end if;
                
                if A = B then
                    Z <= '1';
                else
                    Z <= '0';
                end if;
                
            when others =>  -- ADD, MOV, A : Drapeaux basés sur le RÉSULTAT
                N <= result(31);  -- Bit de signe du résultat
                
                if unsigned(result) = 0 then
                    Z <= '1';
                else
                    Z <= '0';
                end if;
        end case;
    end process;
    
end architecture behavioral;