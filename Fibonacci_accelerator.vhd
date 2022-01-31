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
        
        m_axis_tdata : out STD_LOGIC_VECTOR ( 7 downto 0 );
        m_axis_tlast : out STD_LOGIC_VECTOR ( 0 to 0 );
        m_axis_tready : in STD_LOGIC_VECTOR ( 0 to 0 );
        m_axis_tvalid : out STD_LOGIC_VECTOR ( 0 to 0 );        
        s_axis_tdata : in STD_LOGIC_VECTOR ( 7 downto 0 );
        s_axis_tlast : in STD_LOGIC_VECTOR ( 0 to 0 );
        s_axis_tready : out STD_LOGIC_VECTOR ( 0 to 0 );
        s_axis_tvalid : in STD_LOGIC_VECTOR ( 0 to 0 )
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
  component std_msgs_String_to_AXIS
      Port (
        clk                         : in std_logic;
        rst                         : in std_logic;
        -- AXIS Master
        m_axis_tvalid               : out std_logic;
        m_axis_tdata                : out std_logic_vector (BITS-1 downto 0);
        m_axis_tlast                : out std_logic;
        m_axis_tready               : in std_logic;

        -- ROS message definition
        total_length_in : in std_logic_vector(31 downto 0);
        data_length_in : in std_logic_vector(31 downto 0);
        data_tdata_in : in std_logic_vector(7 downto 0);
        data_tvalid_in : in std_logic;
        data_tlast_in : in std_logic;
        data_tready_out : out std_logic;

        -- Control signals
        newData : in std_logic;
        allRead : out std_logic
      );
    end component; 

    -- ROS message definition
    signal total_length_result:  std_logic_vector(31 downto 0);
    signal data_length_result :  std_logic_vector(31 downto 0);
    signal data_tdata_result :  std_logic_vector(7 downto 0);
    signal data_tvalid_result :  std_logic;
    signal data_tlast_result :  std_logic;
    signal data_tready_result :  std_logic;
    signal total_length_goal :  std_logic_vector(31 downto 0);
    signal data_length_goal :  std_logic_vector(31 downto 0);
    signal data_tdata_goal :  std_logic_vector(7 downto 0);
    signal data_tvalid_goal :  std_logic;
    signal data_tlast_goal :  std_logic;
    signal data_tready_goal :  std_logic;
    
    -- Control signals
    signal newData_goal :  std_logic;
    signal allRead_goal :  std_logic;  
    signal newData_result :  std_logic;
    signal allRead_result :  std_logic; 
    
    signal read_counter: std_logic_vector(2 downto 0):="000";
    signal write_counter: std_logic_vector(2 downto 0):="000";
    
    -- Msg defined in Fibonacci.action
    -- Goal Topic {int32 order }
    signal goal_order:  std_logic_vector(31 downto 0);    
    -- Feedback Topic {int32[] sequence }
    signal feedback_sequence:  std_logic_vector(31 downto 0);    
    -- Result Topic {int32[] sequence }
    signal result_sequence:  std_logic_vector(31 downto 0);
    
    --Function Fibonacci
    signal order: std_logic_vector(31 downto 0):= (others=>'0');
    signal swap_count: std_logic_vector(1 downto 0):= (others=>'0');
    signal first: std_logic_vector(31 downto 0):= x"00000000";
    signal second: std_logic_vector(31 downto 0):= x"00000001";
    signal third: std_logic_vector(31 downto 0):= x"00000000";    
    
begin
    Read_goal_topic: AXIS_to_std_msgs_String port map(        
        clk => clk,
        rst => rst,
        -- AXIS Slave
        s_axis_tvalid => s_axis_tvalid(0),
        s_axis_tdata => s_axis_tdata,
        s_axis_tlast => s_axis_tlast(0),
        s_axis_tready => s_axis_tready(0),
        -- ROS message definition
        total_length_out => total_length_goal,
        data_length_out  => data_length_goal,
        data_tdata_out  => data_tdata_goal,
        data_tvalid_out  => data_tvalid_goal,
        data_tlast_out => data_tlast_goal,
        data_tready_in  => data_tready_goal,
        -- Control signals
        newData => newData_goal,
        allRead  => allRead_goal
    );
    
    Write_result_topic: std_msgs_String_to_AXIS port map(        
        clk => clk,
        rst => rst,
        -- AXIS Slave
        m_axis_tvalid => m_axis_tvalid(0),
        m_axis_tdata => m_axis_tdata,
        m_axis_tlast => m_axis_tlast(0),
        m_axis_tready => m_axis_tready(0),
        -- ROS message definition
        total_length_in => total_length_result,
        data_length_in  => data_length_result,
        data_tdata_in  => data_tdata_result,
        data_tvalid_in  => data_tvalid_result,
        data_tlast_in => data_tlast_result,
        data_tready_out  => data_tready_result,
        -- Control signals
        newData => newData_result,
        allRead  => allRead_result
    );

    setCanceled <= '1' when status = x"4";
    result_sequence <= third when status = x"6";
    feedback_sequence <= third when status = x"9";
    
    Fibonacci: process(clk)
    begin
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
        elsif(status = x"6" or status = x"7" or status = x"8" or status = x"9") then         
            first <= x"00000000";
            second <= x"00000001";
            third <= x"00000000";  
            order <= x"00000000";        
        end if;
    end process;
    
    Fibonacci_reader: process(clk)
    begin
        if(rising_edge(clk)) then
            if(status = x"1" and newData_goal = '1') then
                data_tready_goal<= '1';            
                if(data_tvalid_goal = '1' and read_counter = 0) then
                    goal_order(31 downto 24) <= data_tdata_goal;
                    read_counter <= read_counter + 1;
                elsif(data_tvalid_goal = '1' and read_counter = 1) then
                    goal_order(23 downto 16) <= data_tdata_goal;
                    read_counter <= read_counter + 1;
                elsif(data_tvalid_goal = '1' and read_counter = 2) then
                    goal_order(15 downto 8) <= data_tdata_goal;
                    read_counter <= read_counter + 1;
                elsif(data_tvalid_goal = '1' and read_counter = 3) then
                    goal_order(7 downto 0) <= data_tdata_goal;
                    allRead_goal <= '1';
                end if;                
                if(data_tlast_goal = '1' and status = x"1") then 
                    if(goal_order > 0 and goal_order < 30) then
                        setAccepted <= '1';   
                    elsif(goal_order = 0 or goal_order >= 30) then
                        setRejected <= '1';   
                    end if;
                end if;
            elsif(status = x"6" or status = x"7" or status = x"8" or status = x"9" ) then      
                read_counter <= "000";          
                data_tready_goal<= '0';   
                setAccepted <= '0';   
                setRejected <= '0';   
                allRead_goal <= '0';
            end if;                  
        end if;
    end process;    
    
    data_tdata_result <= third(7 downto 0) when data_tready_result = '1' and write_counter = 0 else
                     third(15 downto 8) when  data_tready_result = '1' and write_counter = 1 else
                     third(23 downto 16) when  data_tready_result = '1' and write_counter = 2 else
                     third(31 downto 24) when data_tready_result = '1' and write_counter = 3;

    Sequence_Writer: process(clk)
    begin
       if(rising_edge(clk)) then
            if(status = x"6" or status = x"7" or status = x"8" or status = x"9")  then                
                data_tvalid_result <= '0';    
                data_tlast_result <= '0';      
                newData_result <= '0';     
                total_length_result <= x"00000000";
                data_length_result <= x"00000000";   
            elsif(order = goal_order and allRead_result = '0')  then 
                newData_result <= '1';
                data_tvalid_result <= '1';               
                total_length_result <= x"00000008";
                data_length_result <= x"00000004";                
                if(write_counter = 3)then
                    data_tlast_result <= '1';
                    setSucceeded <= '1';
                    write_counter <= "000";
                elsif(write_counter < data_length_result) then
                        write_counter <= write_counter + '1';
                end if;                    
            end if;
            
        end if;    
    end process; 
    
end Behavioral;
