library ieee;
use ieee.std_logic_1164.all;
use work.common_pack.all;

entity tb_dataGenConsume is 
end;

architecture test of tb_dataGenConsume is 

  component UART_TX_CTRL is
    port ( 
      SEND : in  STD_LOGIC;
      DATA : in  STD_LOGIC_VECTOR (7 downto 0);
      CLK : in  STD_LOGIC;
      READY : out  STD_LOGIC;
      UART_TX : out  STD_LOGIC
    );
  end component;  
  
  component UART_RX_CTRL is
    port(
      RxD: in std_logic;                -- serial data in
      sysclk: in std_logic; 		-- system clock
      reset: in std_logic;		--	synchronous reset
      rxDone: in std_logic;		-- data succesfully read (active high)
      rcvDataReg: out std_logic_vector(7 downto 0); -- received data
      dataReady: out std_logic;	        -- data ready to be read
      setOE: out std_logic;		-- overrun error (active high)
      setFE: out std_logic		-- frame error (active high)
    );
  end component; 

--  component dataGen is
--    port (
--      clk:		in std_logic;
--      reset:		in std_logic; -- synchronous reset
--      ctrlIn: in std_logic;
--      ctrlOut: out std_logic;
--      data: out std_logic_vector(7 downto 0)
--    );
--  end component;
--  
--  component dataConsume is
--    port (
--      clk:		in std_logic;
--      reset:		in std_logic; -- synchronous reset
--      start: in std_logic;
--      numWords_bcd: in BCD_ARRAY_TYPE(2 downto 0);
--      ctrlIn: in std_logic;
--      ctrlOut: out std_logic;
--      data: in std_logic_vector(7 downto 0);
--      dataReady: out std_logic;
--      byte: out std_logic_vector(7 downto 0);
--      seqDone: out std_logic;
--      maxIndex: out BCD_ARRAY_TYPE(2 downto 0);
--      dataResults: out CHAR_ARRAY_TYPE(0 to 6) 
--    );
--  end component;
  
  component cmdProc is
    port (
      clk:		in std_logic;
      reset:		in std_logic;
      rxnow:		in std_logic;
      rxData:			in std_logic_vector (7 downto 0);
      txData:			out std_logic_vector (7 downto 0);
      rxdone:		out std_logic;
      ovErr:		in std_logic;
      framErr:	in std_logic;
      txnow:		out std_logic;
      txdone:		in std_logic
     -- start: out std_logic;
--      numWords_bcd: out BCD_ARRAY_TYPE(2 downto 0);
--      dataReady: in std_logic;
--      byte: in std_logic_vector(7 downto 0);
--      maxIndex: in BCD_ARRAY_TYPE(2 downto 0);
--      dataResults: in CHAR_ARRAY_TYPE(0 to 6);
--      seqDone: in std_logic
    );
  end component;
  
  signal clk: std_logic := '0';
  signal reset, sig_start, ctrl_genDriv, ctrl_consDriv: std_logic;
  signal sig_rxDone, sig_rxNow, sig_ovErr, sig_framErr, sig_txNow, sig_txDone, sig_seqDone, sig_dataReady: std_logic;
  signal sig_rx, sig_tx, sig_rx_debug: std_logic;
  signal sig_rxData, sig_txData, dataRead, sig_byte: std_logic_vector(7 downto 0);
  signal sig_maxIndex: BCD_ARRAY_TYPE(2 downto 0);
  signal sig_dataResults: CHAR_ARRAY_TYPE(0 to 6);
  signal sig_numWords_bcd: BCD_ARRAY_TYPE(2 downto 0);


begin
  clk <= NOT clk after 5 ns when now <2000 ms else clk;
  reset <= '0', '1' after 2 ns, '0' after 15 ns, '0' after 3600 ns, '0' after 3615 ns;

  ------------------------
  -- issue first read cmd
  ------------------------
  -- A: 1, 01000010, 1
  sig_rx <= '1', '0' after 1 us, '1' after 105 us, '0' after 209 us,  '0' after 313 us,  '0' after 417 us,  
  '0' after 521 us,  '0' after 625 us,  '1' after 729 us,  '0' after 833 us, '1' after 937 us, 
  -- 0: 0, 00001100, 1
  '0' after 1200 us, '0' after 1304 us, '0' after 1408 us, '0' after 1512 us,  '0' after 1616 us,  
  '1' after 1720 us, '1' after 1824 us,  '0' after 1928 us,  '0' after 2032 us,  '1' after 2136 us, 
  -- 0: 0, 00001100, 1
  '0' after 2500 us, '0' after 2604 us, '0' after 2708 us, '0' after 2812 us, '0' after 2916 us,
  '1' after 3020 us,  '1' after 3124 us,  '0' after 3228 us,  '0' after 3332 us,  '1' after 3436 us,  
  -- 2: 0, 01001100, 1
  '0' after 3800 us, '0' after 3904 us, '1' after 4008 us, '0' after 4112 us, '0' after 4216 us, 
  '1' after 4320 us, '1' after 4424 us, '0' after 4528 us, '0' after 4632 us, '1' after 4736 us,
  ------------------------
  -- issue second read cmd
  ------------------------
  -- A: 1, 01000010, 1
  '1' after 32000 us, '0' after 32001 us, '1' after 32105 us, '0' after 32209 us,  '0' after 32313 us,  '0' after 32417 us,  
  '0' after 32521 us,  '0' after 32625 us,  '1' after 32729 us,  '0' after 32833 us, '1' after 32937 us, 
  -- 0: 0, 00001100, 1
  '0' after 33200 us, '0' after 33304 us, '0' after 33408 us, '0' after 33512 us,  '0' after 33616 us,  
  '1' after 33720 us, '1' after 33824 us,  '0' after 33928 us,  '0' after 34032 us,  '1' after 34136 us, 
  -- 0: 0, 00001100, 1
  '0' after 34500 us, '0' after 34604 us, '0' after 34708 us, '0' after 34812 us, '0' after 34916 us,
  '1' after 35020 us,  '1' after 35124 us,  '0' after 35228 us,  '0' after 35332 us,  '1' after 35436 us,  
  -- 2: 0, 01001100, 1
  '0' after 35800 us, '0' after 35904 us, '1' after 36008 us, '0' after 36112 us, '0' after 36216 us, 
  '1' after 36320 us, '1' after 36424 us, '0' after 36528 us, '0' after 36632 us, '1' after 36736 us,
  ------------------------
  -- issue print results cmd
  ------------------------ 
  -- L: 0, 00110010, 1 
  '0' after 65001 us, '0' after 65105 us, '0' after 65209 us,  '1' after 65313 us,  '1' after 65417 us,  
  '0' after 65521 us,  '0' after 65625 us,  '1' after 65729 us,  '0' after 65833 us, '1' after 65937 us;
  
 --dataGen1: dataGen
--    port map (
--      clk => clk,
--      reset => reset,
--      ctrlIn => ctrl_consDriv,
--      ctrlOut => ctrl_genDriv,
--      data => dataRead
--    );
    
 -- dataConsume1: dataConsume
--    port map (
--      clk => clk,
--      reset => reset,
--      start => sig_start,
--      numWords_bcd => sig_numWords_bcd,
--      ctrlIn => ctrl_genDriv,
--      ctrlOut => ctrl_consDriv,
--      dataReady => sig_dataReady,
--      byte => sig_byte,
--      data => dataRead,
--      seqDone => sig_seqDone,
--      maxIndex => sig_maxIndex,
--      dataResults => sig_dataResults
 --   );
    
  cmdProc1: cmdProc
    port map (
      clk => clk,
      reset => reset,
      rxNow => sig_rxNow,
      rxData => sig_rxData,
      txData => sig_txData,
      rxDone => sig_rxDone,
      ovErr => sig_ovErr,
      framErr => sig_framErr,
      txNow => sig_txNow,
      txDone => sig_txDone
      --start => sig_start,
--      numWords_bcd => sig_numWords_bcd,
--      dataReady => sig_dataReady,
--      byte => sig_byte,
--      maxIndex => sig_maxIndex,
--      seqDone => sig_seqDone,
--      dataResults => sig_dataResults
    );
    	
  tx: UART_TX_CTRL
    port map (
      SEND => sig_txNow,
      DATA => sig_txData,
      CLK => clk,
      READY => sig_txDone,
      UART_TX => sig_tx
    );    	
  	
  rx : UART_RX_CTRL
   port map(
     RxD => sig_rx, -- input serial line
     sysclk => clk,
     reset => reset, 
     rxDone => sig_rxdone,
     rcvDataReg => sig_rxData,
     dataReady => sig_rxNow,
     setOE => sig_ovErr,
     setFE =>  sig_framerr
   );   	
  	
 end test;
