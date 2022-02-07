----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/20/2022 03:00:34 PM
-- Design Name: 
-- Module Name: FPGA_ROS_ACTION - Behavioral
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

entity FPGA_ROS_ACTION is
    generic (
        BITS    : integer := 8
    );
    Port (
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;     
        -- from client
        clinet_status: out std_logic_vector(3 downto 0); 
        client_id: in std_logic_vector(3 downto 0);
        server_id: in std_logic_vector(3 downto 0);        
        send_goal: in STD_LOGIC;
        cancel_goal: in STD_LOGIC;
        receive_result_msg: in STD_LOGIC;  
        -- to server
        setAccepted: in std_logic;
        setRejected: in std_logic;
        setSucceeded: in std_logic;
        setAborted: in std_logic;
        setCanceled: in std_logic;
        status: out std_logic_vector(3 downto 0)
     );end FPGA_ROS_ACTION;

architecture Behavioral of FPGA_ROS_ACTION is
  component Client is
    Port (
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;        
        -- Cancel and status control signals to servers
        goal: out STD_LOGIC;
        cancel: out STD_LOGIC;
        status: in std_logic_vector(3 downto 0);       
        -- Recieve signals from clients, the state transitions are triggered by the server status from input and following client signals:
        clinet_status: out std_logic_vector(3 downto 0); 
        client_id: in std_logic_vector(3 downto 0);
        server_id: in std_logic_vector(3 downto 0);        
        send_goal: in STD_LOGIC;
        cancel_goal: in STD_LOGIC;
        receive_result_msg: in STD_LOGIC
      );
    end component;
    
    component Server is
    Port (
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        -- Cancel and Status Topic
        goal: in STD_LOGIC;
        cancel: in STD_LOGIC;      
        status_to_client: out std_logic_vector(3 downto 0);
        --The majority of these state transitions are triggered by the server implementer, using a small set of possible commands:
        setAccepted: in std_logic;
        setRejected: in std_logic;
        setSucceeded: in std_logic;
        setAborted: in std_logic;
        setCanceled: in std_logic;
        
        status: out std_logic_vector(3 downto 0)
     );
    end component;
      
  -- Server Client Connections
  
  signal goal :  std_logic;
  signal cancel :  std_logic;
  signal state :  std_logic_vector(3 downto 0);
  signal goal_order :  std_logic_vector(31 downto 0);
  signal feedback_sequence :  std_logic_vector(31 downto 0);
  signal result_sequence :  std_logic_vector(31 downto 0);
  
begin
server1: Server port map(
        clk  => clk,
        reset => reset,
        cancel  => cancel,
        status => status,
        goal => goal,
        setAccepted => setAccepted,
        setRejected => setRejected,
        setSucceeded => setSucceeded,
        setAborted => setAborted,
        setCanceled => setCanceled,
        status_to_client => state
); 
client1: Client port map(
        clk  => clk,
        reset => reset,
        cancel  => cancel,
        status => state,
        goal => goal,
        clinet_status => clinet_status,
        client_id => client_id,
        server_id => server_id ,   
        send_goal => send_goal,
        cancel_goal => cancel_goal,
        receive_result_msg => receive_result_msg
);











end Behavioral;
