#include <defs.h>
#include <stub.h>


// --------------------------------------------------------
// Firmware routine for bringing up the CPUy
// ---------------------------------------------------------

void configure_io()
{
    // RESET
    reg_mprj_io_0 = GPIO_MODE_USER_STD_INPUT_PULLDOWN;

    // EXTERNAL INTERRUPT
    // IMPORTANT NOTE: 
    // Changing configuration for IO[1-4] will interfere with programming flash. if you change them,
    // You may need to hold reset while powering up the board and initiating flash to keep the process
    // configuring these IO from their default values.
    reg_mprj_io_1 = GPIO_MODE_USER_STD_INPUT_PULLDOWN;
    
    // DATA
    reg_mprj_io_2 = GPIO_MODE_USER_STD_INPUT_PULLUP;
    reg_mprj_io_3 = GPIO_MODE_USER_STD_INPUT_PULLUP;
    reg_mprj_io_4 = GPIO_MODE_USER_STD_INPUT_PULLUP;
    reg_mprj_io_5 = GPIO_MODE_USER_STD_INPUT_PULLUP;
    reg_mprj_io_6 = GPIO_MODE_USER_STD_INPUT_PULLUP;
    reg_mprj_io_7 = GPIO_MODE_USER_STD_INPUT_PULLUP;
    reg_mprj_io_8 = GPIO_MODE_USER_STD_INPUT_PULLUP;    
    reg_mprj_io_9 = GPIO_MODE_USER_STD_INPUT_PULLUP;

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

void pulse_gpio()
{
    reg_gpio_out = 1;
    reg_gpio_out = 0;
}

void main()
{
    
    // Signal via the SoC's single 'gpio' pin that we're starting our main code execution...
    // Start with gpio=0:
    reg_gpio_out = 0;
    // Enable gpio OUTPUT:
    reg_gpio_mode1 = 1;
    reg_gpio_mode0 = 0;
    reg_gpio_ien = 1;
    reg_gpio_oe = 1;

    pulse_gpio();

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

    // Design 3 should now be selected, but note that All GPIOs start in
    // INPUT mode by default (per user_defines), so we won't see the
    // intended output until the GPIO modes are reconfigured...

    configure_io();

    // Pulse gpio again to show we're now finished:
    pulse_gpio();

    // No need for anything else as design 3 (cpuy) is free running and the
    // SoC knows to halt at the exit of main().
}

