library IEEE;
        use ieee.std_logic_1164.all;
        use IEEE.STD_LOGIC_UNSIGNED.ALL;
        use ieee.numeric_std.all;

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
signal control_input_alu: std_logic;
signal alu_flag_out: std_logic;
signal alu_flag_we: std_logic;
signal alu_carry: std_logic;

signal instr_instruction: std_logic_vector(31 downto 0);
signal instr_cond: std_logic_vector(3 downto 0);
signal instr_I: std_logic;
signal instr_Rn: std_logic_vector(3 downto 0);
signal instr_Rd: std_logic_vector(3 downto 0);
signal instr_Rm: std_logic_vector(3 downto 0);
signal instr_operand2: std_logic_vector(11 downto 0);
signal instr_S: std_logic;
signal instr_offset: std_logic_vector(23 downto 0);
signal instr_decoded: std_logic_vector(3 downto 0);
signal instr_class: std_logic_vector(2 downto 0);
signal instr_ld: std_logic;
signal instr_U: std_logic;

signal exec_state: std_logic_vector(2 downto 0);
signal c_instr_class: std_logic_vector(2 downto 0);
signal control_state: std_logic_vector(3 downto 0);

signal go_d: std_logic;
signal step_d: std_logic;
signal instr_d: std_logic;
signal reset_d: std_logic;

signal r_read_addr1: std_logic_vector(3 downto 0);
signal r_data_out1: std_logic_vector(31 downto 0);
signal r_read_addr2: std_logic_vector(3 downto 0);
signal r_data_out2: std_logic_vector(31 downto 0);

signal r_write_addr: std_logic_vector(3 downto 0);
signal r_write_data: std_logic_vector(31 downto 0);
signal r_we: std_logic;

signal r_pc_in: std_logic_vector(31 downto 0):="00000000000000000000000000000000";
signal r_pc_out: std_logic_vector(31 downto 0);
signal r_pc_we: std_logic;

signal IR: std_logic_vector(31 downto 0);
signal DR: std_logic_vector(31 downto 0);
signal A: std_logic_vector(31 downto 0);
signal B: std_logic_vector(31 downto 0);
signal RES: std_logic_vector(31 downto 0);

signal PW: std_logic;
signal IorD: std_logic;
signal MW, IW, DW, Rsrc, M2R, RW, AW, BW, Asrc1, Fset, op, ReW: std_logic;
signal Asrc2: std_logic_vector(1 downto 0);

signal data_address: std_logic_vector(31 downto 0);
signal data_out: std_logic_vector(31 downto 0);
signal write_enable: std_logic;
signal data_in: std_logic_vector(31 downto 0);

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
    control_input => control_input_alu,
    flag_out => alu_flag_out,
    flag_we => alu_flag_we,
    carry => alu_carry
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
    U => instr_U
    );

control_state_fsm: entity work.control_fsm port map(
      reset => reset_d,
      clock => clock,
      exec_state_in => exec_state,
      instr_class_in => c_instr_class,
      control_state_out => control_state,
      ld_bit => instr_ld
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
      go => go,                                               ---WARNING
      step => step,
      instr => instr,
      reset => reset,
      clock => clock
    );

register_file: entity work.reg_file port map(
      read_addr1 => r_read_addr1,
      data_out1 => r_data_out1,
      read_addr2 => r_read_addr2,
      data_out2 => r_data_out2,
      
      write_addr_input => r_write_addr,
      write_input_data => r_write_data,
      write_enable => r_we,
      
      pc_data_in => r_pc_in,
      pc_data_out => r_pc_out,
      pc_we => r_pc_we
      );

IW <= '1' when (control_state="0000" or control_state="0111") and not(exec_state="100" or exec_state="000") else
      '0';
      
PW <= '1' when (control_state="0000" or (control_state="0100" and not( instr_decoded="0111" or instr_decoded="1000"))) and not(exec_state="100" or exec_state="000") else
      alu_flag_out when (control_state="0100" and instr_decoded="0111") and not(exec_state="100" or exec_state="000") else
      not(alu_flag_out) when (control_state="0100" and instr_decoded="1000") and not(exec_state="100" or exec_state="000") else
      '0';

IorD <= '1' when (control_state="0111" or control_state="1000") and not(exec_state="100" or exec_state="000") else
        '0';
        
MW <= '1' when (control_state="0111") and not(exec_state="100" or exec_state="000") else
      '0';

DW <= '1' when (control_state="1000") and not(exec_state="100" or exec_state="000") else
      '0';

Rsrc <= '1' when (control_state="0011") and not(exec_state="100" or exec_state="000") else
        '0';

M2R <= '1' when (control_state="1001") and not(exec_state="100" or exec_state="000") else
       '0';

RW <= '1' when ((control_state="1001") or (control_state="0110" and not(instr_decoded="0011"))) and not(exec_state="100" or exec_state="000") else
      '0';
      
AW <= '1' when (control_state="0001") and not(exec_state="100" or exec_state="000") else
      '0';

BW <= '1' when (control_state="0001" or control_state="0011") and not(exec_state="100" or exec_state="000") else
      '0';
      
Asrc1 <= '1' when (control_state="0011" or control_state="0010") and not(exec_state="100" or exec_state="000") else
         '0';

Asrc2 <= "01" when ((control_state="0000" or control_state="0001")) and not(exec_state="100" or exec_state="000") else
         "10" when ((control_state="0010" and instr_I='1') or control_state="0011") and not(exec_state="100" or exec_state="000") else
         "11" when ((control_state="0100")) and not(exec_state="100" or exec_state="000") else
         "00";

Fset <= '1' when (control_state="0010" and instr_decoded="0011") and not(exec_state="100" or exec_state="000") else
        '0';

op <= '1' when (control_state="0100") and not(exec_state="100" or exec_state="000") else
      instr_U when (control_state="0011") and not(exec_state="100" or exec_state="000") else
      '1' when (control_state="0000" or control_state="0001" or ( control_state="0010" and (instr_decoded="0001" or instr_decoded="0100") )) and not(exec_state="100" or exec_state="000") else
      '0'; 

ReW <= '1' when ((control_state="0010" and not (instr_decoded="0011")) or control_state="0011") and not(exec_state="100" or exec_state="000") else
       '0';

alu_carry <= '1' when (control_state="0100") and not(exec_state="100" or exec_state="000") else
             '0';
       

--((instr_class="0111" and alu_flag_out='1') or (instr_class="1000" and alu_flag_out='0'))
--when "0100" => --brn
--           if instr_class="0111" then -- beq
--                PW<=alu_flag_out;
                
--           elsif instr_class="1000" then --bne
--                PW<= not(alu_flag_out);
--           else
--                PW<='1'; 
--           end if;

--process(control_state, instr_I, instr_decoded, instr_U, instr_class, alu_flag_out)
--begin
--    case control_state is 
--        when "0000" => 
--            --IorD<='0'; MW<='0';
--            -- DW<='0'; Rsrc<='0';
--           -- M2R<='0'; RW<='0'; AW<='0'; BW<='0'; 
--            --Asrc1<='0'; Asrc2<="01";
--            --Fset<='0'; 
--            op<='1'; ReW<='0'; alu_carry<='0';
--        when "0001" =>
--            --IorD<='0'; MW<='0';
--            -- DW<='0'; Rsrc<='0';
--            --M2R<='0'; RW<='0'; AW<='1'; BW<='1';
--            -- Asrc1<='0'; Asrc2<="01";
--            --Fset<='0'; 
--            op<='1'; ReW<='0'; alu_carry<='0';
--        when "0010" =>
--           -- IorD<='0'; MW<='0';
--            -- DW<='0'; Rsrc<='0';
--            --M2R<='0'; RW<='0'; AW<='0'; BW<='0'; 
----            Asrc1<='1'; 
----            if instr_I='0' then
----                Asrc2<="00";
----            else 
----                Asrc2<="10";
----            end if;
            
----            if instr_decoded="0011" then
----                Fset<='1';
----            else
----                Fset<='0';
----            end if;
            
--            if instr_decoded="0001" then
--                op<='1';
--            else
--                op<='0';
--            end if; 
            
--            if instr_decoded="0011" then
--                ReW<='0';
--            else
--                ReW<='1';
--            end if;
                
--            alu_carry<='0';
--        when "0011" =>
--          -- IorD<='0'; MW<='0';
--           --DW<='0'; Rsrc<='1';
--           --M2R<='0'; RW<='0'; AW<='0'; BW<='1'; 
--           --Asrc1<='1'; Asrc2<="10";
--           --Fset<='0'; 
--           op<=instr_U; 
--           ReW<='1'; alu_carry<='0';
--        when "0100" => --brn
----           if instr_class="0111" then -- beq
----                PW<=alu_flag_out;
                
----           elsif instr_class="1000" then --bne
----                PW<= not(alu_flag_out);
----           else
----                PW<='1'; 
----           end if;
           
--           op<=not(instr_offset(23));
--           --IorD<='0'; MW<='0'; 
--           --DW<='0'; Rsrc<='0';
--           --M2R<='0'; RW<='0'; AW<='0'; BW<='0'; 
--           --Asrc1<='0'; Asrc2<="11";
--           --Fset<='0'; --op<='1'; 
--           ReW<='0'; alu_carry<='1';
--       when "0101" =>--halt
--           --IorD<='0'; MW<='0';
--           -- DW<='0'; Rsrc<='0';
--           --M2R<='0'; RW<='0'; AW<='0'; BW<='0'; 
--           --Asrc1<='0'; Asrc2<="00";
--           --Fset<='0'; 
--           op<='0'; ReW<='0'; alu_carry<='0';
--       when "0110" =>--res2RF
--           --IorD<='0'; MW<='0';
--           -- DW<='0'; Rsrc<='0';
--           --M2R<='0'; RW<='1'; AW<='0'; BW<='0'; 
--           --Asrc1<='0'; Asrc2<="00";
--           --Fset<='0'; 
--           op<='0'; ReW<='0'; alu_carry<='0';
--       when "0111" =>--mem_wr
--          --IorD<='1'; MW<='1';
--          -- DW<='0'; Rsrc<='0';
--          --M2R<='0'; RW<='0'; AW<='0'; BW<='0'; 
--          --Asrc1<='0'; Asrc2<="00";
--          --Fset<='0'; 
--          op<='0'; ReW<='0'; alu_carry<='0';
--        when "1000" =>--mem_rd 
--         -- IorD<='1'; MW<='0';
--              --DW<='1'; Rsrc<='0';
--             --M2R<='0'; RW<='0'; AW<='0'; BW<='0';
--             -- Asrc1<='0'; Asrc2<="00";
--             --Fset<='0'; 
--             op<='0'; ReW<='0'; alu_carry<='0';
--         when "1001" =>--mem2RF
--            -- IorD<='0'; MW<='0';
--             --DW<='0'; Rsrc<='0';
--             --M2R<='1'; RW<='1'; AW<='0'; BW<='0'; 
--             --Asrc1<='0'; Asrc2<="00";
--             --Fset<='0'; 
--             op<='0'; ReW<='0'; alu_carry<='0';
--         when "1111" =>
--            -- IorD<='0'; MW<='0';
--             --DW<='0'; Rsrc<='0';
--             --M2R<='0'; RW<='0'; AW<='0'; BW<='0'; 
--             --Asrc1<='0'; Asrc2<="00";
--             --Fset<='0'; 
--             op<='0'; ReW<='0'; alu_carry<='0';
--         when others =>
--             --IorD<='0'; MW<='0';
--             --DW<='0'; Rsrc<='0';
--             --M2R<='0'; RW<='0'; AW<='0'; BW<='0'; 
--             --Asrc1<='0'; Asrc2<="00";
--             --Fset<='0'; 
--             op<='0'; ReW<='0'; alu_carry<='0';
--     end case;
            

--end process;
--r_pc_we<=PW;
write_enable<=MW;  
r_we<=RW;                                                                                                              
process(clock, PW, IW, MW, DW, RW, AW, BW, ReW )
begin
if rising_edge(clock) then
    if PW='1' then
        if control_state="0100" then
            r_pc_in<=alu_result(29 downto 0) & "00";
        else 
            r_pc_in<= alu_result(31 downto 0);
        end if;
        r_pc_we<='1';
    else
        r_pc_we<='0';
    end if;
    --r_pc_we<=PW;
    if IW='1' then
        IR<=data_out;
    end if;
    
    --write_enable<=MW;
    
    if DW='1' then
        DR<= data_out;
    end if;
    
    --r_we<=RW;
    
    if AW='1' then
        if not(instr_decoded="0100") then
            A<=r_data_out1;
        else
            A<="00000000000000000000000000000000";
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
    
    if ReW='1' then
        RES<=alu_result;
    end if;
   
end if;
    

end process;
--r_pc_in<=alu_result;
data_in<=B;
instr_instruction<=IR;
r_read_addr1<=instr_Rn;
r_write_addr<=instr_Rd;
c_instr_class<=instr_class;


--r_pc_we <= PW;

data_address<= r_pc_out when IorD = '0' else
               RES;
               
--write_enable<= MW;

--IR<= data_out when IW='1' else
--     IR;

--DR<= data_out when DW='1' else
--     DR;

r_write_data<= DR when M2R='1' else
               RES;

r_read_addr2<= instr_Rm when Rsrc ='0' else
               instr_Rd;
   
--r_we<=RW;

--A<= r_data_out1 when AW='1' else
--    A;

--B<= r_data_out2 when BW='1' and not (instr_decoded="0100") else
--    "00000000000000000000000000000000" when BW='1' and (instr_decoded="0100") else
--    B;

alu_op1<="00" & r_pc_out(31 downto 2) when Asrc1='0' and control_state="0100" else   --"0100" coreesponds to brn
         r_pc_out (31 downto 0) when Asrc1='0' and not(control_state="0100") else
         A;

alu_op2<= B when Asrc2="00" else
          "00000000000000000000000000000100" when Asrc2="01" else
          "00000000000000000000" & instr_operand2 when Asrc2="10" else
          "00000000" & instr_offset  when (Asrc2="11" and instr_offset(23)='0') else
          "11111111" & instr_offset ;

--if(offset(23)='0') then
--                                reg(15) <= reg(15)+("00000000" & offset)+"00000000000000000000000000000010";
--                            elsif(offset(23)='1') then
--                                reg(15) <= reg(15)-not("11111111" & offset)+"00000000000000000000000000000001";
--                            end if;

control_input_alu<= op;

alu_flag_we<=Fset;

--RES<=alu_result when ReW='1' else
--     RES;
          
led <= instr_instruction(31 downto 16) when slide_switches="0000000000000000" else
       instr_instruction(15 downto 0) when slide_switches="0000000000000001" else
       alu_result(31 downto 16) when slide_switches="0000000000000010" else
       alu_result(15 downto 0) when slide_switches="0000000000000011" else
       A(31 downto 16) when slide_switches="0000000000000100" else
       A(15 downto 0) when slide_switches="0000000000000101" else
       B(31 downto 16) when slide_switches="0000000000000110" else
       B(15 downto 0) when slide_switches="0000000000000111" else
       RES(31 downto 16) when slide_switches="0000000000001000" else
       RES(15 downto 0) when slide_switches="0000000000001001" else
       IR(31 downto 16) when slide_switches="0000000000001010" else
       IR(15 downto 0) when slide_switches="0000000000001011" else
       DR(31 downto 16) when slide_switches="0000000000001100" else
       DR(15 downto 0) when slide_switches="0000000000001101" else
       r_pc_out(31 downto 16) when slide_switches="0000000000001110" else
       r_pc_out(15 downto 0) when slide_switches="0000000000001111" else
       data_address(31 downto 16) when slide_switches="0000000000010000" else
       data_address(15 downto 0) when slide_switches="0000000000010001" else
       data_out(31 downto 16) when slide_switches="0000000000010010" else
       data_out(15 downto 0) when slide_switches="0000000000010011" else
       "1111111111111111";

end architecture behav;