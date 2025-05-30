library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RC_Impulse_Response_TB is
end RC_Impulse_Response_TB;

architecture Behavioral of RC_Impulse_Response_TB is
    constant CLK_PERIOD : time := 10 ns;  -- 100 MHz
    constant R_VALUE   : real := 1000.0;  -- 1kΩ
    constant C_VALUE   : real := 1.0e-6;  -- 1μF
    
    signal clk, reset, trigger, response_done : std_logic := '0';
    signal analog_out : std_logic_vector(15 downto 0);
    
begin
    -- Unit Under Test
    UUT: entity work.RC_Impulse_Response
        generic map (
            CLK_FREQ => 100.0e6,
            RESISTANCE => R_VALUE,
            CAPACITANCE => C_VALUE,
            OUTPUT_BITS => 16,
            TIME_SCALE => 1.0e6
        )
        port map (
            clk => clk,
            reset => reset,
            trigger => trigger,
            analog_out => analog_out,
            response_done => response_done
        );
    
    -- Clock generation
    clk <= not clk after CLK_PERIOD/2;
    
    -- Stimulus process
    stimulus: process
    begin
        -- Initial reset
        reset <= '1';
        wait for 100 ns;
        reset <= '0';
        wait for 100 ns;
        
        -- Apply impulse
        trigger <= '1';
        wait for CLK_PERIOD;
        trigger <= '0';
        
        -- Wait for response to complete
        wait until response_done = '1';
        
        -- Apply second impulse after delay
        wait for 2 ms;
        trigger <= '1';
        wait for CLK_PERIOD;
        trigger <= '0';
        
        -- End simulation
        wait for 10 ms;
        std.env.stop;
    end process;
    
end Behavioral;