----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/03/2022 07:43:08 PM
-- Design Name: 
-- Module Name: switch_tb - Behavioral
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
use IEEE.math_real.all;
use ieee.std_logic_unsigned.all;
entity scheduler_tb is generic (
        BITS               : integer := 8;
        CLIENT_CAPACITY    : integer := 4;
        SERVER_CAPACITY    : integer := 2
    );
end scheduler_tb;

architecture Behavioral of scheduler_tb is
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
component scheduler_spin is
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
        clientState_Active_out: out std_logic_vector(CLIENT_CAPACITY -1 downto 0)
    );
end component;
    constant clock_period: time := 10 ns;

    signal  clk:    STD_LOGIC;
    signal  reset:  STD_LOGIC;
    signal  goal:    std_logic_vector(CLIENT_CAPACITY-1 downto 0);
    signal  cancel:  std_logic_vector(CLIENT_CAPACITY-1 downto 0);
    signal  goal_to_server:    std_logic_vector(SERVER_CAPACITY-1 downto 0);
    signal  cancel_to_server:  std_logic_vector(SERVER_CAPACITY-1 downto 0);
    signal  finish:  std_logic_vector(CLIENT_CAPACITY-1 downto 0);
    
    signal  setSucceeded: std_logic_vector(SERVER_CAPACITY -1 downto 0);
    signal  setAccepted: std_logic_vector(SERVER_CAPACITY -1 downto 0);
    signal  read_server_state: std_logic_vector(4 * SERVER_CAPACITY -1 downto 0);
    signal  clientState_Server:   std_logic_vector(CLIENT_CAPACITY * integer(ceil(log2(real(SERVER_CAPACITY))))-1 downto 0);
    signal  clientState_Active:   std_logic_vector(CLIENT_CAPACITY -1 downto 0);   

begin
    scheduler: scheduler_spin generic map(BITS,CLIENT_CAPACITY, SERVER_CAPACITY) port map (clk,reset, goal,cancel,finish, read_server_state,clientState_Server, clientState_Active );
    serverstate: Server generic map(SERVER_CAPACITY) port map (clk,reset,goal_to_server,cancel_to_server,setAccepted, (others=>'0'), setSucceeded, (others=>'0'), (others=>'0'),read_server_state);
    examples: process
    begin
   
          goal<="1111"; cancel<="0000"; finish<="0000"; setAccepted<="00"; wait for 1*clock_period;
          goal<="0011"; cancel<="0000"; finish<="0000"; setSucceeded<="00"; wait for 10*clock_period;
          goal<="0011"; cancel<="0000"; finish<="1100"; setSucceeded<="00"; wait for 10*clock_period;
--      --input<="gcfssssgcfssssgcfssssgcfssss"; wait for 10*clock_period;
--        input<="1000000100000010000001000000"; wait for 10*clock_period;
--        input<="1000010100001010000001000000"; wait for 10*clock_period;
--        input<="0010110001011010000001000000"; wait for 10*clock_period;
--        input<="1000000100000010000001000000"; wait for 10*clock_period;
--        input<="1000000100000010000001000000"; wait for 10*clock_period;
        wait;
    end process;   
    

    clocking: process
        variable stop_the_clock: integer:=0;
    begin
        while stop_the_clock<100 loop
            clk <= '1', '0' after clock_period / 2;
            stop_the_clock:=stop_the_clock+1;
            wait for clock_period;
        end loop;
        wait;
    end process;
end Behavioral;