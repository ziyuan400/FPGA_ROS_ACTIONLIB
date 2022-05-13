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
use ieee.std_logic_unsigned.all;
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
--    signal    m_axis_tdata :  STD_LOGIC_VECTOR ( 7 downto 0 );
--    signal    m_axis_tlast :  STD_LOGIC_VECTOR ( 0 to 0 );
--    --        m_axis_tready : in STD_LOGIC_VECTOR ( 0 to 0 );
--    signal    m_axis_tvalid :  STD_LOGIC_VECTOR ( 0 to 0 ):="0";
--    --        s_axis_tdata : in STD_LOGIC_VECTOR ( 7 downto 0 );
--    --        s_axis_tlast : in STD_LOGIC_VECTOR ( 0 to 0 );
--    signal    s_axis_tready :  STD_LOGIC_VECTOR ( 0 to 0 );
--    --        s_axis_tvalid : in STD_LOGIC_VECTOR ( 0 to 0 )
--    signal sum:     STD_LOGIC_VECTOR ( 31 downto 0 ):=(others=>'0');
begin
--    axis_out(0)(9) <= '1';
--    add: process(clk)
--    begin
--        if(rising_edge(clk)) then
--            if(axis_in(0)(8) = '1') then
--                sum <= sum + axis_in(0)(7 downto 0 );
--            end if;
--        end if;
--    end process;
end Behavioral;
