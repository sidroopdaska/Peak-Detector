library ieee;
use ieee.std_logic_1164.all;

entity TEST_TOP is 
	port (
		clk:	in std_logic;
		clear:	in std_logic; -- asynchronous reset
		reset:	in std_logic; -- synchronous reset
		rxdata:	in std_logic;
		txdata:	out std_logic
		--rxDataOut: out std_logic_vector(7 downto 0)
	);
end;

architecture STRUCT of TEST_TOP is

	component UART_TX_CTRL is
		port( 
			SEND : in  STD_LOGIC; -- start Tx (active high)
			DATA : in  STD_LOGIC_VECTOR (7 downto 0); -- parallel data in
			CLK : in  STD_LOGIC; -- system clock
			READY : out  STD_LOGIC; -- Tx done (active high)
			UART_TX : out  STD_LOGIC -- seial data out
		);
	end component;  

	component UART_RX_CTRL is
	  port(
		 RxD: in std_logic; 			-- serial data in
		 sysclk: in std_logic; 		-- system clock
		 reset: in std_logic;		--	synchronous reset
		 rxDone: in std_logic;		-- data succesfully read (active high)
		 rcvDataReg: out std_logic_vector(7 downto 0); -- received data
		 dataReady: out std_logic;	-- data ready to be read
		 setOE: out std_logic;		-- overrun error (active high)
		 setFE: out std_logic		-- frame error (active high)
	  );
	end component;


	component cmdProc is
		port (
			 clk:		in std_logic;
      reset:		in std_logic;
      rxnow:		in std_logic;
      rxData:			in std_logic_vector (7 downto 0);
      txData:			out std_logic_vector (7 downto 0);
      rxdone:		out std_logic;
     -- ovErr:		in std_logic;
      --framErr:	in std_logic;
      txnow:		out std_logic;
      txdone:		in std_logic
		);
	end component;	

	for rx: UART_RX_CTRL use
	  entity work.UART_RX_CTRL( RCVR);

	signal sig_rxnow, sig_rxdone, sig_overr, sig_framerr, sig_txnow, sig_txdone: std_logic;
	signal sig_rxdata, sig_txdata: std_logic_vector (7 downto 0);
begin 

control:	cmdProc
	port map (
		clk => clk,
		reset => reset,
		rxnow => sig_rxnow,
		rxData => sig_rxdata,
		txData => sig_txdata,
		rxdone => sig_rxdone,
		--ovrerr => sig_overr,
		--framerr => sig_framerr,
		txnow => sig_txnow,
		txdone => sig_txdone
	);

tx: UART_TX_CTRL
	port map (
		SEND => sig_txnow,
		DATA => sig_txdata,
		CLK => clk,
		READY => sig_txdone,
		UART_TX => txdata
	);

rx : UART_RX_CTRL
   port map(
	  RxD => rxdata, -- input serial line
	  sysclk => clk,
	  reset => reset, 
	  rxDone => sig_rxdone,
	  rcvDataReg => sig_rxdata,
     dataReady => sig_rxnow,
     setOE => sig_overr,
     setFE =>  sig_framerr
   ); 
	
end;