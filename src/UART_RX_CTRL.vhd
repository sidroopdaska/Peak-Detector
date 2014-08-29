----------------------------------------------------------------------------
--	UART_RX_CTRL.vhd -- UART Data Transfer Receiver
----------------------------------------------------------------------------
-- Author:  Dinesh Pamunuwa
----------------------------------------------------------------------------
--
----------------------------------------------------------------------------
--	This component may be used to read data over a UART device. It will
-- read data over a serial line according  to the RS232 protocol with a 
-- start and stop bit with no parity, and make the data byte available 
-- over an 8 bit wide bus when ready. The serial data should have the 
-- following characteristics:
--         *9600 Baud Rate
-- 		  *1 start bit, 0
--         *8 data bits, LSB first
--         *1 stop bit, 1
--         *no parity
--         				
-- Port Descriptions:
--
--     	 RxD - Serial input data line.
--  	 sysclk - system clk: A 100 MHz clock is expected.
--	  	  reset - Synchronous reset.
--  	 rxDone - Used to signal to the receiver that data on the bus has been
--        	    successfully read, and the register can cleared. Should be 
--				 	 set high by the upper layer logic for 1 clock cycle. This 
--           	 signal is read by the Rx to reset the data ready signal
--					 and also to check for overrun errors.
-- rcvDataReg - The received data is made available on this 8 bit wide bus. 
--					 Data for current word is valid when dataReady is high.
--  dataReady - Goes high when all of the bits in a serial transmission of 
--					 a word have been detected. It goes low when rxDone is set 
--					 high by the upper layer logic, to be ready to receive the 
--					 next word and signal completion.
--	     setOE - Goes high when an overrun error ius detected; i.e. a new 
-- 				 word is received, but upper layer logic has not signalled
-- 				 that previous byte has been read.
-- 	  setFE - The start and stop bits are not detected in order according
-- 				 to the RS232 proticol; i.e. a framing error has occured.
--   
-- 
--								Operation
-- 						 --------------
-- The baud rate is 9600, and hence a new bit is to be detected on the serial
-- line every 10416 cycles for a 100 MHz clock. The receiver samples in the 
-- middle of a baud cycle. The way it's implemented here is that a baud cycle
-- is divided into 8 segments. After the detection of the first bit (a '1' 
-- to '0' transition) the Rx waits 4 "segments" of a baud cycle, to sample in
-- the middle of the baud cycle. If the value is still 0, it proceeds to sample
-- the next 9 bits (8 data bits and 1 stop bit) by waiting 8 "segments" of a 
-- baud cycle to sample in the middle of the baud cycle for each bit.
-- The Rx can be made more robust if the line is noisy by sampling in each
-- "segment" and taking for example the majority of the detected values in 
-- each "segment", or the majority in the middle three "segments" or any 
-- suitable algorithm. This is the principle of oversampling, but for this
-- implementation, only 1 sample is taken for each baud cycle.
-- 
----------------------------------------------------------------------------
--
----------------------------------------------------------------------------
-- Version:			1.0
-- Revision History:
--  08/01/2013 (Dinesh): Created using Xilinx Tools 14.2 for 64 bit Win
----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity UART_RX_CTRL is
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
end UART_RX_CTRL; 


architecture RCVR of UART_RX_CTRL is

	-- constant to generate 8x oversampling clock
	-- baudClk_max =(round(100MHz / 9600)) - 1 = 10416
	-- baudClk_x8_max =10416/8=1302
	constant BAUDX8_TMR_MAX: integer := 1302; 
	
	type state_type is (IDLE, START_DETECTED, WAIT_4, WAIT_8, RECV_DATA, DATA_READY);
	type logical_type is (TRUE, FALSE);

	signal currentState, nextState: state_type;
	signal rcvShiftReg: std_logic_vector (9 downto 0); -- receive shift register to receive all bits, including stop and start
	signal baudClkX8Count : integer range 0 to 8; -- indicates when to read the RxD input
	signal bitCount : integer range 0 to 10; -- counts number of bits read
	signal bitTmr : integer range 0 to BAUDX8_TMR_MAX; -- counts system clock cycles to assert baudClkX8Count
	signal enable_baudClkX8Count : logical_type; -- no need to count when serial input is quiet
	signal enable_bitCount, reset_baudClkX8Count, shiftDataIn : logical_type;
	signal regFull : std_logic;

  	
begin
  
  receiver_nextState: process(currentState, baudClkX8Count, bitCount, RxD, regFull, rxDone, rcvShiftReg) 
  begin
	 -- assign defaults at the beginning to avoid assigning in every branch
    setFE <= '0'; setOE <= '1'; 
	 enable_baudClkX8Count <= TRUE;
    case currentState is
      when IDLE => 
        enable_baudClkX8Count <= FALSE; -- disable counting to save power when serial line is quiet
        reset_baudClkX8Count <= TRUE;
        if RxD = '0' then -- start bit is a '0'
          nextState <= START_DETECTED;
        else  
          nextState <= IDLE;
        end if;
      when START_DETECTED =>
        reset_baudClkX8Count <= FALSE;
        nextState <= WAIT_4;
      when WAIT_4 => -- wait for 4 baud "segments" to sample in the middle of the first bit
        reset_baudClkX8Count <= FALSE;
        if baudClkX8Count = 4 then -- in the middle of the bit cycle
          if (RxD = '0') then -- no glitch
            nextState <= RECV_DATA;
          else  
            nextState <= IDLE;
          end if;
        else
				  nextState <= WAIT_4;  
        end if;  
      when WAIT_8 => -- wait for 8 baud "segments" to sample in the middle of the 2nd through 10th bits
        reset_baudClkX8Count <= FALSE;
        if baudClkX8Count = 8 then -- in the middle of the bit cycle
          nextState <= RECV_DATA;
        else
          nextState <= WAIT_8;
        end if;
      when RECV_DATA =>
        reset_baudClkX8Count <= TRUE;
        if bitCount = 9 then -- all 10 bits have been read (1 start + 8 data + 1 stop)
          nextState <= DATA_READY;
        else -- some more bits to be read yet
          nextState <= WAIT_8;
        end if;
      when DATA_READY => -- all 10 bits have been read, and data is valid
        reset_baudClkX8Count <= TRUE;
        nextState <= IDLE;
        --  frame error if stop bit not 1 or start bit not 0
        if rcvShiftReg(9) /= '1' or rcvShiftReg(0) /= '0' then
          setFE <= '1';
        end if;
        --  overrun error if previous data has not been read yet
        if  rxDone /= '1' then
          setOE <= '1';
        end if;
      when OTHERS => -- should never be reached
        nextState <= IDLE;
      end case;
  end process; 
            
  stateRegister:	process (sysclk)
  begin
		if rising_edge (sysclk) then
			if (reset = '1') then
				currentState <= IDLE;
			else
				currentState <= nextState;
			end if;	
		end if;
	end process;

  -- divide a baud (bit) cycle into 8 segments
  bit_timing_process : process (sysclk)
  begin
   if rising_edge(sysclk) then
		if reset ='1' then
			bitTmr <= 0;
			baudClkX8Count <= 0;
		else
			if enable_baudClkX8Count = TRUE then -- detecting serial data
				if bitTmr = BAUDX8_TMR_MAX then -- completed 1 baud "segment"
					bitTmr <= 0;
					baudClkX8Count <= baudClkX8Count + 1;        
				else -- not completed a baud "segment"
					bitTmr <= bitTmr + 1;
				end if;
				if reset_baudClkX8Count = TRUE or baudClkX8Count = 9 then -- reset both 
					bitTmr <= 0;
					baudClkX8Count <= 0;
				end if;
			end if; 	
		end if;
	end if;	
  end process;
  
  -- count number of bits that have been sampled
  bit_counting_process : process (sysclk)
  begin
	if rising_edge(sysclk) then
		if reset ='1' then
			bitCount <= 0;
		else	
			if currentState = RECV_DATA then
				bitCount <= bitCount + 1;
			elsif currentState = IDLE then
				bitCount <= 0;
			end if;
		end if;
	end if;	
  end process;
   
  -- shift data in serially when ready to be sampled
  dataShift:	process (sysclk)
  begin
   if rising_edge(sysclk) then
		if reset ='1' then
			rcvShiftReg <= (others => '1');
		else
			if currentState = RECV_DATA then
				rcvShiftReg <= RxD & rcvShiftReg(9 downto 1); 
			end if;
		end if;  
	end if;	
  end process;

  -- latch the data when valid
  -- A separate set of registers ensures no changes in output
  -- bus until all the bits are valid
  dataLatch:	process (sysclk)
  begin
    if rising_edge(sysclk) then
		if reset ='1' then
			rcvDataReg <= (others => '1');
			regFull <= '0';
		else
			if currentState = DATA_READY then -- update output lines, signal data is valid
				rcvDataReg <= rcvShiftReg(8 downto 1); 
				regFull <= '1';
			elsif rxDone = '1' then  -- ok to clear register
				regFull <= '0';
			end if;	
      end if;
    end if;  
  end process;
 
  dataReady <= regFull;
   
end RCVR;

