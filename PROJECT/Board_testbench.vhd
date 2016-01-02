LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY Board_testbench IS
END Board_testbench;
 
ARCHITECTURE behavior OF Board_testbench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
COMPONENT Board_Nexys4DDR
PORT(
	CLKIN : IN  std_logic;
	ddr2_dq : INOUT  std_logic_vector(15 downto 0);
	ddr2_dqs_p : INOUT  std_logic_vector(1 downto 0);
	ddr2_dqs_n : INOUT  std_logic_vector(1 downto 0);
	ddr2_addr : OUT  std_logic_vector(12 downto 0);
	ddr2_ba : OUT  std_logic_vector(2 downto 0);
	ddr2_ras_n : OUT  std_logic;
	ddr2_cas_n : OUT  std_logic;
	ddr2_we_n : OUT  std_logic;
	ddr2_ck_p : OUT  std_logic_vector(0 downto 0);
	ddr2_ck_n : OUT  std_logic_vector(0 downto 0);
	ddr2_cke : OUT  std_logic_vector(0 downto 0);
	ddr2_cs_n : OUT  std_logic_vector(0 downto 0);
	ddr2_dm : OUT  std_logic_vector(1 downto 0);
	ddr2_odt : OUT  std_logic_vector(0 downto 0)
  );
END COMPONENT;
 
COMPONENT ddr2 
PORT(
       ck		: IN std_logic;
       ck_n	: IN std_logic;
       cke	: IN std_logic;
       cs_n	: IN std_logic;
       ras_n	: IN std_logic;
       cas_n : IN std_logic;
       we_n	: IN std_logic;
       dm_rdqs : INOUT  std_logic_vector(1 downto 0);
       ba		: IN std_logic_vector (2 downto 0);
       addr	: IN std_logic_vector(12 downto 0);
       dq		: INOUT std_logic_vector(15 downto 0);
       dqs	: INOUT std_logic_vector(1 downto 0);
       dqs_n : INOUT std_logic_vector(1 downto 0);
       rdqs_n  : OUT std_logic_vector(1 downto 0);
       odt	: IN std_logic
       );
END COMPONENT;
	 
   --Inputs
   signal CLKIN : std_logic := '0';

	--BiDirs
   signal ddr2_dq : std_logic_vector(15 downto 0);
   signal ddr2_dqs_p : std_logic_vector(1 downto 0);
   signal ddr2_dqs_n : std_logic_vector(1 downto 0);

 	--Outputs
   signal ddr2_addr : std_logic_vector(12 downto 0);
   signal ddr2_ba : std_logic_vector(2 downto 0);
   signal ddr2_ras_n : std_logic;
   signal ddr2_cas_n : std_logic;
   signal ddr2_we_n : std_logic;
   signal ddr2_ck_p : std_logic_vector(0 downto 0);
   signal ddr2_ck_n : std_logic_vector(0 downto 0);
   signal ddr2_cke : std_logic_vector(0 downto 0);
   signal ddr2_cs_n : std_logic_vector(0 downto 0);
   signal ddr2_dm : std_logic_vector(1 downto 0);
   signal ddr2_odt : std_logic_vector(0 downto 0);

   -- Clock period definitions
   constant CLKIN_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Board_Nexys4DDR PORT MAP (
          CLKIN => CLKIN,
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
		 

	inst_ddr2: ddr2
	PORT MAP (
		ck => ddr2_ck_p(0),
		ck_n => ddr2_ck_n(0),
		cke => ddr2_cke(0),
		cs_n => ddr2_cs_n(0),
		ras_n => ddr2_ras_n,
		cas_n => ddr2_cas_n,
		we_n => ddr2_we_n,
		dm_rdqs => ddr2_dm,
		ba => ddr2_ba,
		addr => ddr2_addr,
		dq => ddr2_dq,
		dqs => ddr2_dqs_p,
		dqs_n => ddr2_dqs_n,
		rdqs_n => open,
		odt => ddr2_odt(0)
	);

   -- Clock process definitions
   CLKIN_process :process
   begin
		CLKIN <= '0';
		wait for CLKIN_period/2;
		CLKIN <= '1';
		wait for CLKIN_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for CLKIN_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
