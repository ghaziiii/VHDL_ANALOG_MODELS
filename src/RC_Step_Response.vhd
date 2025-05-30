---------------------------------------------------------------------------------------------------
-- Expected Behavior:
-- When the input voltage changes, the output will follow with exponential characteristics
-- 
-- The response time depends on the RC time constant (τ = RC)
-- 
-- Output will always lag behind input changes
-- 
-- The model properly handles both charging and discharging phases
---------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

entity RC_Step_Response is
    Generic (
        CLK_FREQ        : real    := 100.0e6;    -- 100 MHz clock
        R               : real    := 1000.0;     -- 1kΩ resistance
        C               : real    := 1.0e-6;     -- 1μF capacitance
        ADC_BITS       : integer := 12;         -- 12-bit ADC input
        DAC_BITS       : integer := 12          -- 12-bit DAC output
    );
    Port (
        clk             : in  std_logic;
        reset           : in  std_logic;
        vin             : in  std_logic_vector(ADC_BITS-1 downto 0);  -- Input voltage
        vout            : out std_logic_vector(DAC_BITS-1 downto 0)   -- Output voltage
    );
end RC_Step_Response;

architecture Behavioral of RC_Step_Response is
    constant TAU         : real := R * C;       -- Time constant (τ = RC)
    constant TIME_STEP   : real := 1.0/CLK_FREQ;
    constant MAX_IN      : real := 2.0**ADC_BITS - 1.0;
    constant MAX_OUT     : real := 2.0**DAC_BITS - 1.0;
    
    signal vin_real      : real := 0.0;
    signal vout_real     : real := 0.0;
    signal prev_vin      : real := 0.0;
    
begin
    -- Convert digital input to real voltage
    vin_real <= real(to_integer(unsigned(vin))) / MAX_IN;
    
    process(clk, reset)
        variable alpha : real;
    begin
        if reset = '1' then
            vout_real <= 0.0;
            prev_vin <= 0.0;
        elsif rising_edge(clk) then
            -- Calculate the filter coefficient
            alpha := TIME_STEP / (TAU + TIME_STEP);
            
            -- RC circuit response: Vout = Vout_prev + α*(Vin - Vout_prev)
            vout_real <= vout_real + alpha * (vin_real - vout_real);
            
            prev_vin <= vin_real;
        end if;
    end process;
    
    -- Convert real output voltage back to digital
    vout <= std_logic_vector(to_unsigned(integer(vout_real * MAX_OUT), DAC_BITS));
    
end Behavioral;