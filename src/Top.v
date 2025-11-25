module Top
(
    input         Reset_Button,
    input         User_Button,
    input         XTAL_IN,        // 27 MHz
    output        PWM_AUDIO_PIN,  // 1-bit ΣΔ output
    output [5:0]  LED
);
    wire [5:0] led_internal;
    assign LED = ~led_internal;   // invert all LEDs

    //---------------------------------------------------------------------
    // Clock generation (27 MHz → 150 MHz)
    //---------------------------------------------------------------------
    wire clk_150;
    wire lock;

    Gowin_rPLL pll_inst(
        .clkout(clk_150),
        .lock(lock),
        .clkin(XTAL_IN)
    );

    //---------------------------------------------------------------------
    // 48 kHz audio tick
    //---------------------------------------------------------------------
    reg [12:0] div = 0;
    reg        audio_tick = 0;

    always @(posedge clk_150) begin
        if (div == 3124) begin
            div <= 0;
            audio_tick <= 1;
        end else begin
            div <= div + 1;
            audio_tick <= 0;
        end
    end

    //---------------------------------------------------------------------
    // Audio engine (10-bit)
    //---------------------------------------------------------------------
    wire [9:0] audio_sample;

    AudioEngine audio_inst (
        .clk_150(clk_150),
        .audio_tick(audio_tick),
        .reset(!Reset_Button),
        .audio_sample(audio_sample),
        .led(led_internal)
    );

    

    //---------------------------------------------------------------------
    // ΣΔ DAC (10-bit → 1-bit @150 MHz)
    //---------------------------------------------------------------------
    sigma_delta_dac #(.N(10)) DAC (
        .clk  (clk_150),
        .din  (audio_sample),
        .dout (PWM_AUDIO_PIN)
    );

endmodule
