module uart_control_ii_pack (
	input				               clk,
	input                              enable,
	input                              reset,

    //与uart_send交互的信号
    output reg            			   wr_en,
    output reg      [7:0]       	   wr_data,
 
	input        [7:0]                 tx_frame_data0,	
	input        [7:0]                 tx_frame_data1,	
	input        [7:0]                 tx_frame_data2,	
	input        [7:0]                 tx_frame_data3,	
	input        [7:0]                 tx_frame_data4,	
	input        [7:0]                 tx_frame_data5,	
	input        [7:0]                 tx_frame_data6,	
	input        [7:0]                 tx_frame_data7,
	input        [7:0]                 tx_frame_data8,
	input        [7:0]                 tx_frame_data9,
	input        [7:0]                 tx_frame_data10,
	input        [7:0]                 tx_frame_data11,
	input        [7:0]                 tx_frame_data12,
	input        [7:0]                 tx_frame_data13,
	input        [7:0]                 tx_frame_data14,
	input        [7:0]                 tx_frame_data15,
	input        [7:0]                 tx_frame_data16,
	input        [7:0]                 tx_frame_data17,
	input        [7:0]                 tx_frame_data18,
	input        [7:0]                 tx_frame_data19,
	input        [7:0]                 tx_frame_data20,
    input        [7:0]                 tx_frame_data21,
	input        [7:0]                 tx_frame_data22,
	input        [7:0]                 tx_frame_data23,
	input        [7:0]                 tx_frame_data24,
	input        [7:0]                 tx_frame_data25,
    //与crc8_d8_tx模块交互信号
	output reg                         tx_crc_din_vld,  //输出待校验的数据有效 
	output reg   [7:0]                 tx_crc_din,      //输出待校验的数据 
	input        [7:0]                 tx_crc_dout, 	//输入经过CRC模块校验后的数据
	output reg                         tx_crc_done		//一帧CRC校验完成	
    
);
    

reg [7:0] tx_array [31:0]; //定义数组
reg [4:0] wr_cnt;

always @(posedge clk) begin
    if (reset) begin
    	tx_array[0] <= 8'h55;
    	tx_array[1] <= 8'hbb;  
    	tx_array[2] <= 8'h02;  
    	tx_array[3] <= 8'h1a; 
    	tx_array[31]<= 8'hf0;  
    	//tx_array[30]<= 8'h60;  	     	  	
    end 
    else if (enable )begin

     	tx_array[4]  <= tx_frame_data0;
     	tx_array[5]  <= tx_frame_data1;
     	tx_array[6]  <= tx_frame_data2;
     	tx_array[7]  <= tx_frame_data3;
        tx_array[8]  <= tx_frame_data4; 
        tx_array[9]  <= tx_frame_data5;
        tx_array[10] <= tx_frame_data6;
        tx_array[11] <= tx_frame_data7;	
        tx_array[12] <= tx_frame_data8;
        tx_array[13] <= tx_frame_data9;
        tx_array[14] <= tx_frame_data10;
        tx_array[15] <= tx_frame_data11;
        tx_array[16] <= tx_frame_data12;
        tx_array[17] <= tx_frame_data13;	
        tx_array[18] <= tx_frame_data14;
        tx_array[19] <= tx_frame_data15;
        tx_array[20] <= tx_frame_data16;
        tx_array[21] <= tx_frame_data17;
        tx_array[22] <= tx_frame_data18;
        tx_array[23] <= tx_frame_data19;
        tx_array[24] <= tx_frame_data20;
        tx_array[25] <= tx_frame_data21;
        tx_array[26] <= tx_frame_data22;
        tx_array[27] <= tx_frame_data23;
        tx_array[28] <= tx_frame_data24;
        tx_array[29] <= tx_frame_data25;
          	      	      	   	  	    	   	
    end
end

always @(posedge clk) begin
    if (enable) 
       wr_en <= 1; 
    else if (wr_en && wr_cnt == 5'd31) 
       wr_en <= 0; 
end

always @(posedge clk) begin
    if (reset) 
		wr_cnt <= 0;       
    else if (wr_en && wr_cnt == 5'd31) 
        wr_cnt <= 0;
    else if (wr_en)
       	wr_cnt <= wr_cnt + 1;
        
end

always @(*) begin
	if (wr_cnt == 5'd30) 
		wr_data <= tx_crc_dout;
	else if (wr_en) 
		wr_data <= tx_array[wr_cnt];
	else 
		wr_data <= 0;
end

always @(*) begin
	if (wr_en && wr_cnt >= 5'd2 && wr_cnt <= 5'd29)begin 
		tx_crc_din_vld <= 1;
        tx_crc_din     <= wr_data;
    end
	else if (wr_en && wr_cnt == 5'd31) begin
		tx_crc_done    <= 1;
        tx_crc_din_vld <= 0;
    end    
	else begin
		tx_crc_din_vld <= 0;
		tx_crc_done    <= 0;
        tx_crc_din     <= 0;
	end
end



endmodule
