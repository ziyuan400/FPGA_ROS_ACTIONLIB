----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/15/2022 03:19:23 PM
-- Design Name: 
-- Module Name: atomic_twinLUT - Behavioral
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
use ieee.std_logic_unsigned.all;
use work.util.all;
entity atomic_twinLUT is
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
end atomic_twinLUT;

architecture Behavioral of atomic_twinLUT is
    constant CLIENT_LOG   : integer := log(CLIENT_CAPACITY);
    constant SERVER_LOG   : integer := log(SERVER_CAPACITY);
    signal clientState_Server        : std_logic_vector(CLIENT_CAPACITY * SERVER_LOG - 1 downto 0);
    signal clientState_Active        : std_logic_vector(CLIENT_CAPACITY -1 downto 0):= (others => '0');
    signal serverState_Client        : std_logic_vector(SERVER_CAPACITY * CLIENT_LOG -1 downto 0);
    signal serverState_Active        : std_logic_vector(SERVER_CAPACITY -1 downto 0):= (others => '0');
begin
    clientState_Server_out <= clientState_Server;
    clientState_Active_out <= clientState_Active;
    serverState_Client_out <= serverState_Client;
    serverState_Active_out <= serverState_Active;
    server_list:  for i in SERVER_CAPACITY-1 downto 0 generate    
        server: process(clk)
            begin
                if(rising_edge(clk)) then
                    if(write_mode = '1') then
                        if(server_input = i) then
                            serverState_Client((i+1) * CLIENT_LOG - 1 downto i * CLIENT_LOG) <= client_input;
                            serverState_Active(i) <= '1';
                        end if; 
                    elsif(delete_mode = '1')  then
                        if(serverState_Client((i+1) * CLIENT_LOG - 1 downto i * CLIENT_LOG) = client_input) then
                            serverState_Active(i) <= '0';
                        end if;
                    end if;
                end if;
        end process;        
    end generate;
    client_list:  for i in CLIENT_CAPACITY-1 downto 0 generate    
        client: process(clk)
            begin
                if(rising_edge(clk)) then
                    if(write_mode = '1') then
                        if(client_input = i) then
                            clientState_Server((i+1) * SERVER_LOG - 1 downto i * SERVER_LOG) <= server_input;
                            clientState_Active(i) <= '1';
                        end if;
                    elsif(delete_mode = '1')  then
                        if(client_input = i) then
                            clientState_Active(i) <= '0';
                        end if;
                    end if;
                end if;
        end process;      
    end generate;
end Behavioral;
