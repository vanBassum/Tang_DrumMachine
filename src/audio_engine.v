module AudioEngine
(
    input  wire        clk_150,         // 150 MHz
    input  wire        audio_tick,      // 48 kHz
    input  wire        reset,
    output wire [9:0]  audio_sample,
    output wire [5:0]  led
);

    //----------------------------------------------------------
    // Step clock (120 BPM, 8 steps)
    //----------------------------------------------------------
    reg [12:0] div = 0;
    reg        step_tick = 0;

    always @(posedge audio_tick or posedge reset) begin
        if (reset) begin
            div <= 0;
            step_tick <= 0;
        end else begin
            if (div == 6000) begin
                div <= 0;
                step_tick <= 1;
            end else begin
                div <= div + 1;
                step_tick <= 0;
            end
        end
    end

    //----------------------------------------------------------
    // Sequencers (8-step) — now audio_tick domain
    //----------------------------------------------------------
    wire trig_kick;
    wire trig_ch;
    wire trig_oh;

    assign led[0] = trig_kick;
    assign led[1] = trig_ch;
    assign led[2] = trig_oh;
    assign led[5:3] = 3'b000;


    StepSequencer #(
        .SEQUENCE(8'b10001000)
    ) seqKick (
        .audio_tick(audio_tick),
        .advance(step_tick),
        .reset(reset),
        .trigger(trig_kick)
    );

    StepSequencer #(
        .SEQUENCE(8'b11111111)
    ) seqCH (
        .audio_tick(audio_tick),
        .advance(step_tick),
        .reset(reset),
        .trigger(trig_ch)
    );

    StepSequencer #(
        .SEQUENCE(8'b00100100)
    ) seqOH (
        .audio_tick(audio_tick),
        .advance(step_tick),
        .reset(reset),
        .trigger(trig_oh)
    );

    //----------------------------------------------------------
    // Sound Generators — audio_tick domain
    //----------------------------------------------------------
    wire [9:0] kick_out;
    wire [9:0] ch_out;
    wire [9:0] oh_out;

    KickDrum kd (
        .audio_tick(audio_tick),
        .trigger(trig_kick),
        .reset(reset),
        .out(kick_out)
    );

    HiHat chh (
        .audio_tick(audio_tick),
        .trigger(trig_ch),
        .reset(reset),
        .out(ch_out)
    );

    OpenHiHat ohh (
        .audio_tick(audio_tick),
        .trigger(trig_oh),
        .reset(reset),
        .out(oh_out)
    );

    //----------------------------------------------------------
    // Mixer (clamped)
    //----------------------------------------------------------
    wire [11:0] mix_sum = kick_out + ch_out + oh_out;
    assign audio_sample = mix_sum[11:2];  // reduce back to 10 bits

endmodule
