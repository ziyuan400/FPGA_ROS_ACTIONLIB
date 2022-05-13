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

entity Server is
    generic (
        CAPACITY    : integer := 8
    );
    Port (
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        -- Cancel and Status Topic
        goal: in std_logic_vector(CAPACITY -1 downto 0);
        cancel: in std_logic_vector(CAPACITY -1 downto 0);
        --The majority of these state transitions are triggered by the server implementer, using a small set of possible commands:
        setAccepted: in std_logic_vector(CAPACITY -1 downto 0);
        setRejected: in std_logic_vector(CAPACITY -1 downto 0);
        setSucceeded: in std_logic_vector(CAPACITY -1 downto 0);
        setAborted: in std_logic_vector(CAPACITY -1 downto 0);
        setCanceled: in std_logic_vector(CAPACITY -1 downto 0);
        
        server_state: out std_logic_vector(4 * CAPACITY -1 downto 0)
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
    type server_state_vector is array (0 to CAPACITY-1) of std_logic_vector(3 downto 0);
    signal state: server_state_vector:=(others=>(others=>'0')); 
begin      
    vector2array:  for i in CAPACITY-1 downto 0 generate
        server_state(i * 4 + 3 downto i * 4) <= state(i); 
    end generate;
    
    server_state_machine_vector:    for i in CAPACITY-1 downto 0 generate
        server_state_machine: process (clk)
        begin
            if(rising_edge(clk)) then             
                    if(state(i) = x"0" or state(i) = x"5" or state(i) = x"6" or state(i) = x"7" or state(i) = x"8" or state(i) = x"9") then
                        if(goal(i) = '1') then
                            state(i) <= x"1";
                            end if;    
                    elsif(state(i) = x"1") then       --1.    Pending - The goal has yet to be processed by the action server
                       if(setAccepted(i) = '1') then
                            state(i) <= x"2";             --2.    Active 
                        elsif(cancel(i) = '1') then
                            state(i) <= x"3";             --3.    Recalling
                        elsif(setRejected(i) = '1') then
                            state(i) <= x"5";             --5.    Rejected - The goal was rejected by the action server without being processed and without a request from the action client to cancel   
                        end if;      
                    elsif(state(i) = x"2") then       --2.    Active - The goal is currently being processed by the action server  
                        if(cancel(i) = '1') then
                            state(i) <= x"4";             --4.    Preempting  
                        elsif(setSucceeded(i) = '1') then 
                            state(i) <= x"6";             --6.    Succeeded - The goal was achieved successfully by the action server
                        elsif(setAborted(i) = '1') then
                            state(i) <= x"7";             --7.    Aborted - The goal was terminated by the action server without an external request from the action client to cancel
                        end if;      
                    elsif(state(i) = x"3") then       --3.    Recalling - The goal has not been processed and a cancel request has been received from the action client, but the action server has not confirmed the goal is canceled
                        if(setAccepted(i) = '1') then
                            state(i) <= x"4";             --4.    Preempting
                        elsif(setRejected(i) = '1') then
                            state(i) <= x"5";             --5.    Rejected
                        elsif(setCanceled(i) = '1') then
                            state(i) <= x"8";             --8.    Recalled  - The goal was canceled by either another goal, or a cancel request, before the action server began processing the goal
                        end if;      
                    elsif(state(i) = x"4") then       --4.    Preempting - The goal is being processed, and a cancel request has been received from the action client, but the action server has not confirmed the goal is canceled
                        if(setSucceeded(i) = '1') then
                            state(i) <= x"6";             --6.    Succeeded 
                        elsif(setAborted(i) = '1') then
                            state(i) <= x"7";             --7.    Aborted
                        elsif(setCanceled(i) = '1') then
                            state(i) <= x"9";             --9.    Preempted - Processing of the goal was canceled by either another goal, or a cancel request sent to the action server
                        end if;
                    end if;
            end if;
        end process;
    end generate;
end Behavioral;
