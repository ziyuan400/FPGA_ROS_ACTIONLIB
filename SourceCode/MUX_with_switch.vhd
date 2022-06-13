----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/28/2022 12:57:19 AM
-- Design Name: 
-- Module Name: MUX_with_switch - Behavioral
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
entity MUX_with_switch is  generic(
        BITS    : integer := 8;
        WAY    : integer := 8);
    Port (
        input : in std_logic_vector(BITS*WAY-1 downto 0);
        output : out std_logic_vector(BITS-1 downto 0);
        sel : in std_logic_vector(log(WAY)-1 downto 0);
        turn_on: in std_logic
    );
end MUX_with_switch;

architecture Behavioral of MUX_with_switch is
    component MUX generic(
            BITS    : integer := 8;
            WAY    : integer := 8);
        Port (
            input : in std_logic_vector(BITS*WAY-1 downto 0);
            output : out std_logic_vector(BITS-1 downto 0);
            sel : in std_logic_vector(log(WAY)-1 downto 0)
        );
    end component;
    signal mux_out : std_logic_vector(BITS-1 downto 0);
begin
    MUXo: MUX generic map(BITS, WAY) port map(input, mux_out, sel);
    output <= mux_out when turn_on = '1' else
              (others=>'0');
end Behavioral;
