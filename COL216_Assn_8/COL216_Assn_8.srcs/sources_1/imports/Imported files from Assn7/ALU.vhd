library IEEE;
        use ieee.std_logic_1164.all;
        use IEEE.STD_LOGIC_UNSIGNED.ALL;
        use ieee.numeric_std.all;
        
entity alu is
port 
(   op1_in: in std_logic_vector(31 downto 0);
    op2_in: in std_logic_vector(31 downto 0);
    result: out std_logic_vector(31 downto 0);
    op_code: in std_logic_vector(4 downto 0);
    S_bit : in std_logic;
    flag_out: out std_logic_vector(3 downto 0);
    --flag_we: in std_logic;
    carry: in std_logic;
    shift_bool: in std_logic;
    reset: in std_logic;
    U_bit : in std_logic
    --b: in std_logic
    );
end entity alu;

architecture comb of alu is

signal op1:std_logic_vector(32 downto 0);
signal op2: std_logic_vector(32 downto 0);

signal c_31: std_logic;
signal c_32: std_logic;

signal c: std_logic;
signal v: std_logic;
signal z: std_logic;
signal n: std_logic;
signal result_temp: std_logic_vector(32 downto 0);

begin

--result_temp<=op1 + op2 + carry when control_input='1' else
--        op1 - op2 - carry when control_input='0' else
--        "00000000000000000000000000000000";
op1 <= "0" & op1_in;
op2 <= "0" & op2_in;


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
              op1 - op2 when op_code = "10001" and U_bit = '0' else
              
              

result<=result_temp(31 downto 0);

flag_out<= c & v & z & n;

z <= '0' when reset = '1' else
     '1' when result_temp = "00000000000000000000000000000000" and S_bit = '1' else
     z when S_bit='0' else
     '0';
     
n <= '0' when reset = '1' else
     result_temp(31) when S_bit='1' else
     n;
     
c_31 <= '0' when reset = '1' else op1_in(31) xor op2_in(31) xor (result_temp(31));
c_32 <= '0' when reset = '1' else (op1_in(31) and op2_in(31)) or (op1_in(31) and c_31) or (c_31 and op2_in(31));                                                                                          --WARNING

c <= '0' when reset = '1' else 
    (carry or c_32) when S_bit='1' and shift_bool='1' else
     c_32 when S_bit = '1' and not(shift_bool)='0' else
     c;

v <= '0' when reset = '1' else 
    c_31 xor c_32 when S_bit = '1' else
     v;                                                                                              --WARNING



--z_storage<= z_storage when flag_we='0' else
--            '1' when flag_we='1' and result_temp="00000000000000000000000000000000" else
--            '0';

end architecture comb;
    