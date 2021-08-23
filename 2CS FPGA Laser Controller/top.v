/*
// look in pins.pcf for all the pin names on the TinyFPGA BX board
module top (
    input CLK,    // 16MHz clock
    output LED,   // User/boot LED next to power LED
    output USBPU  // USB pull-up resistor
);
    // drive USB pull-up resistor to '0' to disable USB
    assign USBPU = 0;

    ////////
    // make a simple blink circuit
    ////////

    // keep track of time and location in blink_pattern
    reg [25:0] blink_counter;

    // pattern that will be flashed over the LED over time
    wire [31:0] blink_pattern = 32'b101010001110111011100010101;

    // increment the blink_counter every clock
    always @(posedge CLK) begin
        blink_counter <= blink_counter + 1;
    end

    // light up the LED according to the pattern
    assign LED = blink_pattern[blink_counter[25:21]];
endmodule





// Verilog code for rising edge D flip flop
module RisingEdge_DFlipFlop(D,clk,Q);
  input D; // Data input
  input clk; // clock input
  output Q; // output Q
  always @(posedge clk)
  begin
   Q <= D;
  end
endmodule
*/

module top(
  input CLK,
  input V_SYNC,
  input SW_IN,
  output SYNC_0,SYNC_1, sw_spike, sync_buffer, clk_480hz, clk_30hz, Vsync_delayed
  );
// drive USB pull-up resistor to '0' to disable USB
  assign USBPU = 0;

  wire PB_down, PB_up;
  reg PB_state;
  reg [3:0]sw_index = 4'b000;

  pushbutton_debouncer sw_db (
      .clk (CLK),
      .PB (SW_IN),
      .PB_state (PB_state),
      .PB_down (PB_down),
      .PB_up (PB_up)
  );

// momentary button
//single pulse generated on button press
  pulse_control one_shot (
    .clock (clk_480hz),
    .ready (PB_state),
    .pcEn (sw_spike)
  );

//increment index on button press
  always @(posedge sw_spike) begin
    if (sw_index < 4'b1111)
        sw_index <= sw_index + 4'b0001;
    else
        sw_index <= 4'b0000;
  end

//use PLL to generate a 30Mhz clock, divisible for 30FPS
  pll clk_30Mhz_gen(
    .clock_in (CLK),
    .clock_out (clk_30Mhz)
    );

//clock divided to 480Hz for cycling through delay offsets
// 480Hz = 16x 30FPS, can select 16 positions over one clock cycle
  Clock_divider Clock_div_480Hz (
    .clock_in(clk_30Mhz),
    .divisor(28'd62500),
    .clock_out(clk_480hz)
    );

  Clock_divider Clock_div_30Hz (
    .clock_in(clk_30Mhz),
    .divisor(28'd1000000),
    .clock_out(clk_30hz)
    );
//flip flop chain from which the delayed signal is sig_selected
// using sw_index to pick
  delay sync_delay (
    .clk(clk_480hz),
    .sig_in(sync_buffer),
    .index(sw_index),
    .sig_selected(Vsync_delayed)
    );


//input buffers to sync V_sync to clk
  always @(posedge clk_30Mhz) begin
      sync_buffer <= V_SYNC;
  end

//laser control signal
  always @(posedge clk_30Mhz) begin
    SYNC_0 <= ~Vsync_delayed;  //toggle on/off state for laser 1
    SYNC_1 <= Vsync_delayed; //toggle on/off state for laser 2, opposing laser 1
  end
endmodule
