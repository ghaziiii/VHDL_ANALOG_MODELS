---------------------------------------------------------------------------------------------------
-- file name         : PWM_Generator.vhd
-- module name         : PWM_Generator
-- description         : this module implements a PWM signal generator
-- syNthesisable     : yes
---------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PWM_Generator is
    generic (
        PWM_BITS        : integer := 8                                  -- PWM resolution (default: 8-bit → 256 levels)
    );
    port (
        CLK_I           : in  std_logic;                                -- System clock
        RST_I           : in  std_logic;                                -- Active-high RST_I
        DUTY_I          : in  std_logic_vector(PWM_BITS-1 downto 0);    -- DUTY_I cycle input (0 to 2^PWM_BITS - 1)
        PWM_O           : out std_logic_vector(PWM_BITS-1 downto 0)     -- PWM output signal
    );
end PWM_Generator;

architecture BEHAVIORAL of PWM_Generator is
    --------------------------------------------------------------------
    -- signals
    --------------------------------------------------------------------
    signal S_PWM_CNT : unsigned(PWM_BITS-1 downto 0);           -- internal counter signal


begin
    -------------------------------------------
    -- P_MAIN_PWM : main PWM signal generation signal
    -------------------------------------------
    P_MAIN_PWM: process(CLK_I, RST_I)
    begin
        if RST_I = '1' then
            S_PWM_CNT       <= (others => '0');     -- initialize internal counter
            PWM_O           <= (others =>'0');      -- initialize output signal
        elsif rising_edge(CLK_I) then
            -- Increment counter (auto-rollover)
            S_PWM_CNT   <= S_PWM_CNT + 1;
            
            -- Generate PWM output
            if S_PWM_CNT < unsigned(DUTY_I) then
                PWM_O   <= (others =>'1');          -- set output to high
            else
                PWM_O   <= (others =>'0');          -- set output to low
            end if;
        end if;
    end process P_MAIN_PWM;


end BEHAVIORAL;