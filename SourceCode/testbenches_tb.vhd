library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;
use ieee.std_logic_unsigned.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use work.util.all;

entity testbenches_tb is
    generic (
        BITS               : integer := 8;
        CLIENT_CAPACITY    : integer := 4;
        SERVER_CAPACITY    : integer := 2
    );
end;

architecture bench of testbenches_tb is
  component FPGA_ROS_ACTION
    generic (
        BITS               : integer;
        CLIENT_CAPACITY    : integer;
        SERVER_CAPACITY    : integer
    );
    Port (
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;     
        -- from client
        goal: in std_logic_vector(CLIENT_CAPACITY - 1 downto 0);
        cancel: in std_logic_vector(CLIENT_CAPACITY - 1 downto 0);
        finish: in std_logic_vector(CLIENT_CAPACITY - 1 downto 0);
        client_state: out std_logic_vector(4 * CLIENT_CAPACITY-1 downto 0); 
        -- to server
        setAccepted: in std_logic_vector(SERVER_CAPACITY -1  downto 0);
        setRejected: in std_logic_vector(SERVER_CAPACITY -1  downto 0);
        setSucceeded: in std_logic_vector(SERVER_CAPACITY -1  downto 0);
        setAborted: in std_logic_vector(SERVER_CAPACITY -1  downto 0);
        setCanceled: in std_logic_vector(SERVER_CAPACITY -1  downto 0);
        server_state: out std_logic_vector(4*SERVER_CAPACITY -1  downto 0);
        
        axis_client_in: in  AXIS (CLIENT_CAPACITY - 1 downto 0 );
        axis_client_out: out  AXIS (CLIENT_CAPACITY - 1 downto 0 );
        axis_server_in: in  AXIS (SERVER_CAPACITY - 1 downto 0 );
        axis_server_out: out  AXIS (SERVER_CAPACITY - 1 downto 0 )
     );
  end component; 
  component main
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
        s_axis_tvalid_read_file : in STD_LOGIC_VECTOR ( 0 to 0 ));
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
  
  signal mCom_axis_tdata: STD_LOGIC_VECTOR (8 * CLIENT_CAPACITY - 1 downto 0 );
  signal mCom_axis_tlast: STD_LOGIC_VECTOR (CLIENT_CAPACITY - 1 downto 0 );
  signal mCom_axis_tready: STD_LOGIC_VECTOR (CLIENT_CAPACITY - 1 downto 0 );
  signal mCom_axis_tvalid: STD_LOGIC_VECTOR (CLIENT_CAPACITY - 1 downto 0 );
  signal sCom_axis_tdata: STD_LOGIC_VECTOR (8 * CLIENT_CAPACITY - 1 downto 0 );
  signal sCom_axis_tlast: STD_LOGIC_VECTOR (CLIENT_CAPACITY - 1 downto 0 );
  signal sCom_axis_tready: STD_LOGIC_VECTOR (CLIENT_CAPACITY - 1 downto 0 );
  signal sCom_axis_tvalid: STD_LOGIC_VECTOR (CLIENT_CAPACITY - 1 downto 0 );
  
  constant clock_period: time := 10 ns;
  signal stop_the_clock: boolean;

  signal total_length : std_logic_vector(32 * CLIENT_CAPACITY - 1 downto 0) := (others=>'0');
--  signal s_total_length_valid : std_logic := '0';
--  signal s_BYTES : std_logic_vector(31 downto 0) := (others=>'0');
  signal s_ID : std_logic_vector(8 * CLIENT_CAPACITY - 1 downto 0) := (others=>'0');

  signal st_count : std_logic_vector(32 * CLIENT_CAPACITY - 1 downto 0) := (others=>'0');
--  signal st_valid, st_last : std_logic := '0';
--  signal st_data : std_logic_vector(7 downto 0) := (others=>'0');
 
  signal client_state: STD_LOGIC_VECTOR (4 * CLIENT_CAPACITY - 1 downto 0 );
  signal send_goal: STD_LOGIC_VECTOR (CLIENT_CAPACITY - 1 downto 0 );
  signal cancel_goal: STD_LOGIC_VECTOR (CLIENT_CAPACITY - 1 downto 0 );
  signal receive_result_msg: STD_LOGIC_VECTOR (CLIENT_CAPACITY - 1 downto 0 );  
  
  signal setAccepted: STD_LOGIC_VECTOR (SERVER_CAPACITY - 1 downto 0 );
  signal setRejected: STD_LOGIC_VECTOR (SERVER_CAPACITY - 1 downto 0 );
  signal setSucceeded: STD_LOGIC_VECTOR (SERVER_CAPACITY - 1 downto 0 );
  signal setAborted: STD_LOGIC_VECTOR (SERVER_CAPACITY - 1 downto 0 );
  signal setCanceled: STD_LOGIC_VECTOR (SERVER_CAPACITY - 1 downto 0 );
  signal status:  STD_LOGIC_VECTOR (4 * SERVER_CAPACITY - 1 downto 0 );
  
    signal client_in:   AXIS (CLIENT_CAPACITY - 1 downto 0 );
    signal client_out:   AXIS (CLIENT_CAPACITY - 1 downto 0 );
    signal server_in:   AXIS (SERVER_CAPACITY - 1 downto 0 );
    signal server_out:   AXIS (SERVER_CAPACITY - 1 downto 0 ); 
  signal axis_tdata_goal_in: STD_LOGIC_VECTOR (8 * CLIENT_CAPACITY - 1 downto 0 );
  signal axis_tlast_goal_in: STD_LOGIC_VECTOR (CLIENT_CAPACITY - 1 downto 0 );
  signal axis_tready_goal_out: STD_LOGIC_VECTOR (CLIENT_CAPACITY - 1 downto 0 );
  signal axis_tvalid_goal_in: STD_LOGIC_VECTOR (CLIENT_CAPACITY - 1 downto 0 );
  signal axis_tdata_goal_out: STD_LOGIC_VECTOR (8 * SERVER_CAPACITY - 1 downto 0 );
  signal axis_tlast_goal_out: STD_LOGIC_VECTOR (SERVER_CAPACITY - 1 downto 0 );
  signal axis_tready_goal_in: STD_LOGIC_VECTOR (SERVER_CAPACITY - 1 downto 0 );
  signal axis_tvalid_goal_out: STD_LOGIC_VECTOR (SERVER_CAPACITY - 1 downto 0 );
  signal axis_tdata_result_in: STD_LOGIC_VECTOR (8 * SERVER_CAPACITY - 1 downto 0 );
  signal axis_tlast_result_in: STD_LOGIC_VECTOR (SERVER_CAPACITY - 1 downto 0 );
  signal axis_tready_result_out: STD_LOGIC_VECTOR (SERVER_CAPACITY - 1 downto 0 );
  signal axis_tvalid_result_in: STD_LOGIC_VECTOR (SERVER_CAPACITY - 1 downto 0 );
  signal axis_tdata_result_out: STD_LOGIC_VECTOR (8 * CLIENT_CAPACITY - 1 downto 0 );
  signal axis_tlast_result_out: STD_LOGIC_VECTOR (CLIENT_CAPACITY - 1 downto 0 );
  signal axis_tready_result_in: STD_LOGIC_VECTOR (CLIENT_CAPACITY - 1 downto 0 );
  signal axis_tvalid_result_out: STD_LOGIC_VECTOR (CLIENT_CAPACITY - 1 downto 0 );
  
  file input_file0      : text;
  file output_file0     : text;  
  file input_file1      : text;
  file output_file1     : text;  
  file input_file2      : text;
  file output_file2     : text;  
  file input_file3      : text;
  file output_file3     : text;
  type file_list is array (CLIENT_CAPACITY-1 downto 0) of string(1 to 51);
  signal INPUT_LIST : file_list;
  signal OUTPUT_LIST : file_list;
  signal v_stopCount: boolean := false;
begin
    client_AXIS_bundle:  for i in CLIENT_CAPACITY-1 downto 0 generate
        client_in(i) <= (axis_tready_result_in(i) & 
                         axis_tvalid_goal_in(i) & 
                         axis_tlast_goal_in(i) & 
                         axis_tdata_goal_in(8 * i + 7 downto 8 * i));  
        axis_tready_goal_out(i)  <= client_out(i)(10);
        axis_tvalid_result_out(i)  <= client_out(i)(9);
        axis_tlast_result_out(i)  <= client_out(i)(8);
        axis_tdata_result_out(8 * i + 7 downto 8 * i) <= client_out(i)(7 downto 0);
    end generate;
    server_AXIS_bundle:  for i in SERVER_CAPACITY-1 downto 0 generate
        server_in(i) <= (axis_tready_goal_in(i) & 
                         axis_tvalid_result_in(i) & 
                         axis_tlast_result_in(i) & 
                         axis_tdata_result_in(8 * i + 7 downto 8 * i));  
        axis_tready_result_out(i)  <= server_out(i)(10);
        axis_tvalid_goal_out(i)  <= server_out(i)(9);
        axis_tlast_goal_out(i)  <= server_out(i)(8);
        axis_tdata_goal_out(8 * i + 7 downto 8 * i) <= server_out(i)(7 downto 0);
    end generate;
    
  INPUT_LIST(0)  <= "/home/ziyuan/Projects/actionlib/stimulus_input0.txt";
  INPUT_LIST(1)  <= "/home/ziyuan/Projects/actionlib/stimulus_input1.txt";
  INPUT_LIST(2)  <= "/home/ziyuan/Projects/actionlib/stimulus_input2.txt";
  INPUT_LIST(3)  <= "/home/ziyuan/Projects/actionlib/stimulus_input3.txt";
  OUTPUT_LIST(0) <= "/home/ziyuan/Projects/actionlib/testbench_oput0.txt";
  OUTPUT_LIST(1) <= "/home/ziyuan/Projects/actionlib/testbench_oput1.txt";
  OUTPUT_LIST(2) <= "/home/ziyuan/Projects/actionlib/testbench_oput2.txt";
  OUTPUT_LIST(3) <= "/home/ziyuan/Projects/actionlib/testbench_oput3.txt";

  -- Insert values for generic parameters !!
  ROS: FPGA_ROS_ACTION     generic map(
        BITS             => BITS,
        CLIENT_CAPACITY  => CLIENT_CAPACITY,
        SERVER_CAPACITY  => SERVER_CAPACITY
        ) port map (
        clk              => clk,
        reset            => reset,
        -- from client
        goal             => send_goal(CLIENT_CAPACITY - 1 downto 0 ),
        cancel           => cancel_goal(CLIENT_CAPACITY - 1 downto 0 ),
        finish           => receive_result_msg(CLIENT_CAPACITY - 1 downto 0 ),
        client_state     => client_state,
        -- to server
        setAccepted      => setAccepted(SERVER_CAPACITY - 1 downto 0 ),
        setRejected      => setRejected(SERVER_CAPACITY - 1 downto 0 ),
        setSucceeded     => setSucceeded(SERVER_CAPACITY - 1 downto 0 ),
        setAborted       => setAborted(SERVER_CAPACITY - 1 downto 0 ),
        setCanceled      => setCanceled(SERVER_CAPACITY - 1 downto 0 ),
        server_state     => status,        
        axis_client_in   => client_in,
        axis_client_out  => client_out,
        axis_server_in   => server_in,
        axis_server_out  => server_out
--        axis_tdata_goal_in  => axis_tdata_goal_in,
--        axis_tlast_goal_in  => axis_tlast_goal_in,
--        axis_tready_goal_in => axis_tready_goal_in,
--        axis_tvalid_goal_in => axis_tvalid_goal_in,
--        axis_tdata_result_out  => axis_tdata_result_out,
--        axis_tlast_result_out  => axis_tlast_result_out,
--        axis_tready_result_out => axis_tready_result_out,
--        axis_tvalid_result_out => axis_tvalid_result_out,        
        
--        axis_tdata_result_in    => axis_tdata_result_in,
--        axis_tlast_result_in    => axis_tlast_result_in,
--        axis_tready_result_in   => axis_tready_result_in,
--        axis_tvalid_result_in   => axis_tvalid_result_in,
--        axis_tdata_goal_out    => axis_tdata_goal_out,
--        axis_tlast_goal_out    => axis_tlast_goal_out,
--        axis_tready_goal_out   => axis_tready_goal_out,
--        axis_tvalid_goal_out   => axis_tvalid_goal_out
        
        );
   
  Clients:   for i in CLIENT_CAPACITY-1 downto 0 generate
  c: main port map (
        clk              => clk,
        rst              => reset,
        client_state     => client_state(4*i+3 downto 4*i),
        send_goal        => send_goal(i),
        cancel_goal      => cancel_goal(i),
        receive_result_msg => receive_result_msg(i),
        
        m_axis_tdata  => axis_tdata_goal_in(8*i+7 downto 8*i),
        m_axis_tlast  => axis_tlast_goal_in(i downto i),
        m_axis_tready => axis_tready_goal_out(i downto i),
        m_axis_tvalid => axis_tvalid_goal_in(i downto i),
        s_axis_tdata  => axis_tdata_result_out(8*i+7 downto 8*i),
        s_axis_tlast  => axis_tlast_result_out(i downto i),
        s_axis_tready => axis_tready_result_in(i downto i),
        s_axis_tvalid => axis_tvalid_result_out(i downto i),
        
        m_axis_tdata_write_file      => mCom_axis_tdata(8*i+7 downto 8*i),
        m_axis_tlast_write_file      => mCom_axis_tlast(i downto i),
        m_axis_tready_write_file     => mCom_axis_tready(i downto i),
        m_axis_tvalid_write_file     => mCom_axis_tvalid(i downto i),
        s_axis_tdata_read_file    => sCom_axis_tdata(8*i+7 downto 8*i),
        s_axis_tlast_read_file    => sCom_axis_tlast(i downto i),
        s_axis_tready_read_file   => sCom_axis_tready(i downto i),
        s_axis_tvalid_read_file   =>  sCom_axis_tvalid(i downto i) );      
   end generate;  
   
  Accelerators:  for i in SERVER_CAPACITY-1 downto 0 generate
  s: Fibonacci_accelerator port map (
        clk             => clk,
        rst             => reset,  
        status          => status(4*i+3 downto 4*i),  
        setAccepted     => setAccepted(i),
        setRejected     => setRejected(i),
        setSucceeded    => setSucceeded(i),
        setAborted      => setAborted(i),
        setCanceled     => setCanceled(i),        
        
        m_axis_tdata    => axis_tdata_result_in(8*i+7 downto 8*i),
        m_axis_tlast    => axis_tlast_result_in(i downto i),
        m_axis_tready   => axis_tready_result_out(i downto i),
        m_axis_tvalid   => axis_tvalid_result_in(i downto i),
        s_axis_tdata    => axis_tdata_goal_out(8*i+7 downto 8*i),
        s_axis_tlast    => axis_tlast_goal_out(i downto i),
        s_axis_tready   => axis_tready_goal_in(i downto i),
        s_axis_tvalid   => axis_tvalid_goal_out(i downto i));
   end generate;  

--  tready: process
--  begin
--    mCom_axis_tready <= "0";
--    wait for 10*clock_period;
--    mCom_axis_tready <= "1";
--    wait;
--  end process;


istream_list0:  for i in 0 downto 0 generate
  stream_process: process(clk)
    variable row_input          : line;
    variable v_number : std_logic_vector(7 downto 0);
  begin
    if(rising_edge(clk)) then
        if(v_stopCount=false) then
            if(st_count(32*i+31 downto 32*i)=0) then
                sCom_axis_tdata(8*i+7 downto 8*i) <= (others=>'0');
                sCom_axis_tvalid(i) <= '0';
                sCom_axis_tlast(i) <= '0';                
                file_open(input_file0, INPUT_LIST(i), read_mode);
                readline(input_file0, row_input);
                hread(row_input, v_number);
                s_ID(8*i+7 downto 8*i) <= v_number;
                st_count(32*i+31 downto 32*i) <= st_count(32*i+31 downto 32*i) + '1';
                reset <= '1';
            elsif(st_count(32*i+31 downto 32*i)=1) then
                readline(input_file0, row_input);    -- Reads Length
                hread(row_input, v_number);
                total_length(32*i+7 downto 32*i) <= v_number;
                st_count(32*i+31 downto 32*i) <= st_count(32*i+31 downto 32*i) + '1';
            elsif(st_count(32*i+31 downto 32*i)=2) then
                readline(input_file0, row_input);    -- Reads Length
                hread(row_input, v_number);
                total_length(32*i+15 downto 32*i+8) <= v_number;
                st_count(32*i+31 downto 32*i) <= st_count(32*i+31 downto 32*i) + '1';
            elsif(st_count(32*i+31 downto 32*i)=3) then
                readline(input_file0, row_input);    -- Reads Length
                hread(row_input, v_number);
                total_length(32*i+23 downto 32*i+16) <= v_number;
                st_count(32*i+31 downto 32*i) <= st_count(32*i+31 downto 32*i) + '1';
            elsif(st_count(32*i+31 downto 32*i)=4) then
                readline(input_file0, row_input);    -- Reads Length
                hread(row_input, v_number);
                total_length(32*i+31 downto 32*i+24) <= v_number;
                st_count(32*i+31 downto 32*i) <= st_count(32*i+31 downto 32*i) + '1';
            elsif(st_count(32*i+31 downto 32*i)=total_length(32*i+31 downto 32*i) +10) then
                if (total_length(32*i+31 downto 32*i) > 0)then
                    readline(input_file0, row_input);    -- Reads Length
                    hread(row_input, v_number);
                    if(v_number = 0) then
                        st_count(32*i+31 downto 32*i) <= st_count(32*i+31 downto 32*i) + '1';
                    else
                        total_length(32*i+31 downto 32*i) <= (others=>'0');                    
                        st_count(32*i+31 downto 32*i) <= x"0000000a";  
                    end if;
                end if;
            elsif(st_count(32*i+31 downto 32*i) = total_length(32*i+31 downto 32*i) +11) then
                sCom_axis_tvalid(i) <='0';
                sCom_axis_tdata(8*i+7 downto 8*i) <= (others=>'0');
                sCom_axis_tlast(i) <='0';
                st_count(32*i+31 downto 32*i) <=  x"00000001";
            elsif(sCom_axis_tready(i)='1') then
                if(st_count(32*i+31 downto 32*i)=5+0) then
                    sCom_axis_tvalid(i) <='1';
                    sCom_axis_tdata(8*i+7 downto 8*i) <= s_ID(8*i+7 downto 8*i);
                    st_count(32*i+31 downto 32*i) <= st_count(32*i+31 downto 32*i) + '1';
                elsif(st_count(32*i+31 downto 32*i)=5+1) then
                    sCom_axis_tdata(8*i+7 downto 8*i) <= total_length(32*i+7 downto 32*i);
                    st_count(32*i+31 downto 32*i) <= st_count(32*i+31 downto 32*i) + '1';
                elsif(st_count(32*i+31 downto 32*i)=5+2) then
                    sCom_axis_tdata(8*i+7 downto 8*i) <= total_length(32*i+15 downto 32*i+8);
                    st_count(32*i+31 downto 32*i) <= st_count(32*i+31 downto 32*i) + '1';
                elsif(st_count(32*i+31 downto 32*i)=5+3) then
                    sCom_axis_tdata(8*i+7 downto 8*i) <= total_length(32*i+23 downto 32*i+16);
                    st_count(32*i+31 downto 32*i) <= st_count(32*i+31 downto 32*i) + '1';
                elsif(st_count(32*i+31 downto 32*i)=5+4) then
                    sCom_axis_tdata(8*i+7 downto 8*i) <= total_length(32*i+31 downto 32*i+24);
                    st_count(32*i+31 downto 32*i) <= st_count(32*i+31 downto 32*i) + '1';
                elsif(st_count(32*i+31 downto 32*i)>5+4) then
                    readline(input_file0, row_input);    -- Reads Length
                    hread(row_input, v_number);
                    sCom_axis_tdata(8*i+7 downto 8*i) <= v_number;
                    st_count(32*i+31 downto 32*i) <= st_count(32*i+31 downto 32*i) + '1';
                    if(st_count(32*i+31 downto 32*i) = total_length(32*i+31 downto 32*i)+9) then
                        sCom_axis_tlast(i) <='1';
                        sCom_axis_tvalid(i) <='0';
                    else
                        sCom_axis_tlast(i) <='0';
                    end if;
                end if;
            end if;
        end if;
    end if;
  end process;
end generate;

istream_list1:  for i in 1 downto 1 generate
  stream_process1: process(clk)
    variable row_input1          : line;
    variable v_number1 : std_logic_vector(7 downto 0);
  begin
    if(rising_edge(clk)) then
        if(v_stopCount=false) then
            if(st_count(32*i+31 downto 32*i)=0) then
                sCom_axis_tdata(8*i+7 downto 8*i) <= (others=>'0');
                sCom_axis_tvalid(i) <= '0';
                sCom_axis_tlast(i) <= '0';                
                file_open(input_file1, INPUT_LIST(i), read_mode);
                readline(input_file1, row_input1);
                hread(row_input1, v_number1);
                s_ID(8*i+7 downto 8*i) <= v_number1;
                st_count(32*i+31 downto 32*i) <= st_count(32*i+31 downto 32*i) + '1';
                reset <= '1';
            elsif(st_count(32*i+31 downto 32*i)=1) then
                readline(input_file1, row_input1);    -- Reads Length
                hread(row_input1, v_number1);
                total_length(32*i+7 downto 32*i) <= v_number1;
                st_count(32*i+31 downto 32*i) <= st_count(32*i+31 downto 32*i) + '1';
            elsif(st_count(32*i+31 downto 32*i)=2) then
                readline(input_file1, row_input1);    -- Reads Length
                hread(row_input1, v_number1);
                total_length(32*i+15 downto 32*i+8) <= v_number1;
                st_count(32*i+31 downto 32*i) <= st_count(32*i+31 downto 32*i) + '1';
            elsif(st_count(32*i+31 downto 32*i)=3) then
                readline(input_file1, row_input1);    -- Reads Length
                hread(row_input1, v_number1);
                total_length(32*i+23 downto 32*i+16) <= v_number1;
                st_count(32*i+31 downto 32*i) <= st_count(32*i+31 downto 32*i) + '1';
            elsif(st_count(32*i+31 downto 32*i)=4) then
                readline(input_file1, row_input1);    -- Reads Length
                hread(row_input1, v_number1);
                total_length(32*i+31 downto 32*i+24) <= v_number1;
                st_count(32*i+31 downto 32*i) <= st_count(32*i+31 downto 32*i) + '1';
            elsif(st_count(32*i+31 downto 32*i)=total_length(32*i+31 downto 32*i) +10) then
                if (total_length(32*i+31 downto 32*i) > 0)then
                    readline(input_file1, row_input1);    -- Reads Length
                    hread(row_input1, v_number1);
                    if(v_number1 = 0) then
                        st_count(32*i+31 downto 32*i) <= st_count(32*i+31 downto 32*i) + '1';
                    else
                        total_length(32*i+31 downto 32*i) <= (others=>'0');                      
                        st_count(32*i+31 downto 32*i) <= x"0000000a"; 
                    end if;
                end if;
            elsif(st_count(32*i+31 downto 32*i) = total_length(32*i+31 downto 32*i) +11) then
                sCom_axis_tvalid(i) <='0';
                sCom_axis_tdata(8*i+7 downto 8*i) <= (others=>'0');
                sCom_axis_tlast(i) <='0';
                st_count(32*i+31 downto 32*i) <=  x"00000001";
            elsif(sCom_axis_tready(i)='1') then
                if(st_count(32*i+31 downto 32*i)=5+0) then
                    sCom_axis_tvalid(i) <='1';
                    sCom_axis_tdata(8*i+7 downto 8*i) <= s_ID(8*i+7 downto 8*i);
                    st_count(32*i+31 downto 32*i) <= st_count(32*i+31 downto 32*i) + '1';
                elsif(st_count(32*i+31 downto 32*i)=5+1) then
                    sCom_axis_tdata(8*i+7 downto 8*i) <= total_length(32*i+7 downto 32*i);
                    st_count(32*i+31 downto 32*i) <= st_count(32*i+31 downto 32*i) + '1';
                elsif(st_count(32*i+31 downto 32*i)=5+2) then
                    sCom_axis_tdata(8*i+7 downto 8*i) <= total_length(32*i+15 downto 32*i+8);
                    st_count(32*i+31 downto 32*i) <= st_count(32*i+31 downto 32*i) + '1';
                elsif(st_count(32*i+31 downto 32*i)=5+3) then
                    sCom_axis_tdata(8*i+7 downto 8*i) <= total_length(32*i+23 downto 32*i+16);
                    st_count(32*i+31 downto 32*i) <= st_count(32*i+31 downto 32*i) + '1';
                elsif(st_count(32*i+31 downto 32*i)=5+4) then
                    sCom_axis_tdata(8*i+7 downto 8*i) <= total_length(32*i+31 downto 32*i+24);
                    st_count(32*i+31 downto 32*i) <= st_count(32*i+31 downto 32*i) + '1';
                elsif(st_count(32*i+31 downto 32*i)>5+4) then
                    readline(input_file1, row_input1);    -- Reads Length
                    hread(row_input1, v_number1);
                    sCom_axis_tdata(8*i+7 downto 8*i) <= v_number1;
                    st_count(32*i+31 downto 32*i) <= st_count(32*i+31 downto 32*i) + '1';
                    if(st_count(32*i+31 downto 32*i) = total_length(32*i+31 downto 32*i)+9) then
                        sCom_axis_tlast(i) <='1';
                        sCom_axis_tvalid(i) <='0';
                    else
                        sCom_axis_tlast(i) <='0';
                    end if;
                end if;
            end if;
        end if;
    end if;
  end process;
end generate;

istream_list2:  for i in 2 downto 2 generate
  stream_process2: process(clk)
    variable row_input2          : line;
    variable v_number2 : std_logic_vector(7 downto 0);
  begin
    if(rising_edge(clk)) then
        if(v_stopCount=false) then
            if(st_count(32*i+31 downto 32*i)=0) then
                sCom_axis_tdata(8*i+7 downto 8*i) <= (others=>'0');
                sCom_axis_tvalid(i) <= '0';
                sCom_axis_tlast(i) <= '0';                
                file_open(input_file2, INPUT_LIST(i), read_mode);
                readline(input_file2, row_input2);
                hread(row_input2, v_number2);
                s_ID(8*i+7 downto 8*i) <= v_number2;
                st_count(32*i+31 downto 32*i) <= st_count(32*i+31 downto 32*i) + '1';
                reset <= '1';
            elsif(st_count(32*i+31 downto 32*i)=1) then
                readline(input_file2, row_input2);    -- Reads Length
                hread(row_input2, v_number2);
                total_length(32*i+7 downto 32*i) <= v_number2;
                st_count(32*i+31 downto 32*i) <= st_count(32*i+31 downto 32*i) + '1';
            elsif(st_count(32*i+31 downto 32*i)=2) then
                readline(input_file2, row_input2);    -- Reads Length
                hread(row_input2, v_number2);
                total_length(32*i+15 downto 32*i+8) <= v_number2;
                st_count(32*i+31 downto 32*i) <= st_count(32*i+31 downto 32*i) + '1';
            elsif(st_count(32*i+31 downto 32*i)=3) then
                readline(input_file2, row_input2);    -- Reads Length
                hread(row_input2, v_number2);
                total_length(32*i+23 downto 32*i+16) <= v_number2;
                st_count(32*i+31 downto 32*i) <= st_count(32*i+31 downto 32*i) + '1';
            elsif(st_count(32*i+31 downto 32*i)=4) then
                readline(input_file2, row_input2);    -- Reads Length
                hread(row_input2, v_number2);
                total_length(32*i+31 downto 32*i+24) <= v_number2;
                st_count(32*i+31 downto 32*i) <= st_count(32*i+31 downto 32*i) + '1';
            elsif(st_count(32*i+31 downto 32*i)=total_length(32*i+31 downto 32*i) +10) then
                if (total_length(32*i+31 downto 32*i) > 0)then
                    readline(input_file2, row_input2);    -- Reads Length
                    hread(row_input2, v_number2);
                    if(v_number2 = 0) then
                        st_count(32*i+31 downto 32*i) <= st_count(32*i+31 downto 32*i) + '1';
                    else
                        total_length(32*i+31 downto 32*i) <= (others=>'0');                            
                        st_count(32*i+31 downto 32*i) <= x"0000000a"; 
                    end if;
                end if;
            elsif(st_count(32*i+31 downto 32*i) = total_length(32*i+31 downto 32*i) +11) then
                sCom_axis_tvalid(i) <='0';
                sCom_axis_tdata(8*i+7 downto 8*i) <= (others=>'0');
                sCom_axis_tlast(i) <='0';
                st_count(32*i+31 downto 32*i) <=  x"00000001";
            elsif(sCom_axis_tready(i)='1') then
                if(st_count(32*i+31 downto 32*i)=5+0) then
                    sCom_axis_tvalid(i) <='1';
                    sCom_axis_tdata(8*i+7 downto 8*i) <= s_ID(8*i+7 downto 8*i);
                    st_count(32*i+31 downto 32*i) <= st_count(32*i+31 downto 32*i) + '1';
                elsif(st_count(32*i+31 downto 32*i)=5+1) then
                    sCom_axis_tdata(8*i+7 downto 8*i) <= total_length(32*i+7 downto 32*i);
                    st_count(32*i+31 downto 32*i) <= st_count(32*i+31 downto 32*i) + '1';
                elsif(st_count(32*i+31 downto 32*i)=5+2) then
                    sCom_axis_tdata(8*i+7 downto 8*i) <= total_length(32*i+15 downto 32*i+8);
                    st_count(32*i+31 downto 32*i) <= st_count(32*i+31 downto 32*i) + '1';
                elsif(st_count(32*i+31 downto 32*i)=5+3) then
                    sCom_axis_tdata(8*i+7 downto 8*i) <= total_length(32*i+23 downto 32*i+16);
                    st_count(32*i+31 downto 32*i) <= st_count(32*i+31 downto 32*i) + '1';
                elsif(st_count(32*i+31 downto 32*i)=5+4) then
                    sCom_axis_tdata(8*i+7 downto 8*i) <= total_length(32*i+31 downto 32*i+24);
                    st_count(32*i+31 downto 32*i) <= st_count(32*i+31 downto 32*i) + '1';
                elsif(st_count(32*i+31 downto 32*i)>5+4) then
                    readline(input_file2, row_input2);    -- Reads Length
                    hread(row_input2, v_number2);
                    sCom_axis_tdata(8*i+7 downto 8*i) <= v_number2;
                    st_count(32*i+31 downto 32*i) <= st_count(32*i+31 downto 32*i) + '1';
                    if(st_count(32*i+31 downto 32*i) = total_length(32*i+31 downto 32*i)+9) then
                        sCom_axis_tlast(i) <='1';
                        sCom_axis_tvalid(i) <='0';
                    else
                        sCom_axis_tlast(i) <='0';
                    end if;
                end if;
            end if;
        end if;
    end if;
  end process;
end generate;

istream_list3:  for i in 3 downto 3 generate
  stream_process3: process(clk)
    variable row_input3          : line;
    variable v_number3 : std_logic_vector(7 downto 0);
  begin
    if(rising_edge(clk)) then
        if(v_stopCount=false) then
            if(st_count(32*i+31 downto 32*i)=0) then
                sCom_axis_tdata(8*i+7 downto 8*i) <= (others=>'0');
                sCom_axis_tvalid(i) <= '0';
                sCom_axis_tlast(i) <= '0';                
                file_open(input_file3, INPUT_LIST(i), read_mode);
                readline(input_file3, row_input3);
                hread(row_input3, v_number3);
                s_ID(8*i+7 downto 8*i) <= v_number3;
                st_count(32*i+31 downto 32*i) <= st_count(32*i+31 downto 32*i) + '1';
                reset <= '1';
            elsif(st_count(32*i+31 downto 32*i)=1) then
                readline(input_file3, row_input3);    -- Reads Length
                hread(row_input3, v_number3);
                total_length(32*i+7 downto 32*i) <= v_number3;
                st_count(32*i+31 downto 32*i) <= st_count(32*i+31 downto 32*i) + '1';
            elsif(st_count(32*i+31 downto 32*i)=2) then
                readline(input_file3, row_input3);    -- Reads Length
                hread(row_input3, v_number3);
                total_length(32*i+15 downto 32*i+8) <= v_number3;
                st_count(32*i+31 downto 32*i) <= st_count(32*i+31 downto 32*i) + '1';
            elsif(st_count(32*i+31 downto 32*i)=3) then
                readline(input_file3, row_input3);    -- Reads Length
                hread(row_input3, v_number3);
                total_length(32*i+23 downto 32*i+16) <= v_number3;
                st_count(32*i+31 downto 32*i) <= st_count(32*i+31 downto 32*i) + '1';
            elsif(st_count(32*i+31 downto 32*i)=4) then
                readline(input_file3, row_input3);    -- Reads Length
                hread(row_input3, v_number3);
                total_length(32*i+31 downto 32*i+24) <= v_number3;
                st_count(32*i+31 downto 32*i) <= st_count(32*i+31 downto 32*i) + '1';
            elsif(st_count(32*i+31 downto 32*i)=total_length(32*i+31 downto 32*i) +10) then
               if (total_length(32*i+31 downto 32*i) > 0)then
                readline(input_file3, row_input3);    -- Reads Length
                hread(row_input3, v_number3);
                    if(v_number3 = 0) then
                        st_count(32*i+31 downto 32*i) <= st_count(32*i+31 downto 32*i) + '1';
                    else
                        total_length(32*i+31 downto 32*i) <= (others=>'0');                     
                        st_count(32*i+31 downto 32*i) <= x"0000000a"; 
                    end if;
                end if;
            elsif(st_count(32*i+31 downto 32*i) = total_length(32*i+31 downto 32*i) +11) then
                sCom_axis_tvalid(i) <='0';
                sCom_axis_tdata(8*i+7 downto 8*i) <= (others=>'0');
                sCom_axis_tlast(i) <='0';
                st_count(32*i+31 downto 32*i) <=  x"00000001";
            elsif(sCom_axis_tready(i)='1') then
                if(st_count(32*i+31 downto 32*i)=5+0) then
                    sCom_axis_tvalid(i) <='1';
                    sCom_axis_tdata(8*i+7 downto 8*i) <= s_ID(8*i+7 downto 8*i);
                    st_count(32*i+31 downto 32*i) <= st_count(32*i+31 downto 32*i) + '1';
                elsif(st_count(32*i+31 downto 32*i)=5+1) then
                    sCom_axis_tdata(8*i+7 downto 8*i) <= total_length(32*i+7 downto 32*i);
                    st_count(32*i+31 downto 32*i) <= st_count(32*i+31 downto 32*i) + '1';
                elsif(st_count(32*i+31 downto 32*i)=5+2) then
                    sCom_axis_tdata(8*i+7 downto 8*i) <= total_length(32*i+15 downto 32*i+8);
                    st_count(32*i+31 downto 32*i) <= st_count(32*i+31 downto 32*i) + '1';
                elsif(st_count(32*i+31 downto 32*i)=5+3) then
                    sCom_axis_tdata(8*i+7 downto 8*i) <= total_length(32*i+23 downto 32*i+16);
                    st_count(32*i+31 downto 32*i) <= st_count(32*i+31 downto 32*i) + '1';
                elsif(st_count(32*i+31 downto 32*i)=5+4) then
                    sCom_axis_tdata(8*i+7 downto 8*i) <= total_length(32*i+31 downto 32*i+24);
                    st_count(32*i+31 downto 32*i) <= st_count(32*i+31 downto 32*i) + '1';
                elsif(st_count(32*i+31 downto 32*i)>5+4) then
                    readline(input_file3, row_input3);    -- Reads Length
                    hread(row_input3, v_number3);
                    sCom_axis_tdata(8*i+7 downto 8*i) <= v_number3;
                    st_count(32*i+31 downto 32*i) <= st_count(32*i+31 downto 32*i) + '1';
                    if(st_count(32*i+31 downto 32*i) = total_length(32*i+31 downto 32*i)+9) then
                        sCom_axis_tlast(i) <='1';
                        sCom_axis_tvalid(i) <='0';
                    else
                        sCom_axis_tlast(i) <='0';
                    end if;
                end if;
            end if;
        end if;
    end if;
  end process;
end generate;

mCom_axis_tready <= (others => '1');

ostream_list:  for i in 1-1 downto 0 generate 
  output_proc: process
      variable s_counter_assert_out :integer := 0;
      variable row_output          : line;
  begin
     --file_open(output_file, OUTPUT_LIST(i), write_mode);
     file_open(output_file0,"/home/ziyuan/Projects/actionlib/testbench_oput0.txt", write_mode);
      while (s_counter_assert_out < 600) loop
          s_counter_assert_out := s_counter_assert_out + 1;
          if(mCom_axis_tvalid(i)='1' and mCom_axis_tlast(i)='0' ) then
              hwrite(row_output, mCom_axis_tdata(8*i+7 downto 8*i));
              writeline(output_file0, row_output);
          end if;
          wait for clock_period;
      end loop;
      file_close(output_file0);
      wait;
  end process; 
end generate;

ostream_list2:  for i in 1 downto 1 generate 
    output_proc2: process
          variable s_counter_assert_out :integer := 0;
          variable row_output1          : line;
      begin
         --file_open(output_file, OUTPUT_LIST(i), write_mode);
         file_open(output_file1,"/home/ziyuan/Projects/actionlib/testbench_oput1.txt", write_mode);
          while (s_counter_assert_out < 600) loop
              s_counter_assert_out := s_counter_assert_out + 1;
              if(mCom_axis_tvalid(i)='1' and mCom_axis_tlast(i)='0' ) then
                  hwrite(row_output1, mCom_axis_tdata(8*i+7 downto 8*i));
                  writeline(output_file1, row_output1);
              end if;
              wait for clock_period;
          end loop;
          file_close(output_file1);
          wait;
      end process;
end generate;

ostream_list3:  for i in 2 downto 2 generate 
    output_proc3: process
          variable s_counter_assert_out :integer := 0;
          variable row_output3          : line;
      begin
         --file_open(output_file, OUTPUT_LIST(i), write_mode);
         file_open(output_file2,"/home/ziyuan/Projects/actionlib/testbench_oput2.txt", write_mode);
          while (s_counter_assert_out < 600) loop
              s_counter_assert_out := s_counter_assert_out + 1;
              if(mCom_axis_tvalid(i)='1' and mCom_axis_tlast(i)='0' ) then
                  hwrite(row_output3, mCom_axis_tdata(8*i+7 downto 8*i));
                  writeline(output_file2, row_output3);
              end if;
              wait for clock_period;
          end loop;
          file_close(output_file2);
          wait;
      end process;
end generate;
ostream_list4:  for i in 3 downto 3 generate
    output_proc4: process
          variable s_counter_assert_out : integer := 0;
          variable row_output4          : line;
      begin
         --file_open(output_file, OUTPUT_LIST(i), write_mode);
         file_open(output_file3,"/home/ziyuan/Projects/actionlib/testbench_oput3.txt", write_mode);
          while (s_counter_assert_out < 600) loop
              s_counter_assert_out := s_counter_assert_out + 1;
              if(mCom_axis_tvalid(i)='1' and mCom_axis_tlast(i)='0' ) then
                  hwrite(row_output4, mCom_axis_tdata(8*i+7 downto 8*i));
                  writeline(output_file3, row_output4);
              end if;
              wait for clock_period;
          end loop;
          file_close(output_file3);
          wait;
      end process;
end generate;


  assert_out: process
      variable s_counter_assert_out :integer := 0;
--      variable v_TOTALBYTES : natural;
  begin
--     if(s_total_length_valid='1') then
--          v_TOTALBYTES := to_integer(unsigned(total_length));
--      end if;
      while (s_counter_assert_out < 600) loop
          s_counter_assert_out := s_counter_assert_out + 1;          
          wait for clock_period;
      end loop;
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
