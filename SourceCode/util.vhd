----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/19/2022 03:41:14 AM
-- Design Name: 
-- Module Name: util - Behavioral
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

package util is 
    type AXIS  is array (integer range <>) of std_logic_vector(10 downto 0);
    function log(i: integer) return integer;
end util;
package body util is
    function log(i: integer) return integer is 
    begin
        if (i = 1) then 
            return 1; 
        else
            return integer(ceil(log2(real(i))));
        end if;
    end;
end util;

------------------------------------------------------------------------------
--Script:
--        axis_tdata_goal_in: in STD_LOGIC_VECTOR (8 * CLIENT_CAPACITY - 1 downto 0 );
--        axis_tlast_goal_in: in STD_LOGIC_VECTOR (CLIENT_CAPACITY - 1 downto 0 );
--        axis_tready_goal_out: out STD_LOGIC_VECTOR (CLIENT_CAPACITY - 1 downto 0 );
--        axis_tvalid_goal_in: in STD_LOGIC_VECTOR (CLIENT_CAPACITY - 1 downto 0 );
--        axis_tdata_goal_out: out STD_LOGIC_VECTOR (8 * SERVER_CAPACITY - 1 downto 0 );
--        axis_tlast_goal_out: out STD_LOGIC_VECTOR (SERVER_CAPACITY - 1 downto 0 );
--        axis_tready_goal_in: in STD_LOGIC_VECTOR (SERVER_CAPACITY - 1 downto 0 );
--        axis_tvalid_goal_out: out STD_LOGIC_VECTOR (SERVER_CAPACITY - 1 downto 0 );
--        axis_tdata_result_in: in STD_LOGIC_VECTOR (8 * SERVER_CAPACITY - 1 downto 0 );
--        axis_tlast_result_in: in STD_LOGIC_VECTOR (SERVER_CAPACITY - 1 downto 0 );
--        axis_tready_result_out: out STD_LOGIC_VECTOR (SERVER_CAPACITY - 1 downto 0 );
--        axis_tvalid_result_in: in STD_LOGIC_VECTOR (SERVER_CAPACITY - 1 downto 0 );
--        axis_tdata_result_out: out STD_LOGIC_VECTOR (8 * CLIENT_CAPACITY - 1 downto 0 );
--        axis_tlast_result_out: out STD_LOGIC_VECTOR (CLIENT_CAPACITY - 1 downto 0 );
--        axis_tready_result_in: in STD_LOGIC_VECTOR (CLIENT_CAPACITY - 1 downto 0 );
--        axis_tvalid_result_out: out STD_LOGIC_VECTOR (CLIENT_CAPACITY - 1 downto 0 )
--            axis_tdata_goal_in =>axis_tdata_goal_in,
--            axis_tlast_goal_in =>axis_tlast_goal_in,
--            axis_tready_goal_out =>axis_tready_goal_out,
--            axis_tvalid_goal_in =>axis_tvalid_goal_in,
--            axis_tdata_goal_out =>axis_tdata_goal_out,
--            axis_tlast_goal_out =>axis_tlast_goal_out,
--            axis_tready_goal_in =>axis_tready_goal_in,
--            axis_tvalid_goal_out =>axis_tvalid_goal_out,
--            axis_tdata_result_in =>axis_tdata_result_in,
--            axis_tlast_result_in =>axis_tlast_result_in,
--            axis_tready_result_out =>axis_tready_result_out,
--            axis_tvalid_result_in =>axis_tvalid_result_in,
--            axis_tdata_result_out =>axis_tdata_result_out,
--            axis_tlast_result_out =>axis_tlast_result_out,
--            axis_tready_result_in =>axis_tready_result_in,
--            axis_tvalid_result_out =>axis_tvalid_result_out,
--    client_AXIS_bundle:  for i in CLIENT_CAPACITY-1 downto 0 generate
--        client_in(i) <= (axis_tready_result_in(i) & 
--                         axis_tvalid_goal_in(i) & 
--                         axis_tlast_goal_in(i) & 
--                         axis_tdata_goal_in(8 * i + 7 downto 8 * i));  
--        axis_tready_goal_out(i)  <= client_out(i)(10);
--        axis_tvalid_result_out(i)  <= client_out(i)(9);
--        axis_tlast_result_out(i)  <= client_out(i)(8);
--        axis_tdata_result_out(8 * i + 7 downto 8 * i) <= client_out(i)(7 downto 0);
--    end generate;
--    server_AXIS_bundle:  for i in SERVER_CAPACITY-1 downto 0 generate
--        server_in(i) <= (axis_tready_goal_in(i) & 
--                         axis_tvalid_result_in(i) & 
--                         axis_tlast_result_in(i) & 
--                         axis_tdata_result_in(8 * i + 7 downto 8 * i));  
--        axis_tready_result_out(i)  <= server_out(i)(10);
--        axis_tvalid_goal_out(i)  <= server_out(i)(9);
--        axis_tlast_goal_out(i)  <= server_out(i)(8);
--        axis_tdata_goal_out(8 * i + 7 downto 8 * i) <= server_out(i)(7 downto 0);
--    end generate;
    

--    axis_tready_goal_in(i downto i) <= axis_server_in(11 * i + 10 downto 11 * i);
--    axis_tvalid_result_in(i downto i) <= axis_server_in(11 * i + 9  downto 11 * i);
--    axis_tlast_result_in(i downto i) <= axis_server_in(11 * i + 8  downto 11 * i);
--    axis_tdata_result_in(8 * i + 7 downto 8 * i) <= axis_server_in(11 * i + 7 downto 11 * i);

    
--    index: for j in CLIENT_CAPACITY-1 downto 0 generate
--         bitmap(i*CLIENT_CAPACITY+j) <= '1' when clientState_Server (SERVER_LOG*(j+1)-1 downto SERVER_LOG*j) = i and clientState_Active(j) = '1' else '0';
--    end generate;
    
--    serving_client: onehot_to_number generic map (CLIENT_CAPACITY, CLIENT_LOG) port map (bitmap(CLIENT_CAPACITY*(i+1)-1 downto CLIENT_CAPACITY*i), serverState_Client(CLIENT_LOG*(i+1)-1 downto CLIENT_LOG*i) );

--    serverState_Active_mux: MUX_with_switch generic map (1, CLIENT_CAPACITY) port map 
--    (clientState_Active , serverState_Active(i downto i), serverState_Client(CLIENT_LOG*(i+1)-1 downto CLIENT_LOG*i), '1');