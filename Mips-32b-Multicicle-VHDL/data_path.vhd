----------------------------------------------------------------------------------
-- Company: UERGS
-- Disciplina: Organizacao de computadores
-- Profa.: Debora Matos
-- Baseado na estrutura de memoria de: Newton Jr
-- Trabalho de: Ismael Soller Vianna
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.all;
use ieee.numeric_std.all;
library mito;
use mito.mito_pkg.all;

entity data_path is
    Port (                
        clk                 : in  std_logic;                         -- clock
        rst                 : in  std_logic;                         -- reset
        pc_enable           : in std_logic;                          -- habilita escrever no pc
        ula_flag_zero       : out  std_logic;                        -- flag='1' se caso satisfatorio de branch if equal        
        instr_ou_dado       : in  std_logic;                         -- instrucao ou dado 
        escreve_reg_instr   : in  std_logic;                         -- escreve no registrador de instrucao
        reg_mem             : in  std_logic_vector(1 downto 0);      -- registrador recebe dado da memoria
        fonte_pc            : in  std_logic_vector(1 downto 0);      -- fonte do PC
        ula_op              : in  std_logic_vector(3 downto 0);      -- operacao da ULA
        ula_fonte_b         : in  std_logic_vector(1 downto 0);      -- fonte da entrada B da ULA
        escreve_registrador : in  std_logic;                         -- escreve no banco de registradores
        registrador_destino : in  std_logic;                         -- registrador de destino
        le_operacao         : out std_logic_vector(5 downto 0);      -- operação a ser passada para Unidade de Controle
        entrada_memoria     : out std_logic_vector(31 downto 0);     -- dado enviado para a memória
        endereco_memoria    : out std_logic_vector(8  downto 0);     -- endereço para gravar na memória
        saida_memoria       : in  std_logic_vector(31 downto 0);     -- dado enviado pela memória ao registrador RDM
        ula_outf            : in  std_logic_vector (31 downto 0);
        ula_entrada_a_f     : out std_logic_vector (31 downto 0)
        );
end data_path;

architecture rtl of data_path is
    ---------------------------------
    --           FLOAT             --
    ---------------------------------     
--    component convert_to_float
--        Port ( 
--            clk          : in  std_logic;
--            rst          : in  std_logic; 
--            entrada      : in  std_logic_vector (31 downto 0);
--            finished_job : out std_logic;
--            ula_outf     : out std_logic_vector (31 downto 0)  
--        );
--    end component;
    
    --signal ula_outf_s        : std_logic_vector (31 downto 0); 
    
    ---------------------------------
    --           SINAIS            --
    ---------------------------------
    
    -- MENSAGENS DE ERRO --
    type error_type is (er_livre, er_ula_cntrl_u, er_ula_op_u, er_ula_ri_funct, 
                        er_bnk_reg_rs_u, er_bnk_reg_rt_u, er_bnk_reg_salvar);
    signal erro_ula          : error_type := er_livre; -- operação interna da ula
    signal erro_ula_cntrl    : error_type := er_livre; -- controle da ula
    signal erro_bnk_regs_rs  : error_type := er_livre; -- banco de registradores: monitor do campo RS
    signal erro_bnk_regs_rt  : error_type := er_livre; -- banco de registradores: monitor do campo RT
    signal erro_bnk_regs     : error_type := er_livre; -- banco de registradores: monitor para salvar dados no banco de registradores       
            
    -- CONSTANTES --        
    constant ZEROS32        : std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
    
    -- ULA --
    signal   ula_out        : std_logic_vector(31 downto 0);    -- resultado da ULA
    signal   ula_out32      : std_logic_vector(31 downto 0);    -- auxiliar para resultado da ULA
    signal   ula_out64      : std_logic_vector(63 downto 0);    -- auxiliar para resultado da ULA
    signal   ula_cntrl      : std_logic_vector( 4 downto 0);    -- sinal de controle da ula para selecionar operacao    
    signal   ula_entrada_a  : std_logic_vector(31 downto 0);    -- recebe dado do mux4_a_to_ula
    signal   ula_entrada_b  : std_logic_vector(31 downto 0);    -- recebe dado do mux5_b_to_ula       
        
    -- REGISTRADOR DE INSTRUCOES --
    signal   ri_rs                          :  std_logic_vector( 4 downto 0); -- campo rs, encaminhado para banco de registradores
    signal   ri_rt                          :  std_logic_vector( 4 downto 0); -- campo rt, encaminhado para banco de registradores
    signal   ri_rd                          :  std_logic_vector( 4 downto 0); -- campo rd, encaminhado para banco de registradores
    signal   ri_funct                       :  std_logic_vector( 5 downto 0); -- campo funct, encaminhado para Controlador da ULA
    signal   ri_endereco                    :  std_logic_vector( 8 downto 0); -- campo de endereco de jump, era [25 downto 0]
    signal   ri_imediato                    :  std_logic_vector(15 downto 0); -- campo de imediato/offset
    
    -- BANCO DE REGISTRADORES --
    signal bnk_reg_escreve_registrador_id   :    std_logic_vector( 3 downto 0); -- endereco (ID) do registrador RT=0 ou RD=1, no mux
    signal bnk_reg_escreve_dado             :    std_logic_vector(31  downto 0);-- dado recebido de RDM ou ULAOut
	
	signal banco_de_registradores_r0        :    std_logic_vector(31  downto 0) := "00000000000000000000000000000000"; -- 0
	signal banco_de_registradores_r1        :    std_logic_vector(31  downto 0) := "00000000000000000000000000000000"; -- 1
	signal banco_de_registradores_r2        :    std_logic_vector(31  downto 0) := "00000000000000000000000000000000"; -- 4
	signal banco_de_registradores_r3        :    std_logic_vector(31  downto 0) := "00000000000000000000000000000000"; -- 0
	signal banco_de_registradores_r4        :    std_logic_vector(31  downto 0) := "00000000000000000000000000000000"; -- 0
	signal banco_de_registradores_r5        :    std_logic_vector(31  downto 0) := "00000000000000000000000000000000"; -- 0
	signal banco_de_registradores_r6        :    std_logic_vector(31  downto 0) := "00000000000000000000000000000000"; -- 7
	signal banco_de_registradores_r7        :    std_logic_vector(31  downto 0) := "00000000000000000000000000000000"; -- 9 - usado como retorno se erro
	
	-- REGISTRADOR B --
	signal registrador_b                    :    std_logic_vector(31 downto 0);
	
	-- REGISTRADOR MDR (Registrador de dados da memoria) --
	signal registrador_mdr                  :    std_logic_vector(31 downto 0);
	
	-- PROGRAM COUNTER --
	signal registrador_pc                   :    std_logic_vector(8 downto 0);
	
	-- ULA RESULTADOS AUXILIAR PRA CALCULOS
	signal auxiliar_ula                     :    std_logic_vector(31 downto 0);
	
    begin
    ---------------------------------
    --           FLOAT             --
    ---------------------------------     
--    convert_to_float_i : convert_to_float
--        port map( 
--            clk          => clk,
--            rst          => rst_float, 
--            entrada      => ula_entrada_a,
--            finished_job => finished_job_float,
--            ula_outf     => ula_outf_s  
--        );
      
    ------------------------------------------
    --                 ULA                  --
    ------------------------------------------        
    ULA_HW: process (clk, ula_cntrl)
    begin     
        case ula_cntrl is
            when "00000" =>                                               -- calculado no estado 1, load e store e R                
                ula_out <= std_logic_vector(unsigned(ula_entrada_a) + unsigned(ula_entrada_b));
                --ula_out <= ula_entrada + ula_entrada_b;
                --ula_out <= ula_out64(31 downto 0);
                ula_flag_zero <= '0';
                erro_ula <= er_livre;
            when "00001" =>                                               -- R(add). Salva soma em ula_out. estado 3
                ula_out <= std_logic_vector(unsigned(ula_entrada_a) + unsigned(ula_entrada_b));
                --ula_out <= ula_out64(31 downto 0);
                --ula_out <= ula_entrada + ula_entrada_b;
                ula_flag_zero <= '0';
                erro_ula <= er_livre;
            when "00010" =>                                               -- and = numA and numB
                ula_out <= std_logic_vector(unsigned(ula_entrada_a) and unsigned(ula_entrada_b));
--                ula_out <= ula_entrada(31 downto 0) and ula_entrada_b(31 downto 0);
                --ula_out(0) <= '0';
                ula_flag_zero <= '0';
                erro_ula <= er_livre;
            when "00011" =>                                               -- branch beq. se numA - numB = 0, entao sao iguais
                auxiliar_ula <= std_logic_vector(unsigned(ula_entrada_a) xor unsigned(ula_entrada_b));
                                
                if (auxiliar_ula = ZEROS32) then--if ((ula_entrada xor ula_entrada_b) = ZEROS32) then 
                    ula_flag_zero <= '1';                               -- sao iguais
                else                    
                    ula_flag_zero <= '0';                               -- sao diferentes
                end if;
                ula_out <= std_logic_vector(unsigned(ula_entrada_a) xor unsigned(ula_entrada_b));
                erro_ula <= er_livre;
            when "00100" =>                                               -- xor a, b, c => a = (b' e c) ou (b e c')
                ula_flag_zero <= '0';
                ula_out <= std_logic_vector((not(unsigned(ula_entrada_a)) and unsigned(ula_entrada_b)) or (unsigned(ula_entrada_a) and not(unsigned(ula_entrada_b))));
                erro_ula <= er_livre;
            when "00101" =>                                               -- branch bne. se numA - numB != 0, entao não sao iguais
                auxiliar_ula <= std_logic_vector(unsigned(ula_entrada_a) xor unsigned(ula_entrada_b));

                if (auxiliar_ula = ZEROS32) then                          -- if ((ula_entrada xor ula_entrada_b) = ZEROS32) then 
                    ula_flag_zero <= '0';                                 -- sao iguais
                else                    
                    ula_flag_zero <= '1';                                 -- sao diferentes
                end if;
                ula_out <= std_logic_vector(unsigned(ula_entrada_a) xor unsigned(ula_entrada_b));
                erro_ula <= er_livre;
            when "00110" =>                                               -- stl, set then les. se numA < numB then ula_out = 1 else ula_out = 1
                if (unsigned(ula_entrada_a) < unsigned(ula_entrada_b)) then 
                    ula_out <= ZEROS32(31 downto 1) & '1';                -- numA é menor que numB
                else                    
                    ula_out <=  ZEROS32(31 downto 1) & '0';               -- numA é maior ou igual a numB
                end if;
                erro_ula <= er_livre;
            when "00111" =>                                               -- sub                
                ula_out <= std_logic_vector(unsigned(ula_entrada_a) - unsigned(ula_entrada_b));
                ula_flag_zero <= '0';
                erro_ula <= er_livre;
            when "01000" =>                                               -- move: copia e cola
                ula_out <= std_logic_vector(unsigned(ula_entrada_a));
                ula_flag_zero <= '0';
                erro_ula <= er_livre;  
            when "01001" =>                                               -- load imediato
                ula_out <= std_logic_vector(unsigned(ula_entrada_b));
                ula_flag_zero <= '0';
                erro_ula <= er_livre;   
            when "01010" =>                                               -- nand, c = not (a and b)
                ula_out <= std_logic_vector(not (unsigned(ula_entrada_a) and unsigned(ula_entrada_b)));
                ula_flag_zero <= '0';
                erro_ula <= er_livre;   
            when "01011" =>                                               -- rd = not rs
                ula_out <= std_logic_vector(not (unsigned(ula_entrada_a)));
                ula_flag_zero <= '0';
                erro_ula <= er_livre;        
            when "01100" =>                                               -- nor, c = not (a or b)
                ula_out32 <= std_logic_vector(unsigned(ula_entrada_a) or unsigned(ula_entrada_b));
                ula_out <= std_logic_vector(not (unsigned(ula_out32)));
                ula_flag_zero <= '0';
                erro_ula <= er_livre;    
            when "01101" =>                                               -- or, c = a or b
                ula_out <= std_logic_vector(unsigned(ula_entrada_a) or unsigned(ula_entrada_b));
                ula_flag_zero <= '0';
                erro_ula <= er_livre;    
            when "01110" =>                                               -- mult, c = a mult b
                ula_out64 <= std_logic_vector(unsigned(ula_entrada_a) * unsigned(ula_entrada_b));
                ula_out <= ula_out64(31 downto 0);
                ula_flag_zero <= '0';
                erro_ula <= er_livre;    
            when "01111" =>                                               -- div, c = a div b
                ula_out <= std_logic_vector(unsigned(ula_entrada_a) / unsigned(ula_entrada_b));
                --ula_out <= ula_out64(31 downto 0);
                ula_flag_zero <= '0';
                erro_ula <= er_livre;    
            when "10000" =>                                               -- rem, c = a % b
                ula_out64 <= std_logic_vector(unsigned(ula_entrada_a)-((unsigned(ula_entrada_a) / unsigned(ula_entrada_b) * unsigned(ula_entrada_b))));
                ula_out <= ula_out64(31 downto 0);
                ula_flag_zero <= '0';
                erro_ula <= er_livre;    
            when "10001" =>                                               -- sll, c = a << imediato16
                case unsigned(ula_entrada_b(5 downto 0)) is
                    when "000000" => --0                        
                        ula_out <= std_logic_vector(unsigned(ula_entrada_a));
                    when "000001" => --1
                        ula_out <= std_logic_vector(unsigned(ula_entrada_a(30 downto 0)) & ZEROS32(0));
                    when "000010" => --2
                        ula_out <= std_logic_vector(unsigned(ula_entrada_a(29 downto 0)) & unsigned(ZEROS32(1 downto 0)));
                        --ula_out <= ula_entrada(29 downto 0) & ZEROS32(1 downto 0);
                    when "000011" => --3
                        ula_out <= std_logic_vector(unsigned(ula_entrada_a(28 downto 0)) & unsigned(ZEROS32(2 downto 0)));
                    when "000100" => --4
                        ula_out <= std_logic_vector(unsigned(ula_entrada_a(27 downto 0)) & unsigned(ZEROS32(3 downto 0)));
                    when "000101" => --5
                        ula_out <= std_logic_vector(unsigned(ula_entrada_a(26 downto 0)) & unsigned(ZEROS32(4 downto 0)));
                    when "000110" => --6
                        ula_out <= std_logic_vector(unsigned(ula_entrada_a(25 downto 0)) & unsigned(ZEROS32(5 downto 0)));
                    when "000111" => --7
                        ula_out <= std_logic_vector(unsigned(ula_entrada_a(24 downto 0)) & unsigned(ZEROS32(6 downto 0)));
                    when "001000" => --8
                        ula_out <= std_logic_vector(unsigned(ula_entrada_a(23 downto 0)) & unsigned(ZEROS32(7 downto 0)));
                    when "001001" => --9
                        ula_out <= std_logic_vector(unsigned(ula_entrada_a(22 downto 0)) & unsigned(ZEROS32(8 downto 0)));
                    when "001010" => --10
                        ula_out <= std_logic_vector(unsigned(ula_entrada_a(21 downto 0)) & unsigned(ZEROS32(9 downto 0)));
                    when "001011" => --11
                        ula_out <= std_logic_vector(unsigned(ula_entrada_a(20 downto 0)) & unsigned(ZEROS32(10 downto 0)));
                    when "001100" => --12
                        ula_out <= std_logic_vector(unsigned(ula_entrada_a(19 downto 0)) & unsigned(ZEROS32(11 downto 0)));
                    when "001101" => --13
                        ula_out <= std_logic_vector(unsigned(ula_entrada_a(18 downto 0)) & unsigned(ZEROS32(12 downto 0)));
                    when "001110" => --14
                        ula_out <= std_logic_vector(unsigned(ula_entrada_a(17 downto 0)) & unsigned(ZEROS32(13 downto 0)));
                    when "001111" => --15
                        ula_out <= std_logic_vector(unsigned(ula_entrada_a(16 downto 0)) & unsigned(ZEROS32(14 downto 0)));
                    when "010000" => --16
                        ula_out <= std_logic_vector(unsigned(ula_entrada_a(15 downto 0)) & unsigned(ZEROS32(15 downto 0)));
                    when "010001" => --17
                        ula_out <= std_logic_vector(unsigned(ula_entrada_a(14 downto 0)) & unsigned(ZEROS32(16 downto 0)));
                    when "010010" => --18
                        ula_out <= std_logic_vector(unsigned(ula_entrada_a(13 downto 0)) & unsigned(ZEROS32(17 downto 0)));
                    when "010011" => --19
                        ula_out <= std_logic_vector(unsigned(ula_entrada_a(12 downto 0)) & unsigned(ZEROS32(18 downto 0)));
                    when "010100" => --20
                        ula_out <= std_logic_vector(unsigned(ula_entrada_a(11 downto 0)) & unsigned(ZEROS32(19 downto 0)));
                    when "010101" => --21
                        ula_out <= std_logic_vector(unsigned(ula_entrada_a(10 downto 0)) & unsigned(ZEROS32(20 downto 0)));
                    when "010110" => --22
                        ula_out <= std_logic_vector(unsigned(ula_entrada_a(9 downto 0)) & unsigned(ZEROS32(21 downto 0)));
                    when "010111" => --23
                        ula_out <= std_logic_vector(unsigned(ula_entrada_a(8 downto 0)) & unsigned(ZEROS32(22 downto 0)));
                    when "011000" => --24
                        ula_out <= std_logic_vector(unsigned(ula_entrada_a(7 downto 0)) & unsigned(ZEROS32(23 downto 0)));
                    when "011001" => --25
                        ula_out <= std_logic_vector(unsigned(ula_entrada_a(6 downto 0)) & unsigned(ZEROS32(24 downto 0)));
                    when "011010" => --26
                        ula_out <= std_logic_vector(unsigned(ula_entrada_a(5 downto 0)) & unsigned(ZEROS32(25 downto 0)));
                    when "011011" => --27
                        ula_out <= std_logic_vector(unsigned(ula_entrada_a(4 downto 0)) & unsigned(ZEROS32(26 downto 0)));
                    when "011100" => --28
                        ula_out <= std_logic_vector(unsigned(ula_entrada_a(3 downto 0)) & unsigned(ZEROS32(27 downto 0)));
                    when "011101" => --29
                        ula_out <= std_logic_vector(unsigned(ula_entrada_a(2 downto 0)) & unsigned(ZEROS32(28 downto 0)));
                    when "011110" => --30
                        ula_out <= std_logic_vector(unsigned(ula_entrada_a(1 downto 0)) & unsigned(ZEROS32(29 downto 0)));                               
                    when "011111" => --31
                        ula_out <= std_logic_vector(ula_entrada_a(0) & unsigned(ZEROS32(30 downto 0)));
                    when others =>  -- maior que 31            
                        ula_out <= std_logic_vector(unsigned(ZEROS32));
                end case; 
                
                ula_flag_zero <= '0';
                erro_ula <= er_livre;    
            when "10010" =>                                               -- srl, c = imediato16 >> a
                ula_out32 <= std_logic_vector(unsigned(ZEROS32));
                
                case unsigned(ula_entrada_b(5 downto 0)) is
                    when "000000" => --0                        
                        ula_out32 <= std_logic_vector(unsigned(ula_entrada_a));
                    when "000001" => --1
                        ula_out32(30 downto 0) <= std_logic_vector(unsigned(ula_entrada_a(31 downto 1)));
                    when "000010" => --2
                        ula_out32(29 downto 0) <= std_logic_vector(unsigned(ula_entrada_a(31 downto 2)));
                    when "000011" => --3
                        ula_out32(28 downto 0) <= std_logic_vector(unsigned(ula_entrada_a(31 downto 3)));
                    when "000100" => --4
                        ula_out32(27 downto 0) <= std_logic_vector(unsigned(ula_entrada_a(31 downto 4)));
                    when "000101" => --5
                        ula_out32(26 downto 0) <= std_logic_vector(unsigned(ula_entrada_a(31 downto 5)));
                    when "000110" => --6
                        ula_out32(25 downto 0) <= std_logic_vector(unsigned(ula_entrada_a(31 downto 6)));
                    when "000111" => --7
                        ula_out32(24 downto 0) <= std_logic_vector(unsigned(ula_entrada_a(31 downto 7)));
                    when "001000" => --8
                        ula_out32(23 downto 0) <= std_logic_vector(unsigned(ula_entrada_a(31 downto 8)));
                    when "001001" => --9
                        ula_out32(22 downto 0) <= std_logic_vector(unsigned(ula_entrada_a(31 downto 9)));
                    when "001010" => --10
                        ula_out32(21 downto 0) <= std_logic_vector(unsigned(ula_entrada_a(31 downto 10)));
                    when "001011" => --11
                        ula_out32(20 downto 0) <= std_logic_vector(unsigned(ula_entrada_a(31 downto 11)));
                    when "001100" => --12
                        ula_out32(19 downto 0) <= std_logic_vector(unsigned(ula_entrada_a(31 downto 12)));
                    when "001101" => --13
                        ula_out32(18 downto 0) <= std_logic_vector(unsigned(ula_entrada_a(31 downto 13)));
                    when "001110" => --14
                        ula_out32(17 downto 0) <= std_logic_vector(unsigned(ula_entrada_a(31 downto 14)));
                    when "001111" => --15
                        ula_out32(16 downto 0) <= std_logic_vector(unsigned(ula_entrada_a(31 downto 15)));
                    when "010000" => --16
                        ula_out32(15 downto 0) <= std_logic_vector(unsigned(ula_entrada_a(31 downto 16)));
                    when "010001" => --17
                        ula_out32(14 downto 0) <= std_logic_vector(unsigned(ula_entrada_a(31 downto 17)));
                    when "010010" => --18
                        ula_out32(13 downto 0) <= std_logic_vector(unsigned(ula_entrada_a(31 downto 18)));
                    when "010011" => --19
                        ula_out32(12 downto 0) <= std_logic_vector(unsigned(ula_entrada_a(31 downto 19)));
                    when "010100" => --20
                        ula_out32(11 downto 0) <= std_logic_vector(unsigned(ula_entrada_a(31 downto 20)));
                    when "010101" => --21
                        ula_out32(10 downto 0) <= std_logic_vector(unsigned(ula_entrada_a(31 downto 21)));
                    when "010110" => --22
                        ula_out32(9 downto 0) <= std_logic_vector(unsigned(ula_entrada_a(31 downto 22)));
                    when "010111" => --23
                        ula_out32(8 downto 0) <= std_logic_vector(unsigned(ula_entrada_a(31 downto 23)));
                    when "011000" => --24
                        ula_out32(7 downto 0) <= std_logic_vector(unsigned(ula_entrada_a(31 downto 24)));
                    when "011001" => --25
                        ula_out32(6 downto 0) <= std_logic_vector(unsigned(ula_entrada_a(31 downto 25)));
                    when "011010" => --26
                        ula_out32(5 downto 0) <= std_logic_vector(unsigned(ula_entrada_a(31 downto 26)));
                    when "011011" => --27
                        ula_out32(4 downto 0) <= std_logic_vector(unsigned(ula_entrada_a(31 downto 27)));
                    when "011100" => --28
                        ula_out32(3 downto 0) <= std_logic_vector(unsigned(ula_entrada_a(31 downto 28)));
                    when "011101" => --29
                        ula_out32(2 downto 0) <= std_logic_vector(unsigned(ula_entrada_a(31 downto 29)));
                    when "011110" => --30
                        ula_out32(1 downto 0) <= std_logic_vector(unsigned(ula_entrada_a(31 downto 30)));                               
                    when "011111" => --31
                        ula_out32(0) <= std_logic(ula_entrada_a(31));
                    when others =>  -- maior que 31            
                        --ula_out32 <= std_logic_vector(unsigned(ZEROS32));
                end case; 
                
                ula_out <= ula_out32;
                
                ula_flag_zero <= '0';
                erro_ula <= er_livre;    
            when "10011" =>                                               -- branch bgt
                if (unsigned(ula_entrada_a) > unsigned(ula_entrada_b)) then 
                    ula_flag_zero <= '1';                                 -- a > b
                else                    
                    ula_flag_zero <= '0';                                 
                end if;
                ula_out <= ula_out;
                erro_ula <= er_livre;   
            when "10100" =>                                               -- branch bgt
                if (unsigned(ula_entrada_a) < unsigned(ula_entrada_b)) then 
                    ula_flag_zero <= '1';                                 -- a < b
                else                    
                    ula_flag_zero <= '0';                                 
                end if;
                ula_out <= ula_out;
                erro_ula <= er_livre;   
            when "10101" =>                                               -- spati
                ula_out32 <= std_logic_vector(unsigned(ula_entrada_a));
                
                case unsigned(ula_entrada_b(4 downto 0)) is
                    when "00000" => --0                        
                        ula_out32(0) <= std_logic(ula_entrada_b(5));
                    when "00001" => --1
                        ula_out32(1) <= std_logic(ula_entrada_b(5));
                    when "00010" => --2
                        ula_out32(2) <= std_logic(ula_entrada_b(5));
                    when "00011" => --3
                        ula_out32(3) <= std_logic(ula_entrada_b(5));
                    when "00100" => --4
                        ula_out32(4) <= std_logic(ula_entrada_b(5));
                    when "00101" => --5
                        ula_out32(5) <= std_logic(ula_entrada_b(5));
                    when "00110" => --6
                        ula_out32(6) <= std_logic(ula_entrada_b(5));
                    when "00111" => --7
                        ula_out32(7) <= std_logic(ula_entrada_b(5));
                    when "01000" => --8
                        ula_out32(8) <= std_logic(ula_entrada_b(5));
                    when "01001" => --9
                        ula_out32(9) <= std_logic(ula_entrada_b(5));
                    when "01010" => --10
                        ula_out32(10) <= std_logic(ula_entrada_b(5));
                    when "01011" => --11
                        ula_out32(11) <= std_logic(ula_entrada_b(5));
                    when "01100" => --12
                        ula_out32(12) <= std_logic(ula_entrada_b(5));
                    when "01101" => --13
                        ula_out32(13) <= std_logic(ula_entrada_b(5));
                    when "01110" => --14
                        ula_out32(14) <= std_logic(ula_entrada_b(5));
                    when "01111" => --15
                        ula_out32(15) <= std_logic(ula_entrada_b(5));
                    when "10000" => --16
                        ula_out32(16) <= std_logic(ula_entrada_b(5));
                    when "10001" => --17
                        ula_out32(17) <= std_logic(ula_entrada_b(5));
                    when "10010" => --18
                        ula_out32(18) <= std_logic(ula_entrada_b(5));
                    when "10011" => --19
                        ula_out32(19) <= std_logic(ula_entrada_b(5));
                    when "10100" => --20
                        ula_out32(20) <= std_logic(ula_entrada_b(5));
                    when "10101" => --21
                        ula_out32(21) <= std_logic(ula_entrada_b(5));
                    when "10110" => --22
                        ula_out32(22) <= std_logic(ula_entrada_b(5));
                    when "10111" => --23
                        ula_out32(23) <= std_logic(ula_entrada_b(5));
                    when "11000" => --24
                        ula_out32(24) <= std_logic(ula_entrada_b(5));
                    when "11001" => --25
                        ula_out32(25) <= std_logic(ula_entrada_b(5));
                    when "11010" => --26
                        ula_out32(26) <= std_logic(ula_entrada_b(5));
                    when "11011" => --27
                        ula_out32(27) <= std_logic(ula_entrada_b(5));
                    when "11100" => --28
                        ula_out32(28) <= std_logic(ula_entrada_b(5));
                    when "11101" => --29
                        ula_out32(29) <= std_logic(ula_entrada_b(5));
                    when "11110" => --30
                        ula_out32(30) <= std_logic(ula_entrada_b(5));                                                 
                    when others =>  --31            
                        ula_out32(31) <= std_logic(ula_entrada_b(5));  
                end case; 
                
                ula_out <= ula_out32;
                
                ula_flag_zero <= '0';
                erro_ula <= er_livre;    
            when "10110" =>                                               -- spat
                ula_out32 <= std_logic_vector(unsigned(ula_entrada_a));
                
                case unsigned(ula_entrada_b(4 downto 0)) is
                    when "00000" => --0                        
                        ula_out32(0) <= std_logic(ula_entrada_b(31));
                    when "00001" => --1
                        ula_out32(1) <= std_logic(ula_entrada_b(31));
                    when "00010" => --2
                        ula_out32(2) <= std_logic(ula_entrada_b(31));
                    when "00011" => --3
                        ula_out32(3) <= std_logic(ula_entrada_b(31));
                    when "00100" => --4
                        ula_out32(4) <= std_logic(ula_entrada_b(31));
                    when "00101" => --5
                        ula_out32(5) <= std_logic(ula_entrada_b(31));
                    when "00110" => --6
                        ula_out32(6) <= std_logic(ula_entrada_b(31));
                    when "00111" => --7
                        ula_out32(7) <= std_logic(ula_entrada_b(31));
                    when "01000" => --8
                        ula_out32(8) <= std_logic(ula_entrada_b(31));
                    when "01001" => --9
                        ula_out32(9) <= std_logic(ula_entrada_b(31));
                    when "01010" => --10
                        ula_out32(10) <= std_logic(ula_entrada_b(31));
                    when "01011" => --11
                        ula_out32(11) <= std_logic(ula_entrada_b(31));
                    when "01100" => --12
                        ula_out32(12) <= std_logic(ula_entrada_b(31));
                    when "01101" => --13
                        ula_out32(13) <= std_logic(ula_entrada_b(31));
                    when "01110" => --14
                        ula_out32(14) <= std_logic(ula_entrada_b(31));
                    when "01111" => --15
                        ula_out32(15) <= std_logic(ula_entrada_b(31));
                    when "10000" => --16
                        ula_out32(16) <= std_logic(ula_entrada_b(31));
                    when "10001" => --17
                        ula_out32(17) <= std_logic(ula_entrada_b(31));
                    when "10010" => --18
                        ula_out32(18) <= std_logic(ula_entrada_b(31));
                    when "10011" => --19
                        ula_out32(19) <= std_logic(ula_entrada_b(31));
                    when "10100" => --20
                        ula_out32(20) <= std_logic(ula_entrada_b(31));
                    when "10101" => --21
                        ula_out32(21) <= std_logic(ula_entrada_b(31));
                    when "10110" => --22
                        ula_out32(22) <= std_logic(ula_entrada_b(31));
                    when "10111" => --23
                        ula_out32(23) <= std_logic(ula_entrada_b(31));
                    when "11000" => --24
                        ula_out32(24) <= std_logic(ula_entrada_b(31));
                    when "11001" => --25
                        ula_out32(25) <= std_logic(ula_entrada_b(31));
                    when "11010" => --26
                        ula_out32(26) <= std_logic(ula_entrada_b(31));
                    when "11011" => --27
                        ula_out32(27) <= std_logic(ula_entrada_b(31));
                    when "11100" => --28
                        ula_out32(28) <= std_logic(ula_entrada_b(31));
                    when "11101" => --29
                        ula_out32(29) <= std_logic(ula_entrada_b(31));
                    when "11110" => --30
                        ula_out32(30) <= std_logic(ula_entrada_b(31));                                                 
                    when others =>  --31            
                        ula_out32(31) <= std_logic(ula_entrada_b(31));  
                end case; 
                
                ula_out <= ula_out32;
                
                ula_flag_zero <= '0';
                erro_ula <= er_livre;    
            when "10111" =>                                               -- divf, c = a divf b. c recebe um float de 32bits. Vaorl inteiro[31 to 16], fracao [15 to 0]
                ula_out <= std_logic_vector(unsigned(ZEROS32)); -- não faz nada por enquanto. Falta desenvolver este código
                ula_flag_zero <= '0';  
                erro_ula <= er_livre;   
                            
            when others =>
                ula_out <= ula_out;
                ula_flag_zero <= '0';
                erro_ula <= er_ula_cntrl_u;                             -- ula_cntrl desconhecido
            end case;        
    end process ;
        
    ------------------------------------------
    --          CONTROLE DA ULA             --
    ------------------------------------------
    ULA_CNTRL_HW: process(clk, ula_op, ri_funct)	
    begin          
            if (ula_op="0000") then                                       -- load e store, apenas soma e salva em ula_out                
                ula_cntrl <= "00000";                                     -- envia para a ula o sinal de controle
                erro_ula_cntrl <= er_livre;
            elsif (ula_op="0001") then                                    -- branches, subtrai e salva na flag zero                
                ula_cntrl <= "00011";
                erro_ula_cntrl <= er_livre;
            elsif (ula_op="0010") then                                    -- tipo R                
                case ri_funct is
                    when "000111" =>                                    -- add, apenas soma e salva em ula_out                        
                        ula_cntrl <= "00001";
                        erro_ula_cntrl <= er_livre;
                    when "000001" =>                                    -- and, apenas and e salva em ula_out                        
                        ula_cntrl <= "00010";
                        erro_ula_cntrl <= er_livre;
                    when "001000" =>                                    -- xor, apenas xor e salva em ula_out                        
                        ula_cntrl <= "00100";
                        erro_ula_cntrl <= er_livre;
                    when "001101" =>                                    -- stl, apenas stl e salva em ula_out                        
                        ula_cntrl <= "00110";
                        erro_ula_cntrl <= er_livre;
                    when "001110" =>                                    -- sub, apenas sub e salva em ula_out                        
                        ula_cntrl <= "00111";
                        erro_ula_cntrl <= er_livre;
                    when "001111" =>                                    -- move, copia dado de origem                        
                        ula_cntrl <= "01000";
                        erro_ula_cntrl <= er_livre;
                    when "010000" =>                                    -- nand, c = not (a and b)                        
                        ula_cntrl <= "01010";
                        erro_ula_cntrl <= er_livre;
                    when "010001" =>                                    -- b = not a                        
                        ula_cntrl <= "01011";
                        erro_ula_cntrl <= er_livre;        
                    when "010010" =>                                    -- nor, c = not (a or b)                        
                        ula_cntrl <= "01100";
                        erro_ula_cntrl <= er_livre;        
                    when "010011" =>                                    -- or, c = a or b                        
                        ula_cntrl <= "01101";
                        erro_ula_cntrl <= er_livre;
                    when "010100" =>                                    -- mult, c = a mult b                        
                        ula_cntrl <= "01110";
                        erro_ula_cntrl <= er_livre;        
                    when "010101" =>                                    -- div, c = a div b                        
                        ula_cntrl <= "01111";
                        erro_ula_cntrl <= er_livre;
                    when "010110" =>                                    -- rem, c = a % b                        
                        ula_cntrl <= "10000";
                        erro_ula_cntrl <= er_livre;
                    when "011101" =>                                    -- divf, c = a / b. Retorna um float de 32 bits                        
                        ula_cntrl <= "10111";
                        erro_ula_cntrl <= er_livre;
            
                    when others =>                                      -- ri_funct desconhecido                                        
                        erro_ula_cntrl <= er_ula_ri_funct;        
                end case;
                erro_ula_cntrl <= er_livre;
            elsif (ula_op="0011") then                                    -- branch if not equal compara e salva na flag zero                
                ula_cntrl <= "00101";
                erro_ula_cntrl <= er_livre;            
            elsif (ula_op="0100") then                                    -- load imediato                
                ula_cntrl <= "01001";
                erro_ula_cntrl <= er_livre;
            elsif (ula_op="0101") then                                    -- branch if grater than                
                ula_cntrl <= "10011";
                erro_ula_cntrl <= er_livre;
            elsif (ula_op="0110") then                                    -- branch if less than                
                ula_cntrl <= "10100";
                erro_ula_cntrl <= er_livre;
            elsif (ula_op="0111") then                                    -- spati, set a bit on position at                
                ula_cntrl <= "10101";
                erro_ula_cntrl <= er_livre;
            elsif (ula_op="1000") then                                    -- spat, set a bit on position at                
                ula_cntrl <= "10110";
                erro_ula_cntrl <= er_livre;
            elsif (ula_op="1001") then                                    -- sll, b = a << imediato16                
                ula_cntrl <= "10001";
                erro_ula_cntrl <= er_livre;
            elsif (ula_op="1010") then                                    -- srl, b = imediato16 >> a                
                ula_cntrl <= "10010";
                erro_ula_cntrl <= er_livre;
            elsif (ula_op="1010") then                                    -- load soma                
                ula_cntrl <= "10010";
                erro_ula_cntrl <= er_livre;
            
            else 
                erro_ula_cntrl <= er_ula_op_u;                          -- ula_op desconhecido                    
            end if;		                            
    end process; 
    
    ------------------------------------------
    --       REGISTRADOR_INSTRUCAO          --
    ------------------------------------------
    REGISTRADOR_INSTRUCAO_HW: process(clk, rst, escreve_reg_instr, saida_memoria)	
    begin              
        if (clk'event and clk ='1') then
            if (rst = '1') then			
                le_operacao         <= "100000";           -- inicia com o valor de reset		
                ri_rs               <= "00000";            
                ri_rt               <= "00000";            
                ri_rd               <= "00000";            
                ri_funct            <= "000000";           
                ri_endereco         <= "000000000";        
                ri_imediato         <= "0000000000000000";
                 
            elsif(escreve_reg_instr = '1') then                
                                                                   --    00010100110001110100000001010011 : exemplo
                le_operacao         <= saida_memoria(31 downto 26);-- 5  000101|||||||||||||||||||||||||| 
                ri_rs               <= saida_memoria(25 downto 21);-- 6        00110|||||||||||||||||||||
                ri_rt               <= saida_memoria(20 downto 16);-- 7             00111||||||||||||||||
                ri_rd               <= saida_memoria(15 downto 11);-- 8                  01000|||||||||||
                ri_funct            <= saida_memoria( 5 downto  0);-- 19                 ||||||||||010011
                ri_endereco         <= saida_memoria( 8 downto  0);-- 83                 |||||||001010011
                ri_imediato         <= saida_memoria(15 downto  0);-- 16467              0100000001010011                               
            end if; 
        end if;                             		                            
    end process;
       
    ------------------------------------------
    --        BANCO DE REGISTRADORES        --
    ------------------------------------------
   BANCO_REGISTRADORES_HW_CARREGA_ULA: process(clk, rst, escreve_registrador)
    begin
        if (clk'event and clk ='1' and escreve_registrador = '0' and rst = '0') then
                case ri_rs is
                    when "00000" => 
                        ula_entrada_a <= banco_de_registradores_r0;
                        erro_bnk_regs_rs <= er_livre; 
                    when "00001" => 
                        ula_entrada_a <= banco_de_registradores_r1;
                        erro_bnk_regs_rs <= er_livre; 
                    when "00010" => 
                        ula_entrada_a <= banco_de_registradores_r2; 
                        erro_bnk_regs_rs <= er_livre;
                    when "00011" => 
                        ula_entrada_a <= banco_de_registradores_r3;
                        erro_bnk_regs_rs <= er_livre; 
                    when "00100" => 
                        ula_entrada_a <= banco_de_registradores_r4; 
                        erro_bnk_regs_rs <= er_livre;
                    when "00101" => 
                        ula_entrada_a <= banco_de_registradores_r5; 
                        erro_bnk_regs_rs <= er_livre;
                    when "00110" => 
                        ula_entrada_a <= banco_de_registradores_r6;
                        erro_bnk_regs_rs <= er_livre; 
                    when "00111" => 
                        ula_entrada_a <= banco_de_registradores_r7;
                        erro_bnk_regs_rs <= er_livre;
                    when others =>
                        ula_entrada_a <= banco_de_registradores_r7;                    
                        erro_bnk_regs_rs  <= er_bnk_reg_rs_u; -- RS não reconhecido 
                end case;
                                 
                case ri_rt is
                    when "00000" => 
                        registrador_b <= banco_de_registradores_r0;  
                        erro_bnk_regs_rt <= er_livre;
                    when "00001" => 
                        registrador_b <= banco_de_registradores_r1; 
                        erro_bnk_regs_rt <= er_livre; 
                    when "00010" => 
                        registrador_b <= banco_de_registradores_r2;
                        erro_bnk_regs_rt <= er_livre; 
                    when "00011" => 
                        registrador_b <= banco_de_registradores_r3; 
                        erro_bnk_regs_rt <= er_livre; 
                    when "00100" => 
                        registrador_b <= banco_de_registradores_r4;
                        erro_bnk_regs_rt <= er_livre; 
                    when "00101" => 
                        registrador_b <= banco_de_registradores_r5;
                        erro_bnk_regs_rt <= er_livre; 
                    when "00110" => 
                        registrador_b <= banco_de_registradores_r6; 
                        erro_bnk_regs_rt <= er_livre; 
                    when "00111" => 
                        registrador_b <= banco_de_registradores_r7; 
                        erro_bnk_regs_rt <= er_livre; 
                    when others =>
                        registrador_b <= banco_de_registradores_r7;
                        erro_bnk_regs_rt <= er_bnk_reg_rt_u; -- RT não reconhecido
                end case;                     
        end if;
    end process;    
    
    BANCO_REGISTRADORES_HW_ESCREVE_REGISTRADOR: process(clk, rst, escreve_registrador)	
    begin                                
        if (clk'event and clk ='1' and rst = '0' and escreve_registrador = '1') then
                                                                        -- Sinal de controle que autoriza a escrita do dado no banco de registrador			
            case bnk_reg_escreve_registrador_id is
                when "0000" =>                     
                    banco_de_registradores_r0 <= bnk_reg_escreve_dado;  -- se escrevesse assim estaria certo num loop? when j => reg(i) <= escreve_dado;
                    erro_bnk_regs <= er_livre;
                when "0001" => 
                    banco_de_registradores_r1 <= bnk_reg_escreve_dado;
                    erro_bnk_regs <= er_livre;
                when "0010" => 
                    banco_de_registradores_r2 <= bnk_reg_escreve_dado;
                    erro_bnk_regs <= er_livre;
                when "0011" => 
                    banco_de_registradores_r3 <= bnk_reg_escreve_dado;
                    erro_bnk_regs <= er_livre;
                when "0100" => 
                    banco_de_registradores_r4 <= bnk_reg_escreve_dado;
                    erro_bnk_regs <= er_livre;
                when "0101" => 
                    banco_de_registradores_r5 <= bnk_reg_escreve_dado;
                    erro_bnk_regs <= er_livre;
                when "0110" => 
                    banco_de_registradores_r6 <= bnk_reg_escreve_dado;
                    erro_bnk_regs <= er_livre;
                when "0111" => 
                    banco_de_registradores_r7 <= bnk_reg_escreve_dado;
                    erro_bnk_regs <= er_livre;
                when others =>
                    banco_de_registradores_r7 <= bnk_reg_escreve_dado;
                    erro_bnk_regs <= er_bnk_reg_salvar;                 -- Identificador de registrador desconhecido
            end case;		 
        end if;		                            
    end process;
        
    ------------------------------------------
    --           REGISTRADOR MDR            --
    ------------------------------------------
    REGISTRADOR_MDR_HW: process(clk, rst)	
    begin
        if (clk'event and clk ='1') then
            if (rst='1') then 
                registrador_mdr  <= ZEROS32;
            else
                 registrador_mdr <= saida_memoria(31 downto 0);
            end if;
        end if;                                                                          
    end process;

    ------------------------------------------
    --           PROGRAM COUNTER            --
    ------------------------------------------
    PROGRAM_COUNTER_HW: process(clk, rst, pc_enable, fonte_pc)	
    begin     
        if (clk'event and clk ='1') then 
            if (rst='1') then
                registrador_pc <= ZEROS32(8 downto 0); 
            else        
                if (pc_enable = '1') then   
                        
                    if (fonte_pc = "00") then 
                        if ((registrador_pc + "000000100") > "111111100") then -- testa se (PC+4)>508. é maior que tamanho da memoria? 508, pq mais 4 é o tamanho total da memoria e nao pode receber tamanho total, se não vai dar fora do intervalo
                            registrador_pc <= "000000000";                     -- retorna para o inicio
                        else
                            registrador_pc <= registrador_pc + "000000100";    --PC + 4
                        end if;                        
                    elsif (fonte_pc = "01") then
                        registrador_pc <= ri_endereco;                         -- jump ou branch recebe endereco
                    else
                        registrador_pc <= registrador_pc;
                    end if;
                elsif ((ula_cntrl = "00011") and ((ula_entrada_a xor ula_entrada_b) = ZEROS32)) or
                ((ula_cntrl = "00101") and not ((ula_entrada_a xor ula_entrada_b) = ZEROS32)) or
                ((ula_cntrl = "10011") and (ula_entrada_a > ula_entrada_b)) or
                ((ula_cntrl = "10100") and (ula_entrada_a < ula_entrada_b))  then                
                       registrador_pc <= ri_endereco;                         -- branches!
                end if;	                
            end if;                 	
        end if;	                            
    end process;        
    
    ------------------------------------------
    --         ENTRADA DA MEMORIA           --
    ------------------------------------------
    entrada_memoria <= registrador_b;

    ------------------------------------------
    --               FLOAT                  --
    ------------------------------------------    
    ula_entrada_a_f <= ula_entrada_a;
    
    ------------------------------------------
    --           MULTIPLEXADORES            --
    ------------------------------------------
    -- MUX 5 REGISTRADOR B PARA ULA   
    ula_entrada_b <= std_logic_vector(registrador_b)                       when ula_fonte_b = "00" else                     
                     std_logic_vector(ZEROS32(31 downto 16) & ri_imediato) when ula_fonte_b = "01" else      -- estende sinal do valor imediato               
                     std_logic_vector(ri_imediato(0) & registrador_b(30 downto 0));                                  -- ajuste de sinal de spat regular   
        
    -- MUX 3 CAMPOS RT E RD, DO REGISTRADOR DE INSTRUCAO, PARA BANCO DE REGISTRADORES
    bnk_reg_escreve_registrador_id <= std_logic_vector(ri_rt(3 downto 0)) when registrador_destino = '0' else 
                                      std_logic_vector(ri_rd(3 downto 0));
            
    -- MUX 2 REGISTRADOR DE DADOS DA MEMORIA (RDM) PARA MEMORIA
    bnk_reg_escreve_dado <= std_logic_vector(unsigned(ula_out))         when reg_mem = "00" else 
                            std_logic_vector(unsigned(registrador_mdr)) when reg_mem = "01" else
                            std_logic_vector(unsigned(registrador_mdr) + unsigned(registrador_b)) when reg_mem = "10" else
                            std_logic_vector(unsigned(ula_outf));
    
    -- MUX 1 PROGRAM COUNTER (PC) PARA ENDERECO DA MEMORIA
    endereco_memoria <= registrador_pc when instr_ou_dado = '0' else ula_out(8 downto 0);
    
end rtl;
