----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/01/2022 12:03:10 AM
-- Design Name: 
-- Module Name: index_to_number - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.util.all;
entity onehot_to_number is
  generic (
    WIDTH: integer := 8
  );
  Port (
    i: in std_logic_vector(WIDTH-1 downto 0);
    o: out std_logic_vector(log(WIDTH)-1 downto 0)
   );
end onehot_to_number;

architecture Structural of onehot_to_number is
    constant LOG: integer := log(WIDTH);
    constant MAX: integer := 2**LOG;
    signal selection: std_logic_vector(MAX-1 downto 0);
    signal position: std_logic_vector(MAX-1 downto 0);
    signal fill : std_logic_vector(MAX-1 downto 0):=(others =>'0');
begin
 indexing: if WIDTH > 2 and WIDTH = MAX  generate
    tree:    for j in MAX/2-1 downto 1 generate
        selection(j) <= '1'  when  selection (2 * j) = '1' else
                        '1'  when  selection (2 * j + 1) = '1'  else  '0';   
        position(j)  <=  position(j-1) when selection(j) = '0' else
                        '0'  when  selection(j) = '1' and selection (2 * j) = '1' else
                        '1'  when  selection(j) = '1' and selection (2 * j + 1) = '1'  else  'X';   
    end generate;
    leaf:    for j in MAX/2 -1 downto 0 generate
        selection(j + MAX/2) <=   '1'    when i(2 * j) = '1' else
                                  '1'    when i(2 * j + 1) = '1' else '0'; 
        position(j + MAX/2)  <=   position(j-1+MAX/2) when selection(j + MAX/2) = '0' else
                                  '0'    when i(2 * j) = '1' else
                                  '1'    when i(2 * j + 1) = '1' else '0';   
    end generate;
    result:    for j in LOG downto 1 generate
        o(LOG-j) <= position(2**j-1);
    end generate;
    
 end generate;  
 indexing_with_fill: if WIDTH > 2 and  WIDTH < MAX generate
    fill(WIDTH-1 downto 0) <= i(WIDTH-1 downto 0);
    tree:    for j in MAX/2-1 downto 1 generate
        selection(j) <= '1'  when  selection (2 * j) = '1' else
                        '1'  when  selection (2 * j + 1) = '1'  else  '0';   
        position(j)  <=  position(j-1) when selection(j) = '0' else
                        '0'  when  selection(j) = '1' and selection (2 * j) = '1' else
                        '1'  when  selection(j) = '1' and selection (2 * j + 1) = '1'  else  'X';   
    end generate;
    leaf:    for j in MAX/2 -1 downto 0 generate
        selection(j + MAX/2) <=   '1'    when fill(2 * j) = '1' else
                                  '1'    when fill(2 * j + 1) = '1' else '0'; 
        position(j + MAX/2)  <=   position(j-1+MAX/2) when selection(j + MAX/2) = '0' else
                                  '0'    when fill(2 * j) = '1' else
                                  '1'    when fill(2 * j + 1) = '1' else '0';   
    end generate;
    result:    for j in LOG downto 1 generate
        o(LOG-j) <= position(2**j-1);
    end generate;
    
 end generate;  
 
 x01from10: if WIDTH  = 2 generate   
        o  <=   "0" when i(0) = '1' else
                "1" when i(1) = '1' else
                "0";       
 end generate; 
 pass: if WIDTH  = 1 generate   
        o  <=   i;     
 end generate; 

end Structural;
