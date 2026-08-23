// ============================================================================
// Module: debounce.v - Button Debounce (saturating counter)
// ============================================================================
module debounce (
    input  wire clk,
    input  wire i,
    output reg  o
);

    reg [23:0] c = 24'd0;

    always @(posedge clk) begin
        if (i == 1'b1) begin
            if (c == 24'hFFFFFF) begin
                o <= 1'b1;
            end else begin
                o <= 1'b0;
            end
            c <= c + 1'b1;
        end else begin
            c <= 24'd0;
            o <= 1'b0;
        end
    end

endmodule
