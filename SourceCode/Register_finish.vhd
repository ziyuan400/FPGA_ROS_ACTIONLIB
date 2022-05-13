----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/28/2022 04:10:00 AM
-- Design Name: 
-- Module Name: Register_1bit - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Register_finish is
    generic(
        WIDTH: integer:=8
        );
    Port ( 
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        reg: out std_logic_vector(WIDTH-1 downto 0);
        active: in std_logic_vector(WIDTH-1 downto 0);
        finish: in std_logic_vector(WIDTH-1 downto 0)
    );
end Register_finish;

architecture Behavioral of Register_finish is
begin
    Signal_registers: for i in WIDTH-1 downto 0 generate
        Reqest_finish_register: process(clk)
        begin
            if(rising_edge(clk)) then
                if(active(i) = '0') then
                    reg(i) <= '0';
                elsif(finish(i) = '1') then
                    reg(i) <= '1';
                end if;
            end if;
        end process;
    end generate;

end Behavioral;
