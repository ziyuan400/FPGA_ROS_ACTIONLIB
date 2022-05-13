----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/28/2022 03:11:14 AM
-- Design Name: 
-- Module Name: Switch - Behavioral
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
use IEEE.math_real.all;
use work.util.all;
entity Switch is
    generic (
        BITS               : integer := 8;
        CLIENT_CAPACITY    : integer := 8;
        SERVER_CAPACITY    : integer := 8
    );
    Port (
        clientState_Server: in std_logic_vector(CLIENT_CAPACITY * log(SERVER_CAPACITY)-1 downto 0);      
        clientState_Active: in std_logic_vector(CLIENT_CAPACITY -1 downto 0):= (others => '0');   
        serverState_Client: in std_logic_vector(SERVER_CAPACITY * log(CLIENT_CAPACITY)-1 downto 0);
        serverState_Active: in std_logic_vector(SERVER_CAPACITY -1 downto 0);        
        axis_client_in: in  AXIS (CLIENT_CAPACITY - 1 downto 0 );
        axis_client_out: out  AXIS (CLIENT_CAPACITY - 1 downto 0 );
        axis_server_in: in  AXIS (SERVER_CAPACITY - 1 downto 0 );
        axis_server_out: out  AXIS (SERVER_CAPACITY - 1 downto 0 );         
        goal: in std_logic_vector(CLIENT_CAPACITY-1 downto 0);
        cancel: in std_logic_vector(CLIENT_CAPACITY-1 downto 0);
        goal_to_server: out std_logic_vector(SERVER_CAPACITY -1 downto 0);  
        cancel_to_server: out  std_logic_vector(SERVER_CAPACITY -1 downto 0);    
        read_server_state: in std_logic_vector(4 * SERVER_CAPACITY -1 downto 0);             
        write_server_state_to_client: out std_logic_vector(4 * CLIENT_CAPACITY -1 downto 0)        
     );
end Switch;

architecture Structural of Switch is
   component MUX_with_switch is  generic(
        BITS    : integer := 8;
        WAY    : integer := 8);
    Port (
        input : in std_logic_vector(BITS*WAY-1 downto 0);
        output : out std_logic_vector(BITS-1 downto 0);
        sel : in std_logic_vector(abs(integer(ceil(log2(real(WAY))))-1) downto 0);
        turn_on : in std_logic
        );
    end component;
    component onehot_to_number is
        generic (
            WIDTH: integer := 8;
            LOG: integer := 3
        );
        Port (
            i: in std_logic_vector(WIDTH-1 downto 0);
            o: out std_logic_vector(LOG-1 downto 0)
        );
    end component;
    
    constant CLIENT_LOG   : integer := log(CLIENT_CAPACITY); 
    constant CLIENT_MAX   : integer := 2 ** CLIENT_LOG;    
    constant SERVER_LOG   : integer := log(SERVER_CAPACITY); 
    constant SERVER_MAX   : integer := 2 ** SERVER_LOG; 
    constant AXIS_IO_WIDTH: integer := 11;    

    signal axis_tdata_goal_in:  STD_LOGIC_VECTOR (8 * CLIENT_CAPACITY - 1 downto 0 );
    signal axis_tlast_goal_in:  STD_LOGIC_VECTOR (CLIENT_CAPACITY - 1 downto 0 );
    signal axis_tready_goal_out:  STD_LOGIC_VECTOR (CLIENT_CAPACITY - 1 downto 0 );
    signal axis_tvalid_goal_in:  STD_LOGIC_VECTOR (CLIENT_CAPACITY - 1 downto 0 );
    signal axis_tdata_goal_out:  STD_LOGIC_VECTOR (8 * SERVER_CAPACITY - 1 downto 0 );
    signal axis_tlast_goal_out:  STD_LOGIC_VECTOR (SERVER_CAPACITY - 1 downto 0 );
    signal axis_tready_goal_in:  STD_LOGIC_VECTOR (SERVER_CAPACITY - 1 downto 0 );
    signal axis_tvalid_goal_out:  STD_LOGIC_VECTOR (SERVER_CAPACITY - 1 downto 0 );
    signal axis_tdata_result_in:  STD_LOGIC_VECTOR (8 * SERVER_CAPACITY - 1 downto 0 );
    signal axis_tlast_result_in:  STD_LOGIC_VECTOR (SERVER_CAPACITY - 1 downto 0 );
    signal axis_tready_result_out:  STD_LOGIC_VECTOR (SERVER_CAPACITY - 1 downto 0 );
    signal axis_tvalid_result_in:  STD_LOGIC_VECTOR (SERVER_CAPACITY - 1 downto 0 );
    signal axis_tdata_result_out:  STD_LOGIC_VECTOR (8 * CLIENT_CAPACITY - 1 downto 0 );
    signal axis_tlast_result_out:  STD_LOGIC_VECTOR (CLIENT_CAPACITY - 1 downto 0 );
    signal axis_tready_result_in:  STD_LOGIC_VECTOR (CLIENT_CAPACITY - 1 downto 0 );
    signal axis_tvalid_result_out:  STD_LOGIC_VECTOR (CLIENT_CAPACITY - 1 downto 0 );
begin

server_line:  for i in SERVER_CAPACITY-1 downto 0 generate   
        axis_server_out(i)(7 downto 0) <=  axis_tdata_goal_out(i*8+7 downto i*8);
        axis_server_out(i)(8) <= axis_tlast_goal_out(i);
        axis_tready_goal_in(i) <= axis_server_in(i)(10);
        axis_server_out(i)(9) <= axis_tvalid_goal_out(i);
        
        axis_tdata_result_in(i*8+7 downto i*8) <= axis_server_in(i)(7 downto 0);
        axis_tlast_result_in(i) <= axis_server_in(i)(8);
        axis_server_out(i)(10) <= axis_tready_result_out(i);
        axis_tvalid_result_in(i) <= axis_server_in(i)(9);
end generate;
client_line:  for i in CLIENT_CAPACITY-1 downto 0 generate  
        axis_tdata_goal_in(i*8+7 downto i*8) <= axis_client_in(i)(7 downto 0);
        axis_tlast_goal_in(i) <= axis_client_in(i)(8);
        axis_client_out(i)(10) <= axis_tready_goal_out(i);
        axis_tvalid_goal_in(i) <= axis_client_in(i)(9);
        
        axis_client_out(i)(7 downto 0) <= axis_tdata_result_out(i*8+7 downto i*8);
        axis_client_out(i)(8) <= axis_tlast_result_out(i);
        axis_tready_result_in(i) <= axis_client_in(i)(10);
        axis_client_out(i)(9) <= axis_tvalid_result_out(i);
end generate;
        
server_input:  for i in SERVER_CAPACITY-1 downto 0 generate   
    
    goal_client_to_server: MUX_with_switch generic map (1, CLIENT_CAPACITY) port map 
    (goal , goal_to_server(i downto i), serverState_Client(CLIENT_LOG*(i+1)-1 downto CLIENT_LOG*i), serverState_Active(i));

    cancel_client_to_server: MUX_with_switch generic map (1, CLIENT_CAPACITY) port map (cancel, cancel_to_server(i downto i), 
      serverState_Client(CLIENT_LOG*(i+1)-1 downto CLIENT_LOG*i), serverState_Active(i));



    axis_tdata_goal: MUX_with_switch generic map (BITS, CLIENT_CAPACITY) port map (axis_tdata_goal_in, axis_tdata_goal_out(BITS * i + 7 downto BITS * i),
      serverState_Client(CLIENT_LOG*(i+1)-1 downto CLIENT_LOG*i), serverState_Active(i));

    axis_tlast_goal: MUX_with_switch generic map (1, CLIENT_CAPACITY) port map (axis_tlast_goal_in, axis_tlast_goal_out(i downto i), 
     serverState_Client(CLIENT_LOG*(i+1)-1 downto CLIENT_LOG*i), serverState_Active(i));                                               

    axis_tready_result: MUX_with_switch generic map (1, CLIENT_CAPACITY) port map (axis_tready_result_in, axis_tready_result_out(i downto i),
       serverState_Client(CLIENT_LOG*(i+1)-1 downto CLIENT_LOG*i), serverState_Active(i));

    axis_tvalid_goal: MUX_with_switch generic map (1, CLIENT_CAPACITY) port map (axis_tvalid_goal_in, axis_tvalid_goal_out(i downto i),
       serverState_Client(CLIENT_LOG*(i+1)-1 downto CLIENT_LOG*i), serverState_Active(i));

end generate;

client_input:  for i in CLIENT_CAPACITY-1 downto 0 generate  

    axis_tdata_result: MUX_with_switch generic map (BITS, SERVER_CAPACITY) port map (axis_tdata_result_in, axis_tdata_result_out(BITS * i + 7 downto BITS * i),
      clientState_Server(SERVER_LOG*(i+1)-1 downto SERVER_LOG*i), clientState_Active(i));
      
    axis_tlast_result: MUX_with_switch generic map (1, SERVER_CAPACITY) port map (axis_tlast_result_in, axis_tlast_result_out(i downto i),
      clientState_Server(SERVER_LOG*(i+1)-1 downto SERVER_LOG*i), clientState_Active(i));
      
    axis_tready_goal: MUX_with_switch generic map (1, SERVER_CAPACITY) port map (axis_tready_goal_in, axis_tready_goal_out(i downto i),
      clientState_Server(SERVER_LOG*(i+1)-1 downto SERVER_LOG*i), clientState_Active(i));
      
    axis_tvalid_result: MUX_with_switch generic map (1, SERVER_CAPACITY) port map (axis_tvalid_result_in, axis_tvalid_result_out(i downto i),
      clientState_Server(SERVER_LOG*(i+1)-1 downto SERVER_LOG*i), clientState_Active(i));
      
    
    state_to_client: MUX_with_switch generic map (4, SERVER_CAPACITY) port map (read_server_state, write_server_state_to_client(4 * i + 3 downto 4 * i),
      clientState_Server(SERVER_LOG*(i+1)-1 downto SERVER_LOG*i), clientState_Active(i));
                                                      
end generate;

end Structural;

