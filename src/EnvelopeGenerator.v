module EnvelopeGenerator #(
    parameter DECAY_STEP = 16'd32,   // how much gain decreases
    parameter DECAY_RATE = 8'd4      // every N audio ticks
)(
    input  wire audio_tick,
    input  wire trigger,
    input  wire reset,
    output reg [9:0] gain
);

    reg [7:0] decay_div = 0;
    reg       trigger_d = 0;

    // rising edge detect must be declared outside always
    wire trig_rise = trigger & ~trigger_d;

    always @(posedge audio_tick or posedge reset) begin
        if (reset) begin
            gain      <= 0;
            decay_div <= 0;
            trigger_d <= 0;
        end else begin

            trigger_d <= trigger;

            if (trig_rise) begin
                gain      <= 10'd1023;
                decay_div <= 0;
            end else if (gain != 0) begin
                if (decay_div == DECAY_RATE) begin
                    decay_div <= 0;

                    if (gain > DECAY_STEP[9:0])
                        gain <= gain - DECAY_STEP[9:0];
                    else
                        gain <= 0;
                end else begin
                    decay_div <= decay_div + 1;
                end
            end

        end
    end

endmodule
