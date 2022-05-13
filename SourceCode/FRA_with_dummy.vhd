----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/09/2022 12:16:56 PM
-- Design Name: 
-- Module Name: FRA_with_dummy - Behavioral
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
use work.util.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity FRA_with_dummy is   generic (
        BITS               : integer := 8;
        CLIENT_CAPACITY    : integer := 32;
        SERVER_CAPACITY    : integer := 4
    );
    Port (
        clk : in STD_LOGIC;
        rst : in STD_LOGIC
    );
end FRA_with_dummy;

architecture Behavioral of FRA_with_dummy is
    component dummy_client is
        generic (
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
    end component;
    component dummy_server is
        generic (
            BITS    : integer := 8;
            IPID    : integer := 0
        );
        Port (
            clk : in STD_LOGIC;
            rst : in STD_LOGIC;

            status: in std_logic_vector(3 downto 0);
            setAccepted: out std_logic;
            setRejected: out std_logic;
            setSucceeded: out std_logic;
            setAborted: out std_logic;
            setCanceled: out std_logic;
            axis_in: in AXIS;
            axis_out: out AXIS
        );
    end component;
    component FPGA_ROS_ACTION is
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
    end component;
        signal  goal:  std_logic_vector(CLIENT_CAPACITY-1 downto 0);
        signal  cancel:  std_logic_vector(CLIENT_CAPACITY-1 downto 0);
        signal  finish:  std_logic_vector(CLIENT_CAPACITY-1 downto 0);
        signal  client_state:  std_logic_vector(4 * CLIENT_CAPACITY-1 downto 0);
    -- signals from server
        signal  setAccepted:  std_logic_vector(SERVER_CAPACITY -1  downto 0);
        signal  setRejected:  std_logic_vector(SERVER_CAPACITY -1  downto 0);
        signal  setSucceeded:  std_logic_vector(SERVER_CAPACITY -1  downto 0);
        signal  setAborted:  std_logic_vector(SERVER_CAPACITY -1  downto 0);
        signal  setCanceled:  std_logic_vector(SERVER_CAPACITY -1  downto 0);
        signal  server_state:  std_logic_vector(4*SERVER_CAPACITY -1  downto 0);
    -- data AXIS        
        signal  axis_client_in:   AXIS (CLIENT_CAPACITY - 1 downto 0 );
        signal  axis_client_out:   AXIS (CLIENT_CAPACITY - 1 downto 0 );
        signal  axis_server_in:   AXIS (SERVER_CAPACITY - 1 downto 0 );
        signal  axis_server_out:   AXIS (SERVER_CAPACITY - 1 downto 0 );
begin

Clients: for i in CLIENT_CAPACITY-1 downto 0 generate
    Client:dummy_client generic map (8,0) port map(    
            clk => clk,
            rst => rst,
            client_state => client_state(4*i+3 downto 4*i),
            send_goal => goal(i),
            cancel_goal => cancel(i),
            receive_result_msg => finish(i),
            axis_in => axis_client_in(i downto i),
            axis_out => axis_client_out(i downto i)
    );
end generate;
    
Servers: for i in SERVER_CAPACITY-1 downto 0 generate
    Server:dummy_server generic map (8,0) port map(    
            clk => clk,
            rst => rst,
            status => server_state(4*i+3 downto 4*i),
            setAccepted => setAccepted(i),
            setRejected => setRejected(i),
            setSucceeded => setSucceeded(i),
            setAborted => setAborted(i),
            setCanceled => setCanceled(i),
            axis_in => axis_server_in(i downto i),
            axis_out => axis_server_out(i downto i)
    ); 
end generate;
  ROS: FPGA_ROS_ACTION     generic map(
        BITS             => BITS,
        CLIENT_CAPACITY  => CLIENT_CAPACITY,
        SERVER_CAPACITY  => SERVER_CAPACITY
        ) port map (
        clk              => clk,
        reset            => rst,
        -- from client
        goal             => goal,
        cancel           => cancel,
        finish           => finish,
        client_state     => client_state,
        -- to server
        setAccepted      => setAccepted,
        setRejected      => setRejected,
        setSucceeded     => setSucceeded,
        setAborted       => setAborted,
        setCanceled      => setCanceled,
        server_state     => server_state,        
        axis_client_in   => axis_client_in,
        axis_client_out  => axis_client_out,
        axis_server_in   => axis_server_in,
        axis_server_out  => axis_server_out        
        );

end Behavioral;
