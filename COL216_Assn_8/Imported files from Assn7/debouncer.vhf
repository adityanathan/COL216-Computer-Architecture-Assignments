library IEEE;
    use ieee.std_logic_1164.all;
    use IEEE.STD_LOGIC_UNSIGNED.ALL;
    use ieee.numeric_std.all;
    
entity debouncer is 
port( clock: in std_logic;
      bounce: in std_logic;
      debounce: out std_logic
--      reset: in std_logic
);
end entity;

architecture behavioral of debouncer is 
signal clock_100hz: std_logic;

begin

clock_div: entity work.clock_divider(behavioral) port map(
    clock=>clock,
    slow_clock=>clock_100hz
    );
    
    
process(clock_100hz)
begin
    if rising_edge(clock_100hz) then 
    debounce<=bounce;
    end if;
end process;

end architecture behavioral;