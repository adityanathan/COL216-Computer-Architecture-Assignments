--include libraries
library IEEE;
        use ieee.std_logic_1164.all;
        use IEEE.STD_LOGIC_UNSIGNED.ALL;
        
package reg_array is
type reg_array_type is array(0 to 15) of std_logic_vector(31 downto 0);
end package reg_array;

library IEEE;
        use ieee.std_logic_1164.all;
        use IEEE.STD_LOGIC_UNSIGNED.ALL;
        use ieee.numeric_std.all;
        use work.reg_array.all;

entity processor is
port( clock: in std_logic;
      instruction: in std_logic_vector(31 downto 0);
      data_in: in std_logic_vector(31 downto 0);
      prog_address: out std_logic_vector(31 downto 0);
      data_address: out std_logic_vector(31 downto 0);
      data_out: out std_logic_vector(31 downto 0);--data to be written in data memory
      write_enable: out std_logic;
      
 ------------------------DISPLAY CIRCUIT AND BREAKPOINTS
      step: in std_logic;
      go: in std_logic;
      reset: in std_logic;
      prog_select: in std_logic_vector(2 downto 0);
      i_dec_out: out std_logic_vector(3 downto 0);
      instr_class_out: out std_logic_vector(2 downto 0);
      reg_out: out reg_array_type
      
            
      );
end processor;

architecture behavioral of processor is
signal cond : std_logic_vector (3 downto 0);
signal F_field : std_logic_vector (1 downto 0);
signal I : std_logic;
signal Rn, Rd: std_logic_vector(3 downto 0);
signal operand2: std_logic_vector(11 downto 0);
signal S: std_logic;
signal opcode_for_dp: std_logic_vector(3 downto 0); 
signal opcode_for_b: std_logic_vector(1 downto 0); 
signal offset: std_logic_vector(23 downto 0);

type i_decoded_type is (add,sub,cmp,mov,ldr,str,beq,bne,b,unknown);
signal i_decoded : i_decoded_type;

type instr_class_type is (DP, DT, branch, halted, unknown);
signal instr_class : instr_class_type;

signal Z_flag: std_logic;

--type register_file_type is array(0 to 15) of std_logic_vector(31 downto 0);
signal reg: reg_array_type;  

signal reg_result: std_logic_vector(31 downto 0);

------------------------DISPLAY CIRCUIT AND BREAKPOINTS

type exec_state_type is (initial, onestep, cont, done);
signal exec_state : exec_state_type;
signal halt: std_logic;
signal initial_address: std_logic_vector(31 downto 0);




begin

cond <= instruction(31 downto 28);
F_field<=instruction(27 downto 26);

--dp and dt
I<=instruction(25);
opcode_for_dp<=instruction(24 downto 21);
S<=instruction(20);
Rn<=instruction(19 downto 16);
Rd<=instruction(15 downto 12);
operand2<=instruction(11 downto 0);

--branch
offset<=instruction(23 downto 0);
opcode_for_b<=instruction(25 downto 24);

instr_class<=halted when halt='1' else   ------------------------DISPLAY CIRCUIT AND BREAKPOINTS
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
            b when cond ="1110" and F_field="10" else
            beq when cond ="0000" and F_field="10" else
            bne when cond ="0001" and F_field="10" else
            unknown;
      
write_enable<='1' when i_decoded=str else
              '0';
     
reg_result<= reg(to_integer(unsigned(Rn)))+reg(to_integer(unsigned(instruction(3 downto 0))))    when instr_class=DP and i_decoded=add and i='0' else
             reg(to_integer(unsigned(Rn)))+to_integer(unsigned(instruction(7 downto 0)))   when instr_class=DP and i_decoded=add and i='1' else
             reg(to_integer(unsigned(Rn)))-reg(to_integer(unsigned(instruction(3 downto 0))))    when instr_class=DP and i_decoded=sub and i='0' else
             reg(to_integer(unsigned(Rn)))-to_integer(unsigned(instruction(7 downto 0)))    when instr_class=DP and i_decoded=sub and i='1' else
             reg(to_integer(unsigned(Rn)))-reg(to_integer(unsigned(instruction(3 downto 0))))    when instr_class=DP and i_decoded=cmp and i='0' else
             reg(to_integer(unsigned(Rn)))-to_integer(unsigned(instruction(7 downto 0)))    when instr_class=DP and i_decoded=cmp and i='1' else
             reg(to_integer(unsigned(instruction(3 downto 0)))) when instr_class=DP and i_decoded=mov and i='0' else
             "000000000000000000000000" & instruction(7 downto 0) when instr_class=DP and i_decoded=mov and i='1' else
             --dt
             data_in when instr_class=DT and i_decoded=ldr else
             "00000000000000000000000000000000";
             
data_out<=reg(to_integer(unsigned(Rd))) when instr_class=DT and i_decoded=str else
          "00000000000000000000000000000000";
         
data_address<=reg(to_integer(unsigned(Rn)))+("00000000000000000000" & instruction(11 downto 0)) when instruction(23)='1' and instr_class=DT else
              reg(to_integer(unsigned(Rn)))-("00000000000000000000" & instruction(11 downto 0)) when instruction(23)='0' and instr_class=DT else
              "00000000000000000000000000000000";
          
  
prog_address<=reg(15);


--data_address<=data_address_temp;

state_proc:process(reset, clock)
begin
    if reset='1' then 
        Z_flag<='0';
        reg<=(others => ( others => '0'));
        reg(15)<= initial_address;
    elsif (clock'event and clock='1') then
--    write_enable<='0';
--    data_out<="00000000000000000000000000000000";
        if(exec_state=cont or exec_state=onestep) then   ------------------------DISPLAY CIRCUIT AND BREAKPOINTS
            case instr_class is 
                when halted =>
                    reg(15) <= reg(15)+"00000000000000000000000000000001";
                when unknown =>
                    Z_flag<='0';
                    reg<=(others => ( others => '0'));
                    reg(15)<= initial_address;
                when DP =>
                    if(i_decoded=cmp) then
                        if(reg_result=0) then
                            Z_flag<='1';
                        else
                            Z_flag<='0';
                        end if;
                    else
                        reg(to_integer(unsigned(Rd)))<=reg_result;
                    end if;
                    reg(15) <= reg(15)+"00000000000000000000000000000001";
                when DT =>
                    if i_decoded=ldr then
    --                    data_address<=reg(to_integer(unsigned(Rn)))+("00000000000000000000" & instruction(11 downto 0)) when instruction(23)='1' else
    --                                  reg(to_integer(unsigned(Rn)))-("00000000000000000000" & instruction(11 downto 0)) when instruction(23)='0' else
    --                                  data_address;
                          
    --                      if(instruction(23)='1') then
    --                        data_address<=reg(to_integer(unsigned(Rn)))+("00000000000000000000" & instruction(11 downto 0));
    --                      elsif(instruction(23)='0') then
    --                        data_address<=reg(to_integer(unsigned(Rn)))-("00000000000000000000" & instruction(11 downto 0));
    --                      end if;
                          
                        reg(to_integer(unsigned(Rd)))<=reg_result;
                    
    --                elsif i_decoded=str then
    ----                    data_address<=reg(to_integer(unsigned(Rn)))+("00000000000000000000" & instruction(11 downto 0)) when instruction(23)='1' else
    ----                                  reg(to_integer(unsigned(Rn)))-("00000000000000000000" & instruction(11 downto 0)) when instruction(23)='0' else
    ----                                  data_address;
    ----                      data_out<=reg(to_integer(unsigned(Rd)));
    ----                      write_enable<='1';
    ----                      if(instruction(23)='1') then
    ----                        data_address<=reg(to_integer(unsigned(Rn)))+("00000000000000000000" & instruction(11 downto 0));
    ----                      elsif(instruction(23)='0') then
    ----                        data_address<=reg(to_integer(unsigned(Rn)))-("00000000000000000000" & instruction(11 downto 0));
    ----                      end if;
                    end if;
                    
                    reg(15) <= reg(15)+"00000000000000000000000000000001";
                when others =>
                    if i_decoded = b then 
                    --branch offsetting assumes implicit +2 in word addressing
                        if(offset(23)='0') then
                            reg(15) <= reg(15)+("00000000" & offset)+"00000000000000000000000000000010";
                        elsif(offset(23)='1') then
                            reg(15) <= reg(15)-not("11111111" & offset)+"00000000000000000000000000000001";
                        end if;
                     elsif i_decoded = bne then
                        if Z_flag = '0' then
                            if(offset(23)='0') then
                                reg(15) <= reg(15)+("00000000" & offset)+"00000000000000000000000000000010";
                            elsif(offset(23)='1') then
                                reg(15) <= reg(15)-not("11111111" & offset)+"00000000000000000000000000000001";
                            end if;
                        else reg(15) <= reg(15)+"00000000000000000000000000000001";
                        end if;
                    else
                        if Z_flag = '1' then
                            if(offset(23)='0') then
                                reg(15) <= reg(15)+("00000000" & offset)+"00000000000000000000000000000010";
                            elsif(offset(23)='1') then
                                reg(15) <= reg(15)-not("11111111" & offset)+"00000000000000000000000000000001";
                            end if;
                        else reg(15) <= reg(15)+"00000000000000000000000000000001";
                        end if;
                   end if;                            
            end case;
        end if;
     end if;
end process;

------------------------DISPLAY CIRCUIT AND BREAKPOINTS

halt<= '1' when instruction="00000000000000000000000000000000" else
       '0';

initial_address<= "0000000000000000000000" & prog_select & "0000000";

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

reg_out<=reg;

breakpoint_fsm: process(clock,reset)
begin

    if (reset='1') then 
        exec_state<=initial;
    elsif rising_edge(clock) then
        case exec_state is 
            when initial =>
                if go='1' then
                    exec_state<=cont;
                elsif step='1' then
                    exec_state<=onestep;
                end if;
            when onestep =>
                exec_state<=done;
            when cont =>
                if halt='1' then
                    exec_state<=done;
                end if;
            when done =>
                if (step='0' and go='0') then
                    exec_state<=initial;
                end if;
            end case;
   end if;
end process;



end behavioral;

