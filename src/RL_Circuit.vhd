library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.MATH_REAL.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RL_Circuit is
    generic (
        R : real := 100.0;      -- Resistance in ohms
        L : real := 0.1;         -- Inductance in henries
        time_step : real := 1.0e-6  -- Simulation time step in seconds
    );
    port (
        clk : in std_logic;      -- Clock for discrete-time simulation
        reset : in std_logic;    -- Active-high reset
        voltage_in : in real;    -- Input voltage (real)
        current_out : out real   -- Output current (real)
    );
end RL_Circuit;

architecture Behavioral of RL_Circuit is
    -- Internal signal for current
    signal current : real := 0.0;
    
    -- Constants for numerical integration
    constant alpha : real := L / time_step;
    constant beta : real := R + alpha;
begin
    process(clk, reset)
        variable v_prev : real := 0.0;
    begin
        if reset = '1' then
            -- Reset the current to zero
            current <= 0.0;
            v_prev := 0.0;
        elsif rising_edge(clk) then
            -- Numerical solution to the RL circuit differential equation
            -- Using backward Euler method for stability
            current <= (alpha * current + voltage_in) / beta;
            
            -- Store previous voltage for trapezoidal method (alternative)
            -- Could use this for more accurate integration if needed
            v_prev := voltage_in;
        end if;
    end process;
    
    -- Output the current
    current_out <= current;
end Behavioral;