// ============================================================================
// Module: ov7670_controller.v - Camera Controller (I2C + sys_clk + registers)
// ============================================================================
module ov7670_controller (
    input  wire        clk,
    input  wire        resend,
    output wire        config_finished,
    output wire        sioc,
    inout  wire        siod,
    output wire        reset_out,
    output wire        pwdn,
    output wire        xclk
);

    wire sys_clk;
    wire [15:0] command;
    wire finished;
    wire taken;
    wire send;

    localparam [7:0] CAMERA_ADDRESS = 8'h42;

    assign config_finished = finished;
    assign send            = ~finished;

    // I2C sender
    i2c_sender Inst_i2c_sender (
        .clk   (clk),
        .taken (taken),
        .siod  (siod),
        .sioc  (sioc),
        .send  (send),
        .id    (CAMERA_ADDRESS),
        .reg_addr (command[15:8]),
        .value (command[7:0])
    );

    // Static control signals
    assign reset_out = 1'b1;   // Normal mode
    assign pwdn      = 1'b0;   // Power device up
    assign xclk      = sys_clk;

    // Register sequencer
    ov7670_registers Inst_ov7670_registers (
        .clk      (clk),
        .advance  (taken),
        .command  (command),
        .finished (finished),
        .resend   (resend)
    );

    // Toggle sys_clk (XCLK = clk / 2)
    reg sys_clk_reg = 1'b0;
    always @(posedge clk) begin
        sys_clk_reg <= ~sys_clk_reg;
    end
    assign sys_clk = sys_clk_reg;

endmodule
