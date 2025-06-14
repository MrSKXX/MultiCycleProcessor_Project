
library IEEE;
use IEEE.std_logic_1164.all;

ENTITY top_level IS 
PORT (
	CLOCK_50	: IN 	std_logic;   					-- Horloge
	KEY	: IN 	std_logic_vector(1 DOWNTO 0);  	-- Boutons Poussoir[3:0]
	SW		: IN 	std_logic_vector(9 DOWNTO 0);	-- Interrupteurs[17:0]
	HEX0	: OUT 	std_logic_vector(6 DOWNTO 0);   -- Afficheur 7 Segment 0
   HEX1	: OUT 	std_logic_vector(6 DOWNTO 0);   -- Afficheur 7 Segment 1
   HEX2	: OUT 	std_logic_vector(6 DOWNTO 0);   -- Afficheur 7 Segment 2
   HEX3	: OUT 	std_logic_vector(6 DOWNTO 0);   -- Afficheur 7 Segment 3
   
	LEDR	: OUT 	std_logic_vector(9 DOWNTO 0)   -- LEDs Verte[8:0]
);
END entity;

ARCHITECTURE ARCHI OF top_level IS

component arm
port(
	rst			: 	in 	std_logic;
	clk			:	in 	std_logic;
	irq0,irq1 	: 	in 	std_logic;
	resultat    : 	out	std_logic_vector(31 downto 0)
);
end component;

signal Resultat : std_logic_vector(31 downto 0);
signal Display : std_logic_vector(31 downto 0);

signal nKEY0,nKEY1 :  std_logic; -- Boutons poussoirs

BEGIN

-- Gestion Boutons Poussoirs
	-- Appuye: 1 / Relache: 0
nKEY0<=not(KEY(0));
nKEY1<=not(KEY(1)); 


arm_1: arm port map(
	rst			=>	SW(9),
	clk			=>	CLOCK_50,
	irq0		=>	nKEY0,
	irq1		=>	nKEY1,
	resultat    =>	Resultat);



	Display <= (others=>'1') when SW(1)='1' else Resultat;

	LEDR(0) <= nKEY0;
	LEDR(1) <= nKEY1;
	
	

	process(Display)
	begin
 
		case(Display(3 downto 0)) is
			when "0000" =>  HEX0 <= "1000000"; --0
			when "0001" =>  HEX0 <= "1111001"; --1
			when "0010" =>  HEX0 <= "0100100"; --2
			when "0011" =>  HEX0 <= "0110000"; --3
			when "0100" =>  HEX0 <= "0011001"; --4
			when "0101" =>  HEX0 <= "0010010"; --5
			when "0110" =>  HEX0 <= "0000010"; --6
			when "0111" =>  HEX0 <= "1111000"; --7
			when "1000" =>  HEX0 <= "0000000"; --8
			when "1001" =>  HEX0 <= "0010000"; --9
			when "1010" =>  HEX0 <= "0001000"; --A
			when "1011" =>  HEX0 <= "0000011"; --B
			when "1100" =>  HEX0 <= "1000110"; --C
			when "1101" =>  HEX0 <= "0100001"; --D
			when "1110" =>  HEX0 <= "0000110"; --E
			when "1111" =>  HEX0 <= "0001110"; --F
			when others  => HEX0 <= "0111111"; --'-'
		end case;

 		case(Display(7 downto 4)) is
			when "0000" =>  HEX1 <= "1000000"; --0
			when "0001" =>  HEX1 <= "1111001"; --1
			when "0010" =>  HEX1 <= "0100100"; --2
			when "0011" =>  HEX1 <= "0110000"; --3
			when "0100" =>  HEX1 <= "0011001"; --4
			when "0101" =>  HEX1 <= "0010010"; --5
			when "0110" =>  HEX1 <= "0000010"; --6
			when "0111" =>  HEX1 <= "1111000"; --7
			when "1000" =>  HEX1 <= "0000000"; --8
			when "1001" =>  HEX1 <= "0010000"; --9
			when "1010" =>  HEX1 <= "0001000"; --A
			when "1011" =>  HEX1 <= "0000011"; --B
			when "1100" =>  HEX1 <= "1000110"; --C
			when "1101" =>  HEX1 <= "0100001"; --D
			when "1110" =>  HEX1 <= "0000110"; --E
			when "1111" =>  HEX1 <= "0001110"; --F
			when others  => HEX1 <= "0111111"; --'-'
		end case;

		case(Display(11 downto 8)) is
			when "0000" =>  HEX2 <= "1000000"; --0
			when "0001" =>  HEX2 <= "1111001"; --1
			when "0010" =>  HEX2 <= "0100100"; --2
			when "0011" =>  HEX2 <= "0110000"; --3
			when "0100" =>  HEX2 <= "0011001"; --4
			when "0101" =>  HEX2 <= "0010010"; --5
			when "0110" =>  HEX2 <= "0000010"; --6
			when "0111" =>  HEX2 <= "1111000"; --7
			when "1000" =>  HEX2 <= "0000000"; --8
			when "1001" =>  HEX2 <= "0010000"; --9
			when "1010" =>  HEX2 <= "0001000"; --A
			when "1011" =>  HEX2 <= "0000011"; --B
			when "1100" =>  HEX2 <= "1000110"; --C
			when "1101" =>  HEX2 <= "0100001"; --D
			when "1110" =>  HEX2 <= "0000110"; --E
			when "1111" =>  HEX2 <= "0001110"; --F
			when others  => HEX2 <= "0111111"; --'-'
		end case;

		case(Display(15 downto 12)) is
			when "0000" =>  HEX3 <= "1000000"; --0
			when "0001" =>  HEX3 <= "1111001"; --1
			when "0010" =>  HEX3 <= "0100100"; --2
			when "0011" =>  HEX3 <= "0110000"; --3
			when "0100" =>  HEX3 <= "0011001"; --4
			when "0101" =>  HEX3 <= "0010010"; --5
			when "0110" =>  HEX3 <= "0000010"; --6
			when "0111" =>  HEX3 <= "1111000"; --7
			when "1000" =>  HEX3 <= "0000000"; --8
			when "1001" =>  HEX3 <= "0010000"; --9
			when "1010" =>  HEX3 <= "0001000"; --A
			when "1011" =>  HEX3 <= "0000011"; --B
			when "1100" =>  HEX3 <= "1000110"; --C
			when "1101" =>  HEX3 <= "0100001"; --D
			when "1110" =>  HEX3 <= "0000110"; --E
			when "1111" =>  HEX3 <= "0001110"; --F
			when others  => HEX3 <= "0111111"; --'-'
		end case;
      
 end process;

   LEDR(9 downto 2) <= SW(9 downto 2) ;
  
END architecture;
