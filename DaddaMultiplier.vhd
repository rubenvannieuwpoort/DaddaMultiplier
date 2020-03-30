library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.tools.all;

entity DaddaMultiplier is
	generic(n : integer);
	port(
		a : in std_logic_vector(n - 1 downto 0);
		b : in std_logic_vector(n - 1 downto 0);
		is_signed : in std_logic;
		result : out std_logic_vector(2 * n - 1 downto 0)
	);
end DaddaMultiplier;

architecture Dadda_arch of DaddaMultiplier is
	constant stages : natural := stages(n);

	-- holds the values of the dots in the dot diagram
	type DotDiagram is array (2 * n - 1 downto 0, 0 to n - 1) of std_logic;
	type Wiring is array (0 to stages) of DotDiagram;
	signal dot : Wiring;

	-- intermediate signals for adder input
	signal row1, row2 : std_logic_vector(2 * n - 1 downto 1);
	
	-- intermediate signals for adder output
	signal adder_output : std_logic_vector(2 * n - 1 downto 1);
	signal adder_carry : std_logic;
begin

	-- process for the partial product generation and CSA tree
	main_process: process (a, b, dot, is_signed)
		type Count is array(2 * n - 1 downto 0) of natural;
		variable addCount, dotCount : Count;
		variable target, halfadders, fulladders : natural;
	begin
		-- intialize dot count to zero
		for i in 0 to 2 * n - 1 loop
			dotCount(i) := 0;
		end loop;
		
		-- form partial products
		for i in 0 to n - 1 loop
			for j in 0 to n - 1 loop
				if (i = n - 1 xor j = n - 1) then
					dot(0)(i + j, dotCount(i + j)) <= (a(i) and b(j)) xor is_signed;
				else
					dot(0)(i + j, dotCount(i + j)) <= a(i) and b(j);
				end if;
				dotCount(i + j) := dotCount(i + j) + 1;
			end loop;
		end loop;
		
		-- add correction bits
		dot(0)(n, dotCount(n)) <= is_signed;
		dotCount(n) := dotCount(n) + 1;
		dot(0)(2 * n - 1, dotCount(2 * n - 1)) <= is_signed;
		dotCount(2 * n - 1) := dotCount(2 * n - 1) + 1;
		
		target := n;
		for i in 0 to stages - 1 loop
			-- update target for next reduction
			target := (target * 2 + 2) / 3;
		
			-- initialize add count to zero
			for j in 0 to 2 * n - 1 loop
				addCount(j) := 0;
			end loop;
		
			for j in 0 to 2 * n - 1 loop
				-- calculate number of full adders and half adders
				-- based on the no. of dots and the no. of dots to be added
				fulladders := num_fa(dotCount(j), addCount(j), target);
				halfadders := num_ha(dotCount(j), addCount(j), target);
				
				-- update dot count
				dotCount(j) := dotCount(j) - 3 * fulladders - 2 * halfadders;
				
				-- update the number of dots that will be added in the next stage
				-- (this is not added to dot(...) directly because we can't use these
				-- in adders so it is convenient to distinguish between the two
				addCount(j) := addCount(j) + fulladders + halfadders;
				if (j < 2 * n - 1) then
					addCount(j + 1) := addCount(j + 1) + fulladders + halfadders;
				end if;
				
				-- pass through leftover dots
				for k in 0 to dotCount(j) - 1 loop
					dot(i + 1)(j, k) <= dot(i)(j, 3 * fulladders + 2 * halfadders + k);
				end loop;				
		
				-- connect half adders
				for k in 0 to halfadders - 1 loop
					dot(i + 1)(j, dotCount(j) + k) <= dot(i)(j, 3 * fulladders + 2 * k) xor dot(i)(j, 3 * fulladders + 2 * k + 1);
					dot(i + 1)(j + 1, dots_left(dotCount(j + 1), addCount(j + 1), target)
					                  + num_ha(dotCount(j + 1), addCount(j + 1), target)
					                  + num_fa(dotCount(j + 1), addCount(j + 1), target) + k) <= dot(i)(j, 3 * fulladders + 2 * k) and dot(i)(j, 3 * fulladders + 2 * k + 1);
				end loop;
				
				-- connect full adders
				for k in 0 to fulladders - 1 loop
					dot(i + 1)(j, dotCount(j) + halfadders + k) <= dot(i)(j, 3 * k) xor dot(i)(j, 3 * k + 1) xor dot(i)(j, 3 * k + 2);
					dot(i + 1)(j + 1, dots_left(dotCount(j + 1), addCount(j + 1), target)
					                   + num_ha(dotCount(j + 1), addCount(j + 1), target)
					                   + num_fa(dotCount(j + 1), addCount(j + 1), target) + halfadders + k) <= (dot(i)(j, 3 * k) and dot(i)(j, 3 * k + 1)) or (dot(i)(j, 3 * k) and dot(i)(j, 3 * k + 2)) or (dot(i)(j, 3 * k + 1) and dot(i)(j, 3 * k + 2));
				end loop;
			end loop;
			
			-- update dot count
			for j in 0 to 2 * n - 1 loop
				dotCount(j) := dotCount(j) + addCount(j);
			end loop;
			
		end loop;
	end process;
	
	-- update intermediate row variable
	-- (this is easier than mapping to dot diagram to the adder directly)
	rows_update: process (dot)
	begin
		row1(2 * n - 1) <= dot(stages)(2 * n - 1, 0);
		row2(2 * n - 1) <= '0';
		for i in 2 * n - 2 downto 1 loop
			row1(i) <= dot(stages)(i, 0);
			row2(i) <= dot(stages)(i, 1);
		end loop;
	end process rows_update;
	
	adder_output <= row1 + row2;
	
	result(0) <= dot(stages)(0, 0);
	result(2 * n - 1 downto 1) <= adder_output(2 * n - 1 downto 1);

end Dadda_arch;