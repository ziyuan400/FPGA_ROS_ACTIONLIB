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
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity switch_tb is
    generic (
            BITS               : integer := 8;
            CLIENT_CAPACITY    : integer := 4;
            SERVER_CAPACITY    : integer := 2
        );
end switch_tb;

architecture Behavioral of switch_tb is
    component Switch is
        generic (
            BITS               : integer := 8;
            CLIENT_CAPACITY    : integer := 8;
            SERVER_CAPACITY    : integer := 8
        );
        Port (
            goal: in std_logic_vector(CLIENT_CAPACITY-1 downto 0);
            cancel: in std_logic_vector(CLIENT_CAPACITY-1 downto 0);
            
            axis_tdata_goal_in: in STD_LOGIC_VECTOR (8 * CLIENT_CAPACITY - 1 downto 0 );
            axis_tlast_goal_in: in STD_LOGIC_VECTOR (CLIENT_CAPACITY - 1 downto 0 );
            axis_tready_goal_out: out STD_LOGIC_VECTOR (CLIENT_CAPACITY - 1 downto 0 );
            axis_tvalid_goal_in: in STD_LOGIC_VECTOR (CLIENT_CAPACITY - 1 downto 0 );
            axis_tdata_goal_out: out STD_LOGIC_VECTOR (8 * SERVER_CAPACITY - 1 downto 0 );
            axis_tlast_goal_out: out STD_LOGIC_VECTOR (SERVER_CAPACITY - 1 downto 0 );
            axis_tready_goal_in: in STD_LOGIC_VECTOR (SERVER_CAPACITY - 1 downto 0 );
            axis_tvalid_goal_out: out STD_LOGIC_VECTOR (SERVER_CAPACITY - 1 downto 0 );
            
            axis_tdata_result_in: in STD_LOGIC_VECTOR (8 * SERVER_CAPACITY - 1 downto 0 );
            axis_tlast_result_in: in STD_LOGIC_VECTOR (SERVER_CAPACITY - 1 downto 0 );
            axis_tready_result_out: out STD_LOGIC_VECTOR (SERVER_CAPACITY - 1 downto 0 );
            axis_tvalid_result_in: in STD_LOGIC_VECTOR (SERVER_CAPACITY - 1 downto 0 );                
            axis_tdata_result_out: out STD_LOGIC_VECTOR (8 * CLIENT_CAPACITY - 1 downto 0 );
            axis_tlast_result_out: out STD_LOGIC_VECTOR (CLIENT_CAPACITY - 1 downto 0 );
            axis_tready_result_in: in STD_LOGIC_VECTOR (CLIENT_CAPACITY - 1 downto 0 );
            axis_tvalid_result_out: out STD_LOGIC_VECTOR (CLIENT_CAPACITY - 1 downto 0 );
            
            clientState_Server: in std_logic_vector(CLIENT_CAPACITY * integer(ceil(log2(real(SERVER_CAPACITY))))-1 downto 0);           
            clientState_Active: in std_logic_vector(CLIENT_CAPACITY -1 downto 0):= (others => '0');      
            
            goal_to_server: out std_logic_vector(SERVER_CAPACITY -1 downto 0);  
            cancel_to_server: out  std_logic_vector(SERVER_CAPACITY -1 downto 0);    
            read_server_state: in std_logic_vector(4 * SERVER_CAPACITY -1 downto 0);             
            write_server_state_to_client: out std_logic_vector(4 * CLIENT_CAPACITY -1 downto 0)
            
         );
    end component;
    constant clock_period: time := 10 ns;
    signal input: STD_LOGIC_VECTOR (BITS*CLIENT_CAPACITY-1 downto 0);
--    signal o: STD_LOGIC_VECTOR (BITS-1 downto 0);
--    signal n: STD_LOGIC_VECTOR (WAY-1 downto 0);

begin
    --max8: Switch generic map(BITS,CLIENT_CAPACITY,SERVER_CAPACITY) port map (input,o,n);
    clocking: process
    begin
--        input<=x"AABBCCDD11223344"; wait for 10*clock_period;
--        input<=x"AABBCC6611223344"; wait for 10*clock_period;
--        input<=x"AABBE41111223344"; wait for 10*clock_period;
--        input<=x"AA77CC87112233D8"; wait for 10*clock_period;
--        input<=x"AABBCC331122E344"; wait for 10*clock_period;
--        input<=x"1122334455667788"; wait for 10*clock_period;
--        input<=x"1122334499667788"; wait for 10*clock_period;
--        input<=x"7981357945587896"; wait for 10*clock_period;
--        input<=x"1234567"; wait for 10*clock_period;
--        input<=x"7654321"; wait for 10*clock_period;
--        input<=x"1573925"; wait for 10*clock_period;
--        input<=x"7496482"; wait for 10*clock_period;
--        input<=x"48"; wait for 10*clock_period;
        wait;
    end process;


end Behavioral;
