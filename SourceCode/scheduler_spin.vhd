----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/28/2022 02:30:44 AM
-- Design Name: 
-- Module Name: scheduler_spin - Behavioral
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
entity scheduler_spin is
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
        clientState_Server_out: out std_logic_vector(CLIENT_CAPACITY * integer(ceil(log2(real(SERVER_CAPACITY))))-1 downto 0);
        clientState_Active_out: out std_logic_vector(CLIENT_CAPACITY -1 downto 0);
        serverState_Client_out: out std_logic_vector(SERVER_CAPACITY * integer(ceil(log2(real(CLIENT_CAPACITY))))-1 downto 0);
        serverState_Active_out: out std_logic_vector(SERVER_CAPACITY -1 downto 0)
    );
end scheduler_spin;

architecture Behavioral of scheduler_spin is
    constant CLIENT_LOG   : integer := integer(ceil(log2(real(CLIENT_CAPACITY))));
    constant SERVER_LOG   : integer := integer(ceil(log2(real(SERVER_CAPACITY))));
    constant PRIORITY_NUMBER_DATATYPE   : integer := 4;
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
    component MUX is
        generic(
            BITS    : integer := 8;
            WAY    : integer := 8);
        Port (
            input : in std_logic_vector(BITS*WAY-1 downto 0);
            output : out std_logic_vector(BITS-1 downto 0);
            sel : in std_logic_vector(abs(integer(ceil(log2(real(WAY))))-1) downto 0)
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
            server_input: in std_logic_vector(integer(ceil(log2(real(SERVER_CAPACITY))))-1  -1 downto 0);  
            client_input: in std_logic_vector(integer(ceil(log2(real(CLIENT_CAPACITY))))-1  -1 downto 0);  
            clientState_Server_out: out std_logic_vector(CLIENT_CAPACITY * integer(ceil(log2(real(SERVER_CAPACITY))))-1 downto 0);
            clientState_Active_out: out std_logic_vector(CLIENT_CAPACITY -1 downto 0);
            serverState_Client_out: out std_logic_vector(SERVER_CAPACITY * integer(ceil(log2(real(CLIENT_CAPACITY))))-1 downto 0);
            serverState_Active_out: out std_logic_vector(SERVER_CAPACITY -1 downto 0)     
         );
    end component;
    signal clientState_Server        : std_logic_vector(CLIENT_CAPACITY * SERVER_LOG - 1 downto 0);
    signal clientState_Active        : std_logic_vector(CLIENT_CAPACITY -1 downto 0):= (others => '0');
    signal serverState_Client        : std_logic_vector(SERVER_CAPACITY * CLIENT_LOG -1 downto 0);
    signal serverState_Active        : std_logic_vector(SERVER_CAPACITY -1 downto 0):= (others => '0');
    signal bitmap                    : std_logic_vector(SERVER_CAPACITY * CLIENT_CAPACITY-1 downto 0); 

    signal client_spin: std_logic_vector(3 downto 0):= (others => '0');
    signal spin_lock: std_logic:= '0';
    signal active_client: std_logic_vector(CLIENT_LOG - 1 downto 0);
    signal active_server: std_logic_vector(SERVER_LOG - 1 downto 0);
    signal write_register                  : std_logic:= '0';
    signal write_register_v                : std_logic_vector(CLIENT_CAPACITY - 1 downto 0);   
    signal delete_register                  : std_logic:= '0';
    signal delete_register_v                : std_logic_vector(CLIENT_CAPACITY - 1 downto 0);   
begin
    Scheduler_state_register: atomic_twinLUT generic map (
        CLIENT_CAPACITY => CLIENT_CAPACITY,
        SERVER_CAPACITY => CLIENT_CAPACITY    
    )port map(
        clk => clk,
        reset => reset,
        write_mode => write_register,
        server_input => active_server,
        client_input => active_client,
        clientState_Server_out => clientState_Server,
        clientState_Active_out => clientState_Active,
        serverState_Client_out => serverState_Client,
        serverState_Active_out => serverState_Active
    );
    clientState_Server_out <= clientState_Server;
    clientState_Active_out <= clientState_Active;
    serverState_Client_out <= serverState_Client;
    serverState_Active_out <= serverState_Active;
    Schedulers: for i in CLIENT_CAPACITY-1 downto 0 generate
        spin_scheduler: process(clk)
        begin
            if(rising_edge(clk)) then
                if(finish(i) = '1') then
                    delete_register_v(i) <= '0';
                    active_client <= std_logic_vector(to_unsigned(i, CLIENT_LOG));                    
                elsif(goal(i) = '1' and clientState_Active(i) = '0' and client_spin = i) then
                    if(serverState_Active(0) = '0') then
                        write_register_v(i) <= '1'; 
                        active_client <= std_logic_vector(to_unsigned(i, CLIENT_LOG));
                        active_server <= std_logic_vector(to_unsigned(0, CLIENT_LOG));
                    elsif(serverState_Active(1) = '0')then
                        write_register_v(i) <= '1'; 
                        active_client <= std_logic_vector(to_unsigned(i, CLIENT_LOG));
                        active_server <= std_logic_vector(to_unsigned(1, CLIENT_LOG));
                    end if;
                end if;
            end if;
        end process;
    end generate;

    Spinner: process(clk)
    begin
        if(rising_edge(clk)) then
            if(client_spin < CLIENT_CAPACITY and spin_lock = '0') then
                    client_spin <= client_spin + '1';   
            elsif(spin_lock = '0') then
                    client_spin <= (others => '0');         
            end if;
        end if;
    end process;

    spin_lock <= '1' when (client_spin = 0 and clientState_Active(0) = '0' and goal(0) = '1')
                     or   (client_spin = 1 and clientState_Active(1) = '0' and goal(1) = '1')
                     or   (client_spin = 2 and clientState_Active(2) = '0' and goal(2) = '1')
                     or   (client_spin = 3 and clientState_Active(3) = '0' and goal(3) = '1') else
                     '0';   
        
    write_register <= '0' when write_register_v = 0 else '1';
    delete_register <= '0' when delete_register_v = 0 else '1';

end Behavioral;
