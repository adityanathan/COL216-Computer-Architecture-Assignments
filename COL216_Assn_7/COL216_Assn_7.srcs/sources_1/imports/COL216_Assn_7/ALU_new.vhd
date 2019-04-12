library IEEE;
        use ieee.std_logic_1164.all;
        use IEEE.STD_LOGIC_UNSIGNED.ALL;
        use ieee.numeric_std.all;
        
entity alu is
port 
(   op1: in std_logic_vector(31 downto 0);
    op2: in std_logic_vector(31 downto 0);
    result: out std_logic_vector(31 downto 0);
    op_code: in std_logic_vector(4 downto 0);
    
    flags_in: in std_logic_vector(3 downto 0);
    flags_out: out std_logic_vector(3 downto 0);
    );
end entity alu;

architecture comb of alu is

signal c_31: std_logic;
signal c_32: std_logic;

signal c: std_logic;
signal v: std_logic;
signal z: std_logic;
signal n: std_logic;
signal result_temp: std_logic_vector(32 downto 0);

begin

carry <= flags_in(3);
overflow <= flags_in(2);
zero <= flags_in(1);
negative <= flags_in(0);

result_temp<= op1 and op2 when op_code="00000" else
              op1 xor op2 when op_code="00001" else
              op1 - op2 when op_code="00010" else
              op2 - op1 when op_code="00011" else
              op1 + op2 when op_code="00100" else
              op1 + op2 + carry when op_code="00101" else
              op1 - op2 - not(carry) when op_code="00110" else
              op2 - op1 - not(carry) when op_code="00111" else
              op1 and op2 when op_code="01000" else
              op1 xor op2 when op_code="01001" else
              op1 - op2 when op_code="01010" else
              op1 + op2 when op_code="01011" else
              op1 or op2 when op_code="01100" else
              op2 when op_code="01101" else
              op1 and not(op2) when op_code="01110" else
              not(op2) when op_code="01111" else
              op1 + op2 when op_code = "10000" and U_bit = '1' else
              op1 + op2 when op_code = "10001" and U_bit = '1' else
              op1 - op2 when op_code = "10000" and U_bit = '0' else
              op1 - op2;-- when op_code = "10001" and U_bit = '0' else
              
              

result<=result_temp(31 downto 0);

flags_out<= c & v & z & n;

z <= '1' when result_temp = "00000000000000000000000000000000" else
     '0';
     
n <= result_temp(31);
     
c_31 <= '0' when reset = '1' else op1_in(31) xor op2_in(31) xor (result_temp(31));
c_32 <= '0' when reset = '1' else (op1_in(31) and op2_in(31)) or (op1_in(31) and c_31) or (c_31 and op2_in(31));                                                                                          --WARNING

c <= c_32;

v <= c_31 xor c_32;

end architecture comb;  