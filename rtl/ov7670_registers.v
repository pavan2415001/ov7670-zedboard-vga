// ============================================================================
// Module: ov7670_registers.v - Register Configuration Sequencer
// ============================================================================
module ov7670_registers (
    input  wire         clk,
    input  wire         resend,
    input  wire         advance,
    output wire [15:0]  command,
    output wire         finished
);

    reg  [15:0] sreg;
    reg  [7:0]  address = 8'd0;

    assign command  = sreg;
    assign finished = (sreg == 16'hFFFF) ? 1'b1 : 1'b0;

    always @(posedge clk) begin
        if (resend == 1'b1) begin
            address <= 8'd0;
        end else if (advance == 1'b1) begin
            address <= address + 8'd1;
        end

        case (address)
            8'h00: sreg <= 16'h1280; // COM7   Reset
            8'h01: sreg <= 16'h1280; // COM7   Reset
            8'h02: sreg <= 16'h1204; // COM7   Size & RGB output
            8'h03: sreg <= 16'h1100; // CLKRC  Prescaler - Fin/(1+1)
            8'h04: sreg <= 16'h0C00; // COM3   Lots of stuff, enable scaling
            8'h05: sreg <= 16'h3E00; // COM14  PCLK scaling off

            8'h06: sreg <= 16'h8C00; // RGB444 Disable RGB444
            8'h07: sreg <= 16'h0400; // COM1   no CCIR601
            8'h08: sreg <= 16'h40D0; // COM15  Full range, RGB 565
            8'h09: sreg <= 16'h3A04; // TSLB   Set UV ordering
            8'h0A: sreg <= 16'h1438; // COM9   AGC Ceiling
            8'h0B: sreg <= 16'h4F80; // MTX1   standard RGB matrix
            8'h0C: sreg <= 16'h5080; // MTX2   standard RGB matrix
            8'h0D: sreg <= 16'h5100; // MTX3   standard RGB matrix
            8'h0E: sreg <= 16'h5222; // MTX4   standard RGB matrix
            8'h0F: sreg <= 16'h535E; // MTX5   standard RGB matrix
            8'h10: sreg <= 16'h5480; // MTX6   standard RGB matrix
            8'h11: sreg <= 16'h589E; // MTXS   Auto contrast
            8'h12: sreg <= 16'h3D88; // COM13  Gamma, bypass matrix distortion
            8'h13: sreg <= 16'h138F; // COM8   AGC, AWB, AEC

            8'h14: sreg <= 16'h1711; // HSTART
            8'h15: sreg <= 16'h1861; // HSTOP
            8'h16: sreg <= 16'h32A4; // HREF
            8'h17: sreg <= 16'h1903; // VSTART
            8'h18: sreg <= 16'h1A7B; // VSTOP
            8'h19: sreg <= 16'h030A; // VREF

            default: sreg <= 16'hFFFF;
        endcase
    end

endmodule
