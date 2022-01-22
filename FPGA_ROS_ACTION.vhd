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

entity FPGA_ROS_ACTION is
    generic (
        BITS    : integer := 8
    );
    Port (
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        mCom_axis_tdata : out STD_LOGIC_VECTOR ( 7 downto 0 );
        mCom_axis_tlast : out STD_LOGIC_VECTOR ( 0 to 0 );
        mCom_axis_tready : in STD_LOGIC_VECTOR ( 0 to 0 );
        mCom_axis_tvalid : out STD_LOGIC_VECTOR ( 0 to 0 );
        sCom_axis_tdata : in STD_LOGIC_VECTOR ( 7 downto 0 );
        sCom_axis_tlast : in STD_LOGIC_VECTOR ( 0 to 0 );
        sCom_axis_tready : out STD_LOGIC_VECTOR ( 0 to 0 );
        sCom_axis_tvalid : in STD_LOGIC_VECTOR ( 0 to 0 )
     );end FPGA_ROS_ACTION;

architecture Behavioral of FPGA_ROS_ACTION is
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
  signal data_tready :  std_logic;

  -- Control signals
  signal newData :  std_logic;
  signal allRead :  std_logic;
  
begin


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

m2a: std_msgs_String_to_AXIS Port map(
              clk              => clk,
              rst            => reset,
              m_axis_tdata  => mCom_axis_tdata,
              m_axis_tlast  => mCom_axis_tlast(0),
              m_axis_tready => mCom_axis_tready(0),
              m_axis_tvalid => mCom_axis_tvalid(0),
              total_length_in => total_length,
              data_length_in => data_length,
              data_tdata_in => data_tdata,
              data_tvalid_in => data_tvalid,
              data_tlast_in => data_tlast,
              data_tready_out => data_tready,
              newData  => newData,
              allRead  => allRead
);











end Behavioral;
