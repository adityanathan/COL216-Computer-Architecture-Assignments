library IEEE;
        use ieee.std_logic_1164.all;
        use IEEE.STD_LOGIC_UNSIGNED.ALL;
        use ieee.numeric_std.all;

entity test_bench is
    
end entity;

architecture instantiate of test_bench is
signal clock: std_logic:='0';
signal reset: std_logic:='0';
signal instruction: std_logic_vector(31 downto 0):= "00000000000000000000000000000000";
signal data_in: std_logic_vector(31 downto 0);
signal prog_address: std_logic_vector(31 downto 0):= "00000000000000000000000000000000";
signal data_address: std_logic_vector(31 downto 0):="00000000000000000000000000000000";
signal data_out: std_logic_vector(31 downto 0):= "00000000000000000000000000000000";
signal write_enable: std_logic:='0';


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
    reset=>reset,
    instruction=>instruction,
    data_in=>data_in,
    prog_address=>prog_address,
    data_address=>data_address,
    data_out=>data_out,
    write_enable=>write_enable
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
    
    process
    begin
    reset <= '1' after 1 ns,
             '0' after 101 ns;
    wait;
    end process;
    
    process
    begin
    wait for 100 ns;
    clock<=not clock;
    end process;
end architecture instantiate;