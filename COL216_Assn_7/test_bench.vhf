library IEEE;
        use ieee.std_logic_1164.all;
        use IEEE.STD_LOGIC_UNSIGNED.ALL;
        use ieee.numeric_std.all;
        
        
entity testbench is
port(clock: in std_logic);
end entity;

architecture behav of testbench is
signal led: std_logic_vector (15 downto 0);
signal reset: std_logic := '1' ;
begin

data_p: entity work.main(behav) port map
(      led => led,
       slide_switches => "0000000000000000",
       go => '0',
       step => '0',
       instr => '0',
       reset => reset,
       clock => clock
    );
    
process
begin

wait for 50 ns;
reset<='0';

end process;
    
end behav;
