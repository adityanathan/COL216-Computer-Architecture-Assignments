package control_state_pack is
type control_state_type is (unknown, fetch, decode, arith, reg_read, shift, addr, brn, halt, res2RF, mem_wr, mem_rd, mem2RF);
type exec_state_type is (initial, oneinstr, onestep, cont, done);
end package;

library IEEE;
        use ieee.std_logic_1164.all;
        use IEEE.STD_LOGIC_UNSIGNED.ALL;
        use ieee.numeric_std.all;
        use work.control_state_pack.all;
        use work.inst_pack.all;
        
entity control_fsm is
port (reset: in std_logic;
      clock: in std_logic;
      exec_state_in: in exec_state_type;
      instr_class_in: in instr_class_type; 
      control_state_out:out control_state_type;
      I_bit: in std_logic;
      shift_bit: in std_logic;
      ld_bit: in std_logic
      );
end entity control_fsm;

architecture seq of control_fsm is    
signal control_state : control_state_type := fetch;
begin

process(reset, clock)
begin
    if reset='1' then
        control_state<=fetch;
    elsif rising_edge(clock) then
        if exec_state_in=onestep or exec_state_in=oneinstr or exec_state_in=cont then
            case control_state is
                when fetch => 
                    control_state <= decode;
                when decode => 
                    if instr_class_in =DP then
                        if I_bit = '1' then 
                            control_state <= shift;
                        else 
                            if shift_bit = '1' then
                                control_state <= reg_read;
                            else
                                control_state <= shift;
                            end if;
                        end if;
                    elsif instr_class_in = DT then
                        if P = '1' then
                            control_state <= addr;
                        else
                            if ld_bit = '1' then
                                control_state <= mem_rd;
                            else
                                if B = '1' then
                                    control_state <= mem_rd;
                                else
                                    control_state <= mem_wr;
                                end if;
                            end if;
                        end if;
                    elsif instr_class_in=branch then
                        control_state <= brn;
                    elsif instr_class_in <=halted then
                        control_state <= halt;
                    else
                        control_state <= unknown;
                    end if;
                when shift =>
                    control_state <= arith;
                when reg_read =>
                    control_state <= shift;
                when arith => 
                    control_state <= res2RF;
                when addr =>
                    if ld_bit='0' then
                        if B = '1' then
                            control_state <= mem_rd;
                        else
                            control_state <= mem_wr;
                        end if;                                                                                        
                        --control_state<= mem_wr;
                    else
                        control_state<= mem_rd;
                    end if;
                when mem_rd =>
                    if B = '0' then
                        control_state <= mem2RF;
                    else
                        control_state <= mem_wr;
                    end if;
                    --control_state<= mem2RF;
                when res2RF | mem_wr | mem2RF | brn | halt =>
                    control_state<= fetch;
                when others =>
                    control_state<= unknown;
            end case;
        end if;
    end if;                                    
end process;

--control_state_out <= "0000" when control_state=fetch else
--                     "0001" when control_state=decode else
--                     "0010" when control_state=arith else
--                     "0011" when control_state=addr else
--                     "0100" when control_state=brn else
--                     "0101" when control_state=halt else
--                     "0110" when control_state=res2RF else
--                     "0111" when control_state=mem_wr else
--                     "1000" when control_state=mem_rd else
--                     "1001" when control_state=mem2RF else
--                     "1010" when control_state=shift else
--                     "1011" when control_state=reg_read else
--                     "1111" when control_state=unknown;                    

control_state_out <= control_state;
               
end architecture seq;
 