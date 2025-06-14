LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.NUMERIC_STD.all; 

ENTITY DualPortRAM IS
PORT (
	clock, rst: IN STD_LOGIC;
	data: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
    q: out STD_LOGIC_VECTOR (31 DOWNTO 0);
	rdaddress, wraddress: IN STD_LOGIC_VECTOR (5 DOWNTO 0);
    rden, wren : in std_logic
);
END entity;

ARCHITECTURE rtl OF DualPortRAM IS
TYPE MEM IS ARRAY(0 TO 63) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL ram_block: MEM;
BEGIN
PROCESS (clock,rst)
BEGIN
	IF rst = '1' then 
        ram_block(0 ) <=  x"E3A01020"; -- _main :   MOV R1,#0x20 	; --R1 <= 0x20
        ram_block(1 ) <=  x"E3A02000"; --           MOV R2,#0       ; --R2 <= 0   
        ram_block(2 ) <=  x"E6110000"; -- _loop :   LDR R0,0(R1)   	; --R0 <= MEM[R1]
        ram_block(3 ) <=  x"E0822000"; --           ADD R2,R2,R0 	; --R2 <= R2 + R0
        ram_block(4 ) <=  x"E2811001"; --           ADD R1,R1,#1  	; --R1 <= R1 + 1
        ram_block(5 ) <=  x"E351002A"; --           CMP R1,0x2A   	; --? R1 = 0x2A
        ram_block(6 ) <=  x"BAFFFFFC"; --           BLT loop   	; --branchement à _loop si R1 inferieur a 0x2A
        ram_block(7 ) <=  x"E6012000"; --           STR R2,0(R1)   	; --MEM[R1] <= R2
        ram_block(8 ) <=  x"EAFFFFF8"; --           BAL main		; --branchement à _main 
                                       -- ISR 0 : interruption 0
                                                --sauvegarde du contexte
        ram_block(9 ) <=  x"E60F1000"; --           STR R1,0(R15)   	; --MEM[R15] <= R1 
        ram_block(10) <=  x"E28FF001"; --           ADD R15,R15,1  	; --R15 <= R15 + 1
        ram_block(11) <=  x"E60F3000"; --           STR R3,0(R15)   	; --MEM[R15] <= R3
                                                --traitement
        ram_block(12) <=  x"E3A03020"; --           MOV R3,0x20     	; --R3 <= 0x20
        ram_block(13) <=  x"E6131000"; --           LDR R1,0(R3)    	; --R1 <= MEM[R3]
        ram_block(14) <=  x"E2811001"; --           ADD R1,R1,1     	; --R1 <= R1 + 1
        ram_block(15) <=  x"E6031000"; --           STR R1,0(R3)    	; --MEM[R3] <= R1
                                                -- restauration du contexte
        ram_block(16) <=  x"E61F3000"; --           LDR R3,0(R15)   	; --R3 <= MEM[R15]
        ram_block(17) <=  x"E28FF0FF"; --           ADD R15,R15,-1  	; --R15 <= R15 - 1
        ram_block(18) <=  x"E61F1000"; --           LDR R1,0(R15)   	; --R1 <= MEM[R15]
        ram_block(19) <=  x"EB000000"; --           BX              	; -- instruction de fin d'interruption
        ram_block(20) <=  x"00000000"; 
                                        -- ISR1 : interruption 1  
                                                --sauvegarde du contexte - R15 correspond au pointeur de pile
        ram_block(21) <=  x"E60F4000"; --           STR R4,0(R15)   	; --MEM[R15] <= R4
        ram_block(22) <=  x"E28FF001"; --           ADD R15,R15,1   	; --R15 <= R15 + 1
        ram_block(23) <=  x"E60F5000"; --           STR R5,0(R15)   ; --MEM[R15] <= R5
                                                --traitement
        ram_block(24) <=  x"E3A05020"; --           MOV R5,0x20     	; --R5 <= 0x20
        ram_block(25) <=  x"E6154000"; --           LDR R4,0(R5)    	; --R4 <= MEM[R5]
        ram_block(26) <=  x"E2844002"; --           ADD R4,R4,2     	; --R4 <= R1 + 2
        ram_block(27) <=  x"E6054000"; --           STR R4,0(R5)    	; --MEM[R5] <= R4
                                               -- restauration du contexte 
        ram_block(28) <=  x"E61F5000";--           LDR R5,0(R15)   	; --R5 <= MEM[R15]
        ram_block(29) <=  x"E28FF0FF";  --           ADD R15,R15,-1  	; --R15 <= R15 - 1
        ram_block(30) <=  x"E61F4000"; --           LDR R4,0(R15)   ; --R4 <= MEM[R15]
        ram_block(31) <=  x"EB000000";--           BX              	; -- instruction de fin d'interruption
        ram_block(32) <=  x"00000001";
        ram_block(33) <=  x"00000002";
        ram_block(34) <=  x"00000003";
        ram_block(35) <=  x"00000004";
        ram_block(36) <=  x"00000005";
        ram_block(37) <=  x"00000006";
        ram_block(38) <=  x"00000007";
        ram_block(39) <=  x"00000008";
        ram_block(40) <=  x"00000009";
        ram_block(41) <=  x"0000000A";
        ram_block(42 to 63) <= (others=> x"00000000");
        
    elsif rising_edge(clock) THEN
			if (wren = '1') then
				ram_block(to_integer(unsigned(wrAddress))) <= Data;
			elsif (rden= '1') then
				q <= ram_block(to_integer(unsigned(rdAddress)));
			end if;
end if;

END PROCESS;
END architecture;