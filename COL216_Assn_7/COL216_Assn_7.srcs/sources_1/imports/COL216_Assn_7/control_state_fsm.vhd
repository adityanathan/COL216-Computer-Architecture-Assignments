library IEEE;
        use ieee.std_logic_1164.all;
        use IEEE.STD_LOGIC_UNSIGNED.ALL;
        use ieee.numeric_std.all;
entity control_fsm is
port (reset: in std_logic;
      clock: in std_logic;
      exec_state_in: in std_logic_vector(2 downto 0);
      instr_class_in: in std_logic_vector(2 downto 0); 
      control_state_out: out std_logic_vector(3 downto 0);
      ld_bit: in std_logic
      );
end entity control_fsm;

architecture seq of control_fsm is    
type control_state_type is (unknown, fetch, decode, arith, addr, brn, halt, res2RF, mem_wr, mem_rd, mem2RF);
signal control_state : control_state_type := fetch;
begin

process(reset, clock)
begin
    if reset='1' then
        control_state<=fetch;
    elsif rising_edge(clock) then
        if exec_state_in="001" or exec_state_in="010" or exec_state_in="011" then
            case control_state is
                when fetch => 
                    control_state <= decode;
                when decode => 
                    if instr_class_in ="001" then
                        control_state <= arith;
                    elsif instr_class_in = "010" then
                        control_state <= addr;
                    elsif instr_class_in="011" then
                        control_state <= brn;
                    elsif instr_class_in <="100" then
                        control_state <= halt;
                    else
                        control_state <= unknown;
                    end if;
                when arith => 
                    control_state <= res2RF;
                when addr =>
                    if ld_bit='0' then
                        control_state<= mem_wr;
                    else
                        control_state<= mem_rd;
                    end if;
                when mem_rd =>
                    control_state<= mem2RF;
                when res2RF | mem_wr | mem2RF | brn | halt =>
                    control_state<= fetch;
                when others =>
                    control_state<= unknown;
            end case;
        end if;
    end if;                                    
end process;

control_state_out <= "0000" when control_state=fetch else
                     "0001" when control_state=decode else
                     "0010" when control_state=arith else
                     "0011" when control_state=addr else
                     "0100" when control_state=brn else
                     "0101" when control_state=halt else
                     "0110" when control_state=res2RF else
                     "0111" when control_state=mem_wr else
                     "1000" when control_state=mem_rd else
                     "1001" when control_state=mem2RF else
                     "1111" when control_state=unknown;                    
                     
end architecture seq;
 