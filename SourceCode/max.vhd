----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/01/2022 03:49:02 PM
-- Design Name: 
-- Module Name: max - Behavioral
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
use IEEE.NUMERIC_STD.ALL;
use work.util.all;

entity max is
    generic(
        BITS    : integer := 8;
        WAY    : integer := 8);
    Port (
        input : in std_logic_vector(BITS*WAY-1 downto 0);
        max : out std_logic_vector(BITS-1 downto 0);
        index : out std_logic_vector(WAY-1 downto 0)
    );
end max;
architecture Structural of max is
    constant LOG   : integer := log(WAY);
    constant MAX_WAY   : integer := 2**LOG;
    signal mid     : std_logic_vector(BITS*MAX_WAY-1 downto BITS);
    signal race     : std_logic_vector(MAX_WAY-1 downto 1);
    Signal round_result: std_logic_vector(MAX_WAY * LOG - 1 downto 0);
    Signal final_result: std_logic_vector(MAX_WAY * LOG - 1 downto 0);
    Signal fill: std_logic_vector(MAX_WAY * BITS - 1 downto 0) := (others=>'0');
    
    --    Signal round_result_dbg: std_logic_vector(MAX_WAY * LOG - 1 downto 0) := (others=>'0');
    --    Signal final_result_dbg: std_logic_vector(MAX_WAY * LOG - 1 downto 0) := (others=>'0');
    function rs(n : natural) return natural is
        variable match, scale, shift, result_start, result_shift : natural;
    begin
        shift := n / LOG;
        scale := n mod LOG;

        result_shift := shift / 2 ** (scale+1);
        result_start := 2 ** (LOG-1-scale);

        match := result_shift + result_start;
        return match;
    end function;

    -- index = [i // r // 2 ** (i % r + 1) + 2 **( r-1- i % r) for i in range(r * w) ] #python code to test
    -- [2, 1, 2, 1, 3, 1, 3, 1] for r=2,w=4
    -- [4, 2, 1, 4, 2, 1, 5, 2, 1, 5, 2, 1, 6, 3, 1, 6, 3, 1, 7, 3, 1, 7, 3, 1] for r=3,w=8

    function rs_not(n : natural) return std_logic is
        variable scale, shift : natural;
    begin
        shift := n / LOG;
        scale := n mod LOG;

        if (shift mod (2 ** (scale+1)) < 2 ** scale) then
            return '1';
        else
            return '0';
        end if;
    end function;

    -- not_it = [not (i // r) % 2 ** (i % r + 1) < 2 **( i % r) for i in range(r * w) ] #python code to test
    -- [False, False, False, True, False, False, False, True, False, True, True, False, False, False, True, True, 
    -- False, True, False, True, True, True, True, True] for r=3,w=8
begin
 max_of_list: if WAY > 2 and MAX_WAY = WAY generate
    tree:    for i in MAX_WAY/2-1 downto 1 generate
        mid(BITS * (i + 1) - 1 downto BITS * i) <= 
                    mid(BITS * (2 * i + 1) - 1 downto BITS * 2 * i)  
                        when unsigned(mid(BITS * (i * 2 + 1) - 1 downto BITS * (i * 2))) 
                           > unsigned(mid(BITS * (i * 2 + 2) - 1 downto BITS * (i * 2 + 1))) 
                        else
                    mid(BITS * (2 * i + 2) - 1 downto BITS * (2 * i + 1)); 
        race(i) <= '0' when unsigned(mid(BITS * (i * 2 + 1) - 1 downto BITS * (i * 2))) 
                        > unsigned(mid(BITS * (i * 2 + 2) - 1 downto BITS * (i * 2 + 1))) else
                    '1';
    end generate;
    leaf:    for i in MAX_WAY/2 -1 downto 0 generate
        mid(BITS * (i + 1 + MAX_WAY/2) - 1 downto BITS * (i + MAX_WAY/2))
                     <=   
                        input(BITS * (i * 2 + 1) - 1 downto BITS * (i * 2))  
                     when unsigned(input(BITS * (i * 2 + 1) - 1 downto BITS * (i * 2))) 
                        > unsigned(input(BITS * (i * 2 + 2) - 1 downto BITS * (i * 2 + 1)))
                     else
                        input(BITS * (i * 2 + 2) - 1 downto BITS * (i * 2 + 1));
         race(i+MAX_WAY/2) <= '0' when unsigned(input(BITS * (i * 2 + 1) - 1 downto BITS * (i * 2))) 
                        > unsigned(input(BITS * (i * 2 + 2) - 1 downto BITS * (i * 2 + 1))) else
                    '1';
    end generate;
    
    winner_vector: for i in MAX_WAY * LOG - 1 downto 0 generate
    round_result(i) <= race(rs(i)) xor rs_not(i);
    end generate;
    
--    final_result(MAX_WAY - 1 downto 0) <=  round_result(MAX_WAY - 1 downto 0);
--    final_vector: for i in LOG - 1 downto 1 generate                
--        final_result(MAX_WAY * (i + 1) - 1 downto MAX_WAY * i)
--                     <= final_result(MAX_WAY * i - 1 downto MAX_WAY * (i - 1)) and 
--                        round_result(MAX_WAY * (i + 1) - 1 downto MAX_WAY * i);   
--    end generate;

--    dbg_o: for i in LOG - 1 downto 0 generate        
--        dbg: for j in MAX_WAY - 1 downto 0 generate
--            final_result_dbg(MAX_WAY*i+j) <= final_result(LOG*j+i);
--            round_result_dbg(MAX_WAY*i+j) <= round_result(LOG*j+i);
--        end generate;
--    end generate;  
    
    final_vector_ini: for i in MAX_WAY - 1 downto 0 generate        
        final_result(LOG*i) <= round_result(LOG*i);
    end generate;
    final_vector: for i in LOG - 1 downto 1 generate        
        final_vector_t: for j in MAX_WAY - 1 downto 0 generate
            final_result(LOG*j+i) <= final_result(LOG*j+i-1) and round_result(LOG*j+i);
        end generate;
    end generate;  
    
    final_vector_res: for i in MAX_WAY - 1 downto 0 generate        
        index(i) <= final_result(LOG*(i+1)-1);
    end generate;
    max <= mid(BITS * 2 - 1 downto BITS);
    --index <= final_result(MAX_WAY * LOG - 1 downto MAX_WAY * (LOG-1));
 end generate;  
 
  fill_and_max: if WAY > 2 and MAX_WAY > WAY generate
    fill(BITS*WAY-1 downto 0) <= input(BITS*WAY-1 downto 0);
    tree:    for i in MAX_WAY/2-1 downto 1 generate
        mid(BITS * (i + 1) - 1 downto BITS * i) <= 
                    mid(BITS * (2 * i + 1) - 1 downto BITS * 2 * i)  
                        when unsigned(mid(BITS * (i * 2 + 1) - 1 downto BITS * (i * 2))) 
                           > unsigned(mid(BITS * (i * 2 + 2) - 1 downto BITS * (i * 2 + 1))) 
                        else
                    mid(BITS * (2 * i + 2) - 1 downto BITS * (2 * i + 1)); 
        race(i) <= '0' when unsigned(mid(BITS * (i * 2 + 1) - 1 downto BITS * (i * 2))) 
                        > unsigned(mid(BITS * (i * 2 + 2) - 1 downto BITS * (i * 2 + 1))) else
                    '1';
    end generate;
    leaf:    for i in MAX_WAY/2 -1 downto 0 generate
        mid(BITS * (i + 1 + MAX_WAY/2) - 1 downto BITS * (i + MAX_WAY/2))
                     <=   
                        fill(BITS * (i * 2 + 1) - 1 downto BITS * (i * 2))  
                     when unsigned(fill(BITS * (i * 2 + 1) - 1 downto BITS * (i * 2))) 
                        > unsigned(fill(BITS * (i * 2 + 2) - 1 downto BITS * (i * 2 + 1)))
                     else
                        fill(BITS * (i * 2 + 2) - 1 downto BITS * (i * 2 + 1));
         race(i+MAX_WAY/2) <= '0' when unsigned(fill(BITS * (i * 2 + 1) - 1 downto BITS * (i * 2))) 
                        > unsigned(fill(BITS * (i * 2 + 2) - 1 downto BITS * (i * 2 + 1))) else
                    '1';
    end generate;    
    winner_vector: for i in MAX_WAY * LOG - 1 downto 0 generate
    round_result(i) <= race(rs(i)) xor rs_not(i);
    end generate;
    final_vector_ini: for i in MAX_WAY - 1 downto 0 generate        
        final_result(LOG*i) <= round_result(LOG*i);
    end generate;
    final_vector: for i in LOG - 1 downto 1 generate        
        final_vector_t: for j in MAX_WAY - 1 downto 0 generate
            final_result(LOG*j+i) <= final_result(LOG*j+i-1) and round_result(LOG*j+i);
        end generate;
    end generate;  
    
    final_vector_res: for i in WAY - 1 downto 0 generate        
        index(i) <= final_result(LOG*(i+1)-1);
    end generate;
    max <= mid(BITS * 2 - 1 downto BITS);
 end generate;  
 
 max_of_two: if WAY  = 2 generate   
        max  <=   input(BITS-1 downto 0)     when unsigned(input(BITS-1 downto 0) ) > unsigned(input(BITS * 2 - 1 downto BITS) ) else
                  input(BITS * 2 - 1 downto BITS);
        index  <=   "01"    when unsigned(input(BITS-1 downto 0) ) > unsigned(input(BITS * 2 - 1 downto BITS) ) else
                    "10";
 end generate; 
 pass: if WAY  = 1 generate   
        max  <=   input(BITS-1 downto 0);  
        index(0)  <=   '1'; 
 end generate; 
end Structural;
