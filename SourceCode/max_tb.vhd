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
entity max_tb is
    generic(
        BITS    : integer := 8;
        WAY    : integer := 8);
end max_tb;

architecture Behavioral of max_tb is
    component min is
   -- component max is
        generic(
            BITS    : integer := 8;
            WAY    : integer := 8);
        Port (
            input : in std_logic_vector(BITS*WAY-1 downto 0);
            min : out std_logic_vector(BITS-1 downto 0);
            index : out std_logic_vector(WAY-1 downto 0)
        );
    end component;
    constant clock_period: time := 10 ns;
    signal input: STD_LOGIC_VECTOR (BITS*WAY-1 downto 0);
    signal o: STD_LOGIC_VECTOR (BITS-1 downto 0);
    signal n: STD_LOGIC_VECTOR (WAY-1 downto 0);
begin
    max8: min generic map(BITS,WAY) port map (input,o,n);
    clocking: process
    begin
        input<=x"AA07CCDD11223344"; wait for 10*clock_period;
        input<=x"AABBCC6611223344"; wait for 10*clock_period;
        input<=x"AABBE41111223344"; wait for 10*clock_period;
        input<=x"AA770587112233D8"; wait for 10*clock_period;
        input<=x"AABBCC331122E344"; wait for 10*clock_period;
        input<=x"1122334455067788"; wait for 10*clock_period;
        input<=x"1122334499667788"; wait for 10*clock_period;
        input<=x"7981357945587896"; wait for 10*clock_period;
--        input<=x"1234567"; wait for 10*clock_period;
--        input<=x"7654321"; wait for 10*clock_period;
--        input<=x"1573925"; wait for 10*clock_period;
--        input<=x"7496482"; wait for 10*clock_period;
--        input<=x"48"; wait for 10*clock_period;
        wait;
    end process;
end Behavioral;



























