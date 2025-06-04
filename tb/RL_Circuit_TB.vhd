library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.MATH_REAL.ALL;

entity RL_Circuit_TB is
end RL_Circuit_TB;

architecture Behavioral of RL_Circuit_TB is
    component RL_Circuit
        generic (
            R : real;
            L : real;
            time_step : real
        );
        port (
            clk : in std_logic;
            reset : in std_logic;
            voltage_in : in real;
            current_out : out real
        );
    end component;
    
    -- Testbench signals
    signal clk : std_logic := '0';
    signal reset : std_logic := '1';
    signal voltage_in : real := 0.0;
    signal current_out : real;
    
    -- Clock period definitions
    constant clk_period : time := 1 us;  -- Matches 1.0e-6 second time_step
    
    -- Circuit parameters
    constant R_test : real := 100.0;     -- 100 ohms
    constant L_test : real := 0.1;       -- 0.1 H
    constant time_step_test : real := 1.0e-6; -- 1 us time step
    
begin
    -- Instantiate the Unit Under Test (UUT)
    uut: RL_Circuit
        generic map (
            R => R_test,
            L => L_test,
            time_step => time_step_test
        )
        port map (
            clk => clk,
            reset => reset,
            voltage_in => voltage_in,
            current_out => current_out
        );
    
    -- Clock process definitions
    clk_process : process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;
    
    -- Stimulus process
    stim_proc: process
    begin
        -- Hold reset state for a few clock cycles
        reset <= '1';
        wait for 5*clk_period;
        
        -- Release reset and apply step input
        reset <= '0';
        voltage_in <= 5.0;  -- 5V step input
        
        -- Run simulation long enough to see the transient response
        wait for 10 ms;
        
        -- Change input to see dynamic response
        voltage_in <= 2.5;
        wait for 5 ms;
        
        voltage_in <= 0.0;
        wait;
    end process;
end Behavioral;