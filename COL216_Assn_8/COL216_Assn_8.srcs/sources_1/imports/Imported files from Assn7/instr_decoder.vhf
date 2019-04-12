package inst_pack is
type instr_class_type is (halted, DP, DT, branch, unknown);
type instr_decoded_type is (annd, eor, orr, bic, add, sub, adc, sbc, rsb, rsc, cmp, cmn, tst, teq, mov, mvn, ldr, str, beq, bne, b, unknown);
end package;

library IEEE;
use work.inst_pack.all;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;
 
entity instr_decoder is
port
(   instruction: in std_logic_vector(31 downto 0);
    cond : out std_logic_vector (3 downto 0);

    I : out std_logic;
    S: out std_logic;
    Rn, Rd, Rm, Rs: out std_logic_vector(3 downto 0);
    
    operand2: out std_logic_vector(11 downto 0);
     
    offset: out std_logic_vector(23 downto 0);
    i_dec_out: out instr_decoded_type;
    instr_class_out: out instr_class_type;
    ld_bit, U: out std_logic;
    
    shift_bit: out std_logic;--to specify register shift or constant shift
    sh_amt: out std_logic_vector(4 downto 0);
    sh_type: out std_logic_vector(1 downto 0);
    sh_reg: out std_logic_vector(3 downto 0)
);
end entity instr_decoder;

architecture behavioral of instr_decoder is
signal F_field: std_logic_vector(1 downto 0);
signal opcode_for_dp: std_logic_vector(3 downto 0);
signal opcode_for_b: std_logic_vector(1 downto 0);

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
instr_class_out<=halted when halt='1' else
             DP when F_field="00" else
             DT when F_field="01" else
             branch when F_field="10" else
             unknown;
             
i_dec_out<= annd when opcode_for_dp="0000" and F_field="00" else
            eor when opcode_for_dp="0001" and F_field="00" else
            sub when opcode_for_dp="0010" and F_field="00" else
            rsb when opcode_for_dp="0011" and F_field="00" else
            add when opcode_for_dp="0100" and F_field="00" else
            adc when opcode_for_dp="0101" and F_field="00" else
            sbc when opcode_for_dp="0110" and F_field="00" else
            rsc when opcode_for_dp="0111" and F_field="00" else
            tst when opcode_for_dp="1000" and F_field="00" else
            teq when opcode_for_dp="1001" and F_field="00" else
            cmp when opcode_for_dp="1010" and F_field="00" else
            cmn when opcode_for_dp="1011" and F_field="00" else

            orr when opcode_for_dp="1100" and F_field="00" else
            mov when opcode_for_dp="1101" and F_field="00" else
            bic when opcode_for_dp="1110" and F_field="00" else
            mvn when opcode_for_dp="1111" and F_field="00" else
            str when instruction(20) ='0' and F_field="01" else
            ldr when instruction(20) ='1' and F_field="01" else
            b when instruction(31 downto 28) ="1110" and F_field="10" else
            beq when instruction(31 downto 28) ="0000" and F_field="10" else
            bne when instruction(31 downto 28) ="0001" and F_field="10" else
            unknown;

ld_bit_temp<= '0' when instruction(20) ='0' and F_field="01" else
              '1' when instruction(20) ='1' and F_field="01" else
              '0';  --ld_bit_temp

ld_bit<=ld_bit_temp;       

shift_bit<= instruction(4);
sh_type<= instruction(6 downto 5);
sh_amt<= instruction(11 downto 7);
Rs <= instruction(11 downto 8);
--sh_const <= instruction(7 downto 0);


halt<= '1' when instruction="00000000000000000000000000000000" else
       '0';
            
--i_dec_out<="00000" when i_decoded=annd else
--           "00001" when i_decoded=eor else
--           "00010" when i_decoded=sub else
--           "00011" when i_decoded=rsb else
--           "00100" when i_decoded=add else
--           "00101" when i_decoded=adc else
--           "00110" when i_decoded=sbc else
--           "00111" when i_decoded=rsc else
--           "01000" when i_decoded=tst else
--           "01001" when i_decoded=teq else
--           "01010" when i_decoded=cmp else
--           "01011" when i_decoded=cmn else
--           "01100" when i_decoded=orr else
--           "01101" when i_decoded=mov else
--           "01110" when i_decoded=bic else
--           "01111" when i_decoded=mvn else
--           "10000" when i_decoded=ldr else
--           "10001" when i_decoded=str else
--           "10010" when i_decoded=beq else
--           "10011" when i_decoded=bne else
--           "10100" when i_decoded=b else
--           "10101" when i_decoded=unknown else
--           "11111";
           
--instr_class_out<="001" when instr_class=DP else
--                 "010" when instr_class=DT else
--                 "011" when instr_class=branch else
--                 "100" when instr_class=halted else
--                 "101" when instr_class=unknown else
--                 "000";

end architecture behavioral;