library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

entity RC_Circuit is
    Generic (
        CLK_FREQ    : real := 100.0e6;    -- Clock frequency in Hz (default 100 MHz)
        R_VALUE     : real := 1000.0;     -- Resistance in ohms (default 1kΩ)
        C_VALUE     : real := 1.0e-6;     -- Capacitance in farads (default 1μF)
        ADC_BITS    : integer := 12       -- ADC resolution bits
    );
    Port (
        clk         : in  std_logic;
        reset       : in  std_logic;
        analog_in  : in  std_logic_vector(ADC_BITS-1 downto 0);
        analog_out  : out std_logic_vector(ADC_BITS-1 downto 0)
    );
end RC_Circuit;

architecture Behavioral of RC_Circuit is
    -- Time step based on clock frequency
    constant TIME_STEP : real := 1.0/CLK_FREQ;
    
    -- RC time constant (τ = R*C)
    constant TAU : real := R_VALUE * C_VALUE;
    
    -- Digital representation parameters
    constant MAX_ANALOG_VAL : real := (2.0**ADC_BITS - 1.0);
    
    -- Internal signals
    signal vin_real : real := 0.0;
    signal vout_real : real := 0.0;
    
begin
    -- Convert digital input to real voltage (assuming 0-VREF range)
    vin_real <= real(to_integer(unsigned(analog_in))) / MAX_ANALOG_VAL;
    
    -- RC circuit emulation process
    rc_process: process(clk, reset)
        variable alpha : real;
    begin
        if reset = '1' then
            vout_real <= 0.0;
        elsif rising_edge(clk) then
            -- Calculate the filter coefficient
            alpha := TIME_STEP / (TAU + TIME_STEP);
            
            -- Emulate RC low-pass behavior: Vout = Vout_prev + α*(Vin - Vout_prev)
            vout_real <= vout_real + alpha * (vin_real - vout_real);
        end if;
    end process;
    
    -- Convert real output voltage back to digital
    analog_out <= std_logic_vector(to_unsigned(integer(vout_real * MAX_ANALOG_VAL), ADC_BITS));
    
end Behavioral;