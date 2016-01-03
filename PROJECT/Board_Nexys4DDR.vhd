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
	CLK100MHZ	 	: IN STD_LOGIC;
	CLK200MHZ		: IN STD_LOGIC;
	RESET 			: in STD_LOGIC;
	s_axi_awvalid 	: IN STD_LOGIC;
	s_axi_awready 	: OUT STD_LOGIC;
	s_axi_awaddr 		: IN STD_LOGIC_VECTOR(31 DOWNTO 0);											
	s_axi_wdata 		: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
	s_axi_wstrb 		: IN STD_LOGIC_VECTOR(3 DOWNTO 0);	
	s_axi_wvalid 		: IN STD_LOGIC;
	s_axi_wready 		: OUT STD_LOGIC;
	s_axi_bresp 		: OUT STD_LOGIC_VECTOR(1 DOWNTO 0);	-- remove
	s_axi_bvalid 		: OUT STD_LOGIC;  				-- remove
	s_axi_bready 		: IN STD_LOGIC;				-- remove
	s_axi_araddr 		: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
	s_axi_arvalid 	: IN STD_LOGIC;
	s_axi_arready 	: OUT STD_LOGIC;
	s_axi_rdata 		: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
	s_axi_rresp 		: OUT STD_LOGIC_VECTOR(1 DOWNTO 0);	-- remove
	s_axi_rvalid 		: OUT STD_LOGIC;
	s_axi_rready 		: IN STD_LOGIC;				-- remove
	t_axi_araddr 		: IN  std_logic_vector(31 downto 0);
	t_axi_arlen 		: IN  std_logic_vector(7 downto 0);
	t_axi_arsize 		: IN  std_logic_vector(2 downto 0); 	-- remove
	t_axi_arburst 	: IN  std_logic_vector(1 downto 0);	-- remove
	t_axi_arvalid 	: IN  std_logic;
	t_axi_arready 	: OUT  std_logic;
	t_axi_rdata 		: OUT  std_logic_vector(127 downto 0);
	t_axi_rresp 		: OUT  std_logic_vector(1 downto 0);	-- remove			
	t_axi_rlast 		: OUT  std_logic;
	t_axi_rvalid 		: OUT  std_logic;
	t_axi_rready		: IN  std_logic;				-- remove
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
END COMPONENT;

component DMAtest
   port (
   RESET                : in    std_logic;
   CLK100MHZ		   : in std_logic;
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
signal RESET : STD_LOGIC;
signal LOCKED : STD_LOGIC;
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
  ddr2_dq => ddr2_dq,
  ddr2_dqs_p => ddr2_dqs_p,
  ddr2_dqs_n => ddr2_dqs_n,
  ddr2_addr => ddr2_addr,
  ddr2_ba => ddr2_ba,
  ddr2_ras_n => ddr2_ras_n,
  ddr2_cas_n => ddr2_cas_n,
  ddr2_we_n => ddr2_we_n,
  ddr2_ck_p => ddr2_ck_p,
  ddr2_ck_n => ddr2_ck_n,
  ddr2_cke => ddr2_cke,
  ddr2_cs_n => ddr2_cs_n,
  ddr2_dm => ddr2_dm,
  ddr2_odt => ddr2_odt
  );
  
inst_DMAtest: DMAtest
        port map (
	RESET => RESET,
	CLK100MHZ => CLK100MHZ,
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

