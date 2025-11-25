module OpenHiHat
(
    input  wire audio_tick,
    input  wire trigger,
    input  wire choke,
    input  wire reset,
    output reg [9:0] out
);

    //----------------------------------------------------------
    // Raw noise
    //----------------------------------------------------------
    wire [9:0] noise;

    NoiseGenerator #(16) NG (
        .audio_tick(audio_tick),
        .reset(reset),
        .noise_out(noise)
    );

    //----------------------------------------------------------
    // High-pass + slight band-pass
    //----------------------------------------------------------
    reg [9:0] prev_noise = 0;

    always @(posedge audio_tick)
        prev_noise <= noise;

    wire signed [10:0] hp = {1'b0, noise} - {1'b0, prev_noise};
    wire signed [10:0] bp = hp - (hp >>> 3);
    wire [9:0] hat_noise = bp[10] ? 10'd0 : bp[9:0];

    //----------------------------------------------------------
    // Open-hat envelope
    //----------------------------------------------------------
    wire [9:0] gain;
    
    EnvelopeGenerator #(
        .DECAY_STEP(1),
        .DECAY_RATE(6)
    ) ENV (
        .audio_tick(audio_tick),
        .trigger(trigger),
        .reset(reset),
        .gain(gain)
    );

    //----------------------------------------------------------
    // Choke logic (closed hat kills open hat)
    //----------------------------------------------------------
    reg [9:0] gain_choked = 0;

    always @(posedge audio_tick or posedge reset) begin
        if (reset)
            gain_choked <= 0;
        else if (choke)
            gain_choked <= 0;
        else
            gain_choked <= gain;
    end

    //----------------------------------------------------------
    // Multiply filtered noise by envelope
    //----------------------------------------------------------
    reg [19:0] mult_result = 0;

    always @(posedge audio_tick or posedge reset) begin
        if (reset) begin
            mult_result <= 0;
            out <= 0;
        end else begin
            mult_result <= hat_noise * gain_choked;
            out <= mult_result[19:10];
        end
    end

endmodule
