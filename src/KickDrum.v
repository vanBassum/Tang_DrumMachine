module KickDrum
(
    input  wire        audio_tick,
    input  wire        trigger,
    input  wire        reset,
    output reg [9:0]   out
);

    //----------------------------------------------------------
    // SINE OSCILLATOR
    //----------------------------------------------------------
    reg [15:0] phase = 0;
    wire [7:0] sine_addr = phase[15:8];
    wire [9:0] sine_val;

    sine_rom SINE_TABLE (
        .addr(sine_addr),
        .data(sine_val)
    );

    //----------------------------------------------------------
    // PITCH ENVELOPE
    //----------------------------------------------------------
    localparam [15:0] PITCH_BASE   = 16'd682;
    localparam [15:0] PITCH_ATTACK = 16'd1400;

    reg [15:0] pitch_env = 0;
    reg [5:0]  pitch_div = 0;

    //----------------------------------------------------------
    // AMPLITUDE ENVELOPE
    //----------------------------------------------------------
    reg [9:0] decay_gain = 0;
    reg [4:0] decay_div = 0;

    //----------------------------------------------------------
    // TRIGGER EDGE DETECT (legal now)
    //----------------------------------------------------------
    reg trigger_d = 0;
    wire trig_rise = trigger & ~trigger_d;

    //----------------------------------------------------------
    // MULTIPLIER
    //----------------------------------------------------------
    reg [19:0] mult_result = 0;

    //----------------------------------------------------------
    // MAIN PROCESS
    //----------------------------------------------------------
    always @(posedge audio_tick or posedge reset) begin
        if (reset) begin
            phase       <= 0;
            pitch_env   <= 0;
            pitch_div   <= 0;
            decay_gain  <= 0;
            decay_div   <= 0;
            trigger_d   <= 0;
            mult_result <= 0;
            out         <= 0;
        end else begin

            trigger_d <= trigger;

            //--------------------------------------------------
            // Trigger restart
            //--------------------------------------------------
            if (trig_rise) begin
                pitch_env  <= PITCH_ATTACK;
                pitch_div  <= 0;

                decay_gain <= 10'd1023;
                decay_div  <= 0;

                phase <= 16'd20000;
            end else begin
                //--------------------------------------------------
                // Pitch envelope decay
                //--------------------------------------------------
                if (pitch_env != 0) begin
                    if (pitch_div == 6'd4) begin
                        pitch_div <= 0;
                        pitch_env <= (pitch_env > 16'd40) ? pitch_env - 16'd40 : 0;
                    end else begin
                        pitch_div <= pitch_div + 1;
                    end
                end

                //--------------------------------------------------
                // Amplitude envelope decay
                //--------------------------------------------------
                if (decay_gain != 0) begin
                    if (decay_div == 5'd23) begin
                        decay_div  <= 0;
                        decay_gain <= decay_gain - 10'd1;
                    end else begin
                        decay_div <= decay_div + 1;
                    end
                end
            end

            //--------------------------------------------------
            // Sine oscillator
            //--------------------------------------------------
            phase <= phase + (PITCH_BASE + pitch_env);

            //--------------------------------------------------
            // Multiply
            //--------------------------------------------------
            mult_result <= sine_val * decay_gain;
            out <= mult_result[19:10];
        end
    end

endmodule
