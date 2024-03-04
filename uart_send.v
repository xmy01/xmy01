`timescale 1ns / 1ps

module uart_send(
		input			  clk,
		input             reset,

		input             wr_en,
		input [7:0]       wr_data,

		output reg        uart_tx_en,
		output reg [7:0]  uart_tx_data,
		input             uart_tx_busy
    );



reg [1:0]   state;
localparam  IDLE = 2'b00;
localparam  SEND = 2'b01;
localparam  END =  2'b10;

reg [7:0]  din;
reg        wren;
reg        rd_en;
wire [7:0] dout;
wire       full;
wire       empty;

reg       uart_tx_busy_d0;
reg       uart_tx_busy_d1;

always @(posedge clk) begin
	uart_tx_busy_d0   <= uart_tx_busy;
	uart_tx_busy_d1   <= uart_tx_busy_d0;
end

always @(posedge clk) begin
	din   <= wr_data;
	wren  <= wr_en;
end


always @(posedge clk) begin
    if (reset) 
       state <= IDLE; 
    else
    	case(state)
    		IDLE : begin
    			if (~empty)
    				state <= SEND;
    			else 
    				state <= state;
    		end
    		SEND : begin
    			if (~uart_tx_busy_d0 && uart_tx_busy_d1)
    				state <= END;
    			else 
    				state <= state;
    		end
    		END : begin
    			state <= IDLE;
    		end
    		default : state <= IDLE;
        endcase    
end

always @(posedge clk)begin
    if (state == IDLE && ~empty) 
        rd_en <= 1'b1;
    else 
        rd_en <= 1'b0; 
end

always @(posedge clk) begin
    if (reset) begin
    	uart_tx_en   <= 0;
    	uart_tx_data <= 0;
    end    
    else begin
    	uart_tx_en   <= rd_en;
    	uart_tx_data <= dout;
    end    
end


fifo_w8xd128 fifo_w8xd128 (
  .clk(clk),      // input wire clk
  .srst(reset),    // input wire srst
  .din(din),      // input wire [7 : 0] din
  .wr_en(wren),  // input wire wr_en
  .rd_en(rd_en),  // input wire rd_en
  .dout(dout),    // output wire [7 : 0] dout
  .full(full),    // output wire full
  .empty(empty),  // output wire empty
  .wr_rst_busy(),
  .rd_rst_busy()
);

endmodule
