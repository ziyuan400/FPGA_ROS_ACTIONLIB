----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/22/2022 12:23:37 AM
-- Design Name: 
-- Module Name: Server - Behavioral
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
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;


entity Server is
    Port (
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        -- Cancel and Status Topic
        goalRequest: in STD_LOGIC;
        cancelRequest: in STD_LOGIC;
        status: out std_logic_vector(3 downto 0);
        --The majority of these state transitions are triggered by the server implementer, using a small set of possible commands:
        setAccepted: in std_logic;
        setRejected: in std_logic;
        setSucceeded: in std_logic;
        setAborted: in std_logic;
        setCanceled: in std_logic
     );
end Server;

architecture Behavioral of Server is
    --State machine adapted from http://wiki.ros.org/actionlib/DetailedDescription
    --0.    init
    --1.    Pending - The goal has yet to be processed by the action server
    --2.    Active - The goal is currently being processed by the action server
    --3.    Recalling - The goal has not been processed and a cancel request has been received from the action client, but the action server has not confirmed the goal is canceled
    --4.    Preempting - The goal is being processed, and a cancel request has been received from the action client, but the action server has not confirmed the goal is canceled
    --Terminal States
    --5.    Rejected - The goal was rejected by the action server without being processed and without a request from the action client to cancel
    --6.    Succeeded - The goal was achieved successfully by the action server
    --7.    Aborted - The goal was terminated by the action server without an external request from the action client to cancel
    --8.    Recalled - The goal was canceled by either another goal, or a cancel request, before the action server began processing the goal
    --9.    Preempted - Processing of the goal was canceled by either another goal, or a cancel request sent to the action server
    signal server_state: std_logic_vector(3 downto 0):=x"0";   
begin
    
    --Once a goal(with its state)reaches its terminal state, it stucks their forever.
    --Server can serve only one goal in his entire life for now. 
    --In SW, multiple goals can be served in a list.    
    
    status <= server_state;
    server_state_machine: process (clk)
    begin
        if(rising_edge(clk)) then
            if(server_state = x"0") then
                if(goalRequest = '1') then
                    server_state <= x"1";
                    end if;    
            elsif(server_state = x"1") then       --1.    Pending - The goal has yet to be processed by the action server
               if(setAccepted = '1') then
                    server_state <= x"2";             --2.    Active 
                elsif(cancelRequest = '1') then
                    server_state <= x"3";             --3.    Recalling
                elsif(setRejected = '1') then
                    server_state <= x"5";             --5.    Rejected - The goal was rejected by the action server without being processed and without a request from the action client to cancel   
                end if;      
            elsif(server_state = x"2") then       --2.    Active - The goal is currently being processed by the action server  
                if(cancelRequest = '1') then
                    server_state <= x"4";             --4.    Preempting  
                elsif(setSucceeded = '1') then 
                    server_state <= x"6";             --6.    Succeeded - The goal was achieved successfully by the action server
                elsif(setAborted = '1') then
                    server_state <= x"7";             --7.    Aborted - The goal was terminated by the action server without an external request from the action client to cancel
                end if;      
            elsif(server_state = x"3") then       --3.    Recalling - The goal has not been processed and a cancel request has been received from the action client, but the action server has not confirmed the goal is canceled
                if(setAccepted = '1') then
                    server_state <= x"4";             --4.    Preempting
                elsif(setRejected = '1') then
                    server_state <= x"5";             --5.    Rejected
                elsif(setCanceled = '1') then
                    server_state <= x"8";             --8.    Recalled  - The goal was canceled by either another goal, or a cancel request, before the action server began processing the goal
                end if;      
            elsif(server_state = x"4") then       --4.    Preempting - The goal is being processed, and a cancel request has been received from the action client, but the action server has not confirmed the goal is canceled
                if(setSucceeded = '1') then
                    server_state <= x"6";             --6.    Succeeded 
                elsif(setAborted = '1') then
                    server_state <= x"7";             --7.    Aborted
                elsif(setCanceled = '1') then
                    server_state <= x"9";             --9.    Preempted - Processing of the goal was canceled by either another goal, or a cancel request sent to the action server
                end if;   
            end if;
        end if;   
    end process;    
    
end Behavioral;
