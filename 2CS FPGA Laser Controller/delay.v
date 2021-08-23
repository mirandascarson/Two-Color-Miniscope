module delay(
  input clk,
  input sig_in,
  input [3:0]index,
  output reg sig_selected
);
reg [15:0] sig_delayed;

// 60606
//D flip flop initialize
always @(posedge clk) begin
  sig_delayed[0]<=sig_in;
  sig_delayed[15:1] <= sig_delayed[14:0];
  sig_selected <= sig_delayed[index];
end
endmodule
