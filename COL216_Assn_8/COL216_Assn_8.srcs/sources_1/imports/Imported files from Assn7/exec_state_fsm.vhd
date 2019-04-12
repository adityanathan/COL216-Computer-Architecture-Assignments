library IEEE;
        use ieee.std_logic_1164.all;
        use IEEE.STD_LOGIC_UNSIGNED.ALL;
        use ieee.numeric_std.all;
        use work.control_state_pack.all;
        use work.inst_pack.all;
        
entity exec_state_fsm is
port( 
--      led: out std_logic_vector(15 downto 0);
--      slide_switches: in std_logic_vector(12 downto 0);
--      prog_select_s: in std_logic_vector(2 downto 0);
      control_state_in: in control_state_type;
      exec_state_out: out exec_state_type;
      go:in std_logic;
      step: in std_logic;
      instr: in std_logic;
      reset: in std_logic;
      clock: in std_logic
);
end entity exec_state_fsm;

architecture behav of exec_state_fsm is

signal exec_state : exec_state_type;

begin

process(reset, clock)
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
                elsif instr='1' then
                    exec_state<=oneinstr;
                end if;
            when onestep =>
                exec_state<=done;
            when oneinstr =>
                if control_state_in=res2RF or control_state_in=mem_wr or control_state_in=mem2RF or control_state_in=brn or control_state_in=halt then
                    exec_state<=done;
                end if;
            when cont =>
                if control_state_in=halt then
                    exec_state<=done;
                end if;
            when done =>
                if (step='0' and go='0' and instr='0') then
                    exec_state<=initial;
                end if;
            end case;
    end if;
end process;


--exec_state_out<="000" when exec_state=initial else
--                "001" when exec_state=onestep else
--                "010" when exec_state=oneinstr else
--                "011" when exec_state=cont else
--                "100" when exec_state=done else
--                "111";
exec_state_out <= exec_state;
end architecture behav;