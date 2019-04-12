library IEEE;
        use ieee.std_logic_1164.all;
        use IEEE.STD_LOGIC_UNSIGNED.ALL;
        use ieee.numeric_std.all;
        use work.inst_pack.all;

entity alu is
port
(   op1: in std_logic_vector(31 downto 0);
    op2: in std_logic_vector(31 downto 0);
    result: out std_logic_vector(31 downto 0);
    op_code: in instr_decoded_type;

    flags_in: in std_logic_vector(3 downto 0);
    flags_out: out std_logic_vector(3 downto 0);

    U_bit: in std_logic
    );
end entity alu;

architecture comb of alu is

signal c_31: std_logic;
signal c_32: std_logic;

signal c: std_logic;
signal v: std_logic;
signal z: std_logic;
signal n: std_logic;
signal carry, overflow, zero, negative: std_logic;
signal result_temp: std_logic_vector(31 downto 0);

begin

carry <= flags_in(3);
overflow <= flags_in(2);
zero <= flags_in(1);
negative <= flags_in(0);

result_temp<= op1 and op2 when op_code=annd else
              op1 xor op2 when op_code=eor else
              op1 - op2 when op_code=sub else
              op2 - op1 when op_code=rsb else
              op1 + op2 when op_code=add else
              op1 + op2 + carry when op_code=adc else
              op1 - op2 - not(carry) when op_code=sbc else
              op2 - op1 - not(carry) when op_code=rsc else
              op1 and op2 when op_code=tst else
              op1 xor op2 when op_code=teq else
              op1 - op2 when op_code=cmp else
              op1 + op2 when op_code=cmn else
              op1 or op2 when op_code=orr else
              op2 when op_code=mov else
              op1 and not(op2) when op_code=bic else
              not(op2) when op_code=mvn else
              op1 + op2 when op_code = ldr and U_bit = '1' else
              op1 + op2 when op_code = str and U_bit = '1' else
              op1 - op2 when op_code = ldr and U_bit = '0' else
              op1 - op2 when op_code = str and U_bit = '0' else
              op1 + op2 + carry;



result<=result_temp;

flags_out<= c & n & v & z;

z <= '1' when result_temp = "0000000000000000000000000000000" else
     '0';

n <= result_temp(31);

c_31 <= op1(31) xor op2(31) xor (result_temp(31));
c_32 <= (op1(31) and op2(31)) or (op1(31) and c_31) or (c_31 and op2(31));                                                                                          --WARNING

c <= c_32;

v <= c_31 xor c_32;

end architecture comb;
