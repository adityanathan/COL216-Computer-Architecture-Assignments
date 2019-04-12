library IEEE;
        use ieee.std_logic_1164.all;
        use IEEE.STD_LOGIC_UNSIGNED.ALL;
        use ieee.numeric_std.all;
        
entity alu is
port 
(   op1: in std_logic_vector(31 downto 0);
    op2: in std_logic_vector(31 downto 0);
    result: out std_logic_vector(31 downto 0);
    op_code: in std_logic_vector(3 downto 0);
    flags_out: out std_logic_vector(3 downto 0);   --NCVZ
    flag_we: in std_logic;
    carry: in std_logic;
    S: in std_logic
    );
end entity alu;

architecture comb of alu is
signal flags: std_logic_vector(3 downto 0);
signal result_temp: std_logic_vector(31 downto 0);

begin

result_temp<= op1 and op2 when op_code="0000" else
              op1 xor op2 when op_code="0001" else
              op1 - op2 when op_code="0010" else
              op2 - op1 when op_code="0011" else
              op1 + op2 when op_code="0100" else
              op1 + op2 + carry when op_code="0101" else
              op1 - op2 - not(carry) when op_code="0110" else
              op2 - op1 - not(carry) when op_code="0111" else
              op1 and op2 when op_code="1000" else
              op1 xor op2 when op_code="1001" else
              op1 - op2 when op_code="1010" else
              op1 + op2 when op_code="1011" else
              op1 or op2 when op_code="1100" else
              op2 when op_code="1101" else
              op1 and not(op2) when op_code="1110" else
              not(op2) when op_code="1111";

result_temp<=op1 + op2 + carry when control_input='1' else
        op1 - op2 - carry when control_input='0' else
        "00000000000000000000000000000000";

result<=result_temp;

flags_out<=flags;



flags(0)<=  when flag_we='0' else
            '1' when flag_we='1' and result_temp="00000000000000000000000000000000" else
            '0';

end architecture comb;
    
