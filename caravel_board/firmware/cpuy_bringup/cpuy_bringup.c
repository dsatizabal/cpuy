#include <defs.h>
//#include <stub.h>


// --------------------------------------------------------
// Firmware routine for bringing up the CPUy
// --------------------------------------------------------

void configure_io()
{

//  ======= Useful GPIO mode values =============

//      GPIO_MODE_MGMT_STD_INPUT_NOPULL
//      GPIO_MODE_MGMT_STD_INPUT_PULLDOWN
//      GPIO_MODE_MGMT_STD_INPUT_PULLUP
//      GPIO_MODE_MGMT_STD_OUTPUT
//      GPIO_MODE_MGMT_STD_BIDIRECTIONAL
//      GPIO_MODE_MGMT_STD_ANALOG

//      GPIO_MODE_USER_STD_INPUT_NOPULL
//      GPIO_MODE_USER_STD_INPUT_PULLDOWN
//      GPIO_MODE_USER_STD_INPUT_PULLUP
//      GPIO_MODE_USER_STD_OUTPUT
//      GPIO_MODE_USER_STD_BIDIRECTIONAL
//      GPIO_MODE_USER_STD_ANALOG


//  ======= set each IO to the desired configuration =============

    // RESET
    reg_mprj_io_0 = GPIO_MODE_USER_STD_INPUT_PULLDOWN;

    // EXTERNAL INTERRUPT
    // IMPORTANT NOTE: 
    // Changing configuration for IO[1-4] will interfere with programming flash. if you change them,
    // You may need to hold reset while powering up the board and initiating flash to keep the process
    // configuring these IO from their default values.
    reg_mprj_io_1 = GPIO_MODE_USER_STD_INPUT_PULLDOWN;
    
    // DATA
    reg_mprj_io_2 = GPIO_MODE_USER_STD_OUTPUT_PULLDOWN;
    reg_mprj_io_3 = GPIO_MODE_USER_STD_OUTPUT_PULLDOWN;
    reg_mprj_io_4 = GPIO_MODE_USER_STD_OUTPUT_PULLDOWN;
    reg_mprj_io_5 = GPIO_MODE_USER_STD_OUTPUT_PULLDOWN;
    reg_mprj_io_6 = GPIO_MODE_USER_STD_OUTPUT_PULLDOWN;
    reg_mprj_io_7 = GPIO_MODE_USER_STD_OUTPUT_PULLDOWN;
    reg_mprj_io_8 = GPIO_MODE_USER_STD_OUTPUT_PULLDOWN;
    reg_mprj_io_9 = GPIO_MODE_USER_STD_OUTPUT_PULLDOWN;

    // PORT 0
    reg_mprj_io_10 = GPIO_MODE_USER_STD_OUTPUT_PULLDOWN;
    reg_mprj_io_11 = GPIO_MODE_USER_STD_OUTPUT_PULLDOWN;
    reg_mprj_io_12 = GPIO_MODE_USER_STD_OUTPUT_PULLDOWN;
    reg_mprj_io_13 = GPIO_MODE_USER_STD_OUTPUT_PULLDOWN;
    reg_mprj_io_14 = GPIO_MODE_USER_STD_OUTPUT_PULLDOWN;
    reg_mprj_io_15 = GPIO_MODE_USER_STD_OUTPUT_PULLDOWN;
    reg_mprj_io_16 = GPIO_MODE_USER_STD_OUTPUT_PULLDOWN;
    reg_mprj_io_17 = GPIO_MODE_USER_STD_OUTPUT_PULLDOWN;

    // PORT 1
    reg_mprj_io_18 = GPIO_MODE_USER_STD_OUTPUT_PULLDOWN;
    reg_mprj_io_19 = GPIO_MODE_USER_STD_OUTPUT_PULLDOWN;
    reg_mprj_io_20 = GPIO_MODE_USER_STD_OUTPUT_PULLDOWN;
    reg_mprj_io_21 = GPIO_MODE_USER_STD_OUTPUT_PULLDOWN;

    // ADDRESS
    reg_mprj_io_22 = GPIO_MODE_USER_STD_OUTPUT_PULLDOWN;
    reg_mprj_io_23 = GPIO_MODE_USER_STD_OUTPUT_PULLDOWN;
    reg_mprj_io_24 = GPIO_MODE_USER_STD_OUTPUT_PULLDOWN;
    reg_mprj_io_25 = GPIO_MODE_USER_STD_OUTPUT_PULLDOWN;
    reg_mprj_io_26 = GPIO_MODE_USER_STD_OUTPUT_PULLDOWN;
    reg_mprj_io_27 = GPIO_MODE_USER_STD_OUTPUT_PULLDOWN;
    reg_mprj_io_28 = GPIO_MODE_USER_STD_OUTPUT_PULLDOWN;
    reg_mprj_io_29 = GPIO_MODE_USER_STD_OUTPUT_PULLDOWN;
    reg_mprj_io_30 = GPIO_MODE_USER_STD_OUTPUT_PULLDOWN;
    reg_mprj_io_31 = GPIO_MODE_USER_STD_OUTPUT_PULLDOWN;

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

    reg_gpio_mode1 = 1;
    reg_gpio_mode0 = 0;
    reg_gpio_ien = 1;
    reg_gpio_oeb = 0;


    // Configure All LA probes as inputs to the cpu
	reg_la0_oenb = reg_la0_iena = 0x00000000;    // [31:0]
	reg_la1_oenb = reg_la1_iena = 0x00000000;    // [63:32]
	reg_la2_oenb = reg_la2_iena = 0x00000000;    // [95:64]
	reg_la3_oenb = reg_la3_iena = 0x00000000;    // [127:96]

    // ANTON

    // We'll start with mux design 13, then 14, for a simple test of selectable outputs.

    // I'm basing this code on my earlier instructions here:
    // https://docs.google.com/spreadsheets/d/1kkF1woJQolN3wrGOXv8A0mNClVp3Keje3pYb4Swyta0/edit#gid=1173864902&range=44:44

    // Let's start by selecting design 13, which should:
    // - Make GPIO[31:16] present 0x55AA
    // - Make all other GPIOs inputs

    // Configure 2nd LA bank for 'input'
    // (i.e. output from SoC, input to the user project area):
    reg_la1_oenb = reg_la1_iena = 0xffffffff;
    // la_data_in[63:32] are now writable.

    // Prepare the values that WILL be written into the
    // mux registers after 2 mux_conf_clk rising edges:
    uint32_t la1;
    reg_la1_data = la1 =
     0b01111111101001110000000000000000;
    // 0-------------------------------     mux_conf_clk: Start with mux configuration clock low
    // -11111111-----------------------     i_design_reset[7:0]: All asserted
    // ---------0----------------------     i_mux_auto_reset_enb: 0=auto-reset non-selected designs
    // ----------1---------------------     i_mux_sys_reset_enb: 1=do not use wb_rst_i as a reset
    // -----------0011-----------------     i_mux_sel[3:0]=1101: We'll select design 13
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

    // Let's set GPIO[37:8] to BIDIRECTIONAL mode, since our OEBs should
    // be driven by the mux:

    configure_io();

    // Apply the above configuration:
    reg_mprj_xfer = 1;
    while (reg_mprj_xfer == 1);

    // Hopefully now we should see 0x55AA presenting on GPIO[31:16].

}

