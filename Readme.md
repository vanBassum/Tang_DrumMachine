# FPGA Drum Machine on a Gowin FPGA

Inspired by channels like *mum look no computer* and an itch to play with my FPGA, I built a tiny drum sequencer on a Tang Nano 9K.
For audio output I used a **1.2k resistor + 3.3nF** RC low-pass filter, followed by an **LM386** into a cheap 8 Ω speaker.

Audio is generated using a **sigma-delta DAC running at 150 MHz**, which makes this filter fall in the category of good enough.

I had the motivation to build these components until I got bored with it:

* Kick drum (sine + pitch envelope)
* Closed hi-hat (noise + fast envelope)
* Open hi-hat (noise + long envelope + choke)
* 8-step sequencer with programmable patterns
* 48 kHz audio tick feeding the ΣΔ DAC
