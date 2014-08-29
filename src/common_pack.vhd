library ieee;
use ieee.std_logic_1164.all;

package common_pack is
  
  
	
	type LOGICAL is (TRUE, FALSE);
		
	type CHAR_ARRAY_TYPE is array (integer range<>) of std_logic_vector(7 downto 0); -- unconstrained array
	  
	type BCD_ARRAY_TYPE is array (integer range<>) of std_logic_vector(3 downto 0); -- unconstrained array
		  
	constant SEQ_LENGTH : integer := 500;
	
	constant RESULT_BYTE_NUM:integer := 7;
  
 -- Two data sequences for you to test your code on.
 -- Keep one sequence commented out.
 -- Note that you can select a block of text, right-click and select "More" 
 -- to comment and uncomment the entire block at once.
  
  constant dataSequence : CHAR_ARRAY_TYPE(0 to SEQ_LENGTH-1) := (
      X"95", X"13", X"60", X"09", X"68", X"A8", X"93", X"F9", X"71", X"C7", 
      X"92", X"06", X"83", X"68", X"39", X"3B", X"70", X"EB", X"52", X"49", 
      X"5D", X"80", X"D0", X"3C", X"06", X"4D", X"4D", X"D3", X"23", X"D0", 
      X"DC", X"8E", X"05", X"82", X"B6", X"B2", X"E4", X"B3", X"F0", X"03", 
      X"D2", X"09", X"84", X"A7", X"C1", X"48", X"9A", X"E3", X"A5", X"C9", 
      X"7E", X"67", X"E0", X"B5", X"D3", X"03", X"19", X"8B", X"DB", X"44", 
      X"C6", X"A3", X"B9", X"E5", X"C4", X"35", X"0C", X"28", X"B8", X"21", 
      X"39", X"74", X"77", X"17", X"82", X"14", X"2B", X"BF", X"56", X"4E", 
      X"D1", X"FB", X"F8", X"94", X"3C", X"4B", X"AC", X"93", X"33", X"F5", 
      X"56", X"27", X"54", X"1D", X"C5", X"CB", X"96", X"15", X"32", X"C6", 
      X"5B", X"D6", X"23", X"B3", X"31", X"66", X"57", X"EC", X"D6", X"A1", 
      X"DD", X"38", X"11", X"AD", X"89", X"84", X"42", X"DA", X"D2", X"05", 
      X"7A", X"F1", X"75", X"D9", X"89", X"6F", X"07", X"81", X"E0", X"E8", 
      X"49", X"22", X"01", X"52", X"88", X"D4", X"AC", X"E9", X"C1", X"2B", 
      X"F6", X"59", X"99", X"BB", X"DF", X"56", X"77", X"2B", X"77", X"75", 
      X"21", X"A4", X"E5", X"6D", X"2D", X"4C", X"0F", X"10", X"07", X"8D", 
      X"90", X"4E", X"C1", X"AC", X"F0", X"7C", X"85", X"CA", X"92", X"C4", 
      X"EB", X"36", X"9C", X"77", X"9E", X"34", X"AD", X"05", X"3A", X"EA", 
      X"C4", X"88", X"12", X"33", X"04", X"F7", X"D5", X"72", X"FD", X"CB", 
      X"7D", X"22", X"37", X"D4", X"53", X"BD", X"29", X"BB", X"0E", X"B7", 
      X"20", X"FB", X"98", X"45", X"6F", X"EE", X"82", X"11", X"A9", X"73", 
      X"26", X"C6", X"88", X"17", X"E6", X"DE", X"0F", X"A4", X"E3", X"59", 
      X"AB", X"74", X"72", X"05", X"DC", X"F0", X"7B", X"92", X"FE", X"68", 
      X"39", X"DD", X"B0", X"2C", X"03", X"2C", X"35", X"E6", X"B5", X"22", 
      X"6D", X"A9", X"53", X"99", X"36", X"31", X"36", X"B6", X"41", X"45", 
      X"7B", X"39", X"5B", X"A3", X"C0", X"7E", X"9E", X"52", X"4E", X"25", 
      X"D8", X"4A", X"E8", X"1D", X"9D", X"49", X"82", X"8A", X"0E", X"70", 
      X"38", X"EB", X"B1", X"1E", X"5C", X"4F", X"4E", X"90", X"CC", X"78", 
      X"CA", X"6B", X"BD", X"5C", X"F3", X"C0", X"05", X"C1", X"E9", X"59", 
      X"13", X"DB", X"19", X"8D", X"EA", X"86", X"0E", X"71", X"B1", X"43", 
      X"E5", X"76", X"3C", X"32", X"D9", X"BE", X"A9", X"1C", X"D6", X"75", 
      X"A6", X"E7", X"1D", X"9A", X"05", X"18", X"E7", X"8C", X"A5", X"3D", 
      X"9F", X"15", X"A5", X"2D", X"9E", X"F8", X"AB", X"55", X"75", X"07", 
      X"86", X"FD", X"B9", X"66", X"97", X"93", X"82", X"26", X"4B", X"80", 
      X"25", X"68", X"98", X"CF", X"79", X"AC", X"C2", X"2F", X"9F", X"C5", 
      X"6C", X"70", X"7D", X"38", X"D5", X"80", X"1B", X"5D", X"D2", X"20", 
      X"A6", X"BC", X"B6", X"1B", X"F5", X"6D", X"8F", X"1A", X"7C", X"28", 
      X"4F", X"22", X"58", X"AA", X"84", X"CC", X"94", X"12", X"40", X"E8", 
      X"E3", X"FD", X"53", X"FC", X"9D", X"A7", X"9A", X"CC", X"9C", X"61", 
      X"2D", X"10", X"27", X"62", X"04", X"F7", X"52", X"F4", X"08", X"66", 
      X"47", X"5D", X"C8", X"72", X"0F", X"0D", X"88", X"C4", X"9D", X"EE", 
      X"C8", X"C1", X"54", X"86", X"A5", X"83", X"A9", X"3B", X"FB", X"16", 
      X"6A", X"FC", X"7C", X"9D", X"03", X"C4", X"BE", X"38", X"66", X"43", 
      X"15", X"39", X"7C", X"84", X"D6", X"6A", X"67", X"F3", X"56", X"23", 
      X"B2", X"EC", X"7D", X"81", X"02", X"31", X"C7", X"9C", X"CB", X"D6", 
      X"B0", X"15", X"CE", X"23", X"92", X"93", X"05", X"EF", X"9D", X"AB", 
      X"6C", X"B4", X"79", X"69", X"FD", X"7C", X"1E", X"DB", X"58", X"51", 
      X"61", X"DE", X"88", X"07", X"40", X"B9", X"6F", X"43", X"31", X"37", 
      X"7F", X"09", X"60", X"5B", X"47", X"44", X"BE", X"22", X"CD", X"4E", 
      X"58", X"A9", X"0A", X"C5", X"B0", X"ED", X"10", X"B0", X"BA", X"D8"
);

--  constant dataSequence : CHAR_ARRAY_TYPE(0 to SEQ_LENGTH-1) := (
--      X"9A", X"BB", X"AF", X"10", X"AD", X"4F", X"59", X"BA", X"1C", X"41", 
--      X"70", X"96", X"4F", X"70", X"50", X"EA", X"A8", X"2E", X"A5", X"09", 
--      X"C8", X"01", X"63", X"AC", X"0B", X"6F", X"2D", X"95", X"31", X"62", 
--      X"E1", X"01", X"AE", X"49", X"D2", X"4B", X"64", X"F3", X"D5", X"E4", 
--      X"EE", X"21", X"59", X"B6", X"A0", X"D5", X"39", X"52", X"38", X"08", 
--      X"AE", X"49", X"08", X"49", X"1D", X"13", X"95", X"03", X"D8", X"11", 
--      X"7C", X"2A", X"6C", X"DD", X"A8", X"F6", X"65", X"6A", X"C7", X"E7", 
--      X"AB", X"2C", X"52", X"46", X"3B", X"B4", X"4F", X"F9", X"DC", X"9F", 
--      X"E1", X"4F", X"A0", X"A2", X"4D", X"95", X"1C", X"CC", X"E0", X"A6", 
--      X"0F", X"F0", X"0F", X"40", X"60", X"6A", X"2B", X"F1", X"21", X"C1", 
--      X"A4", X"4F", X"1E", X"F4", X"D3", X"27", X"65", X"77", X"BD", X"E0", 
--      X"F9", X"B9", X"9F", X"D7", X"61", X"E6", X"CA", X"E8", X"6C", X"12", 
--      X"E8", X"9D", X"C0", X"95", X"FE", X"2B", X"B5", X"2B", X"15", X"A2", 
--      X"8D", X"C5", X"0E", X"0C", X"95", X"C3", X"30", X"89", X"93", X"9B", 
--      X"0B", X"45", X"2E", X"87", X"BC", X"EA", X"08", X"D3", X"D9", X"78", 
--      X"5F", X"14", X"2C", X"AC", X"97", X"AB", X"73", X"CA", X"75", X"E5", 
--      X"13", X"A3", X"CF", X"52", X"89", X"DD", X"89", X"CB", X"96", X"E1", 
--      X"72", X"18", X"EE", X"6B", X"87", X"B1", X"0E", X"57", X"CB", X"02", 
--      X"0E", X"46", X"5C", X"C8", X"31", X"68", X"B1", X"D4", X"8C", X"E9", 
--      X"EA", X"9E", X"E9", X"E4", X"59", X"FF", X"E4", X"5D", X"C8", X"54", 
--      X"28", X"BD", X"A2", X"99", X"3E", X"48", X"CC", X"96", X"4D", X"4C", 
--      X"3A", X"81", X"91", X"12", X"2A", X"83", X"8B", X"83", X"20", X"28", 
--      X"69", X"B1", X"C8", X"A3", X"95", X"F9", X"88", X"4A", X"33", X"37", 
--      X"70", X"91", X"EA", X"51", X"48", X"9E", X"39", X"2C", X"05", X"84", 
--      X"01", X"8E", X"8E", X"13", X"66", X"C5", X"92", X"67", X"86", X"65", 
--      X"12", X"C7", X"C3", X"91", X"9D", X"97", X"9E", X"3E", X"CA", X"B4", 
--      X"BD", X"24", X"02", X"BD", X"CF", X"91", X"0F", X"53", X"EF", X"DA", 
--      X"B0", X"2B", X"AE", X"15", X"90", X"76", X"AA", X"6F", X"08", X"71", 
--      X"78", X"03", X"98", X"4D", X"D3", X"EA", X"45", X"4C", X"18", X"BA", 
--      X"B7", X"9F", X"60", X"A1", X"84", X"A6", X"DF", X"55", X"8F", X"08", 
--      X"39", X"C9", X"4B", X"0F", X"B3", X"A3", X"A6", X"E2", X"2A", X"AB", 
--      X"62", X"B1", X"4E", X"A6", X"5C", X"E9", X"64", X"AD", X"C0", X"33", 
--      X"AD", X"CA", X"BA", X"2D", X"1B", X"D1", X"FA", X"C0", X"E8", X"9C", 
--      X"76", X"0C", X"99", X"C8", X"D1", X"39", X"BB", X"AD", X"F8", X"69", 
--      X"0E", X"51", X"51", X"7E", X"0F", X"19", X"3D", X"C8", X"DE", X"A0", 
--      X"55", X"46", X"09", X"DE", X"40", X"FC", X"21", X"88", X"61", X"C8", 
--      X"EA", X"5D", X"E9", X"1F", X"09", X"E7", X"EE", X"97", X"0F", X"E1", 
--      X"D9", X"92", X"76", X"12", X"62", X"BD", X"86", X"7F", X"D4", X"05", 
--      X"44", X"25", X"09", X"4A", X"E4", X"2A", X"FD", X"22", X"78", X"5F", 
--      X"A8", X"DF", X"4C", X"46", X"15", X"30", X"C2", X"E8", X"A5", X"84", 
--      X"B3", X"0C", X"E4", X"AC", X"2B", X"81", X"88", X"A0", X"F6", X"92", 
--      X"94", X"F0", X"10", X"A9", X"1A", X"9C", X"CE", X"09", X"86", X"4C", 
--      X"A9", X"99", X"10", X"E4", X"F4", X"2F", X"13", X"FC", X"6E", X"C2", 
--      X"EC", X"DF", X"F6", X"4C", X"B6", X"E6", X"DF", X"D4", X"09", X"E8", 
--      X"A1", X"93", X"BD", X"82", X"DD", X"24", X"A8", X"98", X"83", X"3F", 
--      X"F9", X"EA", X"A7", X"1D", X"84", X"7B", X"12", X"64", X"CE", X"C9", 
--      X"1F", X"6A", X"CC", X"41", X"96", X"0A", X"AE", X"D3", X"B3", X"5A", 
--      X"7D", X"49", X"44", X"C4", X"96", X"8A", X"FD", X"C5", X"96", X"CA", 
--      X"8C", X"14", X"79", X"D9", X"67", X"3D", X"8B", X"5F", X"C2", X"C5", 
--      X"59", X"F7", X"5B", X"32", X"18", X"50", X"F5", X"A3", X"36", X"55"
--  );
  
end common_pack;

