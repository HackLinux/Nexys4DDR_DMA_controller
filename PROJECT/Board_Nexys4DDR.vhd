library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Board_Nexys4DDR is
port (
       CLKIN			: in    std_logic;
       ddr2_dq              : inout std_logic_vector(15 downto 0);
       ddr2_dqs_p           : inout std_logic_vector(1 downto 0);
       ddr2_dqs_n           : inout std_logic_vector(1 downto 0);
       ddr2_addr            : out   std_logic_vector(12 downto 0);
       ddr2_ba              : out   std_logic_vector(2 downto 0);
       ddr2_ras_n           : out   std_logic;
       ddr2_cas_n           : out   std_logic;
       ddr2_we_n            : out   std_logic;
       ddr2_ck_p            : out   std_logic_vector(0 downto 0);
       ddr2_ck_n            : out   std_logic_vector(0 downto 0);
       ddr2_cke             : out   std_logic_vector(0 downto 0);
       ddr2_cs_n            : out   std_logic_vector(0 downto 0);
       ddr2_dm              : out   std_logic_vector(1 downto 0);
       ddr2_odt             : out   std_logic_vector(0 downto 0)
);
end Board_Nexys4DDR;

architecture RTL of Board_Nexys4DDR is

component clk_wiz_0
port (
       CLK_IN1           : in     std_logic;
       CLK_OUT1          : out    std_logic;
       CLK_OUT2          : out    std_logic;
       LOCKED            : out    std_logic
 );
end component;

COMPONENT DMAcontrollerMIG7
	Port (
	CLK100MHZ	 : 	IN STD_LOGIC;						-- 100MHz clock, registers latch on leading edge
	CLK200MHZ	: STD_LOGIC;
	RESET : in STD_LOGIC;						-- active low reset
	s_axi_awvalid : IN STD_LOGIC;					-- source indicates channel	data valid
	s_axi_awready : OUT STD_LOGIC;					-- destination indicates that it can accept channel data									-- source may not wait for ready to assert valid
	s_axi_awaddr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);			-- true byte addressing											
	s_axi_wdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
	s_axi_wstrb : IN STD_LOGIC_VECTOR(3 DOWNTO 0);			-- active high byte mask for the data	
	s_axi_wvalid : IN STD_LOGIC;
	s_axi_wready : OUT STD_LOGIC;					-- this channel to be removed!
	s_axi_bresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);			-- write response value: see constants
	s_axi_bvalid : OUT STD_LOGIC;					-- BVALID is dependent on WVALID, WREADY, AWVALID, and AWREADY,  
	s_axi_bready : IN STD_LOGIC;
	s_axi_araddr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
	s_axi_arvalid : IN STD_LOGIC;
	s_axi_arready : OUT STD_LOGIC;
	s_axi_rdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
	s_axi_rresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);			-- read response value: see constants
	s_axi_rvalid : OUT STD_LOGIC;					-- RVALID is dependent on ARVALID and ARREADY
	s_axi_rready : IN STD_LOGIC;
	t_axi_araddr : IN  std_logic_vector(31 downto 0);		-- true byte addressing	
	t_axi_arlen : IN  std_logic_vector(7 downto 0);			-- No. beats = axi_arlen + 1
	t_axi_arsize : IN  std_logic_vector(2 downto 0);			-- size in bytes: "000" = 1 byte, "001" = 2 bytes, "010" = 4 bytes, "011" = 8 bytes, "100" = 16 bytes 
	t_axi_arburst : IN  std_logic_vector(1 downto 0);		-- see VHDL constants
	t_axi_arvalid : IN  std_logic;
	t_axi_arready : OUT  std_logic;
	t_axi_rdata : OUT  std_logic_vector(127 downto 0);
	t_axi_rresp : OUT  std_logic_vector(1 downto 0);			
	t_axi_rlast : OUT  std_logic;					-- set high to indicate last data word
	t_axi_rvalid : OUT  std_logic;
	t_axi_rready : IN  std_logic;
	ui_clk               : in     std_logic;				-- CLOCK
	ui_clk_sync_rst      : in     std_logic;				-- active-high reset
	app_en               : out    std_logic;				-- user holds app_en high with a valid app_cmd until app_rdy is asserted
	app_cmd              : out    std_logic_vector(2 downto 0);	-- see VDHL constants
	app_rdy              : in     std_logic;				-- MIG7 registers a command provided rdy is high
	app_addr             : out    std_logic_vector(26 downto 0);	-- true byte addressing
	app_wdf_data         : out    std_logic_vector(127 downto 0);	-- 64 bit data since 16 ddr2 lines and 2:1 MIG7 clocking
	app_wdf_mask         : out    std_logic_vector(15 downto 0);	-- active high byte mask for the data	
	app_wdf_wren         : out    std_logic;				-- user holds high throughout transfer to indicate valid data
	app_wdf_rdy          : in     std_logic;				-- MIG registers data provided rdy is high
	app_wdf_end          : out    std_logic;				-- set high to indicate last data word
	app_rd_data          : in	  std_logic_vector(127 downto 0);
	app_rd_data_end      : in     std_logic;				-- signals end of burst (not needed in handshake logic)
	app_rd_data_valid    : in     std_logic;				-- valid read data is on the bus
	app_sr_req           : out    std_logic;				-- tie to '0'
	app_sr_active        : in     std_logic;				-- disregard
	app_ref_req          : out    std_logic;				-- tie to '0'
	app_ref_ack          : in     std_logic;				-- disregard
	app_zq_req           : out    std_logic;				-- tie to '0'
	app_zq_ack           : in     std_logic;				-- disregard
	init_calib_complete  : in     std_logic				-- MIG7 requires 50-60uS to complete calibraton in simulator
	);		
END COMPONENT;

component ddr
   port (
      -- Inouts
      ddr2_dq              : inout std_logic_vector(15 downto 0);
      ddr2_dqs_p           : inout std_logic_vector(1 downto 0);
      ddr2_dqs_n           : inout std_logic_vector(1 downto 0);
      -- Outputs
      ddr2_addr            : out   std_logic_vector(12 downto 0);
      ddr2_ba              : out   std_logic_vector(2 downto 0);
      ddr2_ras_n           : out   std_logic;
      ddr2_cas_n           : out   std_logic;
      ddr2_we_n            : out   std_logic;
      ddr2_ck_p            : out   std_logic_vector(0 downto 0);
      ddr2_ck_n            : out   std_logic_vector(0 downto 0);
      ddr2_cke             : out   std_logic_vector(0 downto 0);
      ddr2_cs_n            : out   std_logic_vector(0 downto 0);
      ddr2_dm              : out   std_logic_vector(1 downto 0);
      ddr2_odt             : out   std_logic_vector(0 downto 0);
      -- Inputs
      sys_clk_i            : in    std_logic;
      sys_rst              : in    std_logic;
      -- user interface signals
      app_addr             : in    std_logic_vector(26 downto 0);
      app_cmd              : in    std_logic_vector(2 downto 0);
      app_en               : in    std_logic;
      app_wdf_data         : in    std_logic_vector(127 downto 0);
      app_wdf_end          : in    std_logic;
      app_wdf_mask         : in    std_logic_vector(7 downto 0);
      app_wdf_wren         : in    std_logic;
      app_rd_data          : out   std_logic_vector(127 downto 0);
      app_rd_data_end      : out   std_logic;
      app_rd_data_valid    : out   std_logic;
      app_rdy              : out   std_logic;
      app_wdf_rdy          : out   std_logic;
      app_sr_req           : in    std_logic;
      app_sr_active        : out   std_logic;
      app_ref_req          : in    std_logic;
      app_ref_ack          : out   std_logic;
      app_zq_req           : in    std_logic;
      app_zq_ack           : out   std_logic;
      ui_clk               : out   std_logic;
      ui_clk_sync_rst      : out   std_logic;
      --device_temp_i        : in    std_logic_vector(11 downto 0);
      init_calib_complete  : out   std_logic);
end component;

component DMAtest
   port (
   RESET                : in    std_logic;
   s_axi_awvalid : OUT STD_LOGIC;					-- source indicates channel	data valid
   s_axi_awready : IN STD_LOGIC;					-- destination indicates that it can accept channel data
   s_axi_awaddr : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);			-- true byte addressing											
   s_axi_wdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
   s_axi_wstrb : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);			-- active high byte mask for the data	
   s_axi_wvalid : OUT STD_LOGIC;
   s_axi_wready : IN STD_LOGIC;						-- this channel to be removed!
   s_axi_bresp : IN STD_LOGIC_VECTOR(1 DOWNTO 0);			-- write response value: see constants
   s_axi_bvalid : IN STD_LOGIC;					-- BVALID is dependent on WVALID, WREADY, AWVALID, and AWREADY,  
   s_axi_bready : OUT STD_LOGIC;
   s_axi_araddr : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
   s_axi_arvalid : OUT STD_LOGIC;
   s_axi_arready : IN STD_LOGIC;
   s_axi_rdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
   s_axi_rresp : IN STD_LOGIC_VECTOR(1 DOWNTO 0);			-- read response value: see constants
   s_axi_rvalid : IN STD_LOGIC;					-- RVALID is dependent on ARVALID and ARREADY
   s_axi_rready : OUT STD_LOGIC;
   t_axi_araddr : OUT  std_logic_vector(31 downto 0);		-- true byte addressing	
   t_axi_arlen : OUT  std_logic_vector(7 downto 0);			-- No. beats = axi_arlen + 1
   t_axi_arsize : OUT  std_logic_vector(2 downto 0);			-- size in bytes: "000" = 1 byte, "001" = 2 bytes, "010" = 4 bytes, "011" = 8 bytes, "100" = 16 bytes
   t_axi_arburst : OUT  std_logic_vector(1 downto 0);		-- see VHDL constants
   t_axi_arvalid : OUT  std_logic;
   t_axi_arready : IN  std_logic;
   t_axi_rdata : IN  std_logic_vector(127 downto 0);
   t_axi_rresp : IN  std_logic_vector(1 downto 0);			
   t_axi_rlast : IN  std_logic;					-- set high to indicate last data word
   t_axi_rvalid : IN  std_logic;
   t_axi_rready : OUT  std_logic
);
end component;

signal CLK100MHZ, CLK200MHZ : STD_LOGIC;
signal RESET, RESET_LO :STD_LOGIC;
signal s_aresetn :  STD_LOGIC;                                          -- active low reset
signal s_axi_awvalid :  STD_LOGIC;                                   -- source indicates channel       data valid
signal s_axi_awready :  STD_LOGIC;                                   -- destination indicates that it can accept channel data
signal s_axi_awaddr :  STD_LOGIC_VECTOR(31 DOWNTO 0);                     -- true byte addressing                                                                             
signal s_axi_wdata :  STD_LOGIC_VECTOR(31 DOWNTO 0);
signal s_axi_wstrb :  STD_LOGIC_VECTOR(3 DOWNTO 0);                     -- active high byte mask for the data       
signal s_axi_wvalid :  STD_LOGIC;
signal s_axi_wready :  STD_LOGIC;                                          -- this channel to be removed!
signal s_axi_bresp :  STD_LOGIC_VECTOR(1 DOWNTO 0);                     -- write response value: see constants
signal s_axi_bvalid :  STD_LOGIC;                                   -- BVALID is dependent on WVALID, WREADY, AWVALID, and AWREADY,  
signal s_axi_bready :  STD_LOGIC;
signal s_axi_araddr :  STD_LOGIC_VECTOR(31 DOWNTO 0);
signal s_axi_arvalid :  STD_LOGIC;
signal s_axi_arready :  STD_LOGIC;
signal s_axi_rdata :  STD_LOGIC_VECTOR(31 DOWNTO 0);
signal s_axi_rresp :  STD_LOGIC_VECTOR(1 DOWNTO 0);                     -- read response value: see constants
signal s_axi_rvalid :  STD_LOGIC;                                   -- RVALID is dependent on ARVALID and ARREADY
signal s_axi_rready :  STD_LOGIC;
signal t_axi_araddr :   std_logic_vector(31 downto 0);              -- true byte addressing       
signal t_axi_arlen :   std_logic_vector(7 downto 0);                     -- No. beats = axi_arlen + 1
signal t_axi_arsize :   std_logic_vector(2 downto 0);                     -- size in bytes: "000" = 1 byte, "001" = 2 bytes, "010" = 4 bytes, "011" = 8 bytes, "100" = 16 bytes
signal t_axi_arburst :   std_logic_vector(1 downto 0);              -- see VHDL constants
signal t_axi_arvalid :   std_logic;
signal t_axi_arready :   std_logic;
signal t_axi_rdata :   std_logic_vector(127 downto 0);
signal t_axi_rresp :   std_logic_vector(1 downto 0);                     
signal t_axi_rlast :   std_logic;                                   -- set high to indicate last data word
signal t_axi_rvalid :   std_logic;
signal t_axi_rready :   std_logic;
signal app_en               :     std_logic;                            -- user holds app_en high with a valid app_cmd until app_rdy is asserted
signal app_cmd              :     std_logic_vector(2 downto 0);       -- see VDHL constants
signal app_rdy              :      std_logic;                            -- MIG7 registers a command provided rdy is high
signal app_addr             :     std_logic_vector(26 downto 0);       -- true byte addressing
signal app_wdf_data         :     std_logic_vector(127 downto 0);       -- 64 bit data since 16 ddr2 lines and 2:1 MIG7 clocking
signal app_wdf_mask         :     std_logic_vector(15 downto 0);       -- active high byte mask for the data       
signal app_wdf_wren         :     std_logic;                            -- user holds high throughout transfer to indicate valid data
signal app_wdf_rdy          :      std_logic;                            -- MIG registers data provided rdy is high
signal app_wdf_end          :     std_logic;                            -- set high to indicate last data word
signal app_rd_data          :          std_logic_vector(127 downto 0);
signal app_rd_data_end      :      std_logic;                            -- signals end of burst (not needed in handshake logic)
signal app_rd_data_valid    :      std_logic;                            -- valid read data is on the bus
signal app_sr_req           :     std_logic;                            -- tie to '0'
signal app_sr_active        :      std_logic;                            -- disregard
signal app_ref_req          :     std_logic;                            -- tie to '0'
signal app_ref_ack          :      std_logic;                            -- disregard
signal app_zq_req           :     std_logic;                            -- tie to '0'
signal app_zq_ack           :      std_logic;                            -- disregard
signal init_calib_complete  :      std_logic;                            -- MIG7 requires 50-60uS to complete calibraton in simulator

begin

inst_CLOCKGEN: clk_wiz_0
  port map
   (CLK_IN1 => CLKIN,
    CLK_OUT1 => CLK100MHZ,
    CLK_OUT2 => CLK200MHZ,
    LOCKED => LOCKED);

inst_DMAcontrollerMIG7: DMAcontrollerMIG7
 port map
  (
  CLK100MHZ => CLK100MHZ,
  CLK200MHZ => CLK200MHZ,
  RESET => RESET,
  s_axi_awvalid => s_axi_awvalid,
  s_axi_awready => s_axi_awready,
  s_axi_awaddr =>  s_axi_awaddr,                                                                       
  s_axi_wdata => s_axi_wdata,
  s_axi_wstrb => s_axi_wstrb,   
  s_axi_wvalid => s_axi_wvalid,
  s_axi_wready => s_axi_wready,
  s_axi_bresp => s_axi_bresp,
  s_axi_bvalid => s_axi_bvalid,
  s_axi_bready => s_axi_bready, 
  s_axi_araddr => s_axi_araddr,
  s_axi_arvalid => s_axi_arvalid,
  s_axi_arready => s_axi_arready,
  s_axi_rdata => s_axi_rdata, 
  s_axi_rresp => s_axi_rresp,
  s_axi_rvalid => s_axi_rvalid,
  s_axi_rready => s_axi_rready,
  t_axi_araddr => t_axi_araddr,  
  t_axi_arlen => t_axi_arlen,
  t_axi_arsize => t_axi_arsize,
  t_axi_arburst => t_axi_arburst, 
  t_axi_arvalid => t_axi_arvalid,
  t_axi_arready => t_axi_arready,
  t_axi_rdata => t_axi_rdata, 
  t_axi_rresp => t_axi_rresp,            
  t_axi_rlast => t_axi_rlast,
  t_axi_rvalid => t_axi_rvalid,
  t_axi_rready => t_axi_rready,
  ui_clk => ui_clk,
  ui_clk_sync_rst => ui_clk_sync_rst,
  app_en => app_en,
  app_cmd => app_cmd,
  app_rdy => app_rdy,
  app_addr => app_addr,
  app_wdf_data => app_wdf_data,
  app_wdf_mask => app_wdf_mask,     
  app_wdf_wren => app_wdf_wren,
  app_wdf_rdy => app_wdf_rdy,
  app_wdf_end => app_wdf_end,
  app_rd_data => app_rd_data,
  app_rd_data_end => app_rd_data_end,
  app_rd_data_valid => app_rd_data_valid,
  app_sr_req => app_sr_req,
  app_sr_active => app_sr_active,
  app_ref_req => app_ref_req,
  app_ref_ack => app_ref_ack,
  app_zq_req => app_zq_req,
  app_zq_ack => app_zq_ack,
  init_calib_complete => init_calib_complete
  );
  
inst_MIG7: MIG7
  port map (
     ddr2_dq              => ddr2_dq,
     ddr2_dqs_p           => ddr2_dqs_p,
     ddr2_dqs_n           => ddr2_dqs_n,
     ddr2_addr            => ddr2_addr,
     ddr2_ba              => ddr2_ba,
     ddr2_ras_n           => ddr2_ras_n,
     ddr2_cas_n           => ddr2_cas_n,
     ddr2_we_n            => ddr2_we_n,
     ddr2_ck_p            => ddr2_ck_p,
     ddr2_ck_n            => ddr2_ck_n,
     ddr2_cke             => ddr2_cke,
     ddr2_cs_n            => ddr2_cs_n,
     ddr2_dm              => ddr2_dm,
     ddr2_odt             => ddr2_odt,
     sys_clk_i            => sys_clk_i,
     sys_rst              => sys_rst,
     app_addr             => mem_addr,
     app_cmd              => mem_cmd,
     app_en               => mem_en,
     app_wdf_data         => mem_wdf_data,
     app_wdf_end          => mem_wdf_end,
     app_wdf_mask         => mem_wdf_mask,
     app_wdf_wren         => mem_wdf_wren,
     app_rd_data          => mem_rd_data,
     app_rd_data_end      => mem_rd_data_end,
     app_rd_data_valid    => mem_rd_data_valid,
     app_rdy              => mem_rdy,
     app_wdf_rdy          => mem_wdf_rdy,
     app_sr_req           => app_sr_req,
     app_sr_active        => app_sr_active,
     app_ref_req          => app_ref_req,
     app_ref_ack          => app_ref_ack,
     app_zq_req           => app_zq_req,
     app_zq_ack           => app_zq_ack,
     ui_clk               => ui_clk,
     ui_clk_sync_rst      => ui_clk_sync_rst,
     init_calib_complete  => mem_init_calib_complete
     );
  
inst_DMAtest: DMAtest
        port map (
	RESET => RESET,
	s_axi_awvalid => s_axi_awvalid,
	s_axi_awready => s_axi_awready,
	s_axi_awaddr =>  s_axi_awaddr,                                                                       
	s_axi_wdata => s_axi_wdata,
	s_axi_wstrb => s_axi_wstrb,   
	s_axi_wvalid => s_axi_wvalid,
	s_axi_wready => s_axi_wready,
	s_axi_bresp => s_axi_bresp,
	s_axi_bvalid => s_axi_bvalid,
	s_axi_bready => s_axi_bready, 
	s_axi_araddr => s_axi_araddr,
	s_axi_arvalid => s_axi_arvalid,
	s_axi_arready => s_axi_arready,
	s_axi_rdata => s_axi_rdata, 
	s_axi_rresp => s_axi_rresp,
	s_axi_rvalid => s_axi_rvalid,
	s_axi_rready => s_axi_rready,
	t_axi_araddr => t_axi_araddr,  
	t_axi_arlen => t_axi_arlen,
	t_axi_arsize => t_axi_arsize,
	t_axi_arburst => t_axi_arburst, 
	t_axi_arvalid => t_axi_arvalid,
	t_axi_arready => t_axi_arready,
	t_axi_rdata => t_axi_rdata, 
	t_axi_rresp => t_axi_rresp,            
	t_axi_rlast => t_axi_rlast,
	t_axi_rvalid => t_axi_rvalid,
	t_axi_rready => t_axi_rready
     );
  
RESET <= not LOCKED;

end RTL;

