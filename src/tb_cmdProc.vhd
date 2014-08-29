library ieee;
use ieee.std_logic_1164.all;
use work.common_pack.all;

ENTITY tb_cmdProc IS END;

ARCHITECTURE test OF tb_cmdProc IS
  
 component cmdProc is
    port (
      clk:		in std_logic;
      reset:		in std_logic;
      rxnow:		in std_logic;
      rxData:			in std_logic_vector (7 downto 0);
      txData:			out std_logic_vector (7 downto 0);
      rxdone:		out std_logic;
      --ovErr:		in std_logic;
      --framErr:	in std_logic;
      txnow:		out std_logic;
      txdone:		in std_logic
    );
  end component;
  
  
  signal clk: std_logic := '0';
  signal reset: std_logic;
  signal sig_rxDone, sig_rxNow, sig_ovErr, sig_framErr, sig_txNow, sig_txDone: std_logic;
  signal sig_rxData, sig_txData: std_logic_vector(7 downto 0);
  signal sig_rx :std_logic;

CONSTANT Clk_period: time := 100 ns;
  --CONSTANT no_of_cycles: integer := 4; -- no of cycles for result to be valid
BEGIN
  --generate Clk
  Clk <= NOT Clk AFTER 50 ns WHEN NOW < 3 us ELSE Clk; 
  sig_rxData <= 
       "01000001" AFTER 100 ns,
       "00111001" AFTER 200 ns,
       "00110000" AFTER 300 ns,
       "00111001" AFTER 400 ns,
       "00110011" AFTER 500 ns,
       "01001100" AFTER 600 ns,
       "00110101" AFTER 700 ns,
       "01010000" AFTER 800 ns;
       
   reset <= '0' AFTER 10 ns,
            '1' AFTER 20 ns;
  
  cmdProc1: cmdProc
    port map (
      clk => clk,
      reset => reset,
      rxNow => sig_rxNow,
      rxData => sig_rxData,
      txData => sig_txData,
      rxDone => sig_rxDone,
      --ovErr => sig_ovErr,
      --framErr => sig_framErr,
      txNow => sig_txNow,
      txDone => sig_txDone
  
    );
 	
 end test;


