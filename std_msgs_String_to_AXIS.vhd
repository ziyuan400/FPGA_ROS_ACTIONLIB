library IEEE;
library work;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity std_msgs_String_to_AXIS is
    generic (
        BITS    : integer := 8;
        IPID    : integer := 0
    );
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
end std_msgs_String_to_AXIS;

architecture Behavioral of std_msgs_String_to_AXIS is

    signal s_counter : std_logic_vector(31 downto 0) := (others=>'0');
    signal s_counter_data : std_logic_vector(31 downto 0) := (others=>'0');
    signal s_counter_total : std_logic_vector(31 downto 0) := (others=>'0');    -- This counter is used to generate m_axis_tlast

    signal count_EN : std_logic := '0';

    constant c_IDIP : integer := IPID;

    signal s_tlast : std_logic :='0';
    signal s_tlast_delay: std_logic;

begin

    process(clk)
    begin
        if(rising_edge(clk)) then
            if(count_EN='0' and newData='1') then
                count_EN <= '1';
            end if;

            -- Multiplexing logic
            if(count_EN='1' and newData='1') then
                if(m_axis_tready='1') then
                    if(s_counter=0) then
                        s_counter <= s_counter + '1';
                        s_counter_total <= (others=>'0');
                    end if;
                    if(s_counter=0+1) then
                        s_counter <= s_counter + '1';
                        s_counter_total <= s_counter_total + '1';
                    end if;
                    if(s_counter=1+1) then
                        s_counter <= s_counter + '1';
                        s_counter_total <= s_counter_total + '1';
                    end if;
                    if(s_counter=2+1) then
                        s_counter <= s_counter + '1';
                        s_counter_total <= s_counter_total + '1';
                    end if;
                    if(s_counter=3+1) then
                        s_counter <= s_counter + '1';
                        s_counter_total <= s_counter_total + '1';
                    end if;
                    if(s_counter=4+1) then
                        s_counter <= s_counter + '1';
                        s_counter_total <= s_counter_total + '1';
                    end if;
                    if(s_counter=5+1) then
                        s_counter <= s_counter + '1';
                        s_counter_total <= s_counter_total + '1';
                    end if;
                    if(s_counter=6+1) then
                        s_counter <= s_counter + '1';
                        s_counter_total <= s_counter_total + '1';
                    end if;
                    if(s_counter=7+1) then
                        s_counter <= s_counter + '1';
                        s_counter_total <= s_counter_total + '1';
                        data_tready_out <= '1';
                        s_counter_data <= (others=>'0');
                    end if;
                    if(data_tvalid_in='1' and s_counter=8+1) then
                        s_counter_total <= s_counter_total + '1';
                        if(s_counter_data<((data_length_in(3) & data_length_in(2) & data_length_in(1) & data_length_in(0))*std_logic_vector(to_unsigned(1,8)))-1) then
                            s_counter_data <= s_counter_data + '1';
                            data_tready_out <= '1';
                        else
                            data_tready_out <= '0';
                            s_counter_data <= (others=>'0');
                            s_counter <= s_counter + '1';
                        end if;
                    end if;
                    if(s_counter_total=(total_length_in+4)-1) then
                        s_counter <= (others=>'0');
                        s_counter_data <= (others=>'0');
                        s_counter_total <= (others=>'0');
                        count_EN <= '0';
                    end if;
                else
                    data_tready_out <= '0';
                end if;
            else
                data_tready_out <= '0';
            end if;
            s_tlast_delay <= s_tlast;
        end if;
    end process;

    s_tlast <= '1' when s_counter_total=(total_length_in+4)-1 else '0';
    m_axis_tlast <= s_tlast;
    allread <= s_tlast_delay;

    m_axis_tlast <= '1' when s_counter_total=(total_length_in+4)-1 else '0';
    m_axis_tvalid <= count_EN and newData;
    m_axis_tdata <= std_logic_vector(to_unsigned(c_IDIP, m_axis_tdata'length)) when (m_axis_tready='1' and count_EN='1') and s_counter=0 else
                      total_length_in(7 downto 0) when s_counter=0+1 else
                      total_length_in(15 downto 8) when s_counter=1+1 else
                      total_length_in(23 downto 16) when s_counter=2+1 else
                      total_length_in(31 downto 24) when s_counter=3+1 else
                      data_length_in(7 downto 0) when s_counter=4+1 else
                      data_length_in(15 downto 8) when s_counter=5+1 else
                      data_length_in(23 downto 16) when s_counter=6+1 else
                      data_length_in(31 downto 24) when s_counter=7+1 else
                      data_tdata_in when s_counter=8+1 else
                      (others=>'0');

end Behavioral;
