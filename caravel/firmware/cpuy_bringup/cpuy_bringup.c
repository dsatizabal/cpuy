#include <defs.h>
#include <stub.h>


// --------------------------------------------------------
// Firmware routine for bringing up the CPUy
// ---------------------------------------------------------

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

void configure_gpio()
{
    // RESET
    reg_mprj_io_0 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;

    // EXTERNAL INTERRUPT
    reg_mprj_io_1 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
    
    // DATA
    reg_mprj_io_2 = GPIO_MODE_USER_STD_INPUT_PULLDOWN;
    reg_mprj_io_3 = GPIO_MODE_USER_STD_INPUT_PULLDOWN;
    reg_mprj_io_4 = GPIO_MODE_USER_STD_INPUT_PULLDOWN;
    reg_mprj_io_5 = GPIO_MODE_USER_STD_INPUT_PULLDOWN;
    reg_mprj_io_6 = GPIO_MODE_USER_STD_INPUT_PULLDOWN;
    reg_mprj_io_7 = GPIO_MODE_USER_STD_INPUT_PULLDOWN;
    reg_mprj_io_8 = GPIO_MODE_USER_STD_INPUT_PULLDOWN;    
    reg_mprj_io_9 = GPIO_MODE_USER_STD_INPUT_PULLDOWN;

    // PORT 0
    reg_mprj_io_10 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_11 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_12 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_13 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_14 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_15 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_16 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_17 = GPIO_MODE_USER_STD_OUTPUT;

    // PORT 1
    reg_mprj_io_18 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_19 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_20 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_21 = GPIO_MODE_USER_STD_OUTPUT;

    // ADDRESS
    reg_mprj_io_22 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_23 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_24 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_25 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_26 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_27 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_28 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_29 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_30 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_31 = GPIO_MODE_USER_STD_OUTPUT;

    // These are not used in this project
    reg_mprj_io_32 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_33 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_34 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_35 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_36 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_37 = GPIO_MODE_MGMT_STD_OUTPUT;

    // Initiate the serial transfer to configure IO
    reg_mprj_xfer = 1;
    while (reg_mprj_xfer == 1);
}

void main()
{
    
    // Configure Caravel's own "gpio" pin as an output:
    reg_gpio_mode1 = 1;
    reg_gpio_mode0 = 0;
    reg_gpio_ien = 1;
    reg_gpio_oeb = 1;

    // Pulse gpio to show we're starting execution:
    reg_gpio_out = 1;   // LED D3 OFF
    delay(2000000);
    reg_gpio_out = 0;   // LED D3 ON
    delay(2000000);
    reg_gpio_out = 1;   // LED D3 OFF
    delay(2000000);
    reg_gpio_out = 0;   // LED D3 ON
    delay(2000000);
    reg_gpio_out = 1;   // LED D3 OFF
    delay(2000000);
    reg_gpio_out = 0;   // LED D3 ON
    delay(2000000);
    reg_gpio_out = 1;   // LED D3 OFF
    delay(2000000);
    reg_gpio_out = 0;   // LED D3 ON
    delay(2000000);
    reg_gpio_out = 1;   // LED D3 OFF

    configure_gpio();

    // Prepare the values that WILL be written into the
    // mux registers after 2 mux_conf_clk rising edges:
    uint32_t la1;
    reg_la1_data = la1 =
     0b01111111101001110000000000000000;
    // 0-------------------------------     mux_conf_clk: Start with mux configuration clock low
    // -11111111-----------------------     i_design_reset[7:0]: All asserted
    // ---------0----------------------     i_mux_auto_reset_enb: 0=auto-reset non-selected designs
    // ----------1---------------------     i_mux_sys_reset_enb: 1=do not use wb_rst_i as a reset
    // -----------0011-----------------     i_mux_sel[3:0]=0011: We'll select design 3 (cpuy)
    // ---------------1----------------     i_mux_io5_reset_enb: 1=Do not use io[5] as a reset
    // ----------------XXXXXXXXXXXXXXXX     Unused.

    // Pulse mux_conf_clk once...
    reg_la1_data = (la1 |= 0x80000000);
    reg_la1_data = (la1 ^= 0x80000000);
    // ...and again:
    reg_la1_data = (la1 |= 0x80000000);
    reg_la1_data = (la1 ^= 0x80000000);

    // Design 3 should now be selected

    // enviar un reset al CPUy
    // reg_mprj_datal = 1;
    // reg_mprj_datal = 0;

    // desactivar el housekeeping
    reg_hkspi_disable = 1;

    // Pulse gpio again to show we're now finished:
    reg_gpio_out = 1;   // LED D3 OFF
    delay(2000000);
    reg_gpio_out = 0;   // LED D3 ON
    delay(2000000);
    reg_gpio_out = 1;   // LED D3 OFF
    delay(2000000);
    reg_gpio_out = 0;   // LED D3 ON
    delay(2000000);
    reg_gpio_out = 1;   // LED D3 OFF
    delay(2000000);
    reg_gpio_out = 0;   // LED D3 ON
    delay(2000000);
    reg_gpio_out = 1;   // LED D3 OFF
    delay(2000000);
    reg_gpio_out = 0;   // LED D3 ON
    delay(2000000);
    reg_gpio_out = 1;   // LED D3 OFF
}

