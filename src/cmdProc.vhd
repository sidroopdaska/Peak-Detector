
USE WORK.all;
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;
use work.common_pack.all;


entity cmdProc is
port ( 

      clk:		in std_logic;
      reset:		in std_logic;
      rxnow:		in std_logic;
      rxData:			in std_logic_vector (7 downto 0);
      txData:			out std_logic_vector (7 downto 0);
      rxdone:		out std_logic;
      --ovErr:		in std_logic;
     -- framErr:	in std_logic;
      txnow:		out std_logic;
      txdone:		in std_logic;
     numWords_bcd: out BCD_ARRAY_TYPE(2 downto 0)
    );
  
end;
-----------------------------------------------------
architecture dataflow of cmdProc is
     
  -- State declaration
  type state_type is (S0, S1, S2, S3, S4, S5, S6);  -- List all your states here
  signal CURRENT_STATE, NEXT_STATE: state_type;
  
begin
  -----------------------------------------------------
  combi_nestState: process(CURRENT_STATE, rxData)
  begin
    	-- assign defaults at the beginning to avoid having to assign in every branch
		--txNow <= '0';
		--rxDone <= '0';
    ---txData <= "00110000";
    case CURRENT_STATE is
      
     -- when INIT =>
--			  if rxNow = '1' then ------ Rx signals that data is ready
--				  NEXT_STATE <= S0;
--				else 
--				  NEXT_STATE <= INIT;
--				end if;  
				
      when S0 =>
       --	txNow <= '1';   ------
--				rxDone <= '1';   -----
--				
				
        if (rxData="01000001") or (rxData="01100001") then   
          NEXT_STATE <= S1;
        elsif rxData="01001100" or rxdata="01101100"  then         
          NEXT_STATE <= S5;
        elsif rxData="01010000"  or rxData="01110000"     then     
          NEXT_STATE <= S6;
        else
          NEXT_STATE <= S0;
        end if;
        
      when S1 =>
        if rxData="00110000" or rxData="00111001" or rxData="00110001" or rxData="00110010" or rxData="00110011" or rxData="00110100" or rxData="00110101" or rxData="00110110" or rxData="00110111" or rxData="00111000" then
          numWords_bcd(2)<=rxData(3 downto 0);
          NEXT_STATE <= S2;
        elsif (rxData="01000001" or rxData="01100001") then 
         
          NEXT_STATE <= S1;
        else
          NEXT_STATE <= S0;
        end if;
        
      when S2 =>
        if rxData="00110000" or rxData="00111001" or rxData="00110001" or rxData="00110010" or rxData="00110011" or rxData="00110100" or rxData="00110101" or rxData="00110110" or rxData="00110111" or rxData="00111000" then
          numWords_bcd(1)<=rxData(3 downto 0);
          NEXT_STATE <= S3;
        elsif (rxData="01000001" or rxData="01100001") then
          NEXT_STATE <= S1;
         else
          NEXT_STATE <= S0;
        end if;
         
      when S3 =>
          if rxData="00110000" or rxData="00111001" or rxData="00110001" or rxData="00110010" or rxData="00110011" or rxData="00110100" or rxData="00110101" or rxData="00110110" or rxData="00110111" or rxData="00111000" then
           numWords_bcd(0)<=rxData(3 downto 0);
           NEXT_STATE <= S4;
          elsif (rxData="01000001" or rxData="01100001") then 
            NEXT_STATE <= S1;
          else 
            NEXT_STATE <= S0;
          end if;
          
     when S4=>
          txData<="00110001";

           NEXT_STATE <= S0;
         -- NEXT_STATE <= TRANSMIT_DATA;
     when S5 =>
          txData<="00110010";
         NEXT_STATE <= S0;
         -- NEXT_STATE <= TRANSMIT_DATA;
     when S6 => 
          txData<="00110011";  
          NEXT_STATE <= S0;
         -- NEXT_STATE <= TRANSMIT_DATA;
    --      
-- 		 when TRANSMIT_DATA =>
--			  if txDone = '1' then -- wait for Tx to signal that transmission is complete
--					 NEXT_STATE <= INIT;
--				else
--					 NEXT_STATE <= TRANSMIT_DATA;
--      		end if;
      		
    end case;
  end process; -- combi_nextState
  
  
  -----------------------------------------------------
  seq: process (clk, reset)
  begin
    if reset = '0' then
      CURRENT_STATE <= S0;
    elsif clk'event AND clk='1' then
      CURRENT_STATE <= NEXT_STATE;
    end if;
  end process; -- seq
--  txNow<='1';
 --txData<= rxData;
  -----------------------------------------------------
end dataflow;





