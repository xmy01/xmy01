`timescale 1ns / 1ps

module crc8_d8(
	input  wire			  clk,
	input  wire           reset,

	input  wire 		  crc_din_vld, //CRC������Ч
	input  wire [7:0]     crc_din,    //CRC�����У�������
	output reg  [7:0]     crc_dout,   //CRC�����У���ֵ 
	input  wire           crc_done    //CRCУ����� 
    );




/*д��һ
always @(posedge clk) begin
    if (reset) 
       crc_dout <= 0;    //������վ�ĳ�ʼֵ 
    else if (crc_done) 
       crc_dout <= 0;  //������վ�ĳ�ʼֵ
    else if (crc_din_vld)begin
    	crc_dout[0] = crc_din[7] ^ crc_din[6] ^ crc_din[0] ^ crc_dout[0] ^ crc_dout[6] ^ crc_dout[7];
    	crc_dout[1] = crc_din[6] ^ crc_din[1] ^ crc_din[0] ^ crc_dout[0] ^ crc_dout[1] ^ crc_dout[6];
    	crc_dout[2] = crc_din[6] ^ crc_din[2] ^ crc_din[1] ^ crc_din[0] ^ crc_dout[0] ^ crc_dout[1] ^ crc_dout[2] ^ crc_dout[6];
    	crc_dout[3] = crc_din[7] ^ crc_din[3] ^ crc_din[2] ^ crc_din[1] ^ crc_dout[1] ^ crc_dout[2] ^ crc_dout[3] ^ crc_dout[7];
    	crc_dout[4] = crc_din[4] ^ crc_din[3] ^ crc_din[2] ^ crc_dout[2] ^ crc_dout[3] ^ crc_dout[4];
    	crc_dout[5] = crc_din[5] ^ crc_din[4] ^ crc_din[3] ^ crc_dout[3] ^ crc_dout[4] ^ crc_dout[5];
    	crc_dout[6] = crc_din[6] ^ crc_din[5] ^ crc_din[4] ^ crc_dout[4] ^ crc_dout[5] ^ crc_dout[6];
    	crc_dout[7] = crc_din[7] ^ crc_din[6] ^ crc_din[5] ^ crc_dout[5] ^ crc_dout[6] ^ crc_dout[7];    	
    end      
end*/

//д��2

wire [7:0] crc_data;

assign crc_data[0] = crc_din[7] ^ crc_din[6] ^ crc_din[0] ^ crc_dout[0] ^ crc_dout[6] ^ crc_dout[7]; 
assign crc_data[1] = crc_din[6] ^ crc_din[1] ^ crc_din[0] ^ crc_dout[0] ^ crc_dout[1] ^ crc_dout[6];
assign crc_data[2] = crc_din[6] ^ crc_din[2] ^ crc_din[1] ^ crc_din[0] ^ crc_dout[0] ^ crc_dout[1] ^ crc_dout[2] ^ crc_dout[6];
assign crc_data[3] = crc_din[7] ^ crc_din[3] ^ crc_din[2] ^ crc_din[1] ^ crc_dout[1] ^ crc_dout[2] ^ crc_dout[3] ^ crc_dout[7];
assign crc_data[4] = crc_din[4] ^ crc_din[3] ^ crc_din[2] ^ crc_dout[2] ^ crc_dout[3] ^ crc_dout[4];
assign crc_data[5] = crc_din[5] ^ crc_din[4] ^ crc_din[3] ^ crc_dout[3] ^ crc_dout[4] ^ crc_dout[5];
assign crc_data[6] = crc_din[6] ^ crc_din[5] ^ crc_din[4] ^ crc_dout[4] ^ crc_dout[5] ^ crc_dout[6];
assign crc_data[7] = crc_din[7] ^ crc_din[6] ^ crc_din[5] ^ crc_dout[5] ^ crc_dout[6] ^ crc_dout[7]; 

always @(posedge clk) begin
    if (reset) 
       crc_dout <= 0;    //������վ�ĳ�ʼֵ 
    else if (crc_done) 
       crc_dout <= 0;  //������վ�ĳ�ʼֵ
    else if (crc_din_vld)begin
	   crc_dout <= crc_data ; 	
    end      
end

endmodule
