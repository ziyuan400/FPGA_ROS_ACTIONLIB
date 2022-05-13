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
use ieee.std_logic_unsigned.all;

entity Client is
    generic (
        CAPACITY    : integer := 8
    );
    Port (  
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;        
        -- status control signals to servers
        server_state: in std_logic_vector(4 * CAPACITY -1  downto 0);
        client_state: out std_logic_vector(4 * CAPACITY -1  downto 0);        
        -- Recieve signals from clients, the state transitions are triggered by the server status from input and following client signals:        
        goal: in std_logic_vector(CAPACITY -1  downto 0);
        cancel: in std_logic_vector(CAPACITY -1  downto 0);
        receive_result_msg: in std_logic_vector(CAPACITY -1  downto 0)
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
       
    type client_state_vector is array (0 to CAPACITY-1) of std_logic_vector(3 downto 0);
    signal state: client_state_vector:=(others=>(others=>'0')); 
    signal server_state_in: client_state_vector:=(others=>(others=>'0')); 
begin   
    vector2array:  for i in CAPACITY-1 downto 0 generate
        client_state(i * 4 + 3 downto i * 4) <= state(i); 
    end generate;
    vector2array_server:  for i in CAPACITY-1 downto 0 generate
        server_state_in(i) <= server_state(i * 4 + 3 downto i * 4);
    end generate;
    
    client_state_machine_vector:    for i in CAPACITY-1 downto 0 generate
        client_state_machine: process (clk)
        begin
            if(rising_edge(clk)) then                
                if(state(i) = x"0" or state(i) = x"8") then
                    if(goal(i) = '1') then
                        state(i) <= x"1";
                    end if;    
                elsif(state(i) = x"5") then       --5.    Waiting for goal ACK
                    if(cancel(i) = '1') then
                        state(i) <= x"6";             --6.    Waiting for cancel ACK 
                    elsif(server_state_in(i) = x"1") then
                        state(i) <= x"1";             --1.    Pending
                    elsif(server_state_in(i) = x"2") then
                        state(i) <= x"2";             --2.    Active
                    end if;    
                elsif(state(i) = x"1") then       --1.    Pending - The goal has yet to be processed by the action server
                   if(cancel(i) = '1') then
                        state(i) <= x"6";             --6.    Waiting for cancel ACK  
                    elsif(server_state_in(i) = x"2") then
                        state(i) <= x"2";                 --2.    Active
                    elsif(server_state_in(i) = x"3") then
                        state(i) <= x"3";                 --3.    Recalling
                    elsif(server_state_in(i) = x"5") then             --5.Rejected 
                        state(i) <= x"7";                 --7.    Waiting for result   
                    end if;      
                elsif(state(i) = x"2") then       --2.    Active - The goal is currently being processed by the action server  
                    if(cancel(i) = '1') then 
                        state(i) <= x"6";             --6.    Waiting for cancel ACK
                    elsif(server_state_in(i) = x"4") then
                        state(i) <= x"4";             --4.    Preempting  
                    elsif(server_state_in(i) = x"6" or server_state_in(i) = x"7") then  
                        state(i) <= x"7";             --7.    Waiting for result
                    end if;      
                elsif(state(i) = x"6") then       --6.    Waiting for cancel ACK
                    if(server_state_in(i) = x"3") then
                        state(i) <= x"3";             --3.    Recalling
                    elsif(server_state_in(i) = x"4") then
                        state(i) <= x"4";             --4.    Preempting
                    end if;      
                elsif(state(i) = x"3") then       --3.    Recalling - The goal has not been processed and a cancel request has been received from the action client, but the action server has not confirmed the goal is canceled
                    if(server_state_in(i) = x"4") then
                        state(i) <= x"4";             --4.    Preempting 
                    elsif(server_state_in(i) = x"5" or server_state_in(i) = x"8") then
                        state(i) <= x"7";             --7.    Waiting for result
                    end if;     
                elsif(state(i) = x"4") then       --4.    Preempting - The goal is being processed, and a cancel request has been received from the action client, but the action server has not confirmed the goal is canceled
                    if(server_state_in(i) = x"6" or server_state_in(i) = x"7" or server_state_in(i) = x"9") then
                        state(i) <= x"6";             --7.    Waiting for result
                    end if;        
                elsif(state(i) = x"7") then       --7.    Waiting for result
                    if(receive_result_msg(i) = '1') then
                        state(i) <= x"8";             --8.    Done
                    end if;  
                end if;             
            end if;   
        end process;
    end generate;
end Behavioral;
