library ieee;
use ieee.std_logic_1164.all;

package tools is
	function clog2(n : natural) return natural;
	function flog2(n : natural) return natural;
	function max(a, b : integer) return integer;
	function min(a, b : integer) return integer;
	function stages(height : natural) return natural;
	function num_fa(dots, add, target : natural) return natural;
	function num_ha(dots, add, target : natural) return natural;
	function dots_left(dots, add, target : natural) return natural;
end;

package body tools is
	
	function clog2 (n : natural) return natural is
		variable counter : natural;
		variable m : natural;
	begin
		m := n - 1;
		counter := 1;
		while (m > 1) loop
			m := m / 2;
			counter := counter + 1;
		end loop;
		return counter;
	end function;
	
	function flog2 (n : natural) return natural is
		variable counter : natural;
		variable m : natural;
	begin
		m := n;
		counter := 0;
		while (m > 1) loop
			m := m / 2;
			counter := counter + 1;
		end loop;
		return counter;
	end function;

	function max (a, b : integer) return integer is
	begin
		if (a > b) then
			return a;
		else
			return b;
		end if;
	end function;
	
	function min (a, b : integer) return integer is
	begin
		if (a < b) then
			return a;
		else
			return b;
		end if;
	end function;
	
	function num_fa(dots, add, target : natural) return natural is
	begin
		return min(dots / 3, max((dots + add - target) / 2, 0));
	end function;
	
	function num_ha(dots, add, target : natural) return natural is
		variable dots_left, target_left : natural;
	begin
		dots_left := dots - 2 * num_fa(dots, add, target);
		target_left := target - num_fa(dots, add, target);
		return min(dots_left / 2, max(dots_left + add - target, 0));
	end function;

	function stages(height : natural) return natural is
		variable h, count : natural;
	begin
		h := height;
		count := 0;
		while (h > 2) loop
			h := (h * 2 + 2) / 3;
			count := count + 1;
		end loop;
		return count;
	end function;
		
	function dots_left(dots, add, target : natural) return natural is
	begin
		return dots - 3 * num_fa(dots, add, target) - 2 * num_ha(dots, add, target);
	end function;

end package body;