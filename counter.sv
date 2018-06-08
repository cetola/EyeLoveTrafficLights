//
// Synthesizable counter module
//
module counter(clk, load, value, decr, timeup);
input clk, load, decr;
input [7:0] value;
output timeup;
reg [7:0] count;
assign timeup = (count == 0) ? 1 : 0;
always @(posedge clk)
  begin
  if (load)
    begin
    count <= value;
    end
  else if (decr && (count != 0))
    begin
    count <= count - 8'b1;
    end
  else
    count <= count;
  end
endmodule
