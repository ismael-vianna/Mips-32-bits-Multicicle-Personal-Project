----------------------------------------------------------------------------------
-- Company: UERGS
-- Disciplina: Organizacao de computadores
-- Profa.: Debora Matos
-- Baseado na estrutura de memoria de: Newton Jr
-- Trabalho de: Ismael Soller Vianna
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

library mito;
use mito.mito_pkg.all;

entity testebenchd is
end testebenchd;

architecture Behavioral of testebenchd is
        
    component miTo is
        port (
             signal clk             : in  std_logic;
             signal rst_n           : in  std_logic   
        );     
    end component;   
     
    -- control signals
    signal clk_s            : std_logic :='0';
    signal reset_s          : std_logic;
    
begin
   
    miTo_i : miTo
        port map(
            clk                 => clk_s,
            rst_n               => reset_s
        );

    --clock generator - 100MHZ
   clk_s 	<= not clk_s after 5 ns;
    
    --reset signal
    reset_s		<= '1' after 2 ns,
		           '0' after 8 ns;	
		
end Behavioral;