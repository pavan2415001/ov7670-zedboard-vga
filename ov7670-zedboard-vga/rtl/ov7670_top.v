// ============================================================================
// Module: ov7670_top.v - Restored High-Quality Color Camera Top Level
// ============================================================================
module ov7670_top (
    input  wire        clk100,
    output wire        OV7670_SIOC,
    inout  wire        OV7670_SIOD,
    output wire        OV7670_RESET,
    output wire        OV7670_PWDN,
    input  wire        OV7670_VSYNC,
    input  wire        OV7670_HREF,
    input  wire        OV7670_PCLK,
    output wire        OV7670_XCLK,
    input  wire [7:0]  OV7670_D,

    output wire [7:0]  LED,

    output wire [3:0]  vga_red,
    output wire [3:0]  vga_green,
    output wire [3:0]  vga_blue,
    output wire        vga_hsync,
    output wire        vga_vsync,

    input  wire        btn
);

    // -----------------------------------------------------------------------
    // Internal wires
    // -----------------------------------------------------------------------
    wire [18:0] frame_addr;
    wire [11:0] frame_pixel;
    wire [18:0] capture_addr;
    wire [11:0] capture_data;
    wire        capture_we;       // single-bit write-enable
    wire        resend;
    wire        config_finished;
    wire        clk50;
    wire        clk25;
    wire        buffered_pclk;
    wire [0:0]  capture_we_vec;   // [0:0] for blk_mem wea port

    assign capture_we_vec = capture_we;

    // -----------------------------------------------------------------------
    // PCLK buffer
    // -----------------------------------------------------------------------
    BUFG pclk_buf (
        .I (OV7670_PCLK),
        .O (buffered_pclk)
    );

    // -----------------------------------------------------------------------
    // Button debounce
    // -----------------------------------------------------------------------
    debounce btn_debounce (
        .clk (clk50),
        .i   (btn),
        .o   (resend)
    );

    // -----------------------------------------------------------------------
    // VGA controller
    // -----------------------------------------------------------------------
    vga Inst_vga (
        .clk25       (clk25),
        .vga_red     (vga_red),
        .vga_green   (vga_green),
        .vga_blue    (vga_blue),
        .vga_hsync   (vga_hsync),
        .vga_vsync   (vga_vsync),
        .frame_addr  (frame_addr),
        .frame_pixel (frame_pixel)
    );

    // -----------------------------------------------------------------------
    // Frame buffer (Block RAM)
    // -----------------------------------------------------------------------
    blk_mem_gen_0 fb (
        .clka  (buffered_pclk),
        .wea   (capture_we_vec),
        .addra (capture_addr),
        .dina  (capture_data),
        .clkb  (clk50),
        .addrb (frame_addr),
        .doutb (frame_pixel)
    );

    // -----------------------------------------------------------------------
    // Status LED
    // -----------------------------------------------------------------------
    assign LED = {7'b0000000, config_finished};

    // -----------------------------------------------------------------------
    // OV7670 capture
    // -----------------------------------------------------------------------
    ov7670_capture capture (
        .pclk  (buffered_pclk),
        .vsync (OV7670_VSYNC),
        .href  (OV7670_HREF),
        .d     (OV7670_D),
        .addr  (capture_addr),
        .dout  (capture_data),
        .we    (capture_we)
    );

    // -----------------------------------------------------------------------
    // OV7670 controller (I2C + config)
    // -----------------------------------------------------------------------
    ov7670_controller controller (
        .clk             (clk50),
        .sioc            (OV7670_SIOC),
        .resend          (resend),
        .config_finished (config_finished),
        .siod            (OV7670_SIOD),
        .pwdn            (OV7670_PWDN),
        .reset_out       (OV7670_RESET),
        .xclk            (OV7670_XCLK)
    );

    // -----------------------------------------------------------------------
    // Clocking (MMCM)
    // -----------------------------------------------------------------------
    clocking your_instance_name (
        .CLK_100 (clk100),
        .CLK_50  (clk50),
        .CLK_25  (clk25)
    );

endmodule
