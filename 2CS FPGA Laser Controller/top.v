module top(
  input CLK,
  input V_SYNC,
  output SYNC_0,SYNC_1, sync_buffer
  );
// drive USB pull-up resistor to '0' to disable USB
  assign USBPU = 0;

//input buffer for V_SYNC (1/2 freq of V_SYNC)
  always @(posedge V_SYNC) begin
      sync_buffer <= ~sync_buffer;
  end

//laser control signal
  always @(posedge V_SYNC) begin
    SYNC_0 <= sync_buffer;  //toggle on/off state for laser 1
    SYNC_1 <= ~sync_buffer; //toggle on/off state for laser 2, opposing laser 1
  end
endmodule
