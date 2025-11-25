module HiHat
(
    input  wire audio_tick,
    input  wire trigger,
    input  wire reset,
    output reg [9:0] out
);

    //----------------------------------------------------------
    // Raw noise source
    //----------------------------------------------------------
    wire [9:0] noise;
    NoiseGenerator NG (
        .audio_tick(audio_tick),
        .reset(reset),
        .noise_out(noise)
    );

    //----------------------------------------------------------
    // Simple high-pass filter
    //----------------------------------------------------------
    reg [9:0] prev_noise = 0;
    wire signed [10:0] diff = {1'b0, noise} - {1'b0, prev_noise};
    wire [9:0] hp = diff[10] ? 10'd0 : diff[9:0];

    always @(posedge audio_tick)
        prev_noise <= noise;

    //----------------------------------------------------------
    // Envelope (long “tssss”)
    //----------------------------------------------------------
    wire [9:0] gain;

    EnvelopeGenerator #(
        .DECAY_STEP(1),
        .DECAY_RATE(2)
    ) ENV (
        .audio_tick(audio_tick),
        .trigger(trigger),
        .reset(reset),
        .gain(gain)
    );

    //----------------------------------------------------------
    // Multiply noise * envelope
    //----------------------------------------------------------
    reg [19:0] mult_result = 0;

    always @(posedge audio_tick or posedge reset) begin
        if (reset) begin
            mult_result <= 0;
            out <= 0;
        end else begin
            mult_result <= hp * gain;
            out <= mult_result[19:10];
        end
    end

endmodule
