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
use IEEE.math_real.all;
use work.util.all;

entity OFRA is
    generic (
        BITS               : integer := 8;
        CLIENT_CAPACITY    : integer := 8;
        SERVER_CAPACITY    : integer := 2
    );
    Port (
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        -- signals from client
        goal: in std_logic_vector(CLIENT_CAPACITY-1 downto 0);
        cancel: in std_logic_vector(CLIENT_CAPACITY-1 downto 0);
        finish: in std_logic_vector(CLIENT_CAPACITY-1 downto 0);
        client_state: out std_logic_vector(4 * CLIENT_CAPACITY-1 downto 0);
        -- signals from server
        setAccepted: in std_logic_vector(SERVER_CAPACITY -1  downto 0);
        setRejected: in std_logic_vector(SERVER_CAPACITY -1  downto 0);
        setSucceeded: in std_logic_vector(SERVER_CAPACITY -1  downto 0);
        setAborted: in std_logic_vector(SERVER_CAPACITY -1  downto 0);
        setCanceled: in std_logic_vector(SERVER_CAPACITY -1  downto 0);
        server_state: out std_logic_vector(4*SERVER_CAPACITY -1  downto 0);
        -- data AXIS        
        axis_client_in: in  AXIS (CLIENT_CAPACITY - 1 downto 0 );
        axis_client_out: out  AXIS (CLIENT_CAPACITY - 1 downto 0 );
        axis_server_in: in  AXIS (SERVER_CAPACITY - 1 downto 0 );
        axis_server_out: out  AXIS (SERVER_CAPACITY - 1 downto 0 )
    );
end OFRA;
architecture Behavioral of OFRA is
    component Client is
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
    end component;
    component Server is
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
    end component;
    component Switch is
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
    end component;
    component scheduler_spin is
--    component scheduler_priority_table is
--    component scheduler_priority_table is
        generic (
            BITS               : integer := 8;
            CLIENT_CAPACITY    : integer := 8;
            SERVER_CAPACITY    : integer := 8
        );
        Port (
            clk : in STD_LOGIC;
            reset : in STD_LOGIC;
            goal: in std_logic_vector(CLIENT_CAPACITY-1 downto 0);
            cancel: in std_logic_vector(CLIENT_CAPACITY-1 downto 0);
            finish: in std_logic_vector(CLIENT_CAPACITY-1 downto 0);
            read_server_state: in std_logic_vector(4 * SERVER_CAPACITY -1 downto 0);
            clientState_Server_out: out std_logic_vector(CLIENT_CAPACITY * integer(ceil(log2(real(SERVER_CAPACITY))))-1 downto 0);
            clientState_Active_out: out std_logic_vector(CLIENT_CAPACITY -1 downto 0);    
            serverState_Client_out: out std_logic_vector(SERVER_CAPACITY * integer(ceil(log2(real(CLIENT_CAPACITY))))-1 downto 0);
            serverState_Active_out: out std_logic_vector(SERVER_CAPACITY -1 downto 0)    
        );
    end component;
    component scheduler_priority_table is
        --    component scheduler_priority_table is
        generic (
            BITS               : integer := 8;
            CLIENT_CAPACITY    : integer := 8;
            SERVER_CAPACITY    : integer := 8
        );
        Port (
            clk : in STD_LOGIC;
            reset : in STD_LOGIC;
            goal: in std_logic_vector(CLIENT_CAPACITY-1 downto 0);
            cancel: in std_logic_vector(CLIENT_CAPACITY-1 downto 0);
            finish: in std_logic_vector(CLIENT_CAPACITY-1 downto 0);
            read_server_state: in std_logic_vector(4 * SERVER_CAPACITY -1 downto 0);
            clientState_Server_out: out std_logic_vector(CLIENT_CAPACITY * integer(ceil(log2(real(SERVER_CAPACITY))))-1 downto 0);
            clientState_Active_out: out std_logic_vector(CLIENT_CAPACITY -1 downto 0);
            serverState_Client_out: out std_logic_vector(SERVER_CAPACITY * integer(ceil(log2(real(CLIENT_CAPACITY))))-1 downto 0);
            serverState_Active_out: out std_logic_vector(SERVER_CAPACITY -1 downto 0)
        );
    end component;
    component Register_finish is
        generic(
            WIDTH: integer:=8
        );
        Port (
            clk : in STD_LOGIC;
            reset : in STD_LOGIC;
            reg: out std_logic_vector(WIDTH-1 downto 0);
            active: in std_logic_vector(WIDTH-1 downto 0);
            finish: in std_logic_vector(WIDTH-1 downto 0)
        );
    end component;
    
    constant CLIENT_LOG   : integer := integer(ceil(log2(real(CLIENT_CAPACITY))));
    constant CLIENT_MAX   : integer := 2 ** CLIENT_LOG;
    constant SERVER_LOG   : integer := integer(ceil(log2(real(SERVER_CAPACITY))));
    constant SERVER_MAX   : integer := 2 ** SERVER_LOG;

    signal serverState_Client       : std_logic_vector(CLIENT_LOG * SERVER_CAPACITY-1 downto 0);
    signal clientState_Server       : std_logic_vector(CLIENT_CAPACITY * SERVER_LOG-1 downto 0);
    signal serverState_Active       : std_logic_vector(SERVER_CAPACITY -1 downto 0):= (others => '0');
    signal clientState_Active       : std_logic_vector(CLIENT_CAPACITY -1 downto 0):= (others => '0');

    signal client_done_reg: std_logic_vector(CLIENT_CAPACITY -1 downto 0):= (others => '0');
    signal goal_to_server: std_logic_vector(SERVER_CAPACITY -1 downto 0);
    signal cancel_to_server: std_logic_vector(SERVER_CAPACITY -1 downto 0);
    signal read_server_state:  std_logic_vector(4 * SERVER_CAPACITY -1 downto 0);
    signal read_client_state:  std_logic_vector(4 * CLIENT_CAPACITY -1 downto 0);
    signal write_server_state_to_client:  std_logic_vector(4 * CLIENT_CAPACITY -1 downto 0);
    
    signal client_in:   AXIS (CLIENT_CAPACITY - 1 downto 0 );
    signal client_out:   AXIS (CLIENT_CAPACITY - 1 downto 0 );
    signal server_in:   AXIS (SERVER_CAPACITY - 1 downto 0 );
    signal server_out:   AXIS (SERVER_CAPACITY - 1 downto 0 ); 

begin
    server_state <= read_server_state;
    client_state <= read_client_state;

    Server_State_Machine: Server generic map(
            CAPACITY => SERVER_CAPACITY
        )       port map(
            clk  => clk,
            reset => reset,
            goal => goal_to_server,
            cancel  => cancel_to_server,
            server_state => read_server_state,
            setAccepted => setAccepted,
            setRejected => setRejected,
            setSucceeded => setSucceeded,
            setAborted => setAborted,
            setCanceled => setCanceled
        );
    Client_State_Machine: Client generic map(
            CAPACITY => CLIENT_CAPACITY
        )  port map(
            clk  => clk,
            reset => reset,
            goal => goal,
            cancel=> cancel,
            receive_result_msg => client_done_reg,
            server_state => write_server_state_to_client,
            client_state => read_client_state
        );
    Scheduler: scheduler_priority_table generic map(
--    Scheduler: scheduler_spin generic map(
            BITS => BITS,
            CLIENT_CAPACITY => CLIENT_CAPACITY,
            SERVER_CAPACITY => SERVER_CAPACITY
        ) port map(
            clk => clk,
            reset => reset,
            goal =>  goal,
            cancel => cancel,
            finish =>  finish or client_done_reg,
            read_server_state => read_server_state,
            clientState_Server_out => clientState_Server,
            clientState_Active_out => clientState_Active,
            serverState_Client_out => serverState_Client,
            serverState_Active_out => serverState_Active
        );  
    Switch_AXIS: Switch generic map(BITS, CLIENT_CAPACITY, SERVER_CAPACITY) port map(
            clientState_Server =>clientState_Server,
            clientState_Active =>clientState_Active,
            serverState_Client =>serverState_Client,
            serverState_Active =>serverState_Active,
            axis_client_in => axis_client_in,
            axis_client_out => axis_client_out,
            axis_server_in => axis_server_in,
            axis_server_out => axis_server_out,
            goal =>goal,
            cancel =>cancel,
            goal_to_server =>goal_to_server,
            cancel_to_server =>cancel_to_server,
            read_server_state =>read_server_state,
            write_server_state_to_client =>write_server_state_to_client
        );
    Signal_registers:     Register_finish generic map(
            CLIENT_CAPACITY
        ) port map(
            clk => clk,
            reset => reset,
            reg => client_done_reg,
            active => clientState_Active,
            finish => finish
        );


end Behavioral;

