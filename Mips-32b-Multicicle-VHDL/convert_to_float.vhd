--
-- Experimento para transformar um numero inteiro em um numero float
-- Desenvolvido por Ismael Soller Vianna, em 2021-07-20
--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library mito;
use mito.mito_pkg.all;

entity convert_to_float is
  Port (
    clk          : in  std_logic;
    rst          : in  std_logic; 
    entrada_a    : in  std_logic_vector (31 downto 0);
    finished_job : out std_logic;
    ula_outf     : out std_logic_vector (31 downto 0)  
  );
end convert_to_float;

architecture rst of convert_to_float is
    constant BIAS      : std_logic_vector (7 downto 0)  := "01111111";  -- Bias = int(127)
    constant ZERO32    : std_logic_vector (31 downto 0) := "00000000000000000000000000000000";

    signal notacao_exc : std_logic_vector (7 downto 0);
    signal not_exc_fim : std_logic;                    
    signal expoente    : std_logic_vector (7 downto 0);                       
    signal mantissa    : std_logic_vector (31 downto 0);
    signal sinal       : std_logic;                     
begin

sinal <= entrada_a(31) when rst='0' else '0';

expoente <= "00011110" when entrada_a(30) = '1' and rst='0' else
            "00011101" when entrada_a(29) = '1' and rst='0' else
            "00011100" when entrada_a(28) = '1' and rst='0' else
            "00011011" when entrada_a(27) = '1' and rst='0' else
            "00011010" when entrada_a(26) = '1' and rst='0' else
            "00011001" when entrada_a(25) = '1' and rst='0' else
            "00011000" when entrada_a(24) = '1' and rst='0' else
            "00010111" when entrada_a(23) = '1' and rst='0' else
            "00010110" when entrada_a(22) = '1' and rst='0' else
            "00010101" when entrada_a(21) = '1' and rst='0' else
            "00010100" when entrada_a(20) = '1' and rst='0' else
            "00010011" when entrada_a(19) = '1' and rst='0' else
            "00010010" when entrada_a(18) = '1' and rst='0' else
            "00010001" when entrada_a(17) = '1' and rst='0' else
            "00010000" when entrada_a(16) = '1' and rst='0' else
            "00001111" when entrada_a(15) = '1' and rst='0' else
            "00001110" when entrada_a(14) = '1' and rst='0' else
            "00001101" when entrada_a(13) = '1' and rst='0' else
            "00001100" when entrada_a(12) = '1' and rst='0' else
            "00001011" when entrada_a(11) = '1' and rst='0' else
            "00001010" when entrada_a(10) = '1' and rst='0' else
            "00001001" when entrada_a(9) = '1' and rst='0' else
            "00001000" when entrada_a(8) = '1' and rst='0' else
            "00000111" when entrada_a(7) = '1' and rst='0' else
            "00000110" when entrada_a(6) = '1' and rst='0' else
            "00000101" when entrada_a(5) = '1' and rst='0' else
            "00000100" when entrada_a(4) = '1' and rst='0' else
            "00000011" when entrada_a(3) = '1' and rst='0' else
            "00000010" when entrada_a(2) = '1' and rst='0' else
            "00000001" when entrada_a(1) = '1' and rst='0' else
            "00000000" when entrada_a(0) = '1' and rst='0' else
            "11111111";

mantissa <= std_logic_vector(unsigned(entrada_a(29 downto 0)) & unsigned(ZERO32(1 downto 0))) when expoente = "00011110" and rst='0' else
            std_logic_vector(unsigned(entrada_a(28 downto 0)) & unsigned(ZERO32(2 downto 0))) when expoente = "00011101" and rst='0' else
            std_logic_vector(unsigned(entrada_a(27 downto 0)) & unsigned(ZERO32(3 downto 0))) when expoente = "00011100" and rst='0' else
            std_logic_vector(unsigned(entrada_a(26 downto 0)) & unsigned(ZERO32(4 downto 0))) when expoente = "00011011" and rst='0' else
            std_logic_vector(unsigned(entrada_a(25 downto 0)) & unsigned(ZERO32(5 downto 0))) when expoente = "00011010" and rst='0' else
            std_logic_vector(unsigned(entrada_a(24 downto 0)) & unsigned(ZERO32(6 downto 0))) when expoente = "00011001" and rst='0' else
            std_logic_vector(unsigned(entrada_a(23 downto 0)) & unsigned(ZERO32(7 downto 0))) when expoente = "00011000" and rst='0' else
            std_logic_vector(unsigned(entrada_a(22 downto 0)) & unsigned(ZERO32(8 downto 0))) when expoente = "00010111" and rst='0' else
            std_logic_vector(unsigned(entrada_a(21 downto 0)) & unsigned(ZERO32(9 downto 0))) when expoente = "00010110" and rst='0' else
            std_logic_vector(unsigned(entrada_a(20 downto 0)) & unsigned(ZERO32(10 downto 0))) when expoente = "00010101" and rst='0' else
            std_logic_vector(unsigned(entrada_a(19 downto 0)) & unsigned(ZERO32(11 downto 0))) when expoente = "00010100" and rst='0' else
            std_logic_vector(unsigned(entrada_a(18 downto 0)) & unsigned(ZERO32(12 downto 0))) when expoente = "00010011" and rst='0' else
            std_logic_vector(unsigned(entrada_a(17 downto 0)) & unsigned(ZERO32(13 downto 0))) when expoente = "00010010" and rst='0' else
            std_logic_vector(unsigned(entrada_a(16 downto 0)) & unsigned(ZERO32(14 downto 0))) when expoente = "00010001" and rst='0' else
            std_logic_vector(unsigned(entrada_a(15 downto 0)) & unsigned(ZERO32(15 downto 0))) when expoente = "00010000" and rst='0' else
            std_logic_vector(unsigned(entrada_a(14 downto 0)) & unsigned(ZERO32(16 downto 0))) when expoente = "00001111" and rst='0' else
            std_logic_vector(unsigned(entrada_a(13 downto 0)) & unsigned(ZERO32(17 downto 0))) when expoente = "00001110" and rst='0' else
            std_logic_vector(unsigned(entrada_a(12 downto 0)) & unsigned(ZERO32(18 downto 0))) when expoente = "00001101" and rst='0' else
            std_logic_vector(unsigned(entrada_a(11 downto 0)) & unsigned(ZERO32(19 downto 0))) when expoente = "00001100" and rst='0' else
            std_logic_vector(unsigned(entrada_a(10 downto 0)) & unsigned(ZERO32(20 downto 0))) when expoente = "00001011" and rst='0' else
            std_logic_vector(unsigned(entrada_a(9 downto 0)) & unsigned(ZERO32(21 downto 0))) when expoente = "00001010" and rst='0' else
            std_logic_vector(unsigned(entrada_a(8 downto 0)) & unsigned(ZERO32(22 downto 0))) when expoente = "00001001" and rst='0' else
            std_logic_vector(unsigned(entrada_a(7 downto 0)) & unsigned(ZERO32(23 downto 0))) when expoente = "00001000" and rst='0' else
            std_logic_vector(unsigned(entrada_a(6 downto 0)) & unsigned(ZERO32(24 downto 0))) when expoente = "00000111" and rst='0' else
            std_logic_vector(unsigned(entrada_a(5 downto 0)) & unsigned(ZERO32(25 downto 0))) when expoente = "00000110" and rst='0' else
            std_logic_vector(unsigned(entrada_a(4 downto 0)) & unsigned(ZERO32(26 downto 0))) when expoente = "00000101" and rst='0' else
            std_logic_vector(unsigned(entrada_a(3 downto 0)) & unsigned(ZERO32(27 downto 0))) when expoente = "00000100" and rst='0' else
            std_logic_vector(unsigned(entrada_a(2 downto 0)) & unsigned(ZERO32(28 downto 0))) when expoente = "00000011" and rst='0' else
            std_logic_vector(unsigned(entrada_a(1 downto 0)) & unsigned(ZERO32(29 downto 0))) when expoente = "00000010" and rst='0' else
            std_logic_vector(entrada_a(0) & unsigned(ZERO32(30 downto 0))) when expoente = "00000001" and rst='0' else
            std_logic_vector(unsigned(ZERO32));

not_exc_fim <= '1' when rst='0' and expoente/="11111111" else '0';

notacao_exc <= std_logic_vector (unsigned(BIAS) + unsigned(expoente)) when rst='0' and not_exc_fim='1' else "00000000";

MONTA_FLOAT:process(clk, rst, not_exc_fim)
begin
    if (rising_edge(clk) and rst='0')then
        if (not_exc_fim='1')then
            ula_outf <= std_logic_vector(sinal & unsigned(notacao_exc) & unsigned(mantissa(31 downto 9)));
            finished_job <= '1';
        else
            ula_outf <= std_logic_vector(unsigned(ZERO32));
            finished_job <= '0';
        end if;            
    end if;
end process;

-- Ula Float falta desenvolver

end rst;
