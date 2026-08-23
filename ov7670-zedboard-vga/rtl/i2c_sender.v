// ============================================================================
// Module: i2c_sender.v - I2C Bit-Bang Transmitter
// ============================================================================
module i2c_sender (
    input  wire       clk,
    inout  wire       siod,
    output reg        sioc,
    output reg        taken,
    input  wire       send,
    input  wire [7:0] id,
    input  wire [7:0] reg_addr,
    input  wire [7:0] value
);

    reg  [7:0]  divider = 8'd1;
    reg  [31:0] busy_sr = 32'd0;
    reg  [31:0] data_sr = {32{1'b1}};

    // -----------------------------------------------------------------------
    // Tristate control for siod
    // When the I2C state machine is in an ACK-receive phase
    // (bits 11:10, 20:19, or 29:28 of busy_sr == 2'b10), float siod to 'Z'.
    // Otherwise, drive siod with the MSB of data_sr.
    // -----------------------------------------------------------------------
    wire siod_oe;       // output enable (1 = drive, 0 = high-Z)
    wire siod_out;

    assign siod_oe = ~(
        (busy_sr[11:10] == 2'b10) ||
        (busy_sr[20:19] == 2'b10) ||
        (busy_sr[29:28] == 2'b10)
    );

    assign siod_out = data_sr[31];

    // Tristate buffer for bidirectional siod
    assign siod = siod_oe ? siod_out : 1'bz;

    // -----------------------------------------------------------------------
    // Main I2C state machine
    // -----------------------------------------------------------------------
    always @(posedge clk) begin
        taken <= 1'b0;

        if (busy_sr[31] == 1'b0) begin
            // ---- IDLE state ----
            sioc <= 1'b1;
            if (send == 1'b1) begin
                if (divider == 8'h00) begin
                    // Load the shift register with:
                    //   START | ID[7:0] | ACK | REG[7:0] | ACK | VALUE[7:0] | ACK | STOP
                    //   "100"  id, '0'       reg, '0'          value, '0'        "01"
                    data_sr <= {3'b100, id, 1'b0, reg_addr, 1'b0, value, 1'b0, 2'b01};
                    busy_sr <= {3'b111, 9'b111111111, 9'b111111111, 9'b111111111, 2'b11};
                    taken   <= 1'b1;
                end else begin
                    divider <= divider + 8'd1;
                end
            end
        end else begin
            // ---- BUSY state: bit-bang SCL based on busy_sr & divider ----
            case ({busy_sr[31:29], busy_sr[2:0]})
                6'b111_111: begin
                    case (divider[7:6])
                        2'b00, 2'b01, 2'b10, 2'b11: sioc <= 1'b1;
                    endcase
                end

                6'b111_110: begin
                    case (divider[7:6])
                        2'b00, 2'b01, 2'b10, 2'b11: sioc <= 1'b1;
                    endcase
                end

                6'b111_100: begin
                    case (divider[7:6])
                        2'b00, 2'b01, 2'b10, 2'b11: sioc <= 1'b0;
                    endcase
                end

                6'b110_000: begin
                    case (divider[7:6])
                        2'b00: sioc <= 1'b0;
                        2'b01: sioc <= 1'b1;
                        2'b10: sioc <= 1'b1;
                        2'b11: sioc <= 1'b1;
                    endcase
                end

                6'b100_000: begin
                    case (divider[7:6])
                        2'b00, 2'b01, 2'b10, 2'b11: sioc <= 1'b1;
                    endcase
                end

                6'b000_000: begin
                    case (divider[7:6])
                        2'b00, 2'b01, 2'b10, 2'b11: sioc <= 1'b1;
                    endcase
                end

                default: begin
                    case (divider[7:6])
                        2'b00: sioc <= 1'b0;
                        2'b01: sioc <= 1'b1;
                        2'b10: sioc <= 1'b1;
                        2'b11: sioc <= 1'b0;
                    endcase
                end
            endcase

            // Shift the state when divider rolls over
            if (divider == 8'hFF) begin
                busy_sr <= {busy_sr[30:0], 1'b0};
                data_sr <= {data_sr[30:0], 1'b1};
                divider <= 8'd0;
            end else begin
                divider <= divider + 8'd1;
            end
        end
    end

endmodule
