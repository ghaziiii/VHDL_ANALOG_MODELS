library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PWM_Generator is
    Generic (
        PWM_BITS : integer := 8  -- PWM resolution (default: 8-bit → 256 levels)
    );
    Port (
        clk     : in  std_logic;                      			-- System clock
        reset   : in  std_logic;                      			-- Active-high reset
        duty    : in  std_logic_vector(PWM_BITS-1 downto 0);  	-- Duty cycle input (0 to 2^PWM_BITS - 1)
        pwm_out : out std_logic_vector(PWM_BITS-1 downto 0)   	-- PWM output signal
    );
end PWM_Generator;

architecture Behavioral of PWM_Generator is
    signal pwm_counter : unsigned(PWM_BITS-1 downto 0) := (others => '0');
begin
    process(clk, reset)
    begin
        if reset = '1' then
            pwm_counter <= (others => '0');
            pwm_out <= (others =>'0');
        elsif rising_edge(clk) then
            -- Increment counter (auto-rollover)
            pwm_counter <= pwm_counter + 1;
            
            -- Generate PWM output
            if pwm_counter < unsigned(duty) then
                pwm_out <= (others =>'1');
            else
                pwm_out <= (others =>'0');
            end if;
        end if;
    end process;
end Behavioral;