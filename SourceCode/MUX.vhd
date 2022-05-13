----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/21/2022 01:29:03 AM
-- Design Name: 
-- Module Name: MUX - Behavioral
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
use IEEE.math_real.all;
use work.util.all;

entity MUX is
  generic(
        BITS    : integer := 8;
        WAY    : integer := 8);
  Port (
      input : in std_logic_vector(BITS*WAY-1 downto 0);
      output : out std_logic_vector(BITS-1 downto 0);
      sel : in std_logic_vector(log(WAY)-1 downto 0)
   );
end MUX;
architecture Structural of MUX is
    constant LOG   : integer := log(WAY);
    constant MAX   : integer := 2 ** LOG;
    signal mid     : std_logic_vector(BITS*WAY-1 downto BITS);
begin
 Multiplexer: if WAY > 2 generate
    tree:    for i in MAX/2-1 downto 1 generate
        mid(BITS * (i + 1) - 1 downto BITS * i) <= 
                    mid(BITS * (2 * i + 1) - 1 downto BITS * 2 * i)  when  sel (LOG- integer(ceil(log2(real(i+1))))) = '0' else
                    mid(BITS * (2 * i + 2) - 1 downto BITS * (2 * i + 1))  when  sel ( LOG-integer(ceil(log2(real(i+1))))) = '1';
                    -- else                    (others => '0');   
    end generate;
    leaf:    for i in MAX/2 -1 downto 0 generate
        mid(BITS * (i + 1 + MAX/2) - 1 downto BITS * (i + MAX/2)) <=   
                     input(BITS * (i * 2 + 1) - 1 downto BITS * (i * 2))     when sel(0) = '0' else
                     input(BITS * (i * 2 + 2) - 1 downto BITS * (i * 2 + 1)) when sel(0) = '1';
                     -- else                     (others => '0');   
    end generate;
    output <= mid(BITS * 2 - 1 downto BITS);
 end generate;  
 
 two_MUX: if WAY  = 2 generate   
        output  <=   input(BITS-1 downto 0)     when sel(0) = '0' else
                     input(BITS * 2 - 1 downto BITS) when sel(0) = '1' else
                     (others => '0');       
 end generate; 
 pass: if WAY  = 1 generate   
        output  <=   input(BITS-1 downto 0);     
 end generate; 
end Structural;
