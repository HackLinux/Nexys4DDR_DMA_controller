library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

Library UNISIM;
use UNISIM.vcomponents.all;

entity DMAcontrollerMIG7 is
	Port (
	CLK100MHZ : 	IN STD_LOGIC;						-- 100MHz clock, registers latch on leading edge
	---------------------------------------------------------------
	-- AXI4 lite connections (as seen by SLAVE)
	s_aresetn : in STD_LOGIC;						-- active low reset
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
	-- write response channel
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
	t_axi_rdata : OUT  std_logic_vector(31 downto 0);
	t_axi_rresp : OUT  std_logic_vector(1 downto 0);			
	t_axi_rlast : OUT  std_logic;					-- set high to indicate last data word
	t_axi_rvalid : OUT  std_logic;
	t_axi_rready : IN  std_logic;
	----------------------------------------------------------------
	-- MIG7 user interface signals
	ui_clk               : in     std_logic;				-- CLOCK
	ui_clk_sync_rst      : in     std_logic;				-- active-high reset
	-- user command information
	app_en               : out    std_logic;				-- user holds app_en high with a valid app_cmd until app_rdy is asserted
	app_cmd              : out    std_logic_vector(2 downto 0);	-- see VDHL constants
	app_rdy              : in     std_logic;				-- MIG7 registers a command provided rdy is high
	app_addr             : out    std_logic_vector(26 downto 0);	-- true byte addressing
										-- addr needs to be incremented for each new command
	-- write information
		-- write data must preceed WRITE command or follow within 2 clock cycles
	app_wdf_data         : out    std_logic_vector(63 downto 0);	-- 64 bit data since 16 ddr2 lines and 2:1 MIG7 clocking
	app_wdf_mask         : out    std_logic_vector(7 downto 0);	-- active high byte mask for the data	
	app_wdf_wren         : out    std_logic;				-- user holds high throughout transfer to indicate valid data
	app_wdf_rdy          : in     std_logic;				-- MIG registers data provided rdy is high
	app_wdf_end          : out    std_logic;				-- set high to indicate last data word
	-- read information
	app_rd_data          : in	  std_logic_vector(63 downto 0);
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
	-- calibration complete
	init_calib_complete  : in     std_logic				-- MIG7 requires 50-60uS to complete calibraton in simulator
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

begin


end RTL;

