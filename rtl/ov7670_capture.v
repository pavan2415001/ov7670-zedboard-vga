// ============================================================================
// Module: ov7670_capture.v - Pixel Capture (byte-pair → 12-bit RGB)
// ============================================================================
module ov7670_capture (
    input  wire         pclk,
    input  wire         vsync,
    input  wire         href,
    input  wire [7:0]   d,
    output wire [18:0]  addr,
    output reg  [11:0]  dout,
    output reg          we
);

    reg [15:0] d_latch     = 16'd0;
    reg [18:0] address      = 19'd0;
    reg [18:0] address_next = 19'd0;
    reg [1:0]  wr_hold      = 2'b00;

    // Combinational: addr follows the registered address (VHDL concurrent signal)
    assign addr = address;

    always @(posedge pclk) begin
        if (vsync == 1'b1) begin
            address      <= 19'd0;
            address_next <= 19'd0;
            wr_hold      <= 2'b00;
            // d_latch, dout, we, addr retain their values (VHDL default)
            // For safety, also clear d_latch:
            d_latch      <= 16'd0;
        end else begin
            // Output the latched RGB 4:4:4 format (drops LSB of each channel)
            dout   <= { d_latch[15:12], d_latch[10:7], d_latch[4:1] };

            address <= address_next;
            we      <= wr_hold[1];

            wr_hold <= {wr_hold[0], href & ~wr_hold[0]};

            d_latch <= {d_latch[7:0], d};

            if (wr_hold[1] == 1'b1) begin
                address_next <= address_next + 19'd1;
            end
        end
    end

endmodule
