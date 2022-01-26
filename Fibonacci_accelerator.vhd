----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/26/2022 01:27:40 PM
-- Design Name: 
-- Module Name: Fibonacci_accelerator - Behavioral
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
entity Fibonacci_accelerator is
generic (
        BITS    : integer := 8
        );
Port (  
        clk : in STD_LOGIC;
        goal : in STD_LOGIC;
        reset : in STD_LOGIC;
        status: in std_logic_vector(3 downto 0);  
        
        setAccepted: out std_logic;
        setRejected: out std_logic;
        setSucceeded: out std_logic;
        setAborted: out std_logic;
        setCanceled: out std_logic;           
        
        sCom_axis_tdata : in STD_LOGIC_VECTOR ( 7 downto 0 );
        sCom_axis_tlast : in STD_LOGIC_VECTOR ( 0 to 0 );
        sCom_axis_tready : out STD_LOGIC_VECTOR ( 0 to 0 );
        sCom_axis_tvalid : in STD_LOGIC_VECTOR ( 0 to 0 )
     );
end Fibonacci_accelerator;

architecture Behavioral of Fibonacci_accelerator is
   
  component AXIS_to_std_msgs_String
    Port (
        clk                         : in std_logic;
        rst                         : in std_logic;
        -- AXIS Slave
        s_axis_tvalid               : in std_logic;
        s_axis_tdata                : in std_logic_vector (7 downto 0);
        s_axis_tlast                : in std_logic;
        s_axis_tready               : out std_logic;

        -- ROS message definition
        total_length_out : out std_logic_vector(31 downto 0);
        data_length_out : out std_logic_vector(31 downto 0);
        data_tdata_out : out std_logic_vector(7 downto 0);
        data_tvalid_out : out std_logic;
        data_tlast_out : out std_logic;
        data_tready_in : in std_logic;

        -- Control signals
        newData : out std_logic;
        allRead : in std_logic
        );
  end component;
  
    
  -- ROS message definition
  signal total_length :  std_logic_vector(31 downto 0);
  signal data_length :  std_logic_vector(31 downto 0);
  signal data_tdata :  std_logic_vector(7 downto 0);
  signal data_tvalid :  std_logic;
  signal data_tlast :  std_logic;
  signal data_tready :  std_logic:= '1';

  -- Control signals
  signal newData :  std_logic;
  signal allRead :  std_logic;
  

    -- Msg defined in Fibonacci.action
    -- Goal Topic {int32 order }
    signal goal_order:  std_logic_vector(31 downto 0);    
    -- Feedback Topic {int32[] sequence }
    signal feedback_sequence:  std_logic_vector(31 downto 0);    
    -- Result Topic {int32[] sequence }
    signal result_sequence:  std_logic_vector(31 downto 0);
    
    --Function Fibonacci
    signal order: std_logic_vector(7 downto 0):= (others=>'0');
    signal swap_count: std_logic_vector(1 downto 0):= (others=>'0');
    signal first: std_logic_vector(31 downto 0):= (others=>'0');
    signal second: std_logic_vector(31 downto 0):= (others=>'0');
    signal third: std_logic_vector(31 downto 0):= (others=>'0');
    
    
begin
    setAccepted <= '1' when goal = '1' and goal_order > 0 and goal_order < 30;
    setRejected <= '1' when goal = '1' and (goal_order = 0 or goal_order >= 30);
    setSucceeded <= '1' when order = goal_order;
    setCanceled <= '1' when status = x"4";
    result_sequence <= third when status = x"6";
    feedback_sequence <= third when status = x"9";
    
    a2m: AXIS_to_std_msgs_String Port map(

          clk              => clk,
          rst            => reset,
          s_axis_tdata  => sCom_axis_tdata,
          s_axis_tlast  => sCom_axis_tlast(0),
          s_axis_tready => sCom_axis_tready(0),
          s_axis_tvalid => sCom_axis_tvalid(0),
          total_length_out => total_length,
          data_length_out => data_length,
          data_tdata_out => data_tdata,
          data_tvalid_out => data_tvalid,
          data_tlast_out => data_tlast,
          data_tready_in => data_tready,
          newData  => newData,
          allRead  => allRead
    
    );

    fibonacci: process(clk)
    begin
        if(rising_edge(clk) and second = 0) then
            second <= second + '1';         
        end if;
        if(rising_edge(clk) and status = 2 and order < goal_order) then
            if (swap_count = 0) then
                third <= first + second;
                swap_count <= swap_count + '1';
            elsif (swap_count = 1) then
                first <= second; 
                swap_count <= swap_count + '1';
            elsif (swap_count = 2) then
                second <= third;
                order <= order + '1';
                swap_count <= "00";
            end if;            
        end if;
    end process;
end Behavioral;
