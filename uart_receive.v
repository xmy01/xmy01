`timescale 1ns / 1ps

module uart_receive(
	input				           clk,
	input                          reset,
    
    //��uart_rxģ�齻���ź�
	input                          uart_rx_done,
	input     [7:0]                uart_rx_data_o,

    //�������������ݶ�
	output reg                     rx_frame_vld,    //������ݶ�ʹ��
	output reg [7:0]               frame_addr,      //���֡��ַ
	output     [7:0]               rx_frame_data0,	//������ݶΣ����ݶε�0���ֽ�
	output     [7:0]               rx_frame_data1,	
	output     [7:0]               rx_frame_data2,	
	output     [7:0]               rx_frame_data3,	
	output     [7:0]               rx_frame_data4,	
	output     [7:0]               rx_frame_data5,	
	output     [7:0]               rx_frame_data6,	
	output     [7:0]               rx_frame_data7,		
    output     [7:0]               rx_frame_data8,
    output     [7:0]               rx_frame_data9,
    output     [7:0]               rx_frame_data10,
    output     [7:0]               rx_frame_data11,
    output     [7:0]               rx_frame_data12,
    output     [7:0]               rx_frame_data13,
    output     [7:0]               rx_frame_data14,
    output     [7:0]               rx_frame_data15,
    output     [7:0]               rx_frame_data16,
    output     [7:0]               rx_frame_data17,
    output     [7:0]               rx_frame_data18,
    output     [7:0]               rx_frame_data19,
    output     [7:0]               rx_frame_data20,
    output     [7:0]               rx_frame_data21,
    output     [7:0]               rx_frame_data22,
    output     [7:0]               rx_frame_data23,
    output     [7:0]               rx_frame_data24,
    output     [7:0]               rx_frame_data25,
    //��crc8_d8_rxģ�齻���ź�
	output reg                     rx_crc_din_vld,  //�����У���������Ч 
	output reg  [7:0]              rx_crc_din,      //�����У������� 
	input       [7:0]              rx_crc_dout, 	//���뾭��CRCģ��У��������
	output reg                     rx_crc_done,		//һ֡CRCУ�����	
	
	output reg                     start
    );



reg [5:0] cur_status;
reg [5:0] nxt_status;
localparam FRAME_IDLE       = 6'b000000;//00
localparam FRAME_HEAD       = 6'b000001;//01
localparam FRAME_ADDR       = 6'b000010;//02
localparam FRAME_LENGTH     = 6'b000100;//04
localparam FRAME_SCANI      = 6'b000101;//05
localparam FRAME_SCANII     = 6'b000110;//06
localparam FRAME_SCANIII    = 6'b000111;//07
localparam FRAME_DATA       = 6'b001000;//08
localparam FRAME_CRC        = 6'b010000;//10
localparam FRAME_END        = 6'b100000;//20

reg [7:0] frame_data_cnt;
reg [7:0] frame_data_length;

reg [207:0] frame_data_array;
/*--------------------------------------------------*\
				    frame state machine
\*--------------------------------------------------*/
always @(posedge clk) begin
	if (reset) 
		cur_status <= FRAME_IDLE;
	else 
		cur_status <= nxt_status;
end

always @(*) begin
	if (reset) begin
		nxt_status <= FRAME_IDLE;		
	end
	else begin
		case(cur_status)
			FRAME_IDLE : begin 
				if (uart_rx_done && uart_rx_data_o == 8'h55) //��⵽֡ͷ0x55
					nxt_status <= FRAME_HEAD;
				else 
					nxt_status <= cur_status;
			end
			FRAME_HEAD : begin
				if (uart_rx_done && uart_rx_data_o == 8'haa) //��⵽֡ͷ0xaa
					nxt_status <= FRAME_ADDR;
				else if (uart_rx_done && uart_rx_data_o != 8'haa) 
					nxt_status <= FRAME_IDLE;	
				else 
					nxt_status <= cur_status;			
			end	
            FRAME_ADDR : begin               
            	if (uart_rx_done && (uart_rx_data_o == 8'h04))
            	    nxt_status <= FRAME_SCANI;
            	else if (uart_rx_done && (uart_rx_data_o == 8'h05))
            	    nxt_status <= FRAME_SCANII; 
            	else if (uart_rx_done && (uart_rx_data_o == 8'h06))
            	    nxt_status <= FRAME_SCANIII;   
            	else if (uart_rx_done)//���յ�����
            	    nxt_status <= FRAME_LENGTH;
            	else 
            		nxt_status <= cur_status;
            end  
            FRAME_LENGTH : begin               
            	if (uart_rx_done) //���յ����ݳ���
            	 	nxt_status <= FRAME_DATA;
            	else 
            	 	nxt_status <= cur_status;
            end
            FRAME_SCANI : begin               
            	if (uart_rx_done) 
            	 	nxt_status <= FRAME_DATA;
            	else 
            	 	nxt_status <= cur_status;
            end
            FRAME_SCANII : begin               
            	if (uart_rx_done) 
            	 	nxt_status <= FRAME_DATA;
            	else 
            	 	nxt_status <= cur_status;
            end
            FRAME_SCANIII : begin               
            	if (uart_rx_done) 
            	 	nxt_status <= FRAME_DATA;
            	else 
            	 	nxt_status <= cur_status;
            end
            FRAME_DATA : begin
            	if (uart_rx_done && frame_data_cnt == frame_data_length)
            		nxt_status <= FRAME_CRC;
            	else 
            		nxt_status <= cur_status;
            end
            FRAME_CRC : begin
            	if (uart_rx_done && uart_rx_data_o == rx_crc_dout)
            		nxt_status <= FRAME_END;
            	else if (uart_rx_done && uart_rx_data_o != rx_crc_dout)
            		nxt_status <= FRAME_IDLE;
            	else 
            		nxt_status <= cur_status;
            end	
            FRAME_END : begin
            	if (uart_rx_done)
            		nxt_status <= FRAME_IDLE;
            	else 
            		nxt_status <= cur_status;
            end
			default : nxt_status <= FRAME_IDLE;
		endcase	
	end
end

/*--------------------------------------------------*\
				  frame_data_cnt signals
\*--------------------------------------------------*/
always @(posedge clk) begin
    if (cur_status ==FRAME_LENGTH && uart_rx_done) 
        frame_data_length <= uart_rx_data_o - 1;
    else 
        frame_data_length <= frame_data_length;
end

always @(posedge clk) begin
    if (reset) 
        frame_data_cnt <= 0;
    else if (cur_status == FRAME_DATA) begin
        if (uart_rx_done)
        	frame_data_cnt <= frame_data_cnt + 1; //�������ݶ�ʱ�������1
        else 
        	frame_data_cnt <= frame_data_cnt;
    end
    else 
        frame_data_cnt <= 0;
end

/*--------------------------------------------------*\
				     CRC signals
\*--------------------------------------------------*/
always @(posedge clk) begin
    if (cur_status == FRAME_LENGTH || cur_status == FRAME_ADDR || cur_status == FRAME_DATA || cur_status == FRAME_SCANI || cur_status == FRAME_SCANII || cur_status == FRAME_SCANIII) begin
        rx_crc_din_vld <= uart_rx_done;
        rx_crc_din     <= uart_rx_data_o;
    end
    else begin
        rx_crc_din_vld <= 0;
        rx_crc_din     <= rx_crc_din;
    end
end


always @(posedge clk) begin
	rx_crc_done <= cur_status == FRAME_END;
end

/*--------------------------------------------------*\
				  rx_frame_addr signals
\*--------------------------------------------------*/
always @(posedge clk) begin
    if (cur_status == FRAME_ADDR && uart_rx_done)begin 
        frame_addr <= uart_rx_data_o;
    end else frame_addr <= frame_addr;
end

/*--------------------------------------------------*\
				  rx_frame_data signals
\*--------------------------------------------------*/
always @(posedge clk) begin
    if (cur_status == FRAME_DATA && uart_rx_done) 
        frame_data_array <= {uart_rx_data_o,frame_data_array[207:8]}; //��λ
    else 
        frame_data_array <= frame_data_array;
end

/*--------------------------------------------------*\
				  rx_frame_start signals
\*--------------------------------------------------*/
//always @(posedge clk) begin
//    if (cur_status == FRAME_START && uart_rx_done)begin 
        
//    end else 
//end


assign rx_frame_data0  = frame_data_array[7:0];
assign rx_frame_data1  = frame_data_array[15:8];
assign rx_frame_data2  = frame_data_array[23:16];
assign rx_frame_data3  = frame_data_array[31:24];
assign rx_frame_data4  = frame_data_array[39:32];
assign rx_frame_data5  = frame_data_array[47:40];
assign rx_frame_data6  = frame_data_array[55:48];
assign rx_frame_data7  = frame_data_array[63:56];
assign rx_frame_data8  = frame_data_array[71:64];
assign rx_frame_data9  = frame_data_array[79:72];
assign rx_frame_data10 = frame_data_array[87:80];
assign rx_frame_data11 = frame_data_array[95:88];
assign rx_frame_data12  = frame_data_array[103:96];
assign rx_frame_data13  = frame_data_array[111:104];
assign rx_frame_data14  = frame_data_array[119:112];
assign rx_frame_data15  = frame_data_array[127:120];
assign rx_frame_data16  = frame_data_array[135:128];
assign rx_frame_data17  = frame_data_array[143:136];
assign rx_frame_data18  = frame_data_array[151:144];
assign rx_frame_data19  = frame_data_array[159:152];
assign rx_frame_data20  = frame_data_array[167:160];
assign rx_frame_data21  = frame_data_array[175:168];
assign rx_frame_data22  = frame_data_array[183:176];
assign rx_frame_data23  = frame_data_array[191:184];
assign rx_frame_data24  = frame_data_array[199:192];
assign rx_frame_data25  = frame_data_array[207:200];

always @(posedge clk) begin
	if((cur_status == FRAME_END) && uart_rx_done && (uart_rx_data_o == 8'h01))begin//���յ�����֡β
		start        <= 1'b1;
	end else if((cur_status == FRAME_END) && uart_rx_done && (uart_rx_data_o == 8'hf0))begin //���յ�֡β��ʱ��������ݶ�
	    rx_frame_vld <= 1'b1;
	    start        <= 1'b1;
	end else begin 
		rx_frame_vld <= 1'b0;
		start        <= 1'b0;
    end
end

endmodule
