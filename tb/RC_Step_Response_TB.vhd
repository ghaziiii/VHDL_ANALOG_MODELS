library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RC_Step_Response_TB is
end RC_Step_Response_TB;

architecture Behavioral of RC_Step_Response_TB is
    constant CLK_PERIOD : time := 10 ns;  -- 100 MHz
    constant R_VALUE   : real := 1000.0;  -- 1kΩ
    constant C_VALUE   : real := 1.0e-6;  -- 1μF
    
    signal clk         : std_logic := '0';
    signal reset       : std_logic := '1';
    signal vin        : std_logic_vector(11 downto 0) := (others => '0');
    signal vout       : std_logic_vector(11 downto 0);
    
    -- Test voltage levels (12-bit representation)
    constant VOLTAGE_LOW  : integer := 0;
    constant VOLTAGE_HIGH : integer := 4095;  -- 12-bit max
    constant VOLTAGE_MID  : integer := 2048;
    
begin
    -- Unit Under Test
    UUT: entity work.RC_Step_Response
        generic map (
            CLK_FREQ => 100.0e6,
            R => R_VALUE,
            C => C_VALUE,
            ADC_BITS => 12,
            DAC_BITS => 12
        )
        port map (
            clk => clk,
            reset => reset,
            vin => vin,
            vout => vout
        );
    
    -- Clock generation
    clk <= not clk after CLK_PERIOD/2;

    -- Stimulus process
    reset_stimulus: process
    begin
        -- Initial reset
        reset <= '1';
        wait for 100 ns;
        reset <= '0';
        wait;
    end process reset_stimulus;

    -- Stimulus process
    stimulus: process
    begin

        -- Test 1: Low to High step
        vin <= std_logic_vector(to_unsigned(VOLTAGE_LOW, 12));
        wait for 10 ms;
        vin <= std_logic_vector(to_unsigned(VOLTAGE_HIGH, 12));
        wait for 10 ms;  -- Wait for ~5τ

    end process;
    
end Behavioral;