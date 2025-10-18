#include <defs.h>

void delay(const int d)
{
    // Configure timer for a single-shot countdown:
    reg_timer0_config = 0;
    reg_timer0_data = d;
    reg_timer0_config = 1;
    // Loop, waiting for value to reach zero:
    reg_timer0_update = 1;  // latch current value
    while (reg_timer0_value > 0) {
        reg_timer0_update = 1;
    }
}

void main()
{
    // Configure Caravel's own "gpio" pin as an output:
    reg_gpio_mode1 = 1;
    reg_gpio_mode0 = 0;
    reg_gpio_ien = 1;
    reg_gpio_oeb = 0;

    while (1) {
        reg_gpio_out = 1;   // LED D3 OFF
        delay(2000000);
        reg_gpio_out = 0;   // LED D3 ON
        delay(2000000);
    }
}