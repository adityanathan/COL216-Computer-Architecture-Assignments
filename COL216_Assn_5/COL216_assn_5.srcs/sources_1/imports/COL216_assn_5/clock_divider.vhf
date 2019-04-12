library IEEE;
    use ieee.std_logic_1164.all;
    use IEEE.STD_LOGIC_UNSIGNED.ALL;
    use ieee.numeric_std.all;

entity clock_divider is
port( clock: in std_logic;
      slow_clock: out std_logic
--      reset: in std_logic
);
end clock_divider;

architecture behavioral of clock_divider is
signal p: integer:= 0;
signal temp: std_logic:='0';
begin

slow_clock<=temp;

process(clock)
begin
--    if reset='1' then
--        temp<='0';
    if rising_edge(clock) then 
        if p=99999 then p<=0;
        else p<=p+1;
        end if;
    end if;
    if p=0 then
        temp<=not temp;
    end if;
end process;

end architecture behavioral;