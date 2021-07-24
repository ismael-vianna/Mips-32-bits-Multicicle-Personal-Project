----------------------------------------------------------------------------------
-- Company: UERGS
-- Disciplina: Organizacao de computadores
-- Profa.: Debora Matos
-- Baseado na estrutura de memoria de: Newton Jr
-- Trabalho de: Ismael Soller Vianna
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library mito;
use mito.mito_pkg.all;

entity miTo is
  Port (
        clk                    : in  std_logic;
        rst_n                  : in  std_logic      
   );
end miTo;

architecture rtl of miTo is

    signal pc_enable_s           :   std_logic;
    signal ula_flag_zero_s       :   std_logic;    
    signal instr_ou_dado_s       :   std_logic;                     -- instrucao ou dado 
    signal escreve_memoria_s     :   std_logic;                     -- escreve na memoria
    signal escreve_reg_instr_s   :   std_logic;                     -- escreve no registrador de instrucao
    signal reg_mem_s             :   std_logic_vector(1 downto 0);  -- registrador recebe dado da memoria
    signal fonte_pc_s            :   std_logic_vector(1 downto 0);  -- fonte do PC
    signal ula_op_s              :   std_logic_vector(3 downto 0);  -- operacao da ULA
    signal ula_fonte_b_s         :   std_logic_vector(1 downto 0);  -- fonte da entrada B da ULA
    signal escreve_registrador_s :   std_logic;                     -- escreve no banco de registradores
    signal registrador_destino_s :   std_logic;                     -- registrador de destino
    signal le_operacao_s         :   std_logic_vector(5 downto 0);  -- operacao lida da memoria a ser realizada    
    signal entrada_memoria_s     :   std_logic_vector(31 downto 0);
    signal endereco_memoria_s    :   std_logic_vector(8  downto 0);
    signal saida_memoria_s       :   std_logic_vector(31 downto 0);
    signal finished_job_float_s  :   std_logic;
    signal rst_float_s           :   std_logic; 
    signal ula_outf_s            :   std_logic_vector(31 downto 0);
    signal ula_entrada_a_s       :   std_logic_vector(31 downto 0);
    
begin

    control_unit_i : control_unit
        port map( 
            clk                 => clk,
            rst                 => rst_n,
            pc_enable           => pc_enable_s,
            ula_flag_zero       => ula_flag_zero_s,            
            instr_ou_dado       => instr_ou_dado_s, 
            escreve_memoria     => escreve_memoria_s,                        
            escreve_reg_instr   => escreve_reg_instr_s,
            reg_mem             => reg_mem_s,
            fonte_pc            => fonte_pc_s,
            ula_op              => ula_op_s,            
            ula_fonte_b         => ula_fonte_b_s,
            escreve_registrador => escreve_registrador_s,
            registrador_destino => registrador_destino_s,
            le_operacao         => le_operacao_s,
            finished_job_float  => finished_job_float_s,
            rst_float           => rst_float_s    
        );

    convert_to_float_i : convert_to_float
        port map( 
            clk          => clk,
            rst          => rst_float_s, 
            entrada_a    => ula_entrada_a_s,
            finished_job => finished_job_float_s,
            ula_outf     => ula_outf_s  
        );

    data_path_i : data_path
        port map (
            clk                 => clk,
            rst                 => rst_n,            
            pc_enable           => pc_enable_s,
            ula_flag_zero       => ula_flag_zero_s,            
            instr_ou_dado       => instr_ou_dado_s,             
            escreve_reg_instr   => escreve_reg_instr_s,
            reg_mem             => reg_mem_s,
            fonte_pc            => fonte_pc_s,
            ula_op              => ula_op_s,            
            ula_fonte_b         => ula_fonte_b_s,
            escreve_registrador => escreve_registrador_s,
            registrador_destino => registrador_destino_s,
            le_operacao         => le_operacao_s,
            entrada_memoria     => entrada_memoria_s,
            endereco_memoria    => endereco_memoria_s,
            saida_memoria       => saida_memoria_s,
            ula_outf            => ula_outf_s,
            ula_entrada_a_f     => ula_entrada_a_s                                  
      );
      
    memory_i : memory
        port map(
            clk                 => clk,
            escrita             => escreve_memoria_s,             
            rst                 => rst_n,        
            entrada_memoria     => entrada_memoria_s,
            endereco_memoria    => endereco_memoria_s,
            saida_memoria       => saida_memoria_s
      ); 
      
end rtl;
