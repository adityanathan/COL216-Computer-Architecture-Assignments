library IEEE;
        use ieee.std_logic_1164.all;
        use IEEE.STD_LOGIC_UNSIGNED.ALL;
        use ieee.numeric_std.all;

entity reg_file is
port (radd1: in std_logic_vector(3 downto 0);
      out1: out std_logic_vector(31 downto 0);
      radd2: in std_logic_vector(3 downto 0);
      out2: out std_logic_vector(31 downto 0);
      
      wadd: in std_logic_vector(3 downto 0);
      in_write: in std_logic_vector(31 downto 0);
      write_enable: in std_logic;
      
      pc_in: in std_logic_vector(31 downto 0);
      pc_out: out std_logic_vector(31 downto 0);
      pc_we: in std_logic
      );
end entity reg_file;

architecture comb of reg_file is

type register_file_type is array(0 to 15) of std_logic_vector(31 downto 0);
signal reg: register_file_type; 

signal pc: std_logic_vector(31 downto 0);

begin
out1<=reg(to_integer(unsigned(radd1)));
out2<=reg(to_integer(unsigned(radd2)));

reg(to_integer(unsigned(wadd)))<=in_write when write_enable='1' else
                                reg(to_integer(unsigned(wadd)));
                
pc<=pc_in when pc_we='1' else
    pc;

pc_out<=pc;                                  

end architecture comb;

