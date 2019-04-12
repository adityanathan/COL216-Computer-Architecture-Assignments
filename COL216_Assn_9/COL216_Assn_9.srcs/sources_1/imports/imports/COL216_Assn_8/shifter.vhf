library IEEE;
        use ieee.std_logic_1164.all;
        use IEEE.STD_LOGIC_UNSIGNED.ALL;
        use ieee.numeric_std.all;

entity shifter is
port ( in_data: in std_logic_vector(31 downto 0);
       out_data: out std_logic_vector(31 downto 0);
       sh_amt: in std_logic_vector(4 downto 0);
       sh_type: in std_logic_vector(1 downto 0);
       sh_c: out std_logic
     );
end entity shifter;



architecture comb of shifter is

signal out_1: std_logic_vector(31 downto 0);
signal out_2: std_logic_vector(31 downto 0);
signal out_3: std_logic_vector(31 downto 0);
signal out_4: std_logic_vector(31 downto 0);
signal out_5: std_logic_vector(31 downto 0);

begin

out_1 <= in_data(30 downto 0) & "0" when sh_type="00" and sh_amt(0)='1' else
         "0" & in_data(31 downto 1) when sh_type="01" and sh_amt(0)='1' else
         in_data(31) & in_data(31 downto 1) when sh_type="10" and sh_amt(0)='1' else
         in_data(0) & in_data(31 downto 1) when sh_type="11" and sh_amt(0)='1' else
         in_data;
         
out_2 <= out_1(29 downto 0) & "00" when sh_type="00" and sh_amt(1)='1' else
          "00" & out_1(31 downto 2) when sh_type="01" and sh_amt(1)='1' else
          out_1(31) & out_1(31) & out_1(31 downto 2) when sh_type="10" and sh_amt(1)='1' else
          out_1(0) & out_1(1) & out_1(31 downto 2) when sh_type="11" and sh_amt(1)='1' else
          out_1;
                  
out_3 <= out_2(27 downto 0) & "0000" when sh_type="00" and sh_amt(2)='1' else
           "0000" & out_2(31 downto 4) when sh_type="01" and sh_amt(2)='1' else
           "0000" & out_2(31 downto 4) when sh_type="10" and sh_amt(2)='1' and in_data(31) = '0' else
           "1111" & out_2(31 downto 4) when sh_type="10" and sh_amt(2)='1' and in_data(31) = '1' else
           out_2(3 downto 0) & out_2(31 downto 4) when sh_type="11" and sh_amt(2)='1' else
           out_2;
                           
         
out_4 <= out_3(23 downto 0) & "00000000" when sh_type="00" and sh_amt(3)='1' else
        "00000000" & out_3(31 downto 8) when sh_type="01" and sh_amt(3)='1' else
         "00000000" & out_3(31 downto 8) when sh_type="10" and sh_amt(3)='1' and in_data(31) = '0' else
         "11111111" & out_3(31 downto 8) when sh_type="10" and sh_amt(3)='1' and in_data(31) = '1' else
          out_3(7 downto 0) & out_3(31 downto 8) when sh_type="11" and sh_amt(3)='1' else
          out_3;

out_5 <= out_4(30 downto 0) & "0" when sh_type="00" and sh_amt(4)='1' else
         "0000000000000000" & out_4(31 downto 16) when sh_type="01" and sh_amt(4)='1' else
          "0000000000000000" & out_4(31 downto 16) when sh_type="10" and sh_amt(4)='1' and in_data(31) = '0' else
          "1111111111111111" & out_4(31 downto 16) when sh_type="10" and sh_amt(4)='1' and in_data(31) = '1' else
           out_4(15 downto 0) & out_4(31 downto 16) when sh_type="11" and sh_amt(4)='1' else
           out_4;

out_data <= out_5;                                                        

sh_c <= '0' when sh_amt = "00000" else
         in_data(to_integer(unsigned(sh_amt)) - 1) when (sh_type="01" or sh_type="10" or sh_type="11") else
         in_data(31 - to_integer(unsigned(sh_amt)));
         
end architecture comb;

