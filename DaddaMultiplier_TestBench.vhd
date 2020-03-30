library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity testbench is
end testbench;

architecture behavior of testbench is
	component DaddaMultiplier
		generic(n : integer := 8);
		port(
			a : in std_logic_vector(n - 1 downto 0);
			b : in std_logic_vector(n - 1 downto 0);
			is_signed : in std_logic;
			result : out std_logic_vector(2 * n - 1 downto 0)
		);
	end component;

	signal op1 : std_logic_vector(7 downto 0) := "11111111";
	signal op2 : std_logic_vector(7 downto 0) := "11111111";
	signal result : std_logic_vector(15 downto 0);
	
begin
	uut: DaddaMultiplier port map(a => op1, b => op2, is_signed => '1', result => result );

	tb : process
	begin
		op1 <= "01111101";
		op2 <= "11110111";
		wait for 100 ns;
		op1 <= "11111111";
		op2 <= "11111111";
		wait;
	end process;
end;
