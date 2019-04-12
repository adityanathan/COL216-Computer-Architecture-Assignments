library IEEE;
        use ieee.std_logic_1164.all;
        use IEEE.STD_LOGIC_UNSIGNED.ALL;
        use ieee.numeric_std.all;
        use work.control_state_pack.all;
        use work.inst_pack.all;

entity main is
port ( led: out std_logic_vector(15 downto 0);
       slide_switches: in std_logic_vector(15 downto 0);
       go: in std_logic;
       step: in std_logic;
       instr: in std_logic;
       reset: in std_logic;
       clock: in std_logic
     );
end entity main;

architecture behav of main is

signal alu_op1: std_logic_vector(31 downto 0):= "00000000000000000000000000000000";
signal alu_op2: std_logic_vector(31 downto 0):= "00000000000000000000000000000000";
signal alu_result: std_logic_vector(31 downto 0):= "00000000000000000000000000000000";
signal alu_op_code: instr_decoded_type;
signal alu_flags_in: std_logic_vector(3 downto 0):="0000";
signal alu_flags_out: std_logic_vector(3 downto 0):="0000";

signal c, n, v, z: std_logic:='0';
signal flags: std_logic_vector(3 downto 0):="0000";
signal FW:std_logic:= '0';
--signal catch_flags: std_logic_vector(3 downto 0):="0000";

signal shift_in: std_logic_vector(31 downto 0);
signal shift_out: std_logic_vector(31 downto 0);
signal shift_amt: std_logic_vector(4 downto 0);
signal shift_type: std_logic_vector(1 downto 0);
signal shift_carry: std_logic;

signal instr_instruction: std_logic_vector(31 downto 0):="00000000000000000000000000000000";
signal instr_cond: std_logic_vector(3 downto 0):="0000";
signal instr_I: std_logic:='0';
signal instr_Rn: std_logic_vector(3 downto 0):="0000";
signal instr_Rd: std_logic_vector(3 downto 0):="0000";
signal instr_Rm: std_logic_vector(3 downto 0):="0000";
signal instr_operand2: std_logic_vector(11 downto 0):="000000000000";
signal instr_S: std_logic:='0';
signal instr_offset: std_logic_vector(23 downto 0):="000000000000000000000000";
signal instr_decoded: instr_decoded_type;
signal instr_class: instr_class_type;
signal instr_ld: std_logic:='0';
signal instr_U: std_logic:='0';
signal instr_shift_bit: std_logic:='0';
signal instr_sh_amt: std_logic_vector(4 downto 0):="00000";
signal instr_sh_type: std_logic_vector(1 downto 0 ):="00";
signal instr_sh_reg:std_logic_vector(3 downto 0):="0000";
signal instr_p:std_logic;
signal instr_b:std_logic;
signal instr_w:std_logic;
signal instr_dt_1:std_logic;
signal instr_dt_2:std_logic;

signal exec_state: exec_state_type;
signal c_instr_class: instr_class_type;
signal control_state: control_state_type;

signal go_d: std_logic:='0';
signal step_d: std_logic:='0';
signal instr_d: std_logic:='0';
signal reset_d: std_logic:='0';

signal r_read_addr1: std_logic_vector(3 downto 0):="0000";
signal r_data_out1: std_logic_vector(31 downto 0):="00000000000000000000000000000000";
signal r_read_addr2: std_logic_vector(3 downto 0):="0000";
signal r_data_out2: std_logic_vector(31 downto 0):="00000000000000000000000000000000";

signal r_write_addr: std_logic_vector(3 downto 0):="0000";
signal r_write_data: std_logic_vector(31 downto 0):="00000000000000000000000000000000";
signal r_we: std_logic:='0';

signal r_pc_in: std_logic_vector(31 downto 0):="00000000000000000000000000000000";
signal r_pc_out: std_logic_vector(31 downto 0):="00000000000000000000000000000000";
signal r_pc_we: std_logic:='0';

signal IR: std_logic_vector(31 downto 0):="00000000000000000000000000000000";
signal DR: std_logic_vector(31 downto 0):="00000000000000000000000000000000";
signal A: std_logic_vector(31 downto 0):="00000000000000000000000000000000";
signal B: std_logic_vector(31 downto 0):="00000000000000000000000000000000";
signal Creg: std_logic_vector(31 downto 0):="00000000000000000000000000000000";
signal D: std_logic_vector(31 downto 0):="00000000000000000000000000000000";
signal RES: std_logic_vector(31 downto 0):="00000000000000000000000000000000";

signal PW: std_logic:='0';
signal IorD: std_logic:='0';
signal MW, DW2, IW, DW, M2R, RW, AW, BW, Asrc1, Fset, ReW, SW1, SW3, CW: std_logic:='0';
signal SW2, Rsrc: std_logic_vector(1 downto 0):="00";
signal Asrc2: std_logic_vector(2 downto 0):="000";

signal data_address: std_logic_vector(31 downto 0):="00000000000000000000000000000000";
signal data_out: std_logic_vector(31 downto 0):="00000000000000000000000000000000";
signal write_enable: std_logic:='0';
signal data_in: std_logic_vector(31 downto 0):="00000000000000000000000000000000";

signal reg_obs: std_logic_vector(31 downto 0):="00000000000000000000000000000000";
COMPONENT unified_memory
  PORT (
    a : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    d : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    clk : IN STD_LOGIC;
    we : IN STD_LOGIC;
    spo : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
END COMPONENT;

begin

data_memory: unified_memory port map(
    a => data_address(9 downto 2),
    d => data_in,
    clk => clock,
    we => write_enable,
    spo => data_out
    );

alu_inst: entity work.alu(comb) port map
(   op1 => alu_op1,
    op2 => alu_op2, 
    result => alu_result, 
    op_code => alu_op_code,
    flags_in => flags,
    flags_out => alu_flags_out,
    U_bit => instr_U                   ----WARNING
    );

shifter: entity work.shifter(comb) port map
(      in_data => shift_in,
       out_data => shift_out,
       sh_amt => shift_amt,
       sh_type => shift_type,
       sh_c => shift_carry 
);

instr_decoder: entity work.instr_decoder(behavioral) port map(
    instruction => instr_instruction,
    cond => instr_cond,
    I => instr_I,
    Rn => instr_Rn,
    Rd => instr_Rd,
    Rm => instr_Rm,
    operand2 => instr_operand2,
    S => instr_S,
    offset => instr_offset,
    i_dec_out => instr_decoded,
    instr_class_out => instr_class,
    ld_bit => instr_ld,
    U => instr_U,
    shift_bit => instr_shift_bit,
    sh_amt => instr_sh_amt,
    sh_type => instr_sh_type,
    Rs => instr_sh_reg,
    P_bit => instr_p, 
    B_bit => instr_b,
    W_bit => instr_w,
    DT_SH_1 => instr_dt_1,
    DT_SH_2 => instr_dt_2

    );

control_state_fsm: entity work.control_fsm port map(
      reset => reset_d,
      clock => clock,
      exec_state_in => exec_state,
      instr_class_in => c_instr_class,
      control_state_out => control_state,
      ld_bit => instr_ld,
      I_bit => instr_I,
      shift_bit => instr_shift_bit
      );
      
debounce1: entity work.debouncer(behavioral) port map(
            clock=>clock,
            bounce=>go,
            debounce=>go_d
      --      reset=>reset_s
            );
            
debounce2: entity work.debouncer(behavioral) port map(
          clock=>clock,
          bounce=>step,
          debounce=>step_d
--            reset=>reset_s
          );
          
debounce3: entity work.debouncer(behavioral) port map(
                clock=>clock,
                bounce=>reset,
                debounce=>reset_d
--                  reset=>reset_s
                );

debounce4: entity work.debouncer(behavioral) port map(
                clock=>clock,
                bounce=>instr,
                debounce=>instr_d
--                  reset=>reset_s
                );
     
exec_fsm: entity work.exec_state_fsm port map(
      control_state_in => control_state,
      exec_state_out => exec_state,
      go => go_d,                                               ---WARNING
      step => step_d,
      instr => instr_d,
      reset => reset_d,
      clock => clock
    );

register_file: entity work.reg_file port map(
      clock => clock,
      reset => reset_d,
      read_addr1 => r_read_addr1,
      data_out1 => r_data_out1,
      read_addr2 => r_read_addr2,
      data_out2 => r_data_out2,
      
      write_addr_input => r_write_addr,
      write_input_data => r_write_data,
      write_enable => r_we,
      
      pc_data_in => r_pc_in,
      pc_data_out => r_pc_out,
      pc_we => r_pc_we,
            
      read_addr_obs => slide_switches(14 downto 11),
      data_out_obs => reg_obs,
      
      start => slide_switches(15)
      );

IW <= '1' when (control_state=fetch) and not(exec_state=initial or exec_state=done) else
      '0';
      
PW <= '1' when (control_state=fetch or (control_state=brn and not( instr_decoded=beq or instr_decoded=bne))) and not(exec_state=initial or exec_state=done) else
      z when (control_state=brn and instr_decoded=beq) and not(exec_state=initial or exec_state=done) else
      not(z) when (control_state=brn and instr_decoded=bne) and not(exec_state=initial or exec_state=done) else
      '0';

IorD <= '1' when (control_state=mem_wr or control_state=mem_rd) and not(exec_state=initial or exec_state=done) else
        '0';
        
MW <= '1' when (control_state=mem_wr) and not(exec_state=initial or exec_state=done) else
      '0';

DW <= '1' when (control_state=mem_rd) and not(exec_state=initial or exec_state=done) else
      '0';

Rsrc <= "01" when (control_state=addr) and not(exec_state=initial or exec_state=done) else
        "11" when (control_state=reg_read) and not(exec_state=initial or exec_state=done) else
        "00";



RW <= '1' when ((control_state=mem2RF) or (control_state=res2RF and not(instr_decoded=cmp))) and not(exec_state=initial or exec_state=done) else
      '0';
      
M2R <= '1' when RW = '1' and (control_state=mem2RF) else
             '0';
      
AW <= '1' when (control_state=decode) and not(exec_state=initial or exec_state=done) else
      '0';

BW <= '1' when (control_state=decode or control_state=addr) and not(exec_state=initial or exec_state=done) else
      '0';

CW <= '1' when (control_state = reg_read) and not(exec_state=initial or exec_state=done) else
      '0';
      
FW <= '1' when (control_state = arith and (instr_S = '1' or (instr_decoded = annd
                                                          or  instr_decoded = eor
                                                          or  instr_decoded = tst
                                                          or  instr_decoded = teq
                                                          or  instr_decoded = orr
                                                          or  instr_decoded = mov
                                                          or  instr_decoded = bic
                                                          or  instr_decoded = mvn))) else
      '0';
      
Asrc1 <= '1' when (control_state=addr or control_state=arith) and not(exec_state=initial or exec_state=done) else
         '0';

Asrc2 <= "001" when ((control_state=fetch or control_state=decode)) and not(exec_state=initial or exec_state=done) else
         "010" when ((control_state=arith)) and not(exec_state=initial or exec_state=done) else
         "011" when ((control_state=brn)) and not(exec_state=initial or exec_state=done) else
         "100" when (control_state = addr) and not(exec_state=initial or exec_state=done) else
         "000";



Fset <= '1' when (control_state=arith and instr_decoded=cmp) and not(exec_state=initial or exec_state=done) else
        '0'; 

ReW <= '1' when ((control_state=arith and not (instr_decoded=cmp)) or control_state=addr) and not(exec_state=initial or exec_state=done) else
       '0';
       
write_enable<=MW;  
r_we<=RW;
r_pc_we <= PW ;  
r_pc_in <= alu_result(29 downto 0) & "00" when control_state=brn and PW = '1'  else
           alu_result(31 downto 0) when control_state = fetch and PW = '1'  else
           "00000000000000000000000000000000";                                                                                                            
process(clock, PW, IW, MW, DW, RW, AW, BW, ReW )
begin
if rising_edge(clock) then

    if IW='1' then
        IR<=data_out;
    end if;
    
    --write_enable<=MW;
    
    if DW='1' then
        DR<= data_out;
    end if;
    
    if DW2 = '1' then
        D <= shift_out;
    end if;
    
    if AW='1' then
        if not(instr_decoded=mov) then
            A<=r_data_out1;
--        else
--            A<="00000000000000000000000000000000";
        end if;
    --A<=r_data_out1;
    end if;
    
    if BW='1' then
--        if not((instr_class="0111" and alu_flag_out='1') or (instr_class="1000" and alu_flag_out='0')) then
            B<=r_data_out2;
--        else
            --B<="00000000000000000000000000000000";
--        end if;

    end if;
    
    if CW = '1' then
            Creg <= r_data_out2;
    end if;
    
    if FW='1' then
            --c <= alu_flags_out(3) or shift_carry;
            n <= alu_flags_out(2);
            v <= alu_flags_out(1);
            z <= alu_flags_out(0);
    end if;
    
    if (instr_decoded = annd
              or  instr_decoded = eor
              or  instr_decoded = tst
              or  instr_decoded = teq
              or  instr_decoded = orr
              or  instr_decoded = mov
              or  instr_decoded = bic
              or  instr_decoded = mvn) and not(shift_amt = "00000") then
        c <= shift_carry;
    elsif FW ='1' then
        c <= alu_flags_out(3);
    end if; 

    if ReW='1' then
        RES<=alu_result;
    end if;
   
end if;
    

end process;
--r_pc_in<=alu_result;
DW2 <= '1' when control_state = shift and not(exec_state=initial or exec_state=done) else
       '0';

data_in<=B;
instr_instruction<=IR;
r_read_addr1<=instr_Rn;
r_write_addr<=instr_Rd;
c_instr_class<=instr_class;

alu_op_code <= unknown when (control_state = fetch or control_state =brn) and not(exec_state=initial or exec_state=done) else
                instr_decoded;
--r_pc_we <= PW;

data_address<= r_pc_out when IorD = '0' else
               RES;

r_write_data<= DR when M2R='1' else
               RES;

r_read_addr2<= instr_Rd when Rsrc ="01" else
               instr_sh_reg when Rsrc="11" else
               instr_Rm;

alu_op1<="00" & r_pc_out(31 downto 2) when Asrc1='0' and control_state=brn else   --"0100" coreesponds to brn
         r_pc_out (31 downto 0) when Asrc1='0' and not(control_state=brn) else
         A;

alu_op2<= B when Asrc2="000" else
          "00000000000000000000000000000100" when Asrc2="001" else
          D when Asrc2="010" else
          "00000000000000000000" & instr_operand2 when Asrc2="100" else
          "00000000" & instr_offset  when (Asrc2="011" and instr_offset(23)='0') else
          "11111111" & instr_offset ;

shift_in <= B when SW1='0' else
            "000000000000000000000000" & instr_operand2(7 downto 0);

shift_amt <= Creg(4 downto 0) when SW2="00" else
          instr_sh_amt when SW2="01" else              --in case of constant shift
          instr_sh_reg & '0';                 --in case of rot shift for constant operand 2

shift_type <= instr_sh_type when SW3 = '0' else           --in case of shift for reg
              "11";
       
SW1 <= '1' when (control_state = shift and instr_I='1') else
                     '0';
                     
SW2 <= "10" when (control_state = shift and instr_I='1') else
       "01" when (control_state = shift and instr_I='0' and instr_shift_bit = '0') else
       "00";

SW3 <= '1' when (control_state = shift and instr_I ='1') else
       '0'; 

   
flags <= "0000" when (control_state = fetch and not(exec_state=initial or exec_state=done)) else
         "1000" when (control_state = brn and not(exec_state=initial or exec_state=done)) else
         c & n & v & z;




led <= instr_instruction(31 downto 16) when slide_switches(14 downto 0)="000000000000000" else
       instr_instruction(15 downto 0) when slide_switches(14 downto 0)="000000000000001" else
       alu_result(31 downto 16) when slide_switches(14 downto 0)="000000000000010" else
       alu_result(15 downto 0) when slide_switches(14 downto 0)="000000000000011" else
       A(31 downto 16) when slide_switches(14 downto 0)="000000000000100" else
       A(15 downto 0) when slide_switches(14 downto 0)="000000000000101" else
       B(31 downto 16) when slide_switches(14 downto 0)="000000000000110" else
       B(15 downto 0) when slide_switches(14 downto 0)="000000000000111" else
       RES(31 downto 16) when slide_switches(14 downto 0)="000000000001000" else
       RES(15 downto 0) when slide_switches(14 downto 0)="000000000001001" else
       IR(31 downto 16) when slide_switches(14 downto 0)="000000000001010" else
       IR(15 downto 0) when slide_switches(14 downto 0)="000000000001011" else
       DR(31 downto 16) when slide_switches(14 downto 0)="000000000001100" else
       DR(15 downto 0) when slide_switches(14 downto 0)="000000000001101" else
       r_pc_out(31 downto 16) when slide_switches(14 downto 0)="000000000001110" else
       r_pc_out(15 downto 0) when slide_switches(14 downto 0)="000000000001111" else
       data_address(31 downto 16) when slide_switches(14 downto 0)="000000000010000" else
       data_address(15 downto 0) when slide_switches(14 downto 0)="000000000010001" else
       data_out(31 downto 16) when slide_switches(14 downto 0)="000000000010010" else
       data_out(15 downto 0) when slide_switches(14 downto 0)="000000000010011" else
       reg_obs(31 downto 16) when slide_switches(4 downto 0)="10100" else
       reg_obs(15 downto 0) when slide_switches(4 downto 0)="10101" else
       --control_state & "000000000" & exec_state when slide_switches(14 downto 0)="000000000010110" else
       --PW & IorD & MW & IW & DW & Rsrc & M2R & RW & AW & BW & Asrc1 & Fset & Asrc2 & ReW & "0" when slide_switches(14 downto 0) = "000000000010111" else
       --flags & alu_op_code & "0000000000" when slide_switches(14 downto 0) = "000000000011000" else
       "1111111111111111";


end architecture behav;