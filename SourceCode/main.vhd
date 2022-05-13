----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/26/2022 05:07:34 PM
-- Design Name: 
-- Module Name: main - Behavioral
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

entity main is
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

        m_axis_tdata : out STD_LOGIC_VECTOR ( 7 downto 0 );
        m_axis_tlast : out STD_LOGIC_VECTOR ( 0 to 0 );
        m_axis_tready : in STD_LOGIC_VECTOR ( 0 to 0 );
        m_axis_tvalid : out STD_LOGIC_VECTOR ( 0 to 0 );
        s_axis_tdata : in STD_LOGIC_VECTOR ( 7 downto 0 );
        s_axis_tlast : in STD_LOGIC_VECTOR ( 0 to 0 );
        s_axis_tready : out STD_LOGIC_VECTOR ( 0 to 0 );
        s_axis_tvalid : in STD_LOGIC_VECTOR ( 0 to 0 );
        
        m_axis_tdata_write_file : out STD_LOGIC_VECTOR ( 7 downto 0 );
        m_axis_tlast_write_file : out STD_LOGIC_VECTOR ( 0 to 0 );
        m_axis_tready_write_file : in STD_LOGIC_VECTOR ( 0 to 0 );
        m_axis_tvalid_write_file : out STD_LOGIC_VECTOR ( 0 to 0 );
        s_axis_tdata_read_file : in STD_LOGIC_VECTOR ( 7 downto 0 );
        s_axis_tlast_read_file : in STD_LOGIC_VECTOR ( 0 to 0 );
        s_axis_tready_read_file : out STD_LOGIC_VECTOR ( 0 to 0 );
        s_axis_tvalid_read_file : in STD_LOGIC_VECTOR ( 0 to 0 )
    );
end main;

architecture Behavioral of main is
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
    signal total_length_result:  std_logic_vector(31 downto 0):=(others=>'0');
    signal data_length_result :  std_logic_vector(31 downto 0):=(others=>'0');
    signal data_tdata_result :  std_logic_vector(7 downto 0):=(others=>'0');
    signal data_tvalid_result :  std_logic:='0';
    signal data_tlast_result :  std_logic:='0';
    signal data_tready_result :  std_logic:='0';
    signal total_length_goal :  std_logic_vector(31 downto 0):=(others=>'0');
    signal data_length_goal :  std_logic_vector(31 downto 0):=(others=>'0');
    signal data_tdata_goal :  std_logic_vector(7 downto 0):=(others=>'0');
    signal data_tvalid_goal :  std_logic:='0';
    signal data_tlast_goal :  std_logic:='0';
    signal data_tready_goal :  std_logic:='0';
    signal file2goal_ready :  std_logic:='0';
    
    -- Control signals
    signal newData_goal :  std_logic:='1';
    signal allRead_goal :  std_logic:='0';  
    signal newData_result :  std_logic:='1';
    signal allRead_result :  std_logic:='0'; 
    
    signal read_counter: std_logic_vector(3 downto 0):=  (others => '0');
    signal write_counter: std_logic_vector(3 downto 0) :=  (others => '0');

    signal goal_total_length:  std_logic_vector(31 downto 0):= x"00000000";
    signal goal_data_length:  std_logic_vector(31 downto 0):= x"00000000";
    -- Msg defined in Fibonacci.action
    -- Goal Topic {int32 order }
    signal goal_order:  std_logic_vector(31 downto 0):= x"00000000";
    -- Feedback Topic {int32[] sequence }
    signal feedback_sequence:  std_logic_vector(31 downto 0);
    -- Result Topic {int32[] sequence }
    signal result_sequence:  std_logic_vector(31 downto 0);

begin
  Read_result_topic: AXIS_to_std_msgs_String port map(        
        clk => clk,
        rst => rst,
        -- AXIS Slave
        s_axis_tvalid => s_axis_tvalid(0),
        s_axis_tdata => s_axis_tdata,
        s_axis_tlast => s_axis_tlast(0),
        s_axis_tready => s_axis_tready(0),
        -- ROS message definition
        total_length_out => total_length_result,
        data_length_out  => data_length_result,
        data_tdata_out  => data_tdata_result,
        data_tvalid_out  => data_tvalid_result,
        data_tlast_out => data_tlast_result,
        data_tready_in  => data_tready_result,
        -- Control signals
        newData => newData_result,
        allRead  => allRead_result
    );
    
  Write_goal_topic: std_msgs_String_to_AXIS port map(        
        clk => clk,
        rst => rst,
        -- AXIS Slave
        m_axis_tvalid => m_axis_tvalid(0),
        m_axis_tdata => m_axis_tdata,
        m_axis_tlast => m_axis_tlast(0),
        m_axis_tready => m_axis_tready(0),
        -- ROS message definition
        total_length_in => total_length_goal,
        data_length_in  => data_length_goal,
        data_tdata_in  => data_tdata_goal,
        data_tvalid_in  => data_tvalid_goal,
        data_tlast_in => data_tlast_goal,
        data_tready_out  => data_tready_goal,
        -- Control signals
        newData => newData_goal,
        allRead  => allRead_goal
    );
 
    s_axis_tready_read_file(0) <= '1' when (write_counter > 8 and data_tready_goal = '1') or write_counter < 9 else '0'; 
    data_tdata_goal <=   s_axis_tdata_read_file when data_tvalid_goal = '1' and 
                        ( write_counter = 9 or write_counter = 10 or write_counter = 11 or write_counter = 12)
                         else (others => '0');       
    send_goal <= s_axis_tvalid_read_file(0);    
    
   
    total_length_goal <= goal_total_length when allread_goal = '0' else (others => '0');
    data_length_goal <= goal_data_length when allread_goal = '0' else (others => '0');
    data_tlast_goal <= '1' when write_counter = 12 else '0';
    data_tvalid_goal <= data_tready_goal  and newData_goal;
    
    Fibonacci_requst: process(clk)
    begin
        if(rising_edge(clk)) then
            if(newData_goal = '0' and allRead_result = '1') then 
                newData_goal <= '1';
            end if;
            if(allread_goal = '1' and write_counter = 12) then
                newData_goal <= '0';
                write_counter <=  (others => '0');
                goal_total_length <=  (others => '0');
                goal_data_length <=  (others => '0');
                goal_order <=  (others => '0');
            elsif(s_axis_tvalid_read_file(0) = '1') then  
                if(write_counter = 0) then
                    write_counter <= write_counter +1;
                elsif(write_counter = 1) then
                    goal_total_length(7 downto 0) <= s_axis_tdata_read_file;
                    write_counter <= write_counter +1;
                elsif (write_counter = 2) then
                    goal_total_length(15 downto 8) <= s_axis_tdata_read_file;
                    write_counter <= write_counter +1;
                elsif (write_counter = 3) then
                    goal_total_length(23 downto 16) <= s_axis_tdata_read_file;
                    write_counter <= write_counter +1;
                elsif (write_counter = 4) then
                    goal_total_length(31 downto 24) <= s_axis_tdata_read_file;
                    write_counter <= write_counter +1;
                elsif(write_counter = 5) then
                    goal_data_length(7 downto 0) <= s_axis_tdata_read_file;
                    write_counter <= write_counter +1;
                elsif (write_counter = 6) then
                    goal_data_length(15 downto 8) <= s_axis_tdata_read_file;
                    write_counter <= write_counter +1;
                elsif (write_counter = 7) then
                    goal_data_length(23 downto 16) <= s_axis_tdata_read_file;
                    write_counter <= write_counter +1;
                elsif (write_counter = 8) then
                    goal_data_length(31 downto 24) <= s_axis_tdata_read_file;
                    write_counter <= write_counter +1;
                    
                elsif(write_counter = 9 and data_tready_goal = '1') then
                    write_counter <= write_counter +1;
                elsif (write_counter = 10) then
                    write_counter <= write_counter +1;
                elsif (write_counter = 11) then
                    write_counter <= write_counter +1;
                elsif (write_counter = 12) then
                    write_counter <= write_counter +1;
                elsif (write_counter = 13) then
                    write_counter <= write_counter +1;
                elsif (write_counter = 14) then
                    write_counter <= write_counter +1;
                end if;              
            end if;
        end if;
    end process;
    
    
    Receive_result: process(clk)
    begin
        if(rising_edge(clk)) then
            if(newData_result = '1' and data_tvalid_result = '1') then
                if(read_counter = 0) then
                    read_counter <= read_counter +'1';
                elsif (read_counter = 1) then
                    read_counter <= read_counter +'1';
                elsif (read_counter = 2) then
                    read_counter <= read_counter +'1';
                elsif (read_counter = 3) then
                    read_counter <= read_counter +'1';
                    allRead_result <= '1';
                end if;
            end if;
            if(newData_result = '0') then
                read_counter<= (others => '0');
                allRead_result <= '0';
            end if;
        end if;
    end process;
    
    receive_result_msg <= allRead_result;
    data_tready_result <= not allRead_result;
    result_sequence(7 downto 0) <= data_tdata_result when read_counter = 0 else (others => '0');
    result_sequence(15 downto 8) <= data_tdata_result when read_counter = 1 else (others => '0');
    result_sequence(23 downto 16) <= data_tdata_result when read_counter = 2 else (others => '0');
    result_sequence(31 downto 24) <= data_tdata_result when read_counter = 3 else (others => '0');
                    
    m_axis_tlast_write_file(0) <= '1' when read_counter >  3 else '0';
    m_axis_tvalid_write_file(0) <= data_tvalid_result;
    m_axis_tdata_write_file <= result_sequence(7 downto 0) when (read_counter = 0 and data_tvalid_result = '1') else
                            result_sequence(15 downto 8) when (read_counter = 1 and data_tvalid_result = '1') else
                            result_sequence(23 downto 16) when (read_counter = 2 and data_tvalid_result = '1') else
                            result_sequence(31 downto 24) when (read_counter = 3 and data_tvalid_result = '1') else
                            (others => '0');
end Behavioral;
