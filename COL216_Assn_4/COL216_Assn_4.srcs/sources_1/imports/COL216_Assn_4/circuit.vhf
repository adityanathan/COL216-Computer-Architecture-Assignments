--include libraries
library IEEE;
        use ieee.std_logic_1164.all;
        use IEEE.STD_LOGIC_UNSIGNED.ALL;
        use ieee.numeric_std.all;

entity processor is
port( clock: in std_logic;
      reset: in std_logic;
      instruction: in std_logic_vector(31 downto 0);
      data_in: in std_logic_vector(31 downto 0);
      prog_address: out std_logic_vector(31 downto 0);
      data_address: out std_logic_vector(31 downto 0);
      data_out: out std_logic_vector(31 downto 0);
      write_enable: out std_logic
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

type instr_class_type is (DP, DT, branch, unknown);
signal instr_class : instr_class_type;

signal Z_flag: std_logic;

type register_file_type is array(0 to 15) of std_logic_vector(31 downto 0);
signal reg: register_file_type;  

signal reg_result: std_logic_vector(31 downto 0);

--signal data_address_temp: std_logic_vector(31 downto 0);
begin

cond <= instruction(31 downto 28);
F_field<=instruction(27 downto 26);

--dp and dt
I<=instruction(25);
opcode_for_dp<=instruction(24 downto 21);
S<=instruction(20);
Rn<=instruction(20 downto 16);
Rd<=instruction(15 downto 12);
operand2<=instruction(11 downto 0);

--branch
offset<=instruction(23 downto 0);
opcode_for_b<=instruction(25 downto 24);

instr_class<=DP when F_field="00" else
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
             reg(to_integer(unsigned(Rn)))+reg(to_integer(unsigned(instruction(3 downto 0))))    when instr_class=DP and i_decoded=cmp and i='0' else
             reg(to_integer(unsigned(Rn)))+to_integer(unsigned(instruction(7 downto 0)))    when instr_class=DP and i_decoded=cmp and i='1' else
             reg(to_integer(unsigned(instruction(3 downto 0)))) when instr_class=DP and i_decoded=mov and i='0' else
             "000000000000000000000000" & instruction(7 downto 0) when instr_class=DP and i_decoded=mov and i='1' else
             --dt
             data_in when instr_class=DT and i_decoded=ldr else
             "00000000000000000000000000000000";
             
data_out<=reg(to_integer(unsigned(Rd))) when instr_class=DT and i_decoded=str else
          "00000000000000000000000000000000";
          
--prog_address<=reg[15];
prog_address<=reg(15);

--data_address<=data_address_temp;

state_proc:process(reset, clock)
begin
    if reset='1' then 
        Z_flag<='0';
        reg<=(others => ( others => '0'));
    elsif (clock'event and clock='1') then
        case instr_class is 
            when unknown =>
                Z_flag<='0';
                reg<=(others => ( others => '0'));
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
                reg(15) <= reg(15)+"00000000000000000000000000100000";
            when DT =>
                if i_decoded=ldr then
--                    data_address<=reg(to_integer(unsigned(Rn)))+("00000000000000000000" & instruction(11 downto 0)) when instruction(23)='1' else
--                                  reg(to_integer(unsigned(Rn)))-("00000000000000000000" & instruction(11 downto 0)) when instruction(23)='0' else
--                                  data_address;
                      
                      if(instruction(23)='1') then
                        data_address<=reg(to_integer(unsigned(Rn)))+("00000000000000000000" & instruction(11 downto 0));
                      elsif(instruction(23)='0') then
                        data_address<=reg(to_integer(unsigned(Rn)))-("00000000000000000000" & instruction(11 downto 0));
                      end if;
                      
                    reg(to_integer(unsigned(Rd)))<=reg_result;
                
                elsif i_decoded=str then
--                    data_address<=reg(to_integer(unsigned(Rn)))+("00000000000000000000" & instruction(11 downto 0)) when instruction(23)='1' else
--                                  reg(to_integer(unsigned(Rn)))-("00000000000000000000" & instruction(11 downto 0)) when instruction(23)='0' else
--                                  data_address;

                      if(instruction(23)='1') then
                        data_address<=reg(to_integer(unsigned(Rn)))+("00000000000000000000" & instruction(11 downto 0));
                      elsif(instruction(23)='0') then
                        data_address<=reg(to_integer(unsigned(Rn)))-("00000000000000000000" & instruction(11 downto 0));
                      end if;
                end if;
                
                reg(15) <= reg(15)+"00000000000000000000000000100000";
            when others => --branch
                reg(15) <= reg(15)+("00000000" & offset);
        end case;
     end if;
end process;
end behavioral;