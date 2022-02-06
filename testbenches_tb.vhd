library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;
use ieee.std_logic_unsigned.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity testbenches_tb is
end;

architecture bench of testbenches_tb is

  component FPGA_ROS_ACTION
      Port (
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;     
        -- from client
        clinet_status: out std_logic_vector(3 downto 0); 
        client_id: in std_logic_vector(3 downto 0);
        server_id: in std_logic_vector(3 downto 0);        
        send_goal: in STD_LOGIC;
        cancel_goal: in STD_LOGIC;
        receive_result_msg: in STD_LOGIC;  
        -- to server
        setAccepted: in std_logic;
        setRejected: in std_logic;
        setSucceeded: in std_logic;
        setAborted: in std_logic;
        setCanceled: in std_logic;        
        status: out std_logic_vector(3 downto 0)
      );
  end component; 
  component main
      Port (
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        clinet_state: in std_logic_vector(3 downto 0); 
        client_id: out std_logic_vector(3 downto 0);
        server_id: out std_logic_vector(3 downto 0);        
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
        m_axis_tdata_to_file : out STD_LOGIC_VECTOR ( 7 downto 0 );
        m_axis_tlast_to_file : out STD_LOGIC_VECTOR ( 0 to 0 );
        m_axis_tready_to_file : in STD_LOGIC_VECTOR ( 0 to 0 );
        m_axis_tvalid_to_file : out STD_LOGIC_VECTOR ( 0 to 0 );
        s_axis_tdata_from_file : out STD_LOGIC_VECTOR ( 7 downto 0 );
        s_axis_tlast_from_file : out STD_LOGIC_VECTOR ( 0 to 0 );
        s_axis_tready_from_file : in STD_LOGIC_VECTOR ( 0 to 0 );
        s_axis_tvalid_from_file : out STD_LOGIC_VECTOR ( 0 to 0 ));
  end component;
  component Fibonacci_accelerator
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
        s_axis_tvalid : in STD_LOGIC_VECTOR ( 0 to 0 ));
  end component;

  signal clk: STD_LOGIC;
  signal reset: STD_LOGIC;
  
  signal mCom_axis_tdata: STD_LOGIC_VECTOR ( 7 downto 0 );
  signal mCom_axis_tlast: STD_LOGIC_VECTOR ( 0 to 0 );
  signal mCom_axis_tready: STD_LOGIC_VECTOR ( 0 to 0 );
  signal mCom_axis_tvalid: STD_LOGIC_VECTOR ( 0 to 0 );
  signal sCom_axis_tdata: STD_LOGIC_VECTOR ( 7 downto 0 );
  signal sCom_axis_tlast: STD_LOGIC_VECTOR ( 0 to 0 );
  signal sCom_axis_tready: STD_LOGIC_VECTOR ( 0 to 0 );
  signal sCom_axis_tvalid: STD_LOGIC_VECTOR ( 0 to 0 );
  
  constant clock_period: time := 10 ns;
  signal stop_the_clock: boolean;

  signal total_length : std_logic_vector(31 downto 0) := (others=>'0');
--  signal s_total_length_valid : std_logic := '0';
--  signal s_BYTES : std_logic_vector(31 downto 0) := (others=>'0');
  signal s_ID : std_logic_vector(7 downto 0) := (others=>'0');

  signal st_count : std_logic_vector(31 downto 0) := (others=>'0');
--  signal st_valid, st_last : std_logic := '0';
--  signal st_data : std_logic_vector(7 downto 0) := (others=>'0');

  file input_file      : text;
  file output_file     : text;
  
  
  signal client_id: STD_LOGIC_VECTOR ( 3 downto 0 );
  signal server_id: STD_LOGIC_VECTOR ( 3 downto 0 );
  signal clinet_state: STD_LOGIC_VECTOR ( 3 downto 0 );
  signal send_goal: STD_LOGIC_VECTOR ( 0 to 0 );
  signal cancel_goal: STD_LOGIC_VECTOR ( 0 to 0 );
  signal receive_result_msg: STD_LOGIC_VECTOR ( 0 to 0 );  
  
  signal setAccepted: STD_LOGIC_VECTOR ( 0 to 0 );
  signal setRejected: STD_LOGIC_VECTOR ( 0 to 0 );
  signal setSucceeded: STD_LOGIC_VECTOR ( 0 to 0 );
  signal setAborted: STD_LOGIC_VECTOR ( 0 to 0 );
  signal setCanceled: STD_LOGIC_VECTOR ( 0 to 0 );
  signal status:  STD_LOGIC_VECTOR ( 3 downto 0 );
  
  signal axis_tdata_goal: STD_LOGIC_VECTOR ( 7 downto 0 );
  signal axis_tlast_goal: STD_LOGIC_VECTOR ( 0 to 0 );
  signal axis_tready_goal: STD_LOGIC_VECTOR ( 0 to 0 );
  signal axis_tvalid_goal: STD_LOGIC_VECTOR ( 0 to 0 );
  signal axis_tdata_result: STD_LOGIC_VECTOR ( 7 downto 0 );
  signal axis_tlast_result: STD_LOGIC_VECTOR ( 0 to 0 );
  signal axis_tready_result: STD_LOGIC_VECTOR ( 0 to 0 );
  signal axis_tvalid_result: STD_LOGIC_VECTOR ( 0 to 0 );

begin

  -- Insert values for generic parameters !!
  uut: FPGA_ROS_ACTION port map (
        clk              => clk,
        reset            => reset,
        -- from client
        clinet_status     => clinet_state,
        client_id        => client_id,
        server_id        => server_id,
        send_goal        => send_goal(0),
        cancel_goal      => cancel_goal(0),
        receive_result_msg => receive_result_msg(0),
        -- to server
        setAccepted      => setAccepted(0),
        setRejected      => setRejected(0),
        setSucceeded     => setSucceeded(0),
        setAborted       => setAborted(0),
        setCanceled      => setCanceled(0),
        status     => status );
   
  req: main port map (
        clk              => clk,
        rst            => reset,
        clinet_state     => clinet_state,
        client_id        => client_id,
        server_id        => server_id,
        send_goal        => send_goal(0),
        cancel_goal      => cancel_goal(0),
        receive_result_msg => receive_result_msg(0),
        m_axis_tdata  => axis_tdata_goal,
        m_axis_tlast  => axis_tlast_goal,
        m_axis_tready => axis_tready_goal,
        m_axis_tvalid => axis_tvalid_goal,
        s_axis_tdata  => axis_tdata_result,
        s_axis_tlast  => axis_tlast_result,
        s_axis_tready => axis_tready_result,
        s_axis_tvalid => axis_tvalid_result,
        
        m_axis_tdata_to_file => mCom_axis_tdata,
        m_axis_tlast_to_file  => mCom_axis_tlast,
        m_axis_tready_to_file  => mCom_axis_tready,
        m_axis_tvalid_to_file  => mCom_axis_tvalid,
        s_axis_tdata_from_file  => sCom_axis_tdata,
        s_axis_tlast_from_file  => sCom_axis_tlast,
        s_axis_tready_from_file  => sCom_axis_tready,
        s_axis_tvalid_from_file  =>  sCom_axis_tvalid );        
  func: Fibonacci_accelerator port map (
        clk              => clk,
        rst            => reset,  
        status => status,  
        setAccepted => setAccepted(0),
        setRejected => setRejected(0),
        setSucceeded => setSucceeded(0),
        setAborted => setAborted(0),
        setCanceled => setCanceled(0),        
        m_axis_tdata  => axis_tdata_result,
        m_axis_tlast  => axis_tlast_result,
        m_axis_tready => axis_tready_result,
        m_axis_tvalid => axis_tvalid_result,
        s_axis_tdata  => axis_tdata_goal,
        s_axis_tlast  => axis_tlast_goal,
        s_axis_tready => axis_tready_goal,
        s_axis_tvalid => axis_tvalid_goal );

--  tready: process
--  begin
--    mCom_axis_tready <= "0";
--    wait for 10*clock_period;
--    mCom_axis_tready <= "1";
--    wait;
--  end process;

  stream_process: process(clk)
    variable row_input          : line;
    variable v_number : std_logic_vector(7 downto 0);
    variable v_stopCount: boolean := false;
  begin
    if(rising_edge(clk)) then
        if(v_stopCount=false) then
            if(st_count=0) then
                sCom_axis_tdata <= (others=>'0');
                sCom_axis_tvalid <="0";
                sCom_axis_tlast <="0";                
                file_open(input_file, "/home/ziyuan/Projects/actionlib/stimulus_input.txt", read_mode);
                readline(input_file, row_input);
                hread(row_input, v_number);
                s_ID <= v_number;
                st_count <= st_count + '1';
                reset <= '1';
            elsif(st_count=1) then
                readline(input_file, row_input);    -- Reads Length
                hread(row_input, v_number);
                total_length(7 downto 0) <= v_number;
                st_count <= st_count + '1';
            elsif(st_count=2) then
                readline(input_file, row_input);    -- Reads Length
                hread(row_input, v_number);
                total_length(15 downto 8) <= v_number;
                st_count <= st_count + '1';
            elsif(st_count=3) then
                readline(input_file, row_input);    -- Reads Length
                hread(row_input, v_number);
                total_length(23 downto 16) <= v_number;
                st_count <= st_count + '1';
            elsif(st_count=4) then
                readline(input_file, row_input);    -- Reads Length
                hread(row_input, v_number);
                total_length(31 downto 24) <= v_number;
                st_count <= st_count + '1';
            elsif(st_count = total_length+11) then
                sCom_axis_tvalid <="0";
                sCom_axis_tdata <= (others=>'0');
                sCom_axis_tlast <="0";
                st_count <= (others=>'0');
            elsif(sCom_axis_tready="1") then
                if(st_count=5+0) then
                    sCom_axis_tvalid <="1";
                    sCom_axis_tdata <= s_ID;
                    st_count <= st_count + '1';
                elsif(st_count=5+1) then
                    sCom_axis_tdata <= total_length(7 downto 0);
                    st_count <= st_count + '1';
                elsif(st_count=5+2) then
                    sCom_axis_tdata <= total_length(15 downto 8);
                    st_count <= st_count + '1';
                elsif(st_count=5+3) then
                    sCom_axis_tdata <= total_length(23 downto 16);
                    st_count <= st_count + '1';
                elsif(st_count=5+4) then
                    sCom_axis_tdata <= total_length(31 downto 24);
                    st_count <= st_count + '1';
                else
                    readline(input_file, row_input);    -- Reads Length
                    hread(row_input, v_number);
                    sCom_axis_tdata <= v_number;
                    st_count <= st_count + '1';
                    if(st_count = total_length+9) then
                        sCom_axis_tlast <="1";
                    else
                        sCom_axis_tlast <="0";
                    end if;
                end if;
            end if;
        end if;
    end if;
  end process;

  output_assert_proc: process
      variable s_counter_assert_out :integer := 0;
      variable row_output          : line;
--      variable v_TOTALBYTES : natural;
  begin
     file_open(output_file, "/home/ziyuan/Projects/actionlib/testbench_output.txt", write_mode);
--     if(s_total_length_valid='1') then
--          v_TOTALBYTES := to_integer(unsigned(total_length));
--      end if;
      while (s_counter_assert_out < 1200) loop
          s_counter_assert_out := s_counter_assert_out + 1;
          if(mCom_axis_tvalid="1" and mCom_axis_tlast="0" ) then
              hwrite(row_output, mCom_axis_tdata);
              writeline(output_file, row_output);         
          end if;
          wait for clock_period;
      end loop;
      file_close(output_file);
      stop_the_clock <= true;
      wait;
  end process;

  clocking: process
  begin
    while not stop_the_clock loop
      clk <= '1', '0' after clock_period / 2;
      wait for clock_period;
    end loop;
    wait;
  end process;
end;
