library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

Library UNISIM;
use UNISIM.vcomponents.all;

entity DMAcontrollerMIG7 is
	Port (
	CLK100MHZ	 : 	IN STD_LOGIC;						-- 100MHz clock, registers latch on leading edge
	CLK200MHZ    : IN STD_LOGIC;
	RESET : in STD_LOGIC;	
	---------------------------------------------------------------
	-- AXI4 lite connections (as seen by SLAVE)
	-- address of write channel
	-- handshake protocol
	s_axi_awvalid : IN STD_LOGIC;					-- source indicates channel	data valid
	s_axi_awready : OUT STD_LOGIC;					-- destination indicates that it can accept channel data
											-- transfer occurs only when valid and ready are high
											-- destination may hold ready high or wait for valid
											-- source may not wait for ready to assert valid
	s_axi_awaddr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);			-- true byte addressing											
	-- write channel
	s_axi_wdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
	s_axi_wstrb : IN STD_LOGIC_VECTOR(3 DOWNTO 0);			-- active high byte mask for the data	
	s_axi_wvalid : IN STD_LOGIC;
	s_axi_wready : OUT STD_LOGIC;
	-- write response channel						-- this channel to be removed!
	s_axi_bresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);			-- write response value: see constants
	s_axi_bvalid : OUT STD_LOGIC;					-- BVALID is dependent on WVALID, WREADY, AWVALID, and AWREADY,  
	s_axi_bready : IN STD_LOGIC;
	-- address of read channel
	s_axi_araddr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
	s_axi_arvalid : IN STD_LOGIC;
	s_axi_arready : OUT STD_LOGIC;
	-- read/read-response channel
	s_axi_rdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
	s_axi_rresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);			-- read response value: see constants
	s_axi_rvalid : OUT STD_LOGIC;					-- RVALID is dependent on ARVALID and ARREADY
	s_axi_rready : IN STD_LOGIC;
	----------------------------------------------------------------
	-- AIX4 read channel connections (as seen by SLAVE)
	-- address of read channel
	t_axi_araddr : IN  std_logic_vector(31 downto 0);		-- true byte addressing	
										-- MASTER indicates only the first byte address, SLAVE will calculate the rest
	-- burst length specifies the number of beats in the data transfer
	t_axi_arlen : IN  std_logic_vector(7 downto 0);			-- No. beats = axi_arlen + 1
	-- burst size is the number of bytes to transfer in each beat (width)
	t_axi_arsize : IN  std_logic_vector(2 downto 0);			-- size in bytes: "000" = 1 byte, "001" = 2 bytes, "010" = 4 bytes, "011" = 8 bytes, "100" = 16 bytes
	-- burst type is the nature of address increment during the burst 
	t_axi_arburst : IN  std_logic_vector(1 downto 0);		-- see VHDL constants
	t_axi_arvalid : IN  std_logic;
	t_axi_arready : OUT  std_logic;
	-- read/read-response channel
	t_axi_rdata : OUT  std_logic_vector(127 downto 0);
	t_axi_rresp : OUT  std_logic_vector(1 downto 0);			
	t_axi_rlast : OUT  std_logic;					-- set high to indicate last data word
	t_axi_rvalid : OUT  std_logic;
	t_axi_rready : IN  std_logic;
	----------------------------------------------------------------
	-- MIG7 user interface signals
	sys_clk_i		: out	  std_logic;				-- 200MHZ CLOCK
	-- user command information
	app_en               : out    std_logic;				-- user holds app_en high with a valid app_cmd until app_rdy is asserted
	app_cmd              : out    std_logic_vector(2 downto 0);	-- see VDHL constants
	app_rdy              : in     std_logic;				-- MIG7 registers a command provided rdy is high
	app_addr             : out    std_logic_vector(26 downto 0);	-- true byte addressing
										-- addr needs to be incremented for each new command
	-- write information
		-- write data must preceed WRITE command or follow within 2 clock cycles
	app_wdf_data         : out    std_logic_vector(127 downto 0);	-- 64 bit data since 16 ddr2 lines and 2:1 MIG7 clocking
	app_wdf_mask         : out    std_logic_vector(15 downto 0);	-- active high byte mask for the data	
	app_wdf_wren         : out    std_logic;				-- user holds high throughout transfer to indicate valid data
	app_wdf_rdy          : in     std_logic;				-- MIG registers data provided rdy is high
	app_wdf_end          : out    std_logic;				-- set high to indicate last data word
	-- read information
	app_rd_data          : in	  std_logic_vector(127 downto 0);
	app_rd_data_end      : in     std_logic;				-- signals end of burst (not needed in handshake logic)
	app_rd_data_valid    : in     std_logic;				-- valid read data is on the bus
	-- user
	app_sr_req           : out    std_logic;				-- tie to '0'
	app_sr_active        : in     std_logic;				-- disregard
	-- user controlled DRAM refresh
	app_ref_req          : out    std_logic;				-- tie to '0'
	app_ref_ack          : in     std_logic;				-- disregard
	-- user controllerd ZQ calibration
	app_zq_req           : out    std_logic;				-- tie to '0'
	app_zq_ack           : in     std_logic;				-- disregard
	-- user interface
	ui_clk               : in    std_logic;				-- CLOCK
	ui_clk_sync_rst      : in    std_logic;				-- active-high reset
	-- calibration complete		
	init_calib_complete  : in     std_logic;				-- MIG7 requires 50-60uS to complete calibraton in simulator
	-- reset
	sys_rst		: out	std_logic				-- active lo reset
	);			
end DMAcontrollerMIG7;

-- Restricted AXI4 channel relationships
-- AXI4 defines minimal inter-channel dependencies. To eliminate the need for additional FIFO buffers, this device assumes that 
-- wvalid will be asserted on the same cycle as awvalid

architecture RTL of DMAcontrollerMIG7 is

-- MIG7 user interface app_cmd commands
constant MIG_WRITE               : std_logic_vector(2 downto 0) := "000";
constant MIG_READ                : std_logic_vector(2 downto 0) := "001";
-- AXI4 axi_axburst types
constant AXI_INCR          	     : std_logic_vector(1 downto 0) := "01";
-- AXI4 xRESP types
constant AXI_OKAY		     : std_logic_vector(1 downto 0) := "00";
constant AXI_SLVERR		     : std_logic_vector(1 downto 0) := "10";

type handshake_type is (pending, confirm);
type arbiter_type is (s_axi_read, s_axi_write, t_axi_read, t_axi_read_seq, none);

signal s_axi_aw_state, s_axi_w_state, s_axi_ar_state, t_axi_ar_state : handshake_type;
signal s_axi_aw_state_n, s_axi_w_state_n, s_axi_ar_state_n, t_axi_ar_state_n : handshake_type;
signal arbiter : arbiter_type;
signal s_axi_wlanes, s_axi_rlanes : STD_LOGIC_VECTOR(3 DOWNTO 2);
signal t_axi_araddr_r : STD_LOGIC_VECTOR(31 DOWNTO 0);
signal t_axi_arlen_r :  STD_LOGIC_VECTOR(7 downto 0);
signal t_axi_arlen_r1 : STD_LOGIC_VECTOR(7 downto 0);
signal s_axi_arlen_r1 : STD_LOGIC_VECTOR(0 downto 0);

begin

-- MIG7 overall control
sys_clk_i <= CLK200MHZ;
sys_rst <= not RESET;
app_sr_req <= '0';
app_ref_req <= '0';
app_zq_req <= '0';

-- registered signals
process 
begin
	wait until rising_edge(CLK100MHZ);
	if RESET = '1' or init_calib_complete = '0' then
		s_axi_aw_state <= pending;
		s_axi_w_state <= pending;
		s_axi_ar_state <= pending;
		t_axi_ar_state <= pending;		
		s_axi_rlanes <= "00";
		t_axi_arlen_r1 <= (others=>'0');
		s_axi_arlen_r1 <= (others=>'0');
	else
		s_axi_aw_state <= s_axi_aw_state_n;
		s_axi_w_state <= s_axi_w_state_n;	
		s_axi_ar_state <= s_axi_ar_state_n;
		t_axi_ar_state <= t_axi_ar_state_n;

		-- recursive state machine logic
		if arbiter = s_axi_read then
			s_axi_rlanes <= s_axi_araddr(3 downto 2);
		end if;
		
		if arbiter = t_axi_read and app_rdy = '1' then
			t_axi_araddr_r <= t_axi_araddr + 16;
		elsif arbiter = t_axi_read_seq and app_rdy = '1' then
			t_axi_araddr_r <= t_axi_araddr_r + 16;
		else
			t_axi_araddr_r <= (others =>'0');
		end if;
		
		if arbiter = t_axi_read and app_rdy = '1' then
			t_axi_arlen_r <= t_axi_arlen;
		elsif arbiter = t_axi_read_seq and app_rdy = '1' then
			t_axi_arlen_r <= t_axi_arlen_r - 1;
		else
			t_axi_arlen_r <= (others=>'0');
		end if;
		
		if arbiter = t_axi_read and app_rdy = '1' then 
			t_axi_arlen_r1 <= t_axi_arlen + 1;
		elsif t_axi_arlen_r1 /= 0 and app_rd_data_valid = '1' then
			t_axi_arlen_r1 <= t_axi_arlen_r1 - 1;
		end if;
	
		if arbiter = s_axi_read and app_rdy = '1' then 
			s_axi_arlen_r1 <= "1";
		elsif s_axi_arlen_r1 ="1" and app_rd_data_valid = '1' then
			s_axi_arlen_r1 <= "0";
		end if;	
		
	end if;
end process;

-- combinational arbitration
process (t_axi_arlen_r, s_axi_awvalid, s_axi_wvalid, s_axi_arvalid, t_axi_arvalid, init_calib_complete, t_axi_arlen_r1, s_axi_arlen_r1)
begin
	if init_calib_complete = '1' then
		if t_axi_arlen_r /= 0 then
			arbiter <= t_axi_read_seq;
		elsif s_axi_arvalid = '1' and t_axi_arlen_r1 = 0 then
			arbiter <= s_axi_read;
		elsif s_axi_awvalid = '1' and s_axi_wvalid = '1' then
			arbiter <= s_axi_write;
		elsif t_axi_arvalid = '1' and s_axi_arlen_r1 = 0 then
			arbiter <= t_axi_read;
		else 
			arbiter <= none;
		end if;
	else
		arbiter <= none;
	end if;
end process;

-- handshake next state logic
process (s_axi_aw_state, s_axi_awvalid, app_rdy, s_axi_w_state, s_axi_wvalid, app_wdf_rdy, t_axi_ar_state, t_axi_arvalid, arbiter)
begin
	-- s_axi_aw
	case s_axi_aw_state is
	when pending =>
		if s_axi_awvalid = '1' and app_rdy = '1' and arbiter = s_axi_write then
			s_axi_aw_state_n <= confirm;
		else
			s_axi_aw_state_n <= pending;
		end if;
	when confirm =>
		s_axi_aw_state_n <= pending;
	end case;

	-- s_axi_w
	case s_axi_w_state is
	when pending =>
		if s_axi_wvalid = '1' and app_wdf_rdy = '1' and arbiter = s_axi_write then
			s_axi_w_state_n <= confirm;
		else
			s_axi_w_state_n <= pending;
		end if;
	when confirm =>										
		s_axi_w_state_n <= pending;
	end case;	
	
	-- s_axi_ar
	case s_axi_ar_state is
	when pending =>
		if s_axi_arvalid = '1' and app_rdy = '1' and arbiter = s_axi_read then
			s_axi_ar_state_n <= confirm;
		else
			s_axi_ar_state_n <= pending;
		end if;
	when confirm =>
		s_axi_ar_state_n <= pending;
	end case;	
	
	-- t_axi_ar
	case t_axi_ar_state is
	when pending =>
		if t_axi_arvalid = '1' and app_rdy = '1' and arbiter = t_axi_read then
			t_axi_ar_state_n <= confirm;
		else
			t_axi_ar_state_n <= pending;
		end if;
	when confirm =>
		t_axi_ar_state_n <= pending;
	end case;	
end process;

-- combinatorial state-dependent outputs

-- AXI4
with s_axi_aw_state select s_axi_awready <= '1' when confirm, '0' when others;
with s_axi_w_state  select s_axi_wready  <= '1' when confirm, '0' when others;		-- aw and w may signal ready separately.  need to fix control unit for this!
with s_axi_ar_state select s_axi_arready <= '1' when confirm, '0' when others;
with t_axi_ar_state select t_axi_arready <= '1' when confirm, '0' when others;

s_axi_bresp <= AXI_OKAY;
s_axi_bvalid <= '1';								-- violation of channel dependency, rather remove this channel!

with s_axi_arlen_r1 select s_axi_rvalid <=  '0' when "0", app_rd_data_valid when others;
s_axi_rresp <= AXI_OKAY;
with s_axi_rlanes select
	s_axi_rdata <= 	app_rd_data(31 downto 0)	when "00",
				app_rd_data(63 downto 31)	when "01",
				app_rd_data(95 downto 64)	when "10",
				app_rd_data(127 downto 96)	when others;
				
with t_axi_arlen_r1 select t_axi_rvalid <= '0' when "00000000", app_rd_data_valid when others;				
t_axi_rresp <= AXI_OKAY;	
t_axi_rdata <= app_rd_data;
t_axi_rlast <= '1' when t_axi_arlen_r1 = 1 and app_rd_data_valid = '1' else '0';

-- MIG UI			
with arbiter select app_cmd <= MIG_WRITE when s_axi_write, MIG_READ when others;

with arbiter select app_addr <= s_axi_awaddr(26 downto 0) when s_axi_write,
				s_axi_araddr(26 downto 0) when s_axi_read,
				t_axi_araddr(26 downto 0) when t_axi_read,
			   	t_axi_araddr_r(26 downto 0) when others;

app_en <= '1' when 	(arbiter = s_axi_write and s_axi_aw_state = pending) or
			(arbiter = s_axi_read and s_axi_ar_state = pending) or
			(arbiter = t_axi_read and t_axi_ar_state = pending) or
			(arbiter = t_axi_read_seq)
		else 	'0';
		
s_axi_wlanes <= s_axi_awaddr(3 downto 2);
with s_axi_wlanes select
	app_wdf_mask <=	"111111111111" & not s_axi_wstrb 		when "00",
				"11111111" & not s_axi_wstrb & "1111" 	when "01",
				"1111" & not s_axi_wstrb & "11111111" 	when "10",
				not s_axi_wstrb & "111111111111"		when others;
				
app_wdf_data <= s_axi_wdata & s_axi_wdata & s_axi_wdata & s_axi_wdata;	
	
with arbiter select app_wdf_wren <= '1' when s_axi_write, '0' when others;
with arbiter select app_wdf_end <= '1' when s_axi_write, '0' when others;

end RTL;

