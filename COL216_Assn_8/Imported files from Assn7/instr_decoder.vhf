library IEEE;
        use ieee.std_logic_1164.all;
        use IEEE.STD_LOGIC_UNSIGNED.ALL;
        use ieee.numeric_std.all;
        
entity instr_decoder is
port
(   instruction: in std_logic_vector(31 downto 0);
    cond : out std_logic_vector (3 downto 0);

    I : out std_logic;
    Rn, Rd, Rm: out std_logic_vector(3 downto 0);
    operand2: out std_logic_vector(11 downto 0);
    S: out std_logic; 
    offset: out std_logic_vector(23 downto 0);
    i_dec_out: out std_logic_vector(3 downto 0);
    instr_class_out: out std_logic_vector(2 downto 0);
    ld_bit, U: out std_logic
);
end entity instr_decoder;

architecture behavioral of instr_decoder is
signal F_field: std_logic_vector(1 downto 0);
signal opcode_for_dp: std_logic_vector(3 downto 0);
signal opcode_for_b: std_logic_vector(1 downto 0);


type i_decoded_type is (add,sub,cmp,mov,ldr,str,beq,bne,b,unknown);
signal i_decoded : i_decoded_type;

type instr_class_type is (DP, DT, branch, halted, unknown);
signal instr_class : instr_class_type;

signal halt: std_logic;
signal ld_bit_temp: std_logic;
begin


cond <= instruction(31 downto 28);
F_field<=instruction(27 downto 26);

--dp and dt
I<=instruction(25);
opcode_for_dp<=instruction(24 downto 21);
S<=instruction(20);
Rn<=instruction(19 downto 16);
Rm<=instruction(3 downto 0);
Rd<=instruction(15 downto 12);
operand2<=instruction(11 downto 0);

--branch
offset<=instruction(23 downto 0);
opcode_for_b<=instruction(25 downto 24);
U<=instruction(23);
instr_class<=halted when halt='1' else
             DP when F_field="00" else
             DT when F_field="01" else
             branch when F_field="10" else
             unknown;
             
i_decoded<= add when opcode_for_dp="0100" and F_field="00" else
            sub when opcode_for_dp="0010" and F_field="00" else
            mov when opcode_for_dp="1101" and F_field="00" else
            cmp when opcode_for_dp="1010" and F_field="00" else
            str when instruction(20) ='0' and F_field="01" else
            ldr when instruction(20) ='1' and F_field="01" else
            b when instruction(31 downto 28) ="1110" and F_field="10" else
            beq when instruction(31 downto 28) ="0000" and F_field="10" else
            bne when instruction(31 downto 28) ="0001" and F_field="10" else
            unknown;

ld_bit_temp<= '0' when i_decoded=str else
              '1' when i_decoded=ldr else
              ld_bit_temp;

ld_bit<=ld_bit_temp;       

halt<= '1' when instruction="00000000000000000000000000000000" else
       '0';
            
i_dec_out<="0001" when i_decoded=add else
           "0010" when i_decoded=sub else
           "0011" when i_decoded=cmp else
           "0100" when i_decoded=mov else
           "0101" when i_decoded=ldr else
           "0110" when i_decoded=str else
           "0111" when i_decoded=beq else
           "1000" when i_decoded=bne else
           "1001" when i_decoded=b else
           "1010" when i_decoded=unknown else
           "0000";
           
instr_class_out<="001" when instr_class=DP else
                 "010" when instr_class=DT else
                 "011" when instr_class=branch else
                 "100" when instr_class=halted else
                 "101" when instr_class=unknown else
                 "000";

end architecture behavioral;