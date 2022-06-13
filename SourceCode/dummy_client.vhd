----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/09/2022 12:05:21 PM
-- Design Name: 
-- Module Name: dummy_client - Behavioral
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

entity dummy_client is    generic (
        BITS    : integer := 8;
        IPID    : integer := 0
    );
    Port (
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        client_state: in std_logic_vector(3 downto 0);
        send_goal: out STD_LOGIC;
        cancel_goal: out STD_LOGIC;
        receive_result_msg: out STD_LOGIC;
        axis_in: in AXIS;
        axis_out: out AXIS
    );
end dummy_client;

        

--        m_axis_tdata : out STD_LOGIC_VECTOR ( 7 downto 0 );
--        m_axis_tlast : out STD_LOGIC_VECTOR ( 0 to 0 );
--        m_axis_tready : in STD_LOGIC_VECTOR ( 0 to 0 );
--        m_axis_tvalid : out STD_LOGIC_VECTOR ( 0 to 0 );
--        s_axis_tdata : in STD_LOGIC_VECTOR ( 7 downto 0 );
--        s_axis_tlast : in STD_LOGIC_VECTOR ( 0 to 0 );
--        s_axis_tready : out STD_LOGIC_VECTOR ( 0 to 0 );
--        s_axis_tvalid : in STD_LOGIC_VECTOR ( 0 to 0 )
architecture Behavioral of dummy_client is

begin


end Behavioral;
