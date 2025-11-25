module NoiseGenerator #(
    parameter LFSR_WIDTH = 16
)(
    input  wire audio_tick,
    input  wire reset,
    output wire [9:0] noise_out
);

    reg [LFSR_WIDTH-1:0] lfsr = {LFSR_WIDTH{1'b1}};

    always @(posedge audio_tick or posedge reset) begin
        if (reset) begin
            lfsr <= {LFSR_WIDTH{1'b1}};
        end else begin
            lfsr <= {
                lfsr[LFSR_WIDTH-2:0],
                lfsr[LFSR_WIDTH-1] ^
                lfsr[LFSR_WIDTH-3] ^
                lfsr[LFSR_WIDTH-4] ^
                lfsr[LFSR_WIDTH-6]
            };
        end
    end

    assign noise_out = lfsr[LFSR_WIDTH-1 -: 10];

endmodule
