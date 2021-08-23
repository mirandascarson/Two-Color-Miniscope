module DEFF (
  input clock, reset, in,
  output out
);

  reg trig1, trig2;

  assign out = trig1^trig2;

  always @(posedge clock, posedge reset) begin
    if (reset)  trig1 <= 0;
    else  trig1 <= in^trig2;
  end

  always @(negedge clock, posedge reset) begin
    if (reset)  trig2 <= 0;
    else  trig2 <= in^trig1;
  end
endmodule
