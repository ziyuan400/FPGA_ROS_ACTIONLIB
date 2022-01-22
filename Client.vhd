----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/22/2022 12:23:37 AM
-- Design Name: 
-- Module Name: Client - Behavioral
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


entity Client is
    Port (  
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        -- Cancel and Status Topic
        cancel: out STD_LOGIC;
        status: in std_logic_vector(3 downto 0);  
        
        -- Msg defined in Fibonacci.action
        -- Goal Topic {int32 order }
        goal_order: out std_logic_vector(31 downto 0);
    
        -- Feedback Topic {int32[] sequence }
        feedback_sequence: in std_logic_vector(31 downto 0);
    
        -- Result Topic {int32[] sequence }
        result_sequence: in std_logic_vector(31 downto 0)
    
     );
end Client;

architecture Behavioral of Client is
    --State machine adapted from http://wiki.ros.org/actionlib/DetailedDescription
    --In actionlib, we treat the server state machine as the primary machine, and then treat the client state machine as a secondary/coupled state machine that tries to track the server's state
    --0.    init
    --1.    Pending - The goal has yet to be processed by the action server
    --2.    Active - The goal is currently being processed by the action server
    --3.    Recalling - The goal has not been processed and a cancel request has been received from the action client, but the action server has not confirmed the goal is canceled
    --4.    Preempting - The goal is being processed, and a cancel request has been received from the action client, but the action server has not confirmed the goal is canceled
    --5.    Waiting for goal ACK
    --6.    Waiting for cancel ACK
    --7.    Waiting for result
    --8.    Done
       
    signal clinet_state: std_logic_vector(3 downto 0):="0000";
        
    --The state transitions are triggered by the server status from input and following client signals:
    signal send_goal: std_logic:='0';
    signal cancel_goal: std_logic:='0';
    signal receive_result_msg: std_logic:='0';

begin
    client_state_machine: process (clk)
    begin
        if(rising_edge(clk)) then
            if(clinet_state = "0000") then
                if(send_goal = '1') then
                    clinet_state <= "0001";
                end if;    
            elsif(clinet_state = "0101") then       --5.    Waiting for goal ACK
                if(cancel_goal = '1') then
                    clinet_state <= "0110";             --6.    Waiting for cancel ACK 
                elsif(status = "0001") then
                    clinet_state <= "0001";             --1.    Pending
                elsif(status = "0010") then
                    clinet_state <= "0010";             --2.    Active
                end if;    
            elsif(clinet_state = "0001") then       --1.    Pending - The goal has yet to be processed by the action server
               if(cancel_goal = '1') then
                    clinet_state <= "0110";             --6.    Waiting for cancel ACK  
                elsif(status = "0010") then
                    clinet_state <= "0010";                 --2.    Active
                elsif(status = "0011") then
                    clinet_state <= "0011";                 --3.    Recalling
                elsif(status = "0101") then             --5.Rejected 
                    clinet_state <= "0111";                 --7.    Waiting for result   
                end if;      
            elsif(clinet_state = "0010") then       --2.    Active - The goal is currently being processed by the action server  
                if(cancel_goal = '1') then 
                    clinet_state <= "0110";             --6.    Waiting for cancel ACK
                elsif(status = "0100") then
                    clinet_state <= "0100";             --4.    Preempting  
                elsif(status = "0110" or status = "0111") then  
                    clinet_state <= "0111";             --7.    Waiting for result
                end if;      
            elsif(clinet_state = "0110") then       --6.    Waiting for cancel ACK
                if(status = "0011") then
                    clinet_state <= "0011";             --3.    Recalling
                elsif(status = "0100") then
                    clinet_state <= "0100";             --4.    Preempting
                end if;      
            elsif(clinet_state = "0011") then       --3.    Recalling - The goal has not been processed and a cancel request has been received from the action client, but the action server has not confirmed the goal is canceled
                if(status = "0100") then
                    clinet_state <= "0100";             --4.    Preempting 
                elsif(status = "0101" or status = "1000") then
                    clinet_state <= "0111";             --7.    Waiting for result
                end if;     
            elsif(clinet_state = "0100") then       --4.    Preempting - The goal is being processed, and a cancel request has been received from the action client, but the action server has not confirmed the goal is canceled
                if(status = "0110" or status = "0111" or status = "1001") then
                    clinet_state <= "0110";             --7.    Waiting for result
                end if;        
            elsif(clinet_state = "0111") then       --7.    Waiting for result
                if(receive_result_msg = '1') then
                    clinet_state <= "1000";             --8.    Done
                end if;  
            end if; 
        end if;   
    end process;
    
    
    fibonacci: process(clk)
    begin
        if(rising_edge(clk)) then
            goal_order <= x"0000000a";
        end if;
    end process;
    


end Behavioral;
