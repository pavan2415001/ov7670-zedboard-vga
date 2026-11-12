// ============================================================================
// Module: clocking.v - MMCME2_ADV Clock Generator (100 MHz → 50 MHz, 25 MHz)
// ============================================================================
module clocking (
    input  wire CLK_100,
    output wire CLK_50,
    output wire CLK_25
);

    wire clkin1;
    wire clkfbout;
    wire clkfbout_buf;
    wire clkout0;
    wire clkout1;

    // Input clock buffer
    IBUFG clkin1_buf (
        .I (CLK_100),
        .O (clkin1)
    );

    // MMCME2_ADV primitive
    MMCME2_ADV #(
        .BANDWIDTH            ("OPTIMIZED"),
        .CLKOUT4_CASCADE      ("FALSE"),
        .COMPENSATION         ("ZHOLD"),
        .STARTUP_WAIT         ("FALSE"),
        .DIVCLK_DIVIDE        (1),
        .CLKFBOUT_MULT_F      (10.000),
        .CLKFBOUT_PHASE       (0.000),
        .CLKFBOUT_USE_FINE_PS ("FALSE"),
        .CLKOUT0_DIVIDE_F     (20.000),
        .CLKOUT0_PHASE        (0.000),
        .CLKOUT0_DUTY_CYCLE   (0.500),
        .CLKOUT0_USE_FINE_PS  ("FALSE"),
        .CLKOUT1_DIVIDE       (40),
        .CLKOUT1_PHASE        (0.000),
        .CLKOUT1_DUTY_CYCLE   (0.500),
        .CLKOUT1_USE_FINE_PS  ("FALSE"),
        .CLKIN1_PERIOD        (10.000),
        .REF_JITTER1          (0.010)
    ) mmcm_adv_inst (
        .CLKFBOUT     (clkfbout),
        .CLKFBOUTB    (),
        .CLKOUT0      (clkout0),
        .CLKOUT0B     (),
        .CLKOUT1      (clkout1),
        .CLKOUT1B     (),
        .CLKOUT2      (),
        .CLKOUT2B     (),
        .CLKOUT3      (),
        .CLKOUT3B     (),
        .CLKOUT4      (),
        .CLKOUT5      (),
        .CLKOUT6      (),
        .CLKFBIN      (clkfbout_buf),
        .CLKIN1       (clkin1),
        .CLKIN2       (1'b0),
        .CLKINSEL     (1'b1),
        .DADDR        (7'd0),
        .DCLK         (1'b0),
        .DEN          (1'b0),
        .DI           (16'd0),
        .DO           (),
        .DRDY         (),
        .DWE          (1'b0),
        .PSCLK        (1'b0),
        .PSEN         (1'b0),
        .PSINCDEC     (1'b0),
        .PSDONE       (),
        .LOCKED       (),
        .CLKINSTOPPED (),
        .CLKFBSTOPPED (),
        .PWRDWN       (1'b0),
        .RST          (1'b0)
    );

    // Output clock buffers
    BUFG clkf_buf (
        .I (clkfbout),
        .O (clkfbout_buf)
    );

    BUFG clkout1_buf (
        .I (clkout0),
        .O (CLK_50)
    );

    BUFG clkout2_buf (
        .I (clkout1),
        .O (CLK_25)
    );

endmodule
