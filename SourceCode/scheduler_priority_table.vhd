----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/02/2022 01:03:31 AM
-- Design Name: 
-- Module Name: scheduler_priority_table - Behavioral
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
use work.util.all;
entity scheduler_priority_table is
    generic (
        BITS               : integer := 8;
        CLIENT_CAPACITY    : integer := 8;
        SERVER_CAPACITY    : integer := 8
    );
    Port (
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;     
        -- from client
        goal: in std_logic_vector(CLIENT_CAPACITY-1 downto 0);
        cancel: in std_logic_vector(CLIENT_CAPACITY-1 downto 0);
        finish: in std_logic_vector(CLIENT_CAPACITY-1 downto 0);        
        -- from server
        read_server_state: in std_logic_vector(4 * SERVER_CAPACITY -1 downto 0);  
        --output
        clientState_Server_out: out std_logic_vector(CLIENT_CAPACITY * log(SERVER_CAPACITY) - 1 downto 0);
        clientState_Active_out: out std_logic_vector(CLIENT_CAPACITY -1 downto 0);
        serverState_Client_out: out std_logic_vector(SERVER_CAPACITY * log(CLIENT_CAPACITY) - 1 downto 0);
        serverState_Active_out: out std_logic_vector(SERVER_CAPACITY -1 downto 0)
     );
end scheduler_priority_table;

architecture Behavioral of scheduler_priority_table is
------------------------------------------------------------------
--max output the max number ant its index of the list
--Input: {7,2,8,4}
--Max:   8  
--index: {0,0,1,0}
------------------------------------------------------------------
    component min is
        generic(
            BITS    : integer := 8;
            WAY    : integer := 8);
        Port (
            input : in std_logic_vector(BITS*WAY-1 downto 0);
            min : out std_logic_vector(BITS-1 downto 0);
            index : out std_logic_vector(WAY-1 downto 0)
        );
    end component;    
    component max is
        generic(
            BITS    : integer := 8;
            WAY    : integer := 8);
        Port (
            input : in std_logic_vector(BITS*WAY-1 downto 0);
            max : out std_logic_vector(BITS-1 downto 0);
            index : out std_logic_vector(WAY-1 downto 0)
        );
    end component;    
------------------------------------------------------------------
--onehot_to_number convert a vector with one '1' to unsigned
--Input:    {0,0,1,0,0,0,0,0}
--Output:   "010"
------------------------------------------------------------------
    component onehot_to_number is
        generic (
            WIDTH: integer := 8
        );
        Port (
            i: in std_logic_vector(WIDTH-1 downto 0);
            o: out std_logic_vector(log(WIDTH)-1 downto 0)
        );
    end component;
    component MUX is
        generic(
            BITS    : integer := 8;
            WAY    : integer := 8);
        Port (
            input : in std_logic_vector(BITS*WAY-1 downto 0);
            output : out std_logic_vector(BITS-1 downto 0);
            sel : in std_logic_vector(log(WAY)-1 downto 0)
        );
    end component;        
    component atomic_twinLUT is
        generic (
            CLIENT_CAPACITY    : integer := 8;
            SERVER_CAPACITY    : integer := 8
        );
        Port (
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;         
        write_mode: in STD_LOGIC;   
        delete_mode: in STD_LOGIC;        
        client_input: in std_logic_vector(log(CLIENT_CAPACITY)-1 downto 0);  
        server_input: in std_logic_vector(log(SERVER_CAPACITY)-1 downto 0);  
        clientState_Server_out: out std_logic_vector(CLIENT_CAPACITY * log(SERVER_CAPACITY)-1 downto 0);
        clientState_Active_out: out std_logic_vector(CLIENT_CAPACITY -1 downto 0):=(others => '0');
        serverState_Client_out: out std_logic_vector(SERVER_CAPACITY * log(CLIENT_CAPACITY)-1 downto 0);
        serverState_Active_out: out std_logic_vector(SERVER_CAPACITY -1 downto 0):=(others => '0')      
         );
    end component;
    constant CLIENT_LOG   : integer := log(CLIENT_CAPACITY); 
    constant SERVER_LOG   : integer := log(SERVER_CAPACITY); 
    constant PRIORITY_NUMBER_WIDTH  : integer := 4; 
   
    signal priority_table_client           : std_logic_vector(CLIENT_CAPACITY * PRIORITY_NUMBER_WIDTH - 1 downto 0):=(others => '0'); 
    signal masked_table_client             : std_logic_vector(CLIENT_CAPACITY * PRIORITY_NUMBER_WIDTH - 1 downto 0):=(others => '0'); 
    signal priority_table_server           : std_logic_vector(SERVER_CAPACITY * PRIORITY_NUMBER_WIDTH - 1 downto 0):=(others => '0');  
    signal min_priority_number_client      : std_logic_vector(PRIORITY_NUMBER_WIDTH - 1 downto 0);   
    signal min_priority_number_server      : std_logic_vector(PRIORITY_NUMBER_WIDTH - 1 downto 0);   
    signal selected_client_vector          : std_logic_vector(CLIENT_CAPACITY - 1 downto 0);   
    signal selected_server_vector          : std_logic_vector(SERVER_CAPACITY - 1 downto 0);   
    signal clientState_Server              : std_logic_vector(CLIENT_CAPACITY * SERVER_LOG - 1 downto 0);   
    signal clientState_Active              : std_logic_vector(CLIENT_CAPACITY -1 downto 0);    
    signal serverState_Client              : std_logic_vector(SERVER_CAPACITY * CLIENT_LOG -1 downto 0);
    signal serverState_Active              : std_logic_vector(SERVER_CAPACITY -1 downto 0);
    signal selected_server_index           : std_logic_vector(SERVER_LOG -1 downto 0):= (others => '0');    
    signal selected_client_index           : std_logic_vector(CLIENT_LOG -1 downto 0):= (others => '0');   
    signal selected_server_isactive        : std_logic_vector(0 downto 0); 
    
    signal modified_client                 : std_logic_vector(CLIENT_LOG -1 downto 0);   
    signal done_client                     : std_logic_vector(CLIENT_LOG -1 downto 0);   
    signal done_client_vec                 : std_logic_vector(CLIENT_CAPACITY -1 downto 0);    
    signal delete_sig                      : std_logic_vector(0 downto 0);
    signal write_register                  : std_logic:= '0';
    signal write_register_v                : std_logic_vector(CLIENT_CAPACITY - 1 downto 0);   
    signal delete_register                 : std_logic:= '0';
    signal delete_register_v               : std_logic_vector(CLIENT_CAPACITY - 1 downto 0);   
begin
    Scheduler_state_register: atomic_twinLUT generic map (
        CLIENT_CAPACITY => CLIENT_CAPACITY,
        SERVER_CAPACITY => SERVER_CAPACITY    
    )port map(
        clk => clk,
        reset => reset,
        write_mode => write_register,
        delete_mode => delete_register,        
        server_input => selected_server_index,
        client_input => modified_client,
        clientState_Server_out => clientState_Server,
        clientState_Active_out => clientState_Active,
        serverState_Client_out => serverState_Client,
        serverState_Active_out => serverState_Active
    );
    clientState_Server_out <= clientState_Server;
    clientState_Active_out <= clientState_Active;
    serverState_Client_out <= serverState_Client;
    serverState_Active_out <= serverState_Active;
    
    Get_min_priority_client: min generic map(PRIORITY_NUMBER_WIDTH, CLIENT_CAPACITY) port map(masked_table_client, min_priority_number_client, selected_client_vector);
    Get_min_priority_server: min generic map(PRIORITY_NUMBER_WIDTH, SERVER_CAPACITY) port map(priority_table_server, min_priority_number_server , selected_server_vector);
    MP_server_index: onehot_to_number  generic map(SERVER_CAPACITY) port map(selected_server_vector, selected_server_index);
    MP_client_index: onehot_to_number  generic map(CLIENT_CAPACITY) port map(selected_client_vector, selected_client_index);
    
    Get_done_client: max generic map(1, CLIENT_CAPACITY) port map(delete_register_v, delete_sig , done_client_vec);
    Done_client_index: onehot_to_number  generic map(CLIENT_CAPACITY) port map(done_client_vec, done_client);
    
    Selected_server_active:  MUX generic map (1, SERVER_CAPACITY) port map (serverState_Active , Selected_server_isactive(0 downto 0), selected_server_index); 
    Server_priority: for i in SERVER_CAPACITY-1 downto 0 generate
        priority_table_server(PRIORITY_NUMBER_WIDTH * (i+1) - 1 downto PRIORITY_NUMBER_WIDTH * i) <= std_logic_vector(to_unsigned(i, PRIORITY_NUMBER_WIDTH)) 
                                                                                                         when serverState_Active(i) = '0' else
                                                                                                         (others => '1');
    end generate;
            
    Client_priority: for i in CLIENT_CAPACITY-1 downto 0 generate
        masked_table_client(PRIORITY_NUMBER_WIDTH * (i+1) - 1 downto PRIORITY_NUMBER_WIDTH * i) <= 
            priority_table_client(PRIORITY_NUMBER_WIDTH * (i+1) - 1 downto PRIORITY_NUMBER_WIDTH * i)  when goal(i) = '1' else
                                                                                                         (others => '1');
    end generate;
    modified_client <= selected_client_index when delete_register = '0' else done_client;
    signal_vector: for i in CLIENT_CAPACITY-1 downto 0 generate
        delete_register_v(i) <= '1' when finish(i) = '1' and clientState_Active(i) = '1' else '0';
        write_register_v(i)  <= '1' when goal(i) = '1' and clientState_Active(i) = '0'
                                                       and selected_client_vector(i) = '1' 
                                                       and selected_server_isactive(0) = '0' 
                                                       and finish(i) = '0' else '0'; 
    end generate;
    write_register <= '1' when write_register_v >0 else '0';
    delete_register <= '1' when delete_register_v >0 else '0';
    
            
    Priority: for i in CLIENT_CAPACITY-1 downto 0 generate
--        Last_recently_used: process(clk)
        Least_frequent_used: process(clk)
        begin
            if(rising_edge(clk)) then
                if(write_register_v(i) = '1') then
                    priority_table_client(PRIORITY_NUMBER_WIDTH * (i+1) - 1 downto PRIORITY_NUMBER_WIDTH * i) <= min_priority_number_client + '1';
                end if;
                if(priority_table_client(PRIORITY_NUMBER_WIDTH * (i+1) - 1 downto PRIORITY_NUMBER_WIDTH * i)  = "1111") then
                
                 end if;
                
            end if;
        end process;
    end generate;
end Behavioral;
