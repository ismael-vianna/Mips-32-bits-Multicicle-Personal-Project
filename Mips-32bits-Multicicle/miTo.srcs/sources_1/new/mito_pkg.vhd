----------------------------------------------------------------------------------
-- Company: UERGS
-- Disciplina: Organizacao de computadores
-- Profa.: Debora Matos
-- Baseado na estrutura de memoria de: Newton Jr
-- Trabalho de: Ismael Soller Vianna
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

package mito_pkg is
  
    component control_unit
        Port ( 
            clk                 : in  std_logic;                    -- clock
            rst                 : in  std_logic;                    -- reset
            pc_enable           : out std_logic;
            ula_flag_zero       : in  std_logic;
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
            finished_job_float  : in  std_logic;                    -- sinal exclusivo para calculos float
            rst_float           : out std_logic 
        );
    end component;
  
    component convert_to_float
        Port ( 
            clk          : in  std_logic;
            rst          : in  std_logic; 
            entrada_a    : in  std_logic_vector (31 downto 0);
            finished_job : out std_logic;
            ula_outf     : out std_logic_vector (31 downto 0)  
        );
    end component;
  
    component data_path
        Port (
            clk                 : in  std_logic;                     -- clock
            rst                 : in  std_logic;                     -- reset            
            pc_enable           : in  std_logic;
            ula_flag_zero       : out std_logic;            
            instr_ou_dado       : in  std_logic;                     -- instrucao ou dado 
            escreve_reg_instr   : in  std_logic;                     -- escreve no registrador de instrucao
            reg_mem             : in  std_logic_vector(1 downto 0);  -- registrador recebe dado da memoria
            fonte_pc            : in  std_logic_vector(1 downto 0);  -- fonte do PC
            ula_op              : in  std_logic_vector(3 downto 0);  -- operacao da ULA            
            ula_fonte_b         : in  std_logic_vector(1 downto 0);  -- fonte da entrada B da ULA
            escreve_registrador : in  std_logic;                     -- escreve no banco de registradores
            registrador_destino : in  std_logic;                     -- registrador de destino
            le_operacao         : out std_logic_vector(5 downto 0);  -- operacao lida da memoria a ser realizada
            entrada_memoria     : out std_logic_vector(31 downto 0); -- dado enviado para a memória
            endereco_memoria    : out std_logic_vector(8  downto 0); -- endereço para gravar na memória
            saida_memoria       : in  std_logic_vector(31 downto 0); -- dado enviado pela memória ao registrador RDM  
            ula_outf            : in  std_logic_vector (31 downto 0);
            ula_entrada_a_f     : out std_logic_vector (31 downto 0) 
        );
    end component;  
    
    component memory is
		port(        
            clk                 : in  std_logic;
            escrita             : in  std_logic;
            rst                 : in  std_logic;        
            entrada_memoria     : in  std_logic_vector(31 downto 0);
            endereco_memoria    : in  std_logic_vector(8  downto 0);
            saida_memoria       : out std_logic_vector(31 downto 0)
		);          
    end component;

    component mito
        port (
            clck                   : in  std_logic;
            rst_n                  : in  std_logic            
        );
    end component;
  
    component testbench is
        port (
           signal clk 				: in  std_logic := '0';
           signal reset 			: in  std_logic          
        );   
    end component;   

end mito_pkg;

package body mito_pkg is
end mito_pkg;