library IEEE;
        use ieee.std_logic_1164.all;
        use IEEE.STD_LOGIC_UNSIGNED.ALL;
        use ieee.numeric_std.all;

entity reg_file is
port (read_addr1: in std_logic_vector(3 downto 0);
      data_out1: out std_logic_vector(31 downto 0);
      read_addr2: in std_logic_vector(3 downto 0);
      data_out2: out std_logic_vector(31 downto 0);
      
      write_addr_input: in std_logic_vector(3 downto 0);
      write_input_data: in std_logic_vector(31 downto 0);
      write_enable: in std_logic;
      
      pc_data_in: in std_logic_vector(31 downto 0);
      pc_data_out: out std_logic_vector(31 downto 0);
      pc_we: in std_logic
      );
end entity reg_file;

architecture comb of reg_file is

type register_file_type is array(0 to 15) of std_logic_vector(31 downto 0);
signal reg: register_file_type; 

signal pc: std_logic_vector(31 downto 0):= "00000000000000000000000000000000";

begin
data_out1<=reg(to_integer(unsigned(read_addr1)));
data_out2<=reg(to_integer(unsigned(read_addr2)));

reg(to_integer(unsigned(write_addr_input)))<=write_input_data when write_enable='1'; --else
                 --               reg(to_integer(unsigned(write_addr_input)));
                
pc<=pc_data_in when pc_we='1' else
    pc;

pc_data_out<=pc;                                  

end architecture comb;

