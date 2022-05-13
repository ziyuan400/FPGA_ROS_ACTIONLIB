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
use IEEE.math_real.all;
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



architecture Behavioral of dummy_client is
--    signal    m_axis_tdata :  STD_LOGIC_VECTOR ( 7 downto 0 );
--    signal    m_axis_tlast :  STD_LOGIC_VECTOR ( 0 to 0 );
--    --        m_axis_tready : in STD_LOGIC_VECTOR ( 0 to 0 );
--    signal    m_axis_tvalid :  STD_LOGIC_VECTOR ( 0 to 0 ):="0";
--    --        s_axis_tdata : in STD_LOGIC_VECTOR ( 7 downto 0 );
--    --        s_axis_tlast : in STD_LOGIC_VECTOR ( 0 to 0 );
--    signal    s_axis_tready :  STD_LOGIC_VECTOR ( 0 to 0 );
--    --        s_axis_tvalid : in STD_LOGIC_VECTOR ( 0 to 0 )
begin
--    axis_out(0) <= m_axis_tvalid & s_axis_tready & m_axis_tlast & m_axis_tdata;
--    request: process(clk)
--        variable r: real;
--        variable seed: integer:= 999;
--    begin
--        if(rising_edge(clk)) then
--            if(m_axis_tlast(0) = '1') then
--                m_axis_tvalid(0) <= '0';
--                m_axis_tlast(0) <= '0';
--                seed := seed + 1;
--            elsif(m_axis_tvalid(0) = '0') then
--                m_axis_tvalid(0) <= '1';
--                uniform(seed,IPID, r);
--                m_axis_tdata <= std_logic_vector(CEIL(r*256));
--            elsif(axis_in(0)(9) = '1' and m_axis_tvalid(0) = '1') then
--                m_axis_tlast(0) <= '1';
--            end if;
--        end if;

--    end process;
end Behavioral;
