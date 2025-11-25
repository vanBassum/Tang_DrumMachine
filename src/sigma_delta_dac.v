// 1-bit first-order sigma-delta DAC
module sigma_delta_dac #(
    parameter N = 10   // input bits
)(
    input  wire          clk,
    input  wire [N-1:0]  din,   // 0..255
    output reg           dout   // 1-bit output
);
    reg [N:0] acc = { (N+1){1'b0} }; // N+1 bits

    always @(posedge clk) begin
        {dout, acc} <= acc + din;
    end

endmodule
