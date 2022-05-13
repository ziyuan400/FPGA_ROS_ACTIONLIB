----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/23/2022 10:17:59 PM
-- Design Name: 
-- Module Name: mux_tb - Behavioral
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
entity mux_tb is
--  Port ( );
  generic(
        BITS    : integer := 8;
        WAY    : integer := 8);
end mux_tb;

architecture Behavioral of mux_tb is
component MUX is
  generic(
        BITS    : integer := 8;
        WAY    : integer := 8);
  Port (
      input : in std_logic_vector(BITS*WAY-1 downto 0);
      output : out std_logic_vector(BITS-1 downto 0);
      sel : in std_logic_vector(abs(integer(ceil(log2(real(WAY))))-1) downto 0) 
   );
end component;
  constant clock_period: time := 10 ns;
  signal input: STD_LOGIC_VECTOR (BITS*WAY-1 downto 0);
  signal o: STD_LOGIC_VECTOR (BITS-1 downto 0);
  signal s: STD_LOGIC_VECTOR (abs(integer(ceil(log2(real(WAY))))-1) downto 0);
  
  signal log : integer := 255;
  signal i : integer := 0;
begin

mux4: MUX generic map(BITS,WAY) port map (input,o,s);
input<=x"AABBCCDD11223344";
  clocking: process
  begin

    s<="000";
    wait for 10*clock_period;
    log <=  integer(ceil(log2(real(1))));--0
    s<="001";
    wait for 10*clock_period;
    i<= i+1;    
    log <=  integer(ceil(log2(real(2))));--1
    s<="010";
    wait for 10*clock_period;
    i<=i+1;    
    log <= integer(log2(real(3)));--2
    s<="011";
    wait for 10*clock_period;
    i<=i+1;    
    log <= integer(log2(real(4)));--2
    s<="100";
    wait for 10*clock_period;
    i<=i+1;    
    log <= integer(ceil(log2(real(5))));
    s<="101";
    wait for 10*clock_period;
    i<=i+1;    
    log <= integer(ceil(log2(real(6))));
    s<="110";
    wait for 10*clock_period;
    i<=i+1;    
    log <= integer(ceil(log2(real(7))));
    s<="111";
    wait for 10*clock_period;
    i<=i+1;    
    log <= integer(ceil(log2(real(8))));
    wait;
  end process;
end Behavioral;



























