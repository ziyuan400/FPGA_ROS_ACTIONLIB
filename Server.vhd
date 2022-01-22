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
        cancel: in STD_LOGIC;
        status: out std_logic_vector(3 downto 0);  
        
        -- Msg defined in Fibonacci.action
        -- Goal Topic {int32 order }
        goal_order: in std_logic_vector(31 downto 0);
    
        -- Feedback Topic {int32[] sequence }
        feedback_sequence: out std_logic_vector(31 downto 0);
    
        -- Result Topic {int32[] sequence }
        result_sequence: out std_logic_vector(31 downto 0)
    
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
    signal server_state: std_logic_vector(3 downto 0):="0000";
        
    --The majority of these state transitions are triggered by the server implementer, using a small set of possible commands:
    signal setAccepted: std_logic:='0';
    signal setRejected: std_logic:='0';
    signal setSucceeded: std_logic:='0';
    signal setAborted: std_logic:='0';
    signal setCanceled: std_logic:='0';
    
    --The action client can also asynchronously trigger state transitions:
    signal CancelRequest: std_logic:='0';
    signal GoalRequest: std_logic:='0';
    
    
    --Function Fibonacci
    signal order: std_logic_vector(7 downto 0):= (others=>'0');
    signal swap_count: std_logic_vector(1 downto 0):= (others=>'0');
    signal first: std_logic_vector(31 downto 0):= (others=>'0');
    signal second: std_logic_vector(31 downto 0):= (others=>'0');
    signal third: std_logic_vector(31 downto 0):= (others=>'0');
    
begin
    
    CancelRequest <= cancel;
    GoalRequest <= '1' when goal_order > 0;
    setAccepted <= '1' when goal_order > 0 and goal_order < 30;
    setRejected <= '1' when goal_order > 0 and goal_order >= 30;
    
    server_state_machine: process (clk)
    begin
        if(rising_edge(clk)) then
            if(server_state = "0000") then
                if(GoalRequest = '1') then
                    server_state <= "0001";
                    end if;    
            elsif(server_state = "0001") then       --1.    Pending - The goal has yet to be processed by the action server
               if(setAccepted = '1') then
                    server_state <= "0010";             --2.    Active 
                elsif(CancelRequest = '1') then
                    server_state <= "0011";             --3.    Recalling
                elsif(setRejected = '1') then
                    server_state <= "0101";             --5.    Rejected - The goal was rejected by the action server without being processed and without a request from the action client to cancel   
                end if;      
            elsif(server_state = "0010") then       --2.    Active - The goal is currently being processed by the action server  
                if(CancelRequest = '1') then
                    server_state <= "0100";             --4.    Preempting  
                elsif(setSucceeded = '1') then 
                    server_state <= "0110";             --6.    Succeeded - The goal was achieved successfully by the action server
                elsif(setAborted = '1') then
                    server_state <= "0111";             --7.    Aborted - The goal was terminated by the action server without an external request from the action client to cancel
                end if;      
            elsif(server_state = "0011") then       --3.    Recalling - The goal has not been processed and a cancel request has been received from the action client, but the action server has not confirmed the goal is canceled
                if(setAccepted = '1') then
                    server_state <= "0100";             --4.    Preempting
                elsif(setRejected = '1') then
                    server_state <= "0101";             --5.    Rejected
                elsif(setCanceled = '1') then
                    server_state <= "1000";             --8.    Recalled  - The goal was canceled by either another goal, or a cancel request, before the action server began processing the goal
                end if;      
            elsif(server_state = "0100") then       --4.    Preempting - The goal is being processed, and a cancel request has been received from the action client, but the action server has not confirmed the goal is canceled
                if(setSucceeded = '1') then
                    server_state <= "0110";             --6.    Succeeded 
                elsif(setAborted = '1') then
                    server_state <= "0111";             --7.    Aborted
                elsif(setCanceled = '1') then
                    server_state <= "1001";             --9.    Preempted - Processing of the goal was canceled by either another goal, or a cancel request sent to the action server
                end if;   
            end if;
        end if;   
    end process;
    
    fibonacci: process(clk)
    begin
        if(rising_edge(clk) and server_state = 2) then
            if (swap_count = 0) then
                third <= first + second;
                swap_count <= swap_count + '1';
            elsif (swap_count = 1) then
                first <= second; 
                swap_count <= swap_count + '1';
            elsif (swap_count = 2) then
                second <= third;
                order <= order + '1';
                swap_count <= "00";
            end if;
            
        end if;
    end process;
    
end Behavioral;
