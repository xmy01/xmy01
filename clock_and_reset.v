`timescale 1ns / 1ps

module clock_and_reset(
	input  wire		clkin_100m,
	output wire     clkout_100m,
	output wire     clkout_500m,
	output reg		reset
    );

wire locked;
wire clkout;
reg [31:0] cnt;

always @(posedge clkout or negedge locked) begin
	if (~locked) begin
		cnt   <= 32'd0;
		reset <= 1'b1;
	end
	else if (cnt <= 32'd100000) begin
		cnt   <= cnt + 1'b1;
		reset <= 1'b1;
	end
	else begin
		cnt   <= cnt;
		reset <= 1'b0;
	end
end

assign clkout_100m = clkout;
assign clkout_500m = clkout2;


  clk_wiz_2 u_clk_wiz_2
   (
    // Clock out ports
    .clk_out1(clkout),     // output clk_out1
    .clk_out2(clkout2),
    // Status and control signals
    .reset(1'b0), // input reset
    .locked(locked),       // output locked
   // Clock in ports
    .clk_in1(clkin_100m)
    ); 



endmodule
