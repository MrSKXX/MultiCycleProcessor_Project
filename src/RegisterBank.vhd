library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity RegisterBank is
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
end entity RegisterBank;

architecture behavioral of RegisterBank is
    type table is array(15 downto 0) of std_logic_vector(31 downto 0);
    
    function init_banc return table is
        variable result : table;
    begin
        result := (others => (others => '0'));
        result(15) := X"00000030"; 
        return result;
    end function;

    signal Banc: table := init_banc;

    procedure reset_banc(signal banc: out table) is
    begin
        for i in 14 downto 0 loop
            banc(i) <= (others => '0');
        end loop;
        banc(15) <= X"00000030";
    end procedure;

begin

    A <= Banc(to_integer(unsigned(RA))) when to_integer(unsigned(RA)) <= 15 else (others => '0');
    B <= Banc(to_integer(unsigned(RB))) when to_integer(unsigned(RB)) <= 15 else (others => '0');

    write_process : process(CLK, Reset)
    begin
        if Reset = '1' then
            reset_banc(Banc);
        elsif rising_edge(CLK) then
            if WE = '1' then
                if to_integer(unsigned(RW)) < 15 then 
                    Banc(to_integer(unsigned(RW))) <= W;
                end if;
            end if;
        end if;
    end process;

end architecture behavioral;
