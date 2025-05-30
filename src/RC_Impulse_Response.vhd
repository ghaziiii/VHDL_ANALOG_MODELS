library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

entity RC_Impulse_Response is
    Generic (
        CLK_FREQ        : real := 100.0e6;    -- Clock frequency in Hz
        RESISTANCE      : real := 1000.0;     -- Resistance in ohms
        CAPACITANCE     : real := 1.0e-6;     -- Capacitance in farads
        OUTPUT_BITS     : integer := 16;      -- Output resolution bits
        TIME_SCALE      : real := 1.0e6       -- Time scaling factor (1μs)
    );
    Port (
        clk             : in  std_logic;
        reset           : in  std_logic;
        trigger         : in  std_logic;      -- Triggers the impulse
        analog_out      : out std_logic_vector(OUTPUT_BITS-1 downto 0);
        response_done   : out std_logic       -- Indicates response completion
    );
end RC_Impulse_Response;

architecture Behavioral of RC_Impulse_Response is
    constant TIME_CONSTANT : real := RESISTANCE * CAPACITANCE;
    constant TIME_STEP     : real := 1.0/CLK_FREQ;
    constant MAX_OUTPUT    : real := 2.0**OUTPUT_BITS - 1.0;
    
    type state_type is (IDLE, RESPONDING);
    signal state : state_type := IDLE;
    
    signal elapsed_time    : real := 0.0;
    signal voltage_out     : real := 0.0;
    signal trigger_prev    : std_logic := '0';
    
begin
    process(clk, reset)
        variable impulse_time : real := 0.0;
    begin
        if reset = '1' then
            state <= IDLE;
            elapsed_time <= 0.0;
            voltage_out <= 0.0;
            response_done <= '1';
            trigger_prev <= '0';
        elsif rising_edge(clk) then
            trigger_prev <= trigger;
            
            case state is
                when IDLE =>
                    response_done <= '1';
                    if trigger_prev = '0' and trigger = '1' then
                        -- Rising edge detected on trigger
                        state <= RESPONDING;
                        elapsed_time <= 0.0;
                        impulse_time := 0.0;
                        response_done <= '0';
                    end if;
                
                when RESPONDING =>
                    elapsed_time <= elapsed_time + TIME_STEP;
                    impulse_time := impulse_time + TIME_STEP;
                    
                    -- Model impulse as very short pulse (1 clock cycle)
                    if impulse_time < TIME_STEP then
                        voltage_out <= 1.0;  -- Unit impulse
                    else
                        -- Exponential decay: V(t) = V0 * e^(-t/RC)
                        voltage_out <= exp(-elapsed_time/TIME_CONSTANT);
                    end if;
                    
                    -- Check if response has decayed sufficiently
                    if elapsed_time > 5.0 * TIME_CONSTANT then
                        state <= IDLE;
                        response_done <= '1';
                    end if;
            end case;
        end if;
    end process;
    
    -- Convert real voltage to digital output
    analog_out <= std_logic_vector(to_unsigned(
        integer(voltage_out * MAX_OUTPUT), 
        OUTPUT_BITS
    ));
    
end Behavioral;