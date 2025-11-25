module StepSequencer #(
    parameter [7:0] SEQUENCE = 8'b10101010
)(
    input  wire audio_tick,     // 
    input  wire advance,        // Advances sequence
    input  wire reset,
    output reg  trigger         // 1 audio tick long
);

    reg [2:0] step = 0;

    always @(posedge audio_tick or posedge reset) begin
        if (reset) begin
            step <= 3'd0;
            trigger <= 1'b0;
        end else begin
            if (advance) begin
                // advance step
                if (step == 3'd7)
                    step <= 3'd0;
                else
                    step <= step + 3'd1;
                trigger <= SEQUENCE[step];
            end else begin
                trigger <= 0;
            end
        end
    end

endmodule

