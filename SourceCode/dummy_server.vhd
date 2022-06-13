----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/09/2022 12:13:30 PM
-- Design Name: 
-- Module Name: dummy_server - Behavioral
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

entity dummy_server is
generic (
        BITS    : integer := 8;
        IPID    : integer := 0
        );
Port (  
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        
        status: in std_logic_vector(3 downto 0);  
        setAccepted: out std_logic;
        setRejected: out std_logic;
        setSucceeded: out std_logic;
        setAborted: out std_logic;
        setCanceled: out std_logic;           
        axis_in: in AXIS;
        axis_out: out AXIS
     );
end dummy_server;

architecture Behavioral of dummy_server is

begin


end Behavioral;
