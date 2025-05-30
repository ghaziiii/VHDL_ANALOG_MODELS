library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

entity RC_Circuit_TB is
end RC_Circuit_TB;

architecture Behavioral of RC_Circuit_TB is
    -- Constants
    constant CLK_PERIOD     : time := 10 ns;   -- 100 MHz clock
    constant ADC_BITS       : integer := 12;
    constant PWM_BITS       : integer := 12;
    constant R_VALUE        : real := 1000.0;  -- 1kΩ
    constant C_VALUE        : real := 1.0e-6;  -- 1μF
    
    -- Clock and reset signals
    signal clk              : std_logic := '0';
    signal reset            : std_logic := '1';
    
    -- PWM signals
    signal pwm_duty         : std_logic_vector(PWM_BITS-1 downto 0) := (others => '0');
    signal pwm_out          : std_logic_vector(PWM_BITS-1 downto 0);
    
    -- RC Circuit signals
    signal pwm_filtered     : std_logic_vector(ADC_BITS-1 downto 0);
    
    -- Test control
    signal test_done        : boolean := false;
    
    -- PWM Generator Component
    component PWM_Generator is
        Generic (
            PWM_BITS : integer := 8
        );
        Port (
            clk     : in  std_logic;
            reset   : in  std_logic;
            duty    : in  std_logic_vector(PWM_BITS-1 downto 0);
            pwm_out : out std_logic_vector(PWM_BITS-1 downto 0)
        );
    end component;
    
    -- RC Circuit Component (from previous code)
    component RC_Circuit is
        Generic (
            CLK_FREQ    : real;
            R_VALUE     : real;
            C_VALUE     : real;
            ADC_BITS    : integer
        );
        Port (
            clk         : in  std_logic;
            reset       : in  std_logic;
            analog_in   : in  std_logic_vector(ADC_BITS-1 downto 0);
            analog_out  : out std_logic_vector(ADC_BITS-1 downto 0)
        );
    end component;
    
begin
    -- Clock generation
    clk <= not clk after CLK_PERIOD/2 when not test_done else '0';
    
    -- Instantiate PWM Generator
    PWM_GEN: PWM_Generator
        generic map (
            PWM_BITS => PWM_BITS
        )
        port map (
            clk     => clk,
            reset   => reset,
            duty    => pwm_duty,
            pwm_out => pwm_out
        );
    
    -- Instantiate RC Circuit
    RC_FILTER: RC_Circuit
        generic map (
            CLK_FREQ => 100.0e6,
            R_VALUE  => R_VALUE,
            C_VALUE  => C_VALUE,
            ADC_BITS => ADC_BITS
        )
        port map (
            clk        => clk,
            reset      => reset,
            analog_in  => pwm_out, -- Scale PWM duty to ADC width
            analog_out => pwm_filtered
        );
    
    -- Stimulus process
    stimulus: process
    begin
        -- Initial reset
        reset <= '1';
        wait for 100 ns;
        reset <= '0';
        wait for 100 ns;
        
        -- Test different duty cycles
        report "Testing 0% duty cycle";
        pwm_duty <= (others => '0');
        wait for 500 us;
        
        report "Testing 25% duty cycle";
        pwm_duty <= std_logic_vector(to_unsigned(64, PWM_BITS));  -- 25% of 256
        wait for 500 us;
        
        report "Testing 50% duty cycle";
        pwm_duty <= std_logic_vector(to_unsigned(128, PWM_BITS)); -- 50% of 256
        wait for 500 us;
        
        report "Testing 75% duty cycle";
        pwm_duty <= std_logic_vector(to_unsigned(192, PWM_BITS)); -- 75% of 256
        wait for 500 us;
        
        report "Testing 100% duty cycle";
        pwm_duty <= (others => '1');
        wait for 500 us;
        
        -- End simulation
        test_done <= true;
        wait;
    end process;

    
end Behavioral;