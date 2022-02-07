library IEEE;
library work;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;

entity AXIS_to_std_msgs_String is
    generic (
        BITS    : integer := 8;
        IPID    : natural := 0
    );
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
        newData : out std_logic; --tell receiver the data is new
        allRead : in std_logic  --to let this component read new stream
        );
end AXIS_to_std_msgs_String;

architecture Behavioral of AXIS_to_std_msgs_String is

    type t_uint32 is array (0 to 3) of std_logic_vector(7 downto 0);
    type t_uint8 is array (0 to 0) of std_logic_vector(7 downto 0);

    signal s_total_length_latch : t_uint32 := (others=>(others=>'0'));
    signal s_data_length_latch : t_uint32 := (others=>(others=>'0'));

    signal s_counter : std_logic_vector(31 downto 0) := (others=>'0');
    signal s_counter_data : std_logic_vector(31 downto 0) := (others=>'0');
    signal s_tlast_delay, s_tvalid_delay : std_logic_vector(1 downto 0) := (others=>'0');
    signal s_newData : std_logic :='0';

    begin

    process(clk)
    begin
        if(rst='0') then
            s_counter <= (others=>'0');
            s_counter_data <= (others=>'0');
        elsif(rising_edge(clk)) then
            -- Detect rising edge of s_axis_tvalid
            s_tvalid_delay(1) <= s_tvalid_delay(0);
            s_tvalid_delay(0) <= s_axis_tvalid;
            if(s_tvalid_delay(0)='1' and s_tvalid_delay(1)='0') then
                s_newData <= '1';
            end if;

            if(allRead='1') then
                s_newData <= '0';
            end if;

            if(s_axis_tvalid='1') then
                if(s_counter=0) then
                    s_total_length_latch(3) <= s_axis_tdata;
                    s_counter <= s_counter + '1';
                end if;
                if(s_counter=0+1) then
                    s_total_length_latch(3) <= s_axis_tdata;
                    s_counter <= s_counter + '1';
                end if;
                if(s_counter=1+1) then
                    s_total_length_latch(2) <= s_axis_tdata;
                    s_counter <= s_counter + '1';
                end if;
                if(s_counter=2+1) then
                    s_total_length_latch(1) <= s_axis_tdata;
                    s_counter <= s_counter + '1';
                end if;
                if(s_counter=3+1) then
                    s_total_length_latch(0) <= s_axis_tdata;
                    s_counter <= s_counter + '1';
                end if;
                if(s_counter=4+1) then
                    s_data_length_latch(3) <= s_axis_tdata;
                    s_counter <= s_counter + '1';
                end if;
                if(s_counter=5+1) then
                    s_data_length_latch(2) <= s_axis_tdata;
                    s_counter <= s_counter + '1';
                end if;
                if(s_counter=6+1) then
                    s_data_length_latch(1) <= s_axis_tdata;
                    s_counter <= s_counter + '1';
                end if;
                if(s_counter=7+1) then
                    s_data_length_latch(0) <= s_axis_tdata;
                    s_counter <= s_counter + '1';
                end if;
                if(data_tready_in='1' and s_counter=8+1) then
                    if(s_counter_data<((s_data_length_latch(0) & s_data_length_latch(1) & s_data_length_latch(2) & s_data_length_latch(3))*std_logic_vector(to_unsigned(1,8)))-1) then
                        s_counter_data <= s_counter_data + '1';
                    else
                        s_counter_data <= (others=>'0');
                        s_counter <= s_counter + '1';
                    end if;
                end if;
            end if;

            -- Reset the main counter based on s_axis_tlast
            s_tlast_delay(1) <= s_tlast_delay(0);
            s_tlast_delay(0) <= s_axis_tlast;
            if(s_tlast_delay(0)='1' and s_tlast_delay(1)='0') then
                s_counter <= (others=>'0');
                s_counter_data <= (others=>'0');
            end if;

        end if;
    end process;

    total_length_out <= s_total_length_latch(0) & s_total_length_latch(1) & s_total_length_latch(2) & s_total_length_latch(3);
    data_length_out <= s_data_length_latch(0) & s_data_length_latch(1) & s_data_length_latch(2) & s_data_length_latch(3);
    data_tvalid_out <= '1' when (s_counter=8+1 and s_axis_tvalid='1') else '0';
    data_tlast_out <= '1' when s_counter=8+1 and s_counter_data=((s_data_length_latch(0) & s_data_length_latch(1) & s_data_length_latch(2) & s_data_length_latch(3))*std_logic_vector(to_unsigned(1,8)))-1 else '0';
    data_tdata_out <= s_axis_tdata when (s_counter=8+1 and s_axis_tvalid='1' and data_tready_in='1') else (others=>'0');

    s_axis_tready <=
                    data_tready_in when s_counter=8+1 else
                    '1';

    newData <= s_newData;

end Behavioral;
