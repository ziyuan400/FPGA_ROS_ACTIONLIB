----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/01/2022 02:25:50 AM
-- Design Name: 
-- Module Name: onehot2number_tb - Behavioral
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
entity onehot_to_number_tb is
--  Port ( );
  generic(
        WIDTH    : integer := 4;
        LOG    : integer := 2);
end onehot_to_number_tb;

architecture Behavioral of onehot_to_number_tb is

component onehot_to_number is
  generic (
    WIDTH: integer := 8;
    LOG: integer := 3
  );
  Port (
    i: in std_logic_vector(WIDTH-1  downto 0);
    o: out std_logic_vector(LOG-1  downto 0)
   );
end component;
  constant clock_period: time := 10 ns;
  signal i: STD_LOGIC_VECTOR (WIDTH-1 downto 0);
  signal o: STD_LOGIC_VECTOR (LOG-1  downto 0);
--  signal s: STD_LOGIC_VECTOR (abs(integer(ceil(log2(real(WAY))))-1) downto 0);
  
--  signal log : integer := 255;
--  signal i : integer := 0;
begin

indexing: onehot_to_number generic map(WIDTH,LOG) port map (i,o);
  clocking: process
  begin    
--    i<=x"01";     wait for 10*clock_period;
--    i<=x"02";     wait for 10*clock_period;
--    i<=x"04";     wait for 10*clock_period;
--    i<=x"08";     wait for 10*clock_period;
--    i<=x"10";     wait for 10*clock_period;
--    i<=x"20";     wait for 10*clock_period;
--    i<=x"40";     wait for 10*clock_period;
--    i<=x"80";     wait for 10*clock_period;
    i<="0000001";     wait for 10*clock_period;
    i<="0000010";     wait for 10*clock_period;
    i<="0000100";     wait for 10*clock_period;
    i<="0001000";     wait for 10*clock_period;
    i<="0010000";     wait for 10*clock_period;
    i<="0100000";     wait for 10*clock_period;
    i<="1000000";     wait for 10*clock_period;
--    i<=x"0001";     wait for 10*clock_period;
--    i<=x"0002";     wait for 10*clock_period;
--    i<=x"0004";     wait for 10*clock_period;
--    i<=x"0008";     wait for 10*clock_period;
--    i<=x"0010";     wait for 10*clock_period;
--    i<=x"0020";     wait for 10*clock_period;
--    i<=x"0040";     wait for 10*clock_period;
--    i<=x"0080";     wait for 10*clock_period;
--    i<=x"0100";     wait for 10*clock_period;
--    i<=x"0200";     wait for 10*clock_period;
--    i<=x"0400";     wait for 10*clock_period;
--    i<=x"0800";     wait for 10*clock_period;
--    i<=x"1000";     wait for 10*clock_period;
--    i<=x"2000";     wait for 10*clock_period;
--    i<=x"4000";     wait for 10*clock_period;
--    i<=x"8000";     wait for 10*clock_period;
    wait;
  end process;
end Behavioral;