library IEEE;
        use ieee.std_logic_1164.all;
        use IEEE.STD_LOGIC_UNSIGNED.ALL;
        use ieee.numeric_std.all;

entity test_bench is
port( led: out std_logic_vector(15 downto 0);
      slide_switches: in std_logic_vector(12 downto 0);
      prog_select_s: in std_logic_vector(2 downto 0);
      go_s:in std_logic;
      step_s: in std_logic;
      reset_s: in std_logic;
      clock: in std_logic
    
    
    );
end test_bench;

architecture instantiate of test_bench is
--signal clock: std_logic:='0';
signal reset: std_logic:='0';
signal instruction: std_logic_vector(31 downto 0):= "00000000000000000000000000000000";
signal data_in: std_logic_vector(31 downto 0);
signal prog_address: std_logic_vector(31 downto 0):= "00000000000000000000000000000000";
signal data_address: std_logic_vector(31 downto 0):="00000000000000000000000000000000";
signal data_out: std_logic_vector(31 downto 0):= "00000000000000000000000000000000";
signal write_enable: std_logic:='0';
signal go_dummy: std_logic:='0';
signal step_dummy: std_logic:='0';
--signal prog_select_dummy: std_logic_vector(2 downto 0):="000";
signal reset_dummy: std_logic;
signal i_dec_display: std_logic_vector(3 downto 0);
signal instr_class_display: std_logic_vector(2 downto 0);
signal reg3_disp: std_logic_vector(31 downto 0);

COMPONENT rom_program_memory
  PORT (
    a : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    spo : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
END COMPONENT;

COMPONENT ram_data_memory
  PORT (
    a : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    d : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    clk : IN STD_LOGIC;
    we : IN STD_LOGIC;
    spo : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
END COMPONENT;

begin


cpu: entity work.processor(behavioral) port map(
    clock=>clock,
    reset=>reset_dummy,
    instruction=>instruction,
    data_in=>data_in,
    prog_address=>prog_address,
    data_address=>data_address,
    data_out=>data_out,
    write_enable=>write_enable,
    step=>step_dummy,
    go=>go_dummy,
    prog_select=>prog_select_s,
    i_dec_out=>i_dec_display,
    instr_class_out=>instr_class_display,
    reg3_out=>reg3_disp
    );
    
program_memory: rom_program_memory port map(
    a => prog_address(7 downto 0),
    spo=>instruction
    );
    
data_memory: ram_data_memory port map(
    a => data_address(7 downto 0),
    d => data_out,
    clk => clock,
    we => write_enable,
    spo => data_in
    );
    
    
debounce1: entity work.debouncer(behavioral) port map(
      clock=>clock,
      bounce=>go_s,
      debounce=>go_dummy
--      reset=>reset_s
      );
      
debounce2: entity work.debouncer(behavioral) port map(
            clock=>clock,
            bounce=>step_s,
            debounce=>step_dummy
--            reset=>reset_s
            );
            
debounce3: entity work.debouncer(behavioral) port map(
                  clock=>clock,
                  bounce=>reset_s,
                  debounce=>reset_dummy
--                  reset=>reset_s
                  );
    --SIMULATION CODE
--    process
--    begin
--    reset <= '1' after 1 ns,
--             '0' after 101 ns;
--    wait;
--    end process;
    
--    process
--    begin
--    wait for 100 ns;
--    clock<=not clock;
--    end process;




---DISPLAY CIRCUIT
led<=instruction(31 downto 16) when slide_switches="000000000000" else
     instruction(15 downto 0) when slide_switches="000000000001" else
     prog_address(31 downto 16) when slide_switches="000000000010" else
     prog_address(15 downto 0) when slide_switches="000000000011" else
     data_in(31 downto 16) when slide_switches="000000000100" else
     data_in(15 downto 0) when slide_switches="000000000101" else
     data_out(31 downto 16) when slide_switches="000000001000" else
     data_out(15 downto 0) when slide_switches="000000001001" else
     data_address(31 downto 16) when slide_switches="000000010000" else
     data_address(15 downto 0) when slide_switches="000000010001" else
     instr_class_display & "000000000" & i_dec_display when slide_switches="000000100000" else
     reg3_disp(31 downto 16) when slide_switches="100000000000" else
     reg3_disp(15 downto 0) when slide_switches="100000000001" else
     "1111111111111111";

end architecture instantiate;