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

library mito;
use mito.mito_pkg.all;

entity control_unit is
    Port ( 
        clk                 : in  std_logic;
        rst                 : in  std_logic;                    -- reset                
        pc_enable           : out std_logic;                    -- habilita escrever no pc
        ula_flag_zero       : in  std_logic;                    -- flag='1' se caso satisfatorio de branch if equal        
        instr_ou_dado       : out std_logic;                    -- instrucao ou dado 
        escreve_memoria     : out std_logic;                    -- escreve na memoria: 0 nao escreve, 1: escreve
        escreve_reg_instr   : out std_logic;                    -- escreve no registrador de instrucao
        reg_mem             : out std_logic_vector(1 downto 0); -- registrador recebe dado da memoria
        fonte_pc            : out std_logic_vector(1 downto 0); -- fonte do PC
        ula_op              : out std_logic_vector(3 downto 0); -- operacao da ULA
        ula_fonte_b         : out std_logic_vector(1 downto 0); -- fonte da entrada B da ULA
        escreve_registrador : out std_logic;                    -- escreve no banco de registradores
        registrador_destino : out std_logic;                    -- registrador de destino
        le_operacao         : in  std_logic_vector(5 downto 0); -- operacao lida da memoria a ser realizada
        finished_job_float  : in  std_logic;                     -- sinal exclusivo para calculos float
        rst_float           : out std_logic 
    );
end control_unit;


architecture rtl of control_unit is
        type state_type is (passo_reset, passo_erro, passo_1, passo_2, 
                            passo_3_cfloat, passo_3_divf, passo_3_spati, passo_3_spat, passo_3_srl, passo_3_sll, passo_3_rem, passo_3_div, passo_3_mult, passo_3_nand, passo_3_not, passo_3_nor, passo_3_or, passo_3_move, passo_3_sub, passo_3_add, passo_3_addi, passo_3_and, passo_3_store, passo_3_load, passo_3_loadi, passo_3_loads, passo_3_xor, passo_3_stl, passo_3_beq, passo_3_bne, passo_3_bgt, passo_3_blt, passo_3_jump,  passo_3_nop, passo_3_erro, 
                            passo_4_cfloat, passo_4_divf, passo_4_spati, passo_4_spat, passo_4_srl, passo_4_sll, passo_4_rem, passo_4_div, passo_4_mult, passo_4_nand, passo_4_not, passo_4_nor, passo_4_or, passo_4_move, passo_4_sub, passo_4_add, passo_4_addi, passo_4_and, passo_4_store, passo_4_load, passo_4_loadi, passo_4_loads, passo_4_xor, passo_4_stl, passo_4_erro,
                            passo_5_store, passo_5_load, passo_5_loads, passo_halt, passo_starting);
                            
        signal estado : state_type := passo_reset;     
        signal estado_anterior : state_type := passo_starting;
        
begin

    process(clk, rst) 	
    begin  
        if (rst='1') then
            estado <= passo_reset;                    
        elsif (clk'event and clk = '1') then
            estado_anterior <= estado;
            
            case estado is
                when passo_reset =>
                    estado <= passo_1;  
                                      
                when passo_erro =>
                    estado <= passo_reset;

                when passo_halt =>
                    estado <= passo_halt;               -- loop infinito                   
                        
                when passo_1 =>
                    estado <= passo_2;
                    
                when passo_2 =>
                    if (le_operacao = "000001") then     
                        estado <= passo_3_and; 
                    elsif (le_operacao = "000010") then 
                        estado <= passo_3_store;
                    elsif (le_operacao = "000011") then 
                        estado <= passo_3_load;
                    elsif (le_operacao = "000100") then
                        estado <= passo_3_beq; 
                    elsif (le_operacao = "000101") then
                        estado <= passo_3_jump;
                    elsif (le_operacao = "000110") then
                        estado <= passo_halt;            -- loop infinito: encerra programa
                    elsif (le_operacao = "000111") then          
                        estado <= passo_3_add;
                    elsif (le_operacao = "001000") then          
                        estado <= passo_3_xor;
                    elsif (le_operacao = "001001") then          
                        estado <= passo_3_loads;
                    elsif (le_operacao = "001010") then          
                        estado <= passo_3_addi;
                    elsif (le_operacao = "001011") then          
                        estado <= passo_3_loadi;
                    elsif (le_operacao = "001100") then          
                        estado <= passo_3_bne;
                    elsif (le_operacao = "001101") then          
                        estado <= passo_3_stl;
                    elsif (le_operacao = "001110") then          
                        estado <= passo_3_sub;
                    elsif (le_operacao = "001111") then          
                        estado <= passo_3_move;
                    elsif (le_operacao = "010000") then          
                        estado <= passo_3_nand;
                    elsif (le_operacao = "010001") then          
                        estado <= passo_3_not;
                    elsif (le_operacao = "010010") then          
                        estado <= passo_3_nor;
                    elsif (le_operacao = "010011") then          
                        estado <= passo_3_or;
                    elsif (le_operacao = "010100") then          
                        estado <= passo_3_mult;
                    elsif (le_operacao = "010101") then          
                        estado <= passo_3_div;         
                    elsif (le_operacao = "010110") then          
                        estado <= passo_3_rem;         
                    elsif (le_operacao = "010111") then          
                        estado <= passo_3_sll;       
                    elsif (le_operacao = "011000") then          
                        estado <= passo_3_srl;
                    elsif (le_operacao = "011001") then          
                        estado <= passo_3_bgt;       
                    elsif (le_operacao = "011010") then          
                        estado <= passo_3_blt;
                    elsif (le_operacao = "011011") then          
                        estado <= passo_3_spati;
                    elsif (le_operacao = "011100") then          
                        estado <= passo_3_spat;
                    elsif (le_operacao = "011101") then          
                        estado <= passo_3_divf;
                    elsif (le_operacao = "011110") then          
                        estado <= passo_3_nop;
                    elsif (le_operacao = "011111") then          
                        estado <= passo_3_cfloat;
                    elsif (le_operacao = "100000") then
                        estado <= passo_1;               -- passo reseting                    
                    else                        
                        estado <= passo_3_erro;
                    end if;
                
                when passo_3_cfloat =>
                    if (finished_job_float = '0') then
                        estado <= passo_3_cfloat;
                    else
                        estado <= passo_4_cfloat;
                    end if;                    
                when passo_3_nop =>
                    estado <= passo_1;
                when passo_3_divf =>
                    estado <= passo_4_divf;
                when passo_3_spati =>
                    estado <= passo_4_spati;
                when passo_3_spat =>
                    estado <= passo_4_spat;
                when passo_3_bgt =>
                    estado <= passo_1;
                when passo_3_blt =>
                    estado <= passo_1;    
                when passo_3_srl =>
                    estado <= passo_4_srl;
                when passo_3_sll =>
                    estado <= passo_4_sll;
                when passo_3_rem =>
                    estado <= passo_4_rem;
                when passo_3_div =>
                    estado <= passo_4_div;
                when passo_3_mult =>
                    estado <= passo_4_mult;
                when passo_3_and =>
                    estado <= passo_4_and;
                when passo_3_nand =>
                    estado <= passo_4_nand;
                when passo_3_not =>
                    estado <= passo_4_not;
                when passo_3_nor =>
                    estado <= passo_4_nor;
                when passo_3_or =>
                    estado <= passo_4_or;                
                when passo_3_move =>
                    estado <= passo_4_move;
                when passo_3_sub =>
                    estado <= passo_4_sub;    
                when passo_3_add =>
                    estado <= passo_4_add;
                when passo_3_addi =>
                    estado <= passo_4_addi;
                when passo_3_xor =>
                    estado <= passo_4_xor;  
                when passo_3_store =>
                    estado <= passo_4_store;
                when passo_3_load =>
                    estado <= passo_4_load;
                when passo_3_loads =>
                    estado <= passo_4_loads;
                when passo_3_loadi =>
                    estado <= passo_4_loadi; 
                when passo_3_beq =>
                    estado <= passo_1;                    
                when passo_3_bne =>
                    estado <= passo_1;
                when passo_3_jump =>
                    estado <= passo_1;
                when passo_3_stl =>
                    estado <= passo_4_stl;
                when passo_3_erro =>
                    estado <= passo_erro;       -- se erro entao reinicia   
                
                when passo_4_cfloat =>
                    estado <= passo_1;
                when passo_4_divf =>
                    estado <= passo_1;
                when passo_4_spati =>
                    estado <= passo_1;
                when passo_4_spat =>
                    estado <= passo_1;
                when passo_4_srl =>
                    estado <= passo_1;
                when passo_4_sll =>
                    estado <= passo_1;
                when passo_4_rem =>
                    estado <= passo_1;
                when passo_4_div =>
                    estado <= passo_1;
                when passo_4_mult =>
                    estado <= passo_1;                
                when passo_4_nand =>
                    estado <= passo_1;
                when passo_4_not =>
                    estado <= passo_1;
                when passo_4_nor =>
                    estado <= passo_1;
                when passo_4_or =>
                    estado <= passo_1;
                when passo_4_move =>   
                    estado <= passo_1;
                when passo_4_sub =>   
                    estado <= passo_1;    
                when passo_4_add =>   
                    estado <= passo_1;
                when passo_4_addi =>   
                    estado <= passo_1;
                when passo_4_xor =>   
                    estado <= passo_1;
                when passo_4_and =>
                    estado <= passo_1;
                when passo_4_store =>
                    estado <= passo_5_store;
                when passo_4_load =>
                    estado <= passo_5_load;         
                when passo_4_loads =>
                    estado <= passo_5_loads;
                when passo_4_loadi =>
                    estado <= passo_1; 
                when passo_4_stl =>
                    estado <= passo_1;
                when passo_4_erro =>
                    estado <= passo_erro;       -- se erro entao reinicia   
                                                                                      
                when passo_5_store =>
                    estado <= passo_1;
                when passo_5_load =>                    
                    estado <= passo_1;          -- somente load passa aqui
                when passo_5_loads =>                    
                    estado <= passo_1;          -- somente loads passa aqui
                  
                when others =>
                    estado <= passo_reset;
            end case;
        end if;		                            
    end process;        


    process(estado)	
    begin  
        case estado is        
            when passo_1 =>
                pc_enable <= '1';               -- escreve o PC+4
                escreve_reg_instr <= '1';       -- escreve no registrador de instrucao
                instr_ou_dado <= '0';           -- instrucao ou dado: seletor do mux1, se origem é PC(end de nova instrução) ou UlaOut (end da memória a ser gravado o dado)
                escreve_memoria <= '0';         -- escreve na memoria: sinal para memória que permite escrita, se 1 autoriza escrita
                reg_mem <= "00";                -- 'x'- mux2: banco de registradores recebe dado da memoria
                fonte_pc <= "00";               -- fonte do PC: mux6, seletor que envia pc+4, ou jump ou branch
                ula_op  <= "0000";              -- operacao da ULA: sinal para controle a ula
                ula_fonte_b  <= "00";           --  'x' - fonte da entrada B da ULA. mux4: seleciona registrador B ou valor imediato para entrada B da ula.
                escreve_registrador  <= '0';    -- sinal que autoriza escrita em registrador no banco de registradores
                registrador_destino  <= '0';    -- 'x'- seletor de mux3, que indica qual registrador de destino no banco de registradores
                rst_float <= '1';
--                if (estado_anterior = passo_4_store) then
--                    fonte_pc <= "00";
--                else
--                    fonte_pc <= "00";
--                end if;  
                                                      
            when passo_2 =>     
                pc_enable <= '0';
                instr_ou_dado <= '0';           -- 'x' - instrucao ou dado
                escreve_memoria <= '0';         -- escreve na memoria
                escreve_reg_instr <= '0';       -- escreve no registrador de instrucao
                reg_mem <= "00";                -- 'x'- registrador recebe dado da memoria
                fonte_pc <= "00";               -- 'x' - fonte do PC
                ula_op  <= "0000";              -- operacao da ULA
                ula_fonte_b  <= "00";           -- 'x' - fonte da entrada B da ULA
                escreve_registrador  <= '0';    -- escreve no banco de registradores    
                registrador_destino  <= '0';    -- 'x'- registrador de destino
                rst_float <= '1';
                
            when passo_3_cfloat =>              --falta implementar
                pc_enable <= '0';                
                instr_ou_dado <= '0';           -- 'x' - instrucao ou dado 
                escreve_memoria <= '0';         -- escreve na memoria
                escreve_reg_instr <= '0';       -- escreve no registrador de instrucao
                reg_mem <= "11";                -- 'x'- registrador recebe dado da memoria
                fonte_pc <= "00";               -- 'x' - fonte do PC
                ula_op  <= "0010";              -- operacao da ULA
                ula_fonte_b  <= "00";           -- 'x' fonte da entrada B da ULA. 
                escreve_registrador  <= '0';    -- escreve no banco de registradores
                registrador_destino  <= '0';    -- 'x'- registrador de destino
                rst_float <= '0';               -- inicia calculo float
                    
            when passo_3_move =>
                pc_enable <= '0';                
                instr_ou_dado <= '0';           -- 'x' - instrucao ou dado 
                escreve_memoria <= '0';         -- escreve na memoria
                escreve_reg_instr <= '0';       -- escreve no registrador de instrucao
                reg_mem <= "00";                -- 'x'- registrador recebe dado da memoria
                fonte_pc <= "00";               -- 'x' - fonte do PC
                ula_op  <= "0010";              -- operacao da ULA
                ula_fonte_b  <= "00";           -- 'x' fonte da entrada B da ULA. 
                escreve_registrador  <= '0';    -- escreve no banco de registradores
                registrador_destino  <= '0';    -- 'x'- registrador de destino
                rst_float <= '1';
                                
            when passo_3_nand =>
                pc_enable <= '0';                
                instr_ou_dado <= '0';           -- 'x' - instrucao ou dado 
                escreve_memoria <= '0';         -- escreve na memoria
                escreve_reg_instr <= '0';       -- escreve no registrador de instrucao
                reg_mem <= "00";                -- 'x'- registrador recebe dado da memoria
                fonte_pc <= "00";               -- 'x' - fonte do PC
                ula_op  <= "0010";              -- operacao da ULA
                ula_fonte_b  <= "00";           -- fonte da entrada B da ULA
                escreve_registrador  <= '0';    -- escreve no banco de registradores
                registrador_destino  <= '0';    -- 'x'- registrador de destino
                rst_float <= '1';
                
            when passo_3_not =>
                pc_enable <= '0';                
                instr_ou_dado <= '0';           -- 'x' - instrucao ou dado 
                escreve_memoria <= '0';         -- escreve na memoria
                escreve_reg_instr <= '0';       -- escreve no registrador de instrucao
                reg_mem <= "00";                -- 'x'- registrador recebe dado da memoria
                fonte_pc <= "00";               -- 'x' - fonte do PC
                ula_op  <= "0010";              -- operacao da ULA
                ula_fonte_b  <= "00";           -- fonte da entrada B da ULA
                escreve_registrador  <= '0';    -- escreve no banco de registradores
                registrador_destino  <= '0';    -- 'x'- registrador de destino
                rst_float <= '1';
                
            when passo_3_nor =>
                pc_enable <= '0';                
                instr_ou_dado <= '0';           -- 'x' - instrucao ou dado 
                escreve_memoria <= '0';         -- escreve na memoria
                escreve_reg_instr <= '0';       -- escreve no registrador de instrucao
                reg_mem <= "00";                -- 'x'- registrador recebe dado da memoria
                fonte_pc <= "00";               -- 'x' - fonte do PC
                ula_op  <= "0010";              -- operacao da ULA
                ula_fonte_b  <= "00";           -- fonte da entrada B da ULA
                escreve_registrador  <= '0';    -- escreve no banco de registradores
                registrador_destino  <= '0';    -- 'x'- registrador de destino
                rst_float <= '1';
                     
            when passo_3_or =>
                pc_enable <= '0';                
                instr_ou_dado <= '0';           -- 'x' - instrucao ou dado 
                escreve_memoria <= '0';         -- escreve na memoria
                escreve_reg_instr <= '0';       -- escreve no registrador de instrucao
                reg_mem <= "00";                -- 'x'- registrador recebe dado da memoria
                fonte_pc <= "00";               -- 'x' - fonte do PC
                ula_op  <= "0010";              -- operacao da ULA
                ula_fonte_b  <= "00";           -- fonte da entrada B da ULA
                escreve_registrador  <= '0';    -- escreve no banco de registradores
                registrador_destino  <= '0';    -- 'x'- registrador de destino
                rst_float <= '1';
                
            when passo_3_mult =>
                pc_enable <= '0';                
                instr_ou_dado <= '0';           -- 'x' - instrucao ou dado 
                escreve_memoria <= '0';         -- escreve na memoria
                escreve_reg_instr <= '0';       -- escreve no registrador de instrucao
                reg_mem <= "00";                -- 'x'- registrador recebe dado da memoria
                fonte_pc <= "00";               -- 'x' - fonte do PC
                ula_op  <= "0010";              -- operacao da ULA
                ula_fonte_b  <= "00";           -- fonte da entrada B da ULA
                escreve_registrador  <= '0';    -- escreve no banco de registradores
                registrador_destino  <= '0';    -- 'x'- registrador de destino
                rst_float <= '1';
                                    
            when passo_3_rem =>
                pc_enable <= '0';                
                instr_ou_dado <= '0';           -- 'x' - instrucao ou dado 
                escreve_memoria <= '0';         -- escreve na memoria
                escreve_reg_instr <= '0';       -- escreve no registrador de instrucao
                reg_mem <= "00";                -- 'x'- registrador recebe dado da memoria
                fonte_pc <= "00";               -- 'x' - fonte do PC
                ula_op  <= "0010";              -- operacao da ULA
                ula_fonte_b  <= "00";           -- fonte da entrada B da ULA
                escreve_registrador  <= '0';    -- escreve no banco de registradores
                registrador_destino  <= '0';    -- 'x'- registrador de destino
                rst_float <= '1';
                            
            when passo_3_srl =>
                pc_enable <= '0';                
                instr_ou_dado <= '0';           -- 'x' - instrucao ou dado 
                escreve_memoria <= '0';         -- escreve na memoria
                escreve_reg_instr <= '0';       -- escreve no registrador de instrucao
                reg_mem <= "00";                -- 'x'- registrador recebe dado da memoria
                fonte_pc <= "00";               -- 'x' - fonte do PC
                ula_op  <= "1010";              -- operacao da ULA
                ula_fonte_b  <= "01";           -- fonte da entrada B da ULA
                escreve_registrador  <= '0';    -- escreve no banco de registradores
                registrador_destino  <= '0';    -- 'x'- registrador de destino
                rst_float <= '1';
                                                    
            when passo_3_sll =>
                pc_enable <= '0';                
                instr_ou_dado <= '0';           -- 'x' - instrucao ou dado 
                escreve_memoria <= '0';         -- escreve na memoria
                escreve_reg_instr <= '0';       -- escreve no registrador de instrucao
                reg_mem <= "00";                -- 'x'- registrador recebe dado da memoria
                fonte_pc <= "00";               -- 'x' - fonte do PC
                ula_op  <= "1001";              -- operacao da ULA
                ula_fonte_b  <= "01";           -- fonte da entrada B da ULA
                escreve_registrador  <= '0';    -- escreve no banco de registradores
                registrador_destino  <= '0';    -- 'x'- registrador de destino
                rst_float <= '1';
                                      
            when passo_3_add =>
                pc_enable <= '0';                
                instr_ou_dado <= '0';           -- 'x' - instrucao ou dado 
                escreve_memoria <= '0';         -- escreve na memoria
                escreve_reg_instr <= '0';       -- escreve no registrador de instrucao
                reg_mem <= "00";                -- 'x'- registrador recebe dado da memoria
                fonte_pc <= "00";               -- 'x' - fonte do PC
                ula_op  <= "0010";              -- operacao da ULA
                ula_fonte_b  <= "00";           -- fonte da entrada B da ULA
                escreve_registrador  <= '0';    -- escreve no banco de registradores
                registrador_destino  <= '0';    -- 'x'- registrador de destino
                rst_float <= '1';
                
            when passo_3_addi =>
                pc_enable <= '0';                
                instr_ou_dado <= '0';           -- 'x' - instrucao ou dado 
                escreve_memoria <= '0';         -- escreve na memoria
                escreve_reg_instr <= '0';       -- escreve no registrador de instrucao
                reg_mem <= "00";                -- 'x'- registrador recebe dado da memoria
                fonte_pc <= "00";               -- 'x' - fonte do PC
                ula_op  <= "0000";              -- operacao da ULA - Usa a soma de load e store, sem precisar adicionar hardware
                ula_fonte_b  <= "01";           -- fonte da entrada B da ULA
                escreve_registrador  <= '0';    -- escreve no banco de registradores
                registrador_destino  <= '0';    -- 'x'- registrador de destino            
                rst_float <= '1';
                
            when passo_3_spati =>
                pc_enable <= '0';                
                instr_ou_dado <= '0';           -- 'x' - instrucao ou dado 
                escreve_memoria <= '0';         -- escreve na memoria
                escreve_reg_instr <= '0';       -- escreve no registrador de instrucao
                reg_mem <= "00";                -- 'x'- registrador recebe dado da memoria
                fonte_pc <= "00";               -- 'x' - fonte do PC
                ula_op  <= "0111";              -- operacao da ULA - Usa a soma de load e store, sem precisar adicionar hardware
                ula_fonte_b  <= "01";           -- fonte da entrada B da ULA
                escreve_registrador  <= '0';    -- escreve no banco de registradores
                registrador_destino  <= '0';    -- 'x'- registrador de destino            
                rst_float <= '1';
                
            when passo_3_spat =>
                pc_enable <= '0';                
                instr_ou_dado <= '0';           -- 'x' - instrucao ou dado 
                escreve_memoria <= '0';         -- escreve na memoria
                escreve_reg_instr <= '0';       -- escreve no registrador de instrucao
                reg_mem <= "00";                -- 'x'- registrador recebe dado da memoria
                fonte_pc <= "00";               -- 'x' - fonte do PC
                ula_op  <= "1000";              -- operacao da ULA - Usa a soma de load e store, sem precisar adicionar hardware
                ula_fonte_b  <= "10";           -- fonte da entrada B da ULA
                escreve_registrador  <= '0';    -- escreve no banco de registradores
                registrador_destino  <= '0';    -- 'x'- registrador de destino            
                rst_float <= '1';
                
            when passo_3_div =>
                pc_enable <= '0';                
                instr_ou_dado <= '0';           -- 'x' - instrucao ou dado 
                escreve_memoria <= '0';         -- escreve na memoria
                escreve_reg_instr <= '0';       -- escreve no registrador de instrucao
                reg_mem <= "00";                -- 'x'- registrador recebe dado da memoria
                fonte_pc <= "00";               -- 'x' - fonte do PC
                ula_op  <= "0010";              -- operacao da ULA
                ula_fonte_b  <= "00";           -- fonte da entrada B da ULA
                escreve_registrador  <= '0';    -- escreve no banco de registradores
                registrador_destino  <= '0';    -- 'x'- registrador de destino
                rst_float <= '1';
                
            when passo_3_divf =>
                pc_enable <= '0';                
                instr_ou_dado <= '0';           -- 'x' - instrucao ou dado 
                escreve_memoria <= '0';         -- escreve na memoria
                escreve_reg_instr <= '0';       -- escreve no registrador de instrucao
                reg_mem <= "00";                -- 'x'- registrador recebe dado da memoria
                fonte_pc <= "00";               -- 'x' - fonte do PC
                ula_op  <= "0010";              -- operacao da ULA
                ula_fonte_b  <= "00";           -- fonte da entrada B da ULA
                escreve_registrador  <= '0';    -- escreve no banco de registradores
                registrador_destino  <= '0';    -- 'x'- registrador de destino
                rst_float <= '1';
                
            when passo_3_sub =>
                pc_enable <= '0';                
                instr_ou_dado <= '0';           -- 'x' - instrucao ou dado 
                escreve_memoria <= '0';         -- escreve na memoria
                escreve_reg_instr <= '0';       -- escreve no registrador de instrucao
                reg_mem <= "00";                -- 'x'- registrador recebe dado da memoria
                fonte_pc <= "00";               -- 'x' - fonte do PC
                ula_op  <= "0010";              -- operacao da ULA
                ula_fonte_b  <= "00";           -- fonte da entrada B da ULA
                escreve_registrador  <= '0';    -- escreve no banco de registradores
                registrador_destino  <= '0';    -- 'x'- registrador de destino
                rst_float <= '1';
                
            when passo_3_xor =>
                pc_enable <= '0';                
                instr_ou_dado <= '0';           -- 'x' - instrucao ou dado 
                escreve_memoria <= '0';         -- escreve na memoria
                escreve_reg_instr <= '0';       -- escreve no registrador de instrucao
                reg_mem <= "00";                -- 'x'- registrador recebe dado da memoria
                fonte_pc <= "00";               -- 'x' - fonte do PC
                ula_op  <= "0010";              -- operacao da ULA
                ula_fonte_b  <= "00";           -- fonte da entrada B da ULA
                escreve_registrador  <= '0';    -- escreve no banco de registradores
                registrador_destino  <= '0';    -- 'x'- registrador de destino
                rst_float <= '1';
                                
            when passo_3_and =>
                pc_enable <= '0';                
                instr_ou_dado <= '0';           -- 'x' - instrucao ou dado
                escreve_memoria <= '0';         -- escreve na memoria
                escreve_reg_instr <= '0';       -- escreve no registrador de instrucao
                reg_mem <= "00";                -- 'x'- registrador recebe dado da memoria
                fonte_pc <= "00";               -- 'x' - fonte do PC
                ula_op  <= "0010";              -- operacao da ULA
                ula_fonte_b  <= "00";           -- fonte da entrada B da ULA
                escreve_registrador  <= '0';    -- escreve no banco de registradores
                registrador_destino  <= '0';    -- 'x'- registrador de destino
                rst_float <= '1';
                
            when passo_3_store =>
                pc_enable <= '0';                
                instr_ou_dado <= '0';           -- 'x' - instrucao ou dado
                escreve_memoria <= '0';         -- escreve na memoria
                escreve_reg_instr <= '0';       -- escreve no registrador de instrucao
                reg_mem <= "00";                -- 'x'- registrador recebe dado da memoria
                fonte_pc <= "00";               -- 'x' - fonte do PC
                ula_op  <= "0000";              -- operacao da ULA
                ula_fonte_b  <= "01";           -- fonte da entrada B da ULA
                escreve_registrador  <= '0';    -- escreve no banco de registradores  
                registrador_destino  <= '0';    -- 'x'- registrador de destino
                rst_float <= '1';
                
            when passo_3_load =>
                pc_enable <= '0';                
                instr_ou_dado <= '0';           -- 'x' - instrucao ou dado
                escreve_memoria <= '0';         -- escreve na memoria
                escreve_reg_instr <= '0';       -- escreve no registrador de instrucao
                reg_mem <= "01";                -- 'x'- registrador recebe dado da memoria
                fonte_pc <= "00";               -- 'x' - fonte do PC
                ula_op  <= "0000";              -- operacao da ULA
                ula_fonte_b  <= "01";           -- fonte da entrada B da ULA
                escreve_registrador  <= '0';    -- escreve no banco de registradores
                registrador_destino  <= '0';    -- 'x'- registrador de destino
                rst_float <= '1';
                
            when passo_3_loadi =>
                pc_enable <= '0';                
                instr_ou_dado <= '0';           -- 'x' - instrucao ou dado 
                escreve_memoria <= '0';         -- escreve na memoria
                escreve_reg_instr <= '0';       -- escreve no registrador de instrucao
                reg_mem <= "00";                -- 'x'- registrador recebe dado da memoria
                fonte_pc <= "00";               -- 'x' - fonte do PC
                ula_op  <= "0100";              -- operacao da ULA
                ula_fonte_b  <= "01";           -- 'x' fonte da entrada B da ULA. 
                escreve_registrador  <= '0';    -- escreve no banco de registradores
                registrador_destino  <= '0';    -- 'x'- registrador de destino
                rst_float <= '1';
                    
            when passo_3_loads =>
                pc_enable <= '0';                
                instr_ou_dado <= '1';           -- 'x' - instrucao ou dado
                escreve_memoria <= '0';         -- escreve na memoria
                escreve_reg_instr <= '0';       -- escreve no registrador de instrucao
                reg_mem <= "10";                -- 'x'- registrador recebe dado da memoria
                fonte_pc <= "00";               -- 'x' - fonte do PC
                ula_op  <= "0000";              -- operacao da ULA
                ula_fonte_b  <= "01";           -- fonte da entrada B da ULA
                escreve_registrador  <= '0';    -- escreve no banco de registradores
                registrador_destino  <= '1';    -- 'x'- registrador de destino
                rst_float <= '1';
                
            when passo_3_stl =>
                pc_enable <= '0';                
                instr_ou_dado <= '0';           -- 'x' - instrucao ou dado 
                escreve_memoria <= '0';         -- escreve na memoria
                escreve_reg_instr <= '0';       -- escreve no registrador de instrucao
                reg_mem <= "00";                -- 'x'- registrador recebe dado da memoria
                fonte_pc <= "00";               -- 'x' - fonte do PC
                ula_op  <= "0010";              -- operacao da ULA
                ula_fonte_b  <= "00";           -- fonte da entrada B da ULA
                escreve_registrador  <= '0';    -- escreve no banco de registradores
                registrador_destino  <= '0';    -- 'x'- registrador de destino
                rst_float <= '1';
                
            when passo_3_blt =>
                pc_enable <= ula_flag_zero;     --'1' and ula_flag_zero; -- Se Flag=1, então o BEQ foi satisfeito
                instr_ou_dado <= '0';           -- 'x' - instrucao ou dado
                escreve_memoria <= '0';         -- escreve na memoria
                escreve_reg_instr <= '0';       -- escreve no registrador de instrucao
                reg_mem <= "00";                -- 'x'- registrador recebe dado da memoria
                fonte_pc <= "01";               -- fonte do PC - Escolhe endereço
                ula_op  <= "0110";              -- operacao da ULA
                ula_fonte_b  <= "00";           -- fonte da entrada B da ULA
                escreve_registrador  <= '0';    -- escreve no banco de registradores  
                registrador_destino  <= '0';    -- 'x'- registrador de destino
                rst_float <= '1';
                 
            when passo_3_bgt =>
                pc_enable <= ula_flag_zero;     --'1' and ula_flag_zero; -- Se Flag=1, então o BEQ foi satisfeito
                instr_ou_dado <= '0';           -- 'x' - instrucao ou dado
                escreve_memoria <= '0';         -- escreve na memoria
                escreve_reg_instr <= '0';       -- escreve no registrador de instrucao
                reg_mem <= "00";                -- 'x'- registrador recebe dado da memoria
                fonte_pc <= "01";               -- fonte do PC - Escolhe endereço
                ula_op  <= "0101";              -- operacao da ULA
                ula_fonte_b  <= "00";           -- fonte da entrada B da ULA
                escreve_registrador  <= '0';    -- escreve no banco de registradores  
                registrador_destino  <= '0';    -- 'x'- registrador de destino
                rst_float <= '1';
                 
            when passo_3_beq =>
                pc_enable <= ula_flag_zero;     --'1' and ula_flag_zero; -- Se Flag=1, então o BEQ foi satisfeito
                instr_ou_dado <= '0';           -- 'x' - instrucao ou dado
                escreve_memoria <= '0';         -- escreve na memoria
                escreve_reg_instr <= '0';       -- escreve no registrador de instrucao
                reg_mem <= "00";                -- 'x'- registrador recebe dado da memoria
                fonte_pc <= "01";               -- fonte do PC - Escolhe endereço
                ula_op  <= "0001";              -- operacao da ULA
                ula_fonte_b  <= "00";           -- fonte da entrada B da ULA
                escreve_registrador  <= '0';    -- escreve no banco de registradores  
                registrador_destino  <= '0';    -- 'x'- registrador de destino
                rst_float <= '1';
                
            when passo_3_bne =>
                pc_enable <= ula_flag_zero;     --'1' and ula_flag_zero; -- Se Flag=1, então o BEQ foi satisfeito
                instr_ou_dado <= '0';           -- 'x' - instrucao ou dado
                escreve_memoria <= '0';         -- escreve na memoria
                escreve_reg_instr <= '0';       -- escreve no registrador de instrucao
                reg_mem <= "00";                -- 'x'- registrador recebe dado da memoria
                fonte_pc <= "01";               -- fonte do PC - Escolhe endereço
                ula_op  <= "0011";              -- operacao da ULA
                ula_fonte_b  <= "00";           -- fonte da entrada B da ULA
                escreve_registrador  <= '0';    -- escreve no banco de registradores  
                registrador_destino  <= '0';    -- 'x'- registrador de destino
                rst_float <= '1';
                   
            when passo_3_nop =>
                pc_enable <= '0';                
                instr_ou_dado <= '0';           -- 'x' - instrucao ou dado
                escreve_memoria <= '0';         -- 'x' - escreve na memoria
                escreve_reg_instr <= '0';       -- 'x' - escreve no registrador de instrucao
                reg_mem <= "00";                -- 'x' - registrador recebe dado da memoria ou ula_out
                fonte_pc <= "01";               -- 'x' - fonte do PC
                ula_op  <= "0001";              -- 'x' - operacao da ULA
                ula_fonte_b  <= "00";           -- 'x' - fonte da entrada B da ULA
                escreve_registrador  <= '0';    -- 'x' - escreve no banco de registradores                                                                        
                registrador_destino  <= '0';    -- 'x' - registrador de destino
                rst_float <= '1';
                
            when passo_3_jump =>
                pc_enable <= '1';                
                instr_ou_dado <= '0';           -- 'x' - instrucao ou dado
                escreve_memoria <= '0';         -- escreve na memoria
                escreve_reg_instr <= '0';       -- escreve no registrador de instrucao
                reg_mem <= "00";                -- 'x'- registrador recebe dado da memoria ou ula_out
                fonte_pc <= "01";               -- fonte do PC
                ula_op  <= "0001";              -- operacao da ULA
                ula_fonte_b  <= "00";           -- 'x' - fonte da entrada B da ULA
                escreve_registrador  <= '0';    -- escreve no banco de registradores                                                                        
                registrador_destino  <= '0';    -- 'x'- registrador de destino
                rst_float <= '1';
                
            when passo_4_stl =>
                pc_enable <= '0';                 
                instr_ou_dado <= '0';           -- 'x' - instrucao ou dado
                escreve_memoria <= '0';         -- escreve na memoria
                escreve_reg_instr <= '0';       -- escreve no registrador de instrucao
                reg_mem <= "00";                -- registrador recebe dado de ula_out
                fonte_pc <= "00";               -- 'x' - fonte do PC
                ula_op  <= "0010";              -- 'x' - operacao da ULA
                ula_fonte_b  <= "00";           -- 'x' - fonte da entrada B da ULA
                escreve_registrador  <= '1';    -- escreve no banco de registradores
                registrador_destino  <= '1';    -- registrador de destino
                rst_float <= '1';
                
            when passo_4_cfloat =>              --falta implementar
                pc_enable <= '0';                 
                instr_ou_dado <= '0';           -- 'x' - instrucao ou dado
                escreve_memoria <= '0';         -- escreve na memoria
                escreve_reg_instr <= '0';       -- escreve no registrador de instrucao
                reg_mem <= "11";                -- registrador recebe dado da ula_out
                fonte_pc <= "00";               -- 'x' - fonte do PC
                ula_op  <= "0010";              -- 'x' - operacao da ULA
                ula_fonte_b  <= "00";           -- 'x' - fonte da entrada B da ULA
                escreve_registrador  <= '1';    -- escreve no banco de registradores
                registrador_destino  <= '0';    -- registrador de destino
                rst_float <= '0';
                
            when passo_4_move =>
                pc_enable <= '0';                 
                instr_ou_dado <= '0';           -- 'x' - instrucao ou dado
                escreve_memoria <= '0';         -- escreve na memoria
                escreve_reg_instr <= '0';       -- escreve no registrador de instrucao
                reg_mem <= "00";                -- registrador recebe dado da ula_out
                fonte_pc <= "00";               -- 'x' - fonte do PC
                ula_op  <= "0010";              -- 'x' - operacao da ULA
                ula_fonte_b  <= "00";           -- 'x' - fonte da entrada B da ULA
                escreve_registrador  <= '1';    -- escreve no banco de registradores
                registrador_destino  <= '0';    -- registrador de destino
                rst_float <= '1';
                
            when passo_4_nand =>
                pc_enable <= '0';                 
                instr_ou_dado <= '0';           -- 'x' - instrucao ou dado
                escreve_memoria <= '0';         -- escreve na memoria
                escreve_reg_instr <= '0';       -- escreve no registrador de instrucao
                reg_mem <= "00";                -- registrador recebe dado da ula_out
                fonte_pc <= "00";               -- 'x' - fonte do PC
                ula_op  <= "0010";              -- 'x' - operacao da ULA
                ula_fonte_b  <= "00";           -- 'x' - fonte da entrada B da ULA
                escreve_registrador  <= '1';    -- escreve no banco de registradores
                registrador_destino  <= '1';    -- registrador de destino
                rst_float <= '1';
                
            when passo_4_not =>
                pc_enable <= '0';                 
                instr_ou_dado <= '0';           -- 'x' - instrucao ou dado
                escreve_memoria <= '0';         -- escreve na memoria
                escreve_reg_instr <= '0';       -- escreve no registrador de instrucao
                reg_mem <= "00";                -- registrador recebe dado da ula_out
                fonte_pc <= "00";               -- 'x' - fonte do PC
                ula_op  <= "0010";              -- 'x' - operacao da ULA
                ula_fonte_b  <= "00";           -- 'x' - fonte da entrada B da ULA
                escreve_registrador  <= '1';    -- escreve no banco de registradores
                registrador_destino  <= '1';    -- registrador de destino
                rst_float <= '1';
                
            when passo_4_nor =>
                pc_enable <= '0';                 
                instr_ou_dado <= '0';           -- 'x' - instrucao ou dado
                escreve_memoria <= '0';         -- escreve na memoria
                escreve_reg_instr <= '0';       -- escreve no registrador de instrucao
                reg_mem <= "00";                -- registrador recebe dado da ula_out
                fonte_pc <= "00";               -- 'x' - fonte do PC
                ula_op  <= "0010";              -- 'x' - operacao da ULA
                ula_fonte_b  <= "00";           -- 'x' - fonte da entrada B da ULA
                escreve_registrador  <= '1';    -- escreve no banco de registradores
                registrador_destino  <= '1';    -- registrador de destino
                rst_float <= '1';
                
            when passo_4_or =>
                pc_enable <= '0';                 
                instr_ou_dado <= '0';           -- 'x' - instrucao ou dado
                escreve_memoria <= '0';         -- escreve na memoria
                escreve_reg_instr <= '0';       -- escreve no registrador de instrucao
                reg_mem <= "00";                -- registrador recebe dado da ula_out
                fonte_pc <= "00";               -- 'x' - fonte do PC
                ula_op  <= "0010";              -- 'x' - operacao da ULA
                ula_fonte_b  <= "00";           -- 'x' - fonte da entrada B da ULA
                escreve_registrador  <= '1';    -- escreve no banco de registradores
                registrador_destino  <= '1';    -- registrador de destino
                rst_float <= '1';
                
            when passo_4_spat =>
                pc_enable <= '0';                 
                instr_ou_dado <= '0';           -- 'x' - instrucao ou dado
                escreve_memoria <= '0';         -- escreve na memoria
                escreve_reg_instr <= '0';       -- escreve no registrador de instrucao
                reg_mem <= "00";                -- registrador recebe dado da ula_out
                fonte_pc <= "00";               -- 'x' - fonte do PC
                ula_op  <= "1000";              -- 'x' - operacao da ULA
                ula_fonte_b  <= "10";           -- 'x' - fonte da entrada B da ULA
                escreve_registrador  <= '1';    -- escreve no banco de registradores
                registrador_destino  <= '1';    -- registrador de destino
                rst_float <= '1';
                
            when passo_4_spati =>
                pc_enable <= '0';                 
                instr_ou_dado <= '0';           -- 'x' - instrucao ou dado
                escreve_memoria <= '0';         -- escreve na memoria
                escreve_reg_instr <= '0';       -- escreve no registrador de instrucao
                reg_mem <= "00";                -- registrador recebe dado da ula_out
                fonte_pc <= "00";               -- 'x' - fonte do PC
                ula_op  <= "0111";              -- 'x' - operacao da ULA
                ula_fonte_b  <= "01";           -- 'x' - fonte da entrada B da ULA
                escreve_registrador  <= '1';    -- escreve no banco de registradores
                registrador_destino  <= '0';    -- registrador de destino
                rst_float <= '1';
                
            when passo_4_mult =>
                pc_enable <= '0';                 
                instr_ou_dado <= '0';           -- 'x' - instrucao ou dado
                escreve_memoria <= '0';         -- escreve na memoria
                escreve_reg_instr <= '0';       -- escreve no registrador de instrucao
                reg_mem <= "00";                -- registrador recebe dado da ula_out
                fonte_pc <= "00";               -- 'x' - fonte do PC
                ula_op  <= "0010";              -- 'x' - operacao da ULA
                ula_fonte_b  <= "00";           -- 'x' - fonte da entrada B da ULA
                escreve_registrador  <= '1';    -- escreve no banco de registradores
                registrador_destino  <= '1';    -- registrador de destino
                rst_float <= '1';
                
            when passo_4_div =>
                pc_enable <= '0';                 
                instr_ou_dado <= '0';           -- 'x' - instrucao ou dado
                escreve_memoria <= '0';         -- escreve na memoria
                escreve_reg_instr <= '0';       -- escreve no registrador de instrucao
                reg_mem <= "00";                -- registrador recebe dado da ula_out
                fonte_pc <= "00";               -- 'x' - fonte do PC
                ula_op  <= "0010";              -- 'x' - operacao da ULA
                ula_fonte_b  <= "00";           -- 'x' - fonte da entrada B da ULA
                escreve_registrador  <= '1';    -- escreve no banco de registradores
                registrador_destino  <= '1';    -- registrador de destino
                rst_float <= '1';
                
            when passo_4_divf =>
                pc_enable <= '0';                 
                instr_ou_dado <= '0';           -- 'x' - instrucao ou dado
                escreve_memoria <= '0';         -- escreve na memoria
                escreve_reg_instr <= '0';       -- escreve no registrador de instrucao
                reg_mem <= "00";                -- registrador recebe dado da ula_out
                fonte_pc <= "00";               -- 'x' - fonte do PC
                ula_op  <= "0010";              -- 'x' - operacao da ULA
                ula_fonte_b  <= "00";           -- 'x' - fonte da entrada B da ULA
                escreve_registrador  <= '1';    -- escreve no banco de registradores
                registrador_destino  <= '1';    -- registrador de destino
                rst_float <= '1';
                
            when passo_4_rem =>
                pc_enable <= '0';                 
                instr_ou_dado <= '0';           -- 'x' - instrucao ou dado
                escreve_memoria <= '0';         -- escreve na memoria
                escreve_reg_instr <= '0';       -- escreve no registrador de instrucao
                reg_mem <= "00";                -- registrador recebe dado da ula_out
                fonte_pc <= "00";               -- 'x' - fonte do PC
                ula_op  <= "0010";              -- 'x' - operacao da ULA
                ula_fonte_b  <= "00";           -- 'x' - fonte da entrada B da ULA
                escreve_registrador  <= '1';    -- escreve no banco de registradores
                registrador_destino  <= '1';    -- registrador de destino
                rst_float <= '1';
                
            when passo_4_sll =>
                pc_enable <= '0';                 
                instr_ou_dado <= '0';           -- 'x' - instrucao ou dado
                escreve_memoria <= '0';         -- escreve na memoria
                escreve_reg_instr <= '0';       -- escreve no registrador de instrucao
                reg_mem <= "00";                -- registrador recebe dado da ula_out
                fonte_pc <= "00";               -- 'x' - fonte do PC
                ula_op  <= "1001";              -- 'x' - operacao da ULA
                ula_fonte_b  <= "01";           -- 'x' - fonte da entrada B da ULA
                escreve_registrador  <= '1';    -- escreve no banco de registradores
                registrador_destino  <= '0';    -- registrador de destino
                rst_float <= '1';
                
            when passo_4_srl =>
                pc_enable <= '0';                 
                instr_ou_dado <= '0';           -- 'x' - instrucao ou dado
                escreve_memoria <= '0';         -- escreve na memoria
                escreve_reg_instr <= '0';       -- escreve no registrador de instrucao
                reg_mem <= "00";                -- registrador recebe dado da ula_out
                fonte_pc <= "00";               -- 'x' - fonte do PC
                ula_op  <= "1010";              -- 'x' - operacao da ULA
                ula_fonte_b  <= "01";           -- 'x' - fonte da entrada B da ULA
                escreve_registrador  <= '1';    -- escreve no banco de registradores
                registrador_destino  <= '0';    -- registrador de destino
                rst_float <= '1';
                
            when passo_4_add =>
                pc_enable <= '0';                 
                instr_ou_dado <= '0';           -- 'x' - instrucao ou dado
                escreve_memoria <= '0';         -- escreve na memoria
                escreve_reg_instr <= '0';       -- escreve no registrador de instrucao
                reg_mem <= "00";                -- registrador recebe dado da ula_out
                fonte_pc <= "00";               -- 'x' - fonte do PC
                ula_op  <= "0010";              -- 'x' - operacao da ULA
                ula_fonte_b  <="00";            -- 'x' - fonte da entrada B da ULA
                escreve_registrador  <= '1';    -- escreve no banco de registradores
                registrador_destino  <= '1';    -- registrador de destino
                rst_float <= '1';
                
            when passo_4_addi =>
                pc_enable <= '0';                 
                instr_ou_dado <= '0';           -- 'x' - instrucao ou dado
                escreve_memoria <= '0';         -- escreve na memoria
                escreve_reg_instr <= '0';       -- escreve no registrador de instrucao
                reg_mem <= "00";                -- registrador recebe dado da ula_out
                fonte_pc <= "00";               -- 'x' - fonte do PC
                ula_op  <= "0000";              -- 'x' - operacao da ULA
                ula_fonte_b  <= "01";           -- 'x' - fonte da entrada B da ULA
                escreve_registrador  <= '1';    -- escreve no banco de registradores
                registrador_destino  <= '0';    -- registrador de destino
                rst_float <= '1';
                
            when passo_4_sub =>
                pc_enable <= '0';                 
                instr_ou_dado <= '0';           -- 'x' - instrucao ou dado
                escreve_memoria <= '0';         -- escreve na memoria
                escreve_reg_instr <= '0';       -- escreve no registrador de instrucao
                reg_mem <= "00";                -- registrador recebe dado  da ula_out
                fonte_pc <= "00";               -- 'x' - fonte do PC
                ula_op  <= "0010";              -- 'x' - operacao da ULA
                ula_fonte_b  <= "00";           -- 'x' - fonte da entrada B da ULA
                escreve_registrador  <= '1';    -- escreve no banco de registradores
                registrador_destino  <= '1';    -- registrador de destino
                rst_float <= '1';
                
            when passo_4_xor =>
                pc_enable <= '0';                 
                instr_ou_dado <= '0';           -- 'x' - instrucao ou dado
                escreve_memoria <= '0';         -- escreve na memoria
                escreve_reg_instr <= '0';       -- escreve no registrador de instrucao
                reg_mem <= "00";                -- registrador recebe dado da ula_out
                fonte_pc <= "00";               -- 'x' - fonte do PC
                ula_op  <= "0010";              -- 'x' - operacao da ULA
                ula_fonte_b  <= "00";           -- 'x' - fonte da entrada B da ULA
                escreve_registrador  <= '1';    -- escreve no banco de registradores
                registrador_destino  <= '1';    -- registrador de destino
                rst_float <= '1';
                       
            when passo_4_and =>
                pc_enable <= '0';                
                instr_ou_dado <= '0';           -- 'x' - instrucao ou dado
                escreve_memoria <= '0';         -- escreve na memoria
                escreve_reg_instr <= '0';       -- escreve no registrador de instrucao
                reg_mem <= "00";                -- registrador recebe dado da ula_out
                fonte_pc <= "00";               -- 'x' - fonte do PC
                ula_op  <= "0010";              -- 'x' - operacao da ULA
                ula_fonte_b  <= "00";           -- 'x' - fonte da entrada B da ULA
                escreve_registrador  <= '1';    -- escreve no banco de registradores
                registrador_destino  <= '1';    -- registrador de destino
                rst_float <= '1';
                
            when passo_4_store =>
                pc_enable <= '0';                
                instr_ou_dado <= '1';           -- instrucao ou dado 
                escreve_memoria <= '1';         -- escreve na memoria
                escreve_reg_instr <= '0';       -- escreve no registrador de instrucao
                reg_mem <= "00";                -- 'x' - registrador recebe dado da memoria
                fonte_pc <= "00";               -- 'x' - fonte do PC
                ula_op  <= "0000";              -- 'x' - operacao da ULA
                ula_fonte_b  <= "01";           -- 'x' - fonte da entrada B da ULA
                escreve_registrador  <= '0';    -- escreve no banco de registradores  
                registrador_destino  <= '0';    -- registrador de destino
                rst_float <= '1';
                
            when passo_4_load =>
                pc_enable <= '0';                
                instr_ou_dado <= '1';           -- instrucao ou dado 
                escreve_memoria <= '0';         -- escreve na memoria
                escreve_reg_instr <= '0';       -- escreve no registrador de instrucao                    
                reg_mem <= "01";                -- 'x' - registrador recebe dado da memoria
                fonte_pc <= "00";               -- 'x' - fonte do PC
                ula_op  <= "0000";              -- 'x' - operacao da ULA
                ula_fonte_b  <= "01";           -- 'x' - fonte da entrada B da ULA
                escreve_registrador  <= '0';    -- escreve no banco de registradores                                 
                registrador_destino  <= '0';    -- registrador de destino
                rst_float <= '1';
                
            when passo_4_loadi =>
                pc_enable <= '0';                 
                instr_ou_dado <= '0';           -- 'x' - instrucao ou dado
                escreve_memoria <= '0';         -- escreve na memoria
                escreve_reg_instr <= '0';       -- escreve no registrador de instrucao
                reg_mem <= "00";                -- registrador recebe dado da ula_out
                fonte_pc <= "00";               -- 'x' - fonte do PC
                ula_op  <= "0100";              -- 'x' - operacao da ULA
                ula_fonte_b  <= "01";           -- 'x' - fonte da entrada B da ULA
                escreve_registrador  <= '1';    -- escreve no banco de registradores
                registrador_destino  <= '0';    -- registrador de destino
                rst_float <= '1';
                
            when passo_4_loads =>
                pc_enable <= '0';                
                instr_ou_dado <= '1';           -- instrucao ou dado 
                escreve_memoria <= '0';         -- escreve na memoria
                escreve_reg_instr <= '0';       -- escreve no registrador de instrucao                    
                reg_mem <= "10";                -- 'x' - registrador recebe dado da memoria
                fonte_pc <= "00";               -- 'x' - fonte do PC
                ula_op  <= "0000";              -- 'x' - operacao da ULA
                ula_fonte_b  <= "01";           -- 'x' - fonte da entrada B da ULA
                escreve_registrador  <= '0';    -- escreve no banco de registradores                                 
                registrador_destino  <= '1';    -- registrador de destino
                rst_float <= '1';
                
            when passo_5_store =>
                pc_enable <= '0';                
                instr_ou_dado <= '1';           -- instrucao ou dado 
                escreve_memoria <= '1';         -- escreve na memoria
                escreve_reg_instr <= '0';       -- escreve no registrador de instrucao
                reg_mem <= "00";                -- 'x' - registrador recebe dado da memoria
                fonte_pc <= "00";               -- 'x' - fonte do PC
                ula_op  <= "0000";              -- 'x' - operacao da ULA
                ula_fonte_b  <= "01";           -- 'x' - fonte da entrada B da ULA
                escreve_registrador  <= '0';    -- escreve no banco de registradores  
                registrador_destino  <= '0';    -- registrador de destino
                rst_float <= '1';
                
            when passo_5_load =>                -- somente load passa aqui
                pc_enable <= '0';                 
                instr_ou_dado <= '1';           -- 'x' - instrucao ou dado
                escreve_memoria <= '0';         -- escreve na memoria
                escreve_reg_instr <= '0';       -- escreve no registrador de instrucao
                reg_mem <= "01";                -- registrador recebe dado da memoria
                fonte_pc <= "00";               -- 'x' - fonte do PC
                ula_op  <= "0000";              -- 'x' - operacao da ULA
                ula_fonte_b  <= "01";           -- 'x' - fonte da entrada B da ULA
                escreve_registrador  <= '1';    -- escreve no banco de registradores
                registrador_destino  <= '0';    -- registrador de destino
                rst_float <= '1';
                            
            when passo_5_loads =>               -- somente load passa aqui
                pc_enable <= '0';                 
                instr_ou_dado <= '1';           -- 'x' - instrucao ou dado
                escreve_memoria <= '0';         -- escreve na memoria
                escreve_reg_instr <= '0';       -- escreve no registrador de instrucao
                reg_mem <= "10";                -- registrador recebe dado da memoria e efetua a soma com o valor do registrador B 
                fonte_pc <= "00";               -- 'x' - fonte do PC
                ula_op  <= "0000";              -- 'x' - operacao da ULA
                ula_fonte_b  <= "01";           -- 'x' - fonte da entrada B da ULA
                escreve_registrador  <= '1';    -- escreve no banco de registradores
                registrador_destino  <= '1';    -- registrador de destino
                rst_float <= '1';
                
            when passo_reset =>                 
                pc_enable <= '0';                 
                instr_ou_dado <= '0';           -- 'x' - instrucao ou dado
                escreve_memoria <= '0';         -- escreve na memoria
                escreve_reg_instr <= '0';       -- escreve no registrador de instrucao
                reg_mem <= "00";                -- registrador recebe dado da memoria
                fonte_pc <= "00";               -- 'x' - fonte do PC
                ula_op  <= "0111";              -- 'x' - operacao da ULA
                ula_fonte_b  <= "00";           -- 'x' - fonte da entrada B da ULA
                escreve_registrador  <= '0';    -- escreve no banco de registradores
                registrador_destino  <= '0';    -- registrador de destino
                rst_float <= '0';
                
            when others =>
                --                              -- houve um reset, passo_starting, halt ou um erro!  
                                                -- passos em outros: passo_erro, passo_halt, passo_reset
                pc_enable <= '0';               -- 'x' - NÃO escreve o PC+4                
                instr_ou_dado <= '0';           -- 'x' - instrucao ou dado 
                escreve_memoria <= '0';         -- 'x' - escreve na memoria
                escreve_reg_instr <= '0';       -- 'x' - escreve no registrador de instrucao
                reg_mem <= "00";                -- 'x' - registrador recebe dado da memoria
                fonte_pc <= "00";               -- 'x' - fonte do PC
                ula_op  <= "1111";              -- 'x' - operacao da ULA: para reset, resultara em erro tipo: er_ula_op_u
                ula_fonte_b  <= "00";           -- 'x' - fonte da entrada B da ULA
                escreve_registrador  <= '0';    -- 'x' - escreve no banco de registradores
                registrador_destino  <= '0';    -- 'x' - registrador de destino  
                rst_float <= '1';
                
        end case;                  
    end process;        

end rtl;
