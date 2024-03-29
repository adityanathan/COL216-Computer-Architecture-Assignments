library IEEE;
        use ieee.std_logic_1164.all;
        use IEEE.STD_LOGIC_UNSIGNED.ALL;
        use ieee.numeric_std.all;
        
entity alu is
port 
(   op1: in std_logic_vector(31 downto 0);
    op2: in std_logic_vector(31 downto 0);
    result: out std_logic_vector(31 downto 0);
    control_input: in std_logic_vector(1 downto 0);
    flag_out: out std_logic;
    flag_we: in std_logic;
    carry: in std_logic;
    reset: in std_logic
    --start: in std_logic
    );
end entity alu;

architecture comb of alu is
signal z_storage: std_logic;
signal result_temp: std_logic_vector(31 downto 0);

begin

result_temp<=op1 + op2 + carry when control_input="01" else
        op1 - op2 - carry when control_input="10" else
        op1 - op2 - carry when control_input="11" else
        op2 when control_input="00" else
        "00000000000000000000000000000000";

result<=result_temp;

flag_out<=z_storage;

z_storage<= '0' when reset = '1' else
            z_storage when flag_we='0' else
            '1' when flag_we='1' and result_temp="00000000000000000000000000000000" else
            '0';

end architecture comb;
    