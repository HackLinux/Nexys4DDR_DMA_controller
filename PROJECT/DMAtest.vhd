library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity DMAtest is
   port (
   RESET                : in    std_logic;
   CLK100MHZ	: in std_logic;
   -- address of write channel
   -- handshake protocol
   s_axi_awvalid : OUT STD_LOGIC;					-- source indicates channel	data valid
   s_axi_awready : IN STD_LOGIC;					-- destination indicates that it can accept channel data
   										-- transfer occurs only when valid and ready are high
   										-- destination may hold ready high or wait for valid
   										-- source may not wait for ready to assert valid
   s_axi_awaddr : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);			-- true byte addressing											
   -- write channel
   s_axi_wdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
   s_axi_wstrb : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);			-- active high byte mask for the data	
   s_axi_wvalid : OUT STD_LOGIC;
   s_axi_wready : IN STD_LOGIC;
   -- write response channel						-- this channel to be removed!
   s_axi_bresp : IN STD_LOGIC_VECTOR(1 DOWNTO 0);			-- write response value: see constants
   s_axi_bvalid : IN STD_LOGIC;					-- BVALID is dependent on WVALID, WREADY, AWVALID, and AWREADY,  
   s_axi_bready : OUT STD_LOGIC;
   -- address of read channel
   s_axi_araddr : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
   s_axi_arvalid : OUT STD_LOGIC;
   s_axi_arready : IN STD_LOGIC;
   -- read/read-response channel
   s_axi_rdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
   s_axi_rresp : IN STD_LOGIC_VECTOR(1 DOWNTO 0);			-- read response value: see constants
   s_axi_rvalid : IN STD_LOGIC;					-- RVALID is dependent on ARVALID and ARREADY
   s_axi_rready : OUT STD_LOGIC;
   ----------------------------------------------------------------
   -- AIX4 read channel connections (as seen by SLAVE)
   -- address of read channel
   t_axi_araddr : OUT  std_logic_vector(31 downto 0);		-- true byte addressing	
   									-- MASTER indicates only the first byte address, SLAVE will calculate the rest
   -- burst length specifies the number of beats in the data transfer
   t_axi_arlen : OUT  std_logic_vector(7 downto 0);			-- No. beats = axi_arlen + 1
   -- burst size is the number of bytes to transfer in each beat (width)
   t_axi_arsize : OUT  std_logic_vector(2 downto 0);			-- size in bytes: "000" = 1 byte, "001" = 2 bytes, "010" = 4 bytes, "011" = 8 bytes, "100" = 16 bytes
   -- burst type is the nature of address increment during the burst 
   t_axi_arburst : OUT  std_logic_vector(1 downto 0);		-- see VHDL constants
   t_axi_arvalid : OUT  std_logic;
   t_axi_arready : IN  std_logic;
   -- read/read-response channel
   t_axi_rdata : IN  std_logic_vector(127 downto 0);
   t_axi_rresp : IN  std_logic_vector(1 downto 0);			
   t_axi_rlast : IN  std_logic;					-- set high to indicate last data word
   t_axi_rvalid : IN  std_logic;
   t_axi_rready : OUT  std_logic
);
end DMAtest;

architecture RTL of DMAtest is

signal tick1, tick2, tick3 : std_logic;

begin

process
begin
	tick1 <= '0';
	s_axi_awvalid <= '0';
	s_axi_wstrb <= (others=> '0');
	s_axi_awaddr <= (others => '0');											
	wait until RESET = '0';
	s_axi_awaddr <= "00000000000000000000000000000100";
	s_axi_wstrb <= "1111";
	s_axi_awvalid <= '1';
	wait until rising_edge(CLK100MHZ) and s_axi_awready = '1';
	s_axi_awvalid <= '0';
	tick1 <= '1';
	wait;
end process;

process
begin
	tick2 <= '0';
	s_axi_bready <= '1';	
	s_axi_wdata <= (others => '0');
	s_axi_wstrb <= (others => '0');	
	s_axi_wvalid <= '0';	
	wait until RESET = '0';
	s_axi_wdata <= X"FEDCBA98";
	s_axi_wstrb <= "1111";
	s_axi_wvalid <= '1';
	wait until rising_edge(CLK100MHZ) and s_axi_wready = '1';
	s_axi_wvalid <= '0';
	tick2 <= '1';
	wait;
end process;

process
begin
	tick3 <= '0';
	s_axi_araddr <= (others => '0');
	s_axi_arvalid <= '0';
	s_axi_rready <= '0';
	wait until tick1 = '1' and tick2 = '1' and rising_edge(CLK100MHZ);
	s_axi_araddr <= "00000000000000000000000000000100";
	s_axi_arvalid <= '1';
	wait until rising_edge(CLK100MHZ) and s_axi_arready = '1';
	s_axi_arvalid <= '0';
	tick3 <= '1';
	wait;
end process;

process
begin
	t_axi_araddr <= (others => '0');
	t_axi_arlen <= (others => '0');
	t_axi_arsize <= (others => '0');
	t_axi_arburst <= (others => '0');
	t_axi_arvalid <= '0';
	t_axi_rready <= '0';
	wait until tick3 = '1' and rising_edge(CLK100MHZ);	
	t_axi_arlen <= "00000011";
	t_axi_arvalid <= '1';
	wait until rising_edge(CLK100MHZ) and t_axi_arready = '1';
	t_axi_arvalid <= '0';
	wait;
end process;

end RTL;
