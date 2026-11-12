// ============================================================================
// Module: vga.v - VGA Timing Generator (640×480 @ 25 MHz)
// ============================================================================
module vga (
    input  wire         clk25,
    output reg  [3:0]   vga_red,
    output reg  [3:0]   vga_green,
    output reg  [3:0]   vga_blue,
    output reg          vga_hsync,
    output reg          vga_vsync,
    output reg  [18:0]  frame_addr,
    input  wire [11:0]  frame_pixel
);

    // VGA 640×480 @ 60 Hz timing constants
    localparam H_REZ        = 640;
    localparam H_START_SYNC = 640 + 16;
    localparam H_END_SYNC   = 640 + 16 + 96;
    localparam H_MAX_COUNT  = 800;

    localparam V_REZ        = 480;
    localparam V_START_SYNC = 480 + 10;
    localparam V_END_SYNC   = 480 + 10 + 2;
    localparam V_MAX_COUNT  = 480 + 10 + 2 + 33;

    localparam HSYNC_ACTIVE = 1'b0;
    localparam VSYNC_ACTIVE = 1'b0;

    reg [9:0]  hCounter = 10'd0;
    reg [9:0]  vCounter = 10'd0;
    reg [18:0] address  = 19'd0;
    reg        blank    = 1'b1;

    always @(posedge clk25) begin
        // ---- Horizontal & vertical counters ----
        if (hCounter == (H_MAX_COUNT - 1)) begin
            hCounter <= 10'd0;
            if (vCounter == (V_MAX_COUNT - 1)) begin
                vCounter <= 10'd0;
            end else begin
                vCounter <= vCounter + 10'd1;
            end
        end else begin
            hCounter <= hCounter + 10'd1;
        end

        // ---- Pixel output ----
        if (blank == 1'b0) begin
            vga_red   <= frame_pixel[7:4];
            vga_green <= frame_pixel[7:4];
            vga_blue  <= frame_pixel[7:4];
        end else begin
            vga_red   <= 4'd0;
            vga_green <= 4'd0;
            vga_blue  <= 4'd0;
        end

        // ---- Address / blank generation ----
        if (vCounter >= V_REZ) begin
            address <= 19'd0;
            blank   <= 1'b1;
        end else begin
            if (hCounter < 640) begin
                blank   <= 1'b0;
                address <= address + 19'd1;
            end else begin
                blank   <= 1'b1;
            end
        end

        // ---- Horizontal sync ----
        if ((hCounter > H_START_SYNC) && (hCounter <= H_END_SYNC)) begin
            vga_hsync <= HSYNC_ACTIVE;
        end else begin
            vga_hsync <= ~HSYNC_ACTIVE;
        end

        // ---- Vertical sync ----
        if ((vCounter >= V_START_SYNC) && (vCounter < V_END_SYNC)) begin
            vga_vsync <= VSYNC_ACTIVE;
        end else begin
            vga_vsync <= ~VSYNC_ACTIVE;
        end

        // Drive frame_addr from address register
        frame_addr <= address;
    end

endmodule
