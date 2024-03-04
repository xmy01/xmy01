`timescale 1ns / 1ps



module top(
    input   wire    uart_rx_i,
    input   wire    laser_trigger,
    input   wire    diff_clock_clk_p,
	input   wire    diff_clock_clk_n,
    
    output  wire    uart_tx_o,
    
    output  wire    sendck,
    output  wire    sync,
    output  wire    chl_x,
    output  wire    chl_y,
    output  wire    txdone,
    output  wire    xy2_state,
    
    output  wire    frame,       
    output  wire    pixel,   
    output  wire    laser,
    output  wire    spad,
    output  wire    spad_fine,
    output  wire    u_laser,
    output  wire    u_spad,
    output  wire    u_spad_fine,    
    output  wire    card_power_en,
    output  wire    reset,
    output  wire    laser_trigger_out,
    output  reg     flag_led
);
    wire       		rx_crc_din_vld;
	wire [7:0] 		rx_crc_dout;
	wire [7:0] 		rx_crc_din;
	wire       		rx_crc_done;
    
    wire [7:0]      uart_tx_data;
    
    wire            clk;
    //对差分时钟采用 IBUFGDS IP 核去转换
    IBUFGDS CLK_U(
    .I(diff_clock_clk_p),
    .IB(diff_clock_clk_n),
    .O(clk)
    );
    
    assign  card_power_en   =   1'b1;  
    
    ip_clock u_ip_clock(
        .clk             (clk),
           
        .locked          (),
        .clk_out_50m     (clk_50m)
    );
    
    ip_clock1 u_ip_clock1(
        .clk            (clk),

        .clk_out_200m   (clk_out_200m),
        .clk_out_400m   (clk_out_400m)
    );
 
    
    wire [7:0]  uart_rx_data_o;
    wire        uart_tx_busy;
    reg         uart_busy_r  = 1'b0;
    reg         uart_busy_r1 = 1'b0;
    reg  [7:0]  negedge_cnt  = 7'b0;
    reg         send_en_r    = 1'b0;
    reg         send_en_r2   = 1'b0;
    reg         send_en_r3   = 1'b0;
    
    reg         frame_r;
    reg         frame_r2;      
    reg  [7:0]  cnt          = 7'b0;
    
    reg  [15:0] nx_pix;
    reg  [15:0] ny_pix;
    reg  [31:0] pixel_time;
    reg  [15:0] nx_min;   
    reg  [15:0] nx_max;
    reg  [15:0] ny_min;
    reg  [15:0] ny_max;
    reg  [7:0]  zero_point;
    
    
    reg  [7:0]   frame_nums;
    reg  [7:0]   pixel_nums;
    reg  [7:0]   laser_nums;
    reg  [7:0]   spad_nums;
    reg  [31:0]  sig_start_frame;
    reg  [15:0]  duty_cycle_frame;
    reg  [31:0]  sig_start_pixel;
    reg  [15:0]  duty_cycle_pixel;
    reg  [31:0]  sig_start_laser;
    reg  [15:0]  duty_cycle_laser;
    reg  [31:0]  sig_start_spad;
    reg  [15:0]  duty_cycle_spad;
    reg  [63:0]  frame_period;
    reg  [31:0]  pixel_period;
    reg  [31:0]  laser_period;
    reg  [31:0]  spad_period;
    reg  [15:0]  i_cnt_value;
    
    wire [7:0]  rx_frame_data0; 
    wire [7:0]  rx_frame_data1;
    wire [7:0]  rx_frame_data2;
    wire [7:0]  rx_frame_data3;
    wire [7:0]  rx_frame_data4;
    wire [7:0]  rx_frame_data5;
    wire [7:0]  rx_frame_data6;
    wire [7:0]  rx_frame_data7;
    wire [7:0]  rx_frame_data8;
    wire [7:0]  rx_frame_data9;
    wire [7:0]  rx_frame_data10;
    wire [7:0]  rx_frame_data11;
    wire [7:0]  rx_frame_data12;
    wire [7:0]  rx_frame_data13;
    wire [7:0]  rx_frame_data14;
    wire [7:0]  rx_frame_data15;
    wire [7:0]  rx_frame_data16;
    wire [7:0]  rx_frame_data17;
    wire [7:0]  rx_frame_data18;
    wire [7:0]  rx_frame_data19;
    wire [7:0]  rx_frame_data20;
    wire [7:0]  rx_frame_data21;
    wire [7:0]  rx_frame_data22;
    wire [7:0]  rx_frame_data23;
    wire [7:0]  rx_frame_data24;
    wire [7:0]  rx_frame_data25; 
    
    wire [7:0]  frame_addr;
    
    uart_tx_path u_uart_tx_path(
        .clk_i                              (clk_50m),
        .uart_tx_data_i                     (uart_tx_data[7:0]), //待发送数据
        .uart_tx_en_i                       (uart_tx_en), //发送发送使能信号
        
        .uart_tx_o                          (uart_tx_o),
        .uart_busy                          (uart_tx_busy)
    );
    
    uart_rx_path u_uart_rx_path(
        .clk_i                              (clk_50m),
        .uart_rx_i                          (uart_rx_i),
        
        .uart_rx_data_o                     (uart_rx_data_o),
        .uart_rx_done                       (uart_rx_done)
    );
    
    clock_and_reset u_clock_and_reset(
	   .clkin_100m                 (clk),
	   .clkout_100m                (),
	   .clkout_500m                (clk_out_500m),
	   .reset                      (reset)
    );
    
    
//    wire            m50;
    
//    M50 m50_inst(
//        .clk        (clk),
    
//        .m50        (m50)
//    );
    
    uart_receive uart_receive_inst(
	    .clk               (clk_50m),
	    .reset             (reset),
    
        //与uart_rx模块交互信号
	    .uart_rx_done      (uart_rx_done),
	    .uart_rx_data_o    (uart_rx_data_o),

        //输出解析后的数据段
        .rx_frame_vld      (),
	    .frame_addr        (frame_addr[7:0]),    //输出帧地址
	    .rx_frame_data0    (rx_frame_data0),	  //输出数据段，数据段第0个字节
	    .rx_frame_data1    (rx_frame_data1),	
	    .rx_frame_data2    (rx_frame_data2),	
	    .rx_frame_data3    (rx_frame_data3),	
	    .rx_frame_data4    (rx_frame_data4),	
	    .rx_frame_data5    (rx_frame_data5),	
	    .rx_frame_data6    (rx_frame_data6),	
	    .rx_frame_data7    (rx_frame_data7),		
        .rx_frame_data8    (rx_frame_data8),
        .rx_frame_data9    (rx_frame_data9),
        .rx_frame_data10   (rx_frame_data10),
        .rx_frame_data11   (rx_frame_data11),
        .rx_frame_data12   (rx_frame_data12),
        .rx_frame_data13   (rx_frame_data13),
        .rx_frame_data14   (rx_frame_data14),
        .rx_frame_data15   (rx_frame_data15),
        .rx_frame_data16   (rx_frame_data16),
        .rx_frame_data17   (rx_frame_data17),
        .rx_frame_data18   (rx_frame_data18),
        .rx_frame_data19   (rx_frame_data19),
        .rx_frame_data20   (rx_frame_data20),
        .rx_frame_data21   (rx_frame_data21),
        .rx_frame_data22   (rx_frame_data22),
        .rx_frame_data23   (rx_frame_data23),
        .rx_frame_data24   (rx_frame_data24),
        .rx_frame_data25   (rx_frame_data25),
        //与crc8_d8_rx模块交互信号
	    .rx_crc_din_vld    (rx_crc_din_vld),//输出待校验的数据有效 
	    .rx_crc_din        (rx_crc_din),//输出待校验的数据 
	    .rx_crc_dout       (rx_crc_dout),//输入经过CRC模块校验后的数据
	    .rx_crc_done       (rx_crc_done), //一帧CRC校验完成	
	    .start             (start)		
    );
    
    wire            flag_scan            ;
    wire            flag_control_i       ;
    wire            flag_control_ii      ;
    wire            flag_gate            ;
    reg             flag_start            = 1'b0;
    reg             flag_start2           = 1'b0;
    reg             flag_start3           = 1'b0;
    
    reg             flag_start21          = 1'b0;
    reg             flag_start221         = 1'b0;
    reg             flag_start321         = 1'b0;
    
    reg             flag_start_r          = 1'b0;
    reg             flag_start_r2         = 1'b0;
    reg             flag_start_r3         = 1'b0;         
    
    reg             flag_start2_r          = 1'b0;
    reg             flag_start2_r2         = 1'b0;
    reg             flag_start2_r3         = 1'b0;
    
    reg             flag_start3_r          = 1'b0;
    reg             flag_start3_r2         = 1'b0;
    reg             flag_start3_r3         = 1'b0;
    
    reg             flag_start21_r        = 1'b0;
    reg             flag_start21_r2       = 1'b0;
    
    reg             flag_start221_r        = 1'b0;
    reg             flag_start221_r2       = 1'b0;
    
    reg             flag_start321_r        = 1'b0;
    reg             flag_start321_r2       = 1'b0;
    
    reg             flag_scan20           = 1'b0;
    reg             flag_control_i20      = 1'b0;
    reg             flag_control_ii20     = 1'b0;
    reg             flag_gate20           = 1'b0;

    reg             u_scan_sendback_r         = 1'b0;
    reg             u_control_i_sendback_r    = 1'b0;
    reg             u_control_ii_sendback_r   = 1'b0;
    reg             u_gate_sendback_r         = 1'b0;
    
    reg             u_scan_sendback_r2        = 1'b0;
    reg             u_control_i_sendback_r2   = 1'b0;
    reg             u_control_ii_sendback_r2  = 1'b0;
    reg             u_gate_sendback_r2        = 1'b0; 
    
    reg             scan_sendback21           = 1'b0;
    reg             control_i_sendback21      = 1'b0;
    reg             control_ii_sendback21     = 1'b0;
    reg             gate_sendback21           = 1'b0;
    
    reg             scan_sendback_r           = 1'b0;
    reg             scan_sendback_r2          = 1'b0; 
    reg             control_i_sendback_r      = 1'b0;
    reg             control_i_sendback_r2     = 1'b0;
    reg             control_ii_sendback_r     = 1'b0;
    reg             control_ii_sendback_r2    = 1'b0;
    reg             gate_sendback_r           = 1'b0;
    reg             gate_sendback_r2          = 1'b0;
    
    reg             rx_crc_done_r             = 1'b0;
    reg             rx_crc_done_r2            = 1'b0;
    
    wire            scan_sendback      ;
    wire            control_i_sendback ;
    wire            control_ii_sendback;
    wire            gate_sendback      ;
    
    assign          u_scan_sendback        = (scan_sendback21)?1'b1:1'b0;
    assign          u_control_i_sendback   = (control_i_sendback21)?1'b1:1'b0;
    assign          u_control_ii_sendback  = (control_ii_sendback21)?1'b1:1'b0;
    assign          u_gate_sendback        = (gate_sendback21)?1'b1:1'b0;
    
    
    localparam SCAN         = 8'h00;
    localparam CONTROL_I    = 8'h01;
    localparam CONTROL_II   = 8'h02;
    localparam GATE         = 8'h03;
    localparam SCAN_I       = 8'h04;
    localparam SCAN_II      = 8'h05;
    localparam SCAN_III     = 8'h06;
    
    reg laser_trigger_out_r  = 1'b0;
    reg laser_trigger_r      = 1'b0;
    reg laser_trigger_r2     = 1'b0;
    reg laser_trigger_r3     = 1'b0;
    
    always @(posedge clk_out_200m)begin
        laser_trigger_r  <= laser_trigger;
        laser_trigger_r2 <= laser_trigger_r;     
        laser_trigger_r3 <= laser_trigger_r2;    
    end
    
    always @(posedge clk_out_200m)begin
        if((!laser_trigger_r3)&&laser_trigger)
            laser_trigger_out_r <=  1'b1;
        else if(laser_trigger_r3&&(!laser_trigger))
            laser_trigger_out_r <=  1'b0;    
        else laser_trigger_out_r <=  laser_trigger_out_r;
    end
    
    assign laser_trigger_out = laser_trigger_out_r;
    
    always @(posedge clk)begin
        if(reset)begin

        end else if(!reset)begin
            flag_start21_r         <= flag_start21;
            flag_start21_r2        <= flag_start21_r;
            
            flag_start221_r        <= flag_start221;
            flag_start221_r2       <= flag_start221_r;
            
            flag_start321_r        <= flag_start321;
            flag_start321_r2       <= flag_start321_r; 
            
            scan_sendback_r        <= scan_sendback;
            scan_sendback_r2       <= scan_sendback_r; 
            control_i_sendback_r   <= control_i_sendback;
            control_i_sendback_r2  <= control_i_sendback_r; 
            control_ii_sendback_r  <= control_ii_sendback;
            control_ii_sendback_r2 <= control_ii_sendback_r;
            gate_sendback_r        <= gate_sendback;
            gate_sendback_r2       <= gate_sendback_r;
            
            rx_crc_done_r          <= rx_crc_done;
            rx_crc_done_r2         <= rx_crc_done_r;
            
            u_scan_sendback_r           <= u_scan_sendback;
            u_scan_sendback_r2          <= u_scan_sendback_r;
            u_control_i_sendback_r      <= u_control_i_sendback;
            u_control_i_sendback_r2     <= u_control_i_sendback_r;
            u_control_ii_sendback_r     <= u_control_ii_sendback;
            u_control_ii_sendback_r2    <= u_control_ii_sendback_r;
            u_gate_sendback_r           <= u_gate_sendback;
            u_gate_sendback_r2          <= u_gate_sendback_r;
            
            if(u_scan_sendback_r2)begin
                scan_sendback21       <= 1'b0;
            end else if(u_control_i_sendback_r2)begin
                control_i_sendback21  <= 1'b0;
            end else if(u_control_ii_sendback_r2)begin
                control_ii_sendback21 <= 1'b0;
            end else if(u_gate_sendback_r2)begin
                gate_sendback21       <= 1'b0;
            end else if(flag_start21_r2)begin
                flag_start21          <= 1'b0;
            end else if(flag_start221_r2)begin
                flag_start221         <= 1'b0;
            end else if(flag_start321_r2)begin
                flag_start321         <= 1'b0;
            end else if(scan_sendback_r&&(!scan_sendback_r2))begin
                flag_scan20           <= 1'b0;
            end else if(control_i_sendback_r&&(!control_i_sendback_r2))begin
                flag_control_i20       <= 1'b0;
            end else if(control_ii_sendback_r&&(!control_i_sendback_r2))begin 
                flag_control_ii20     <= 1'b0;
            end else if(gate_sendback_r&&(!gate_sendback_r2))begin 
                flag_gate20           <= 1'b0; 
            end else if(rx_crc_done_r&&(!rx_crc_done_r2))begin 
                case(frame_addr)
                
                    SCAN:begin
                        scan_sendback21       <= 1'b1; 
                    end
                
                    CONTROL_I:begin
                        control_i_sendback21  <= 1'b1;
                    end
                
                    CONTROL_II:begin
                        control_ii_sendback21 <= 1'b1;                
                    end
                
                    GATE:begin
                        gate_sendback21       <= 1'b1;
                    end
                endcase      
            end else if(start&&flag_scan&&flag_control_i&&flag_control_ii&&flag_gate&&(!flag_start)&&(!flag_start2)&&(!flag_start3))begin
                case(frame_addr)
                
                    SCAN:begin
                        flag_scan20       <= 1'b1; 
                    end
                
                    CONTROL_I:begin
                        flag_control_i20  <= 1'b1;
                    end
                
                    CONTROL_II:begin
                        flag_control_ii20 <= 1'b1;                
                    end
                
                    GATE:begin
                        flag_gate20       <= 1'b1;
                    end
                
                    SCAN_I:begin
                        flag_start21      <= 1'b1;    
                    end
                    
                    SCAN_II:begin
                        flag_start221      <= 1'b1;    
                    end
                
                    SCAN_III:begin
                        flag_start321      <= 1'b1;    
                    end
                    
                endcase    
            end
        end
    end
    
   
    pack_and_send_signal scan_signal(
        .u_signal       (u_scan_sendback),
        .clk            (clk),
    
        .signal         (scan_sendback)
    );
    
    pack_and_send_signal control_i_signal(
        .u_signal       (u_control_i_sendback),
        .clk            (clk),
    
        .signal         (control_i_sendback)
    );
    
    pack_and_send_signal control_ii_signal(
        .u_signal       (u_control_ii_sendback),
        .clk            (clk),
    
        .signal         (control_ii_sendback)
    );
    
    pack_and_send_signal gate_signal(
        .u_signal       (u_gate_sendback),
        .clk            (clk),
    
        .signal         (gate_sendback)
    );
    
    always@(posedge clk)begin
        if(reset)begin           
        
        end
        else if(!reset)begin  
            if(!flag_scan)begin
                nx_pix[15:8]        <= rx_frame_data0[7:0];
                nx_pix[7:0]         <= rx_frame_data1[7:0]; 
                ny_pix[15:8]        <= rx_frame_data2[7:0];
                ny_pix[7:0]         <= rx_frame_data3[7:0];      
                nx_min[15:8]        <= rx_frame_data4[7:0];
                nx_min[7:0]         <= rx_frame_data5[7:0]; 
                nx_max[15:8]        <= rx_frame_data6[7:0];
                nx_max[7:0]         <= rx_frame_data7[7:0];
                ny_min[15:8]        <= rx_frame_data8[7:0];
                ny_min[7:0]         <= rx_frame_data9[7:0];
                ny_max[15:8]        <= rx_frame_data10[7:0];
                ny_max[7:0]         <= rx_frame_data11[7:0];  
                pixel_time[31:24]   <= rx_frame_data12[7:0];
                pixel_time[23:16]   <= rx_frame_data13[7:0];
                pixel_time[15:8]    <= rx_frame_data14[7:0];
                pixel_time[7:0]     <= rx_frame_data15[7:0];               
            end else if(!flag_control_i)begin
                sig_start_frame[31:24]      <= rx_frame_data0[7:0];   
                sig_start_frame[23:16]      <= rx_frame_data1[7:0];
                sig_start_frame[15:8]       <= rx_frame_data2[7:0];
                sig_start_frame[7:0]        <= rx_frame_data3[7:0]; 
                duty_cycle_frame[15:8]      <= rx_frame_data4[7:0];
                duty_cycle_frame[7:0]       <= rx_frame_data5[7:0];
                sig_start_pixel[31:24]      <= rx_frame_data6[7:0];   
                sig_start_pixel[23:16]      <= rx_frame_data7[7:0];
                sig_start_pixel[15:8]       <= rx_frame_data8[7:0];
                sig_start_pixel[7:0]        <= rx_frame_data9[7:0]; 
                duty_cycle_pixel[15:8]      <= rx_frame_data10[7:0];
                duty_cycle_pixel[7:0]       <= rx_frame_data11[7:0];
                sig_start_laser[31:24]      <= rx_frame_data12[7:0];   
                sig_start_laser[23:16]      <= rx_frame_data13[7:0];
                sig_start_laser[15:8]       <= rx_frame_data14[7:0];
                sig_start_laser[7:0]        <= rx_frame_data15[7:0]; 
                duty_cycle_laser[15:8]      <= rx_frame_data16[7:0];
                duty_cycle_laser[7:0]       <= rx_frame_data17[7:0];
            end else if(!flag_control_ii)begin 
                frame_nums[7:0]             <= rx_frame_data16[7:0];
                pixel_nums[7:0]             <= rx_frame_data17[7:0]; 
                laser_nums[7:0]             <= rx_frame_data18[7:0];
                frame_period[63:56]         <= rx_frame_data0[7:0];
                frame_period[55:48]         <= rx_frame_data1[7:0];
                frame_period[47:40]         <= rx_frame_data2[7:0];
                frame_period[39:32]         <= rx_frame_data3[7:0];
                frame_period[31:24]         <= rx_frame_data4[7:0];
                frame_period[23:16]         <= rx_frame_data5[7:0];
                frame_period[15:8]          <= rx_frame_data6[7:0];
                frame_period[7:0]           <= rx_frame_data7[7:0];  
                pixel_period[31:24]         <= rx_frame_data8[7:0]; 
                pixel_period[23:16]         <= rx_frame_data9[7:0];
                pixel_period[15:8]          <= rx_frame_data10[7:0];
                pixel_period[7:0]           <= rx_frame_data11[7:0];  
                laser_period[31:24]         <= rx_frame_data12[7:0]; 
                laser_period[23:16]         <= rx_frame_data13[7:0];
                laser_period[15:8]          <= rx_frame_data14[7:0];
                laser_period[7:0]           <= rx_frame_data15[7:0]; 
            end else if(!flag_gate)begin
                i_cnt_value[7:0]            <= rx_frame_data0[7:0];
                i_cnt_value[15:8]           <= rx_frame_data1[7:0];
                spad_nums[7:0]              <= rx_frame_data2[7:0];
                sig_start_spad[31:24]       <= rx_frame_data3[7:0]; 
                sig_start_spad[23:16]       <= rx_frame_data4[7:0];
                sig_start_spad[15:8]        <= rx_frame_data5[7:0];
                sig_start_spad[7:0]         <= rx_frame_data6[7:0];
                duty_cycle_spad[15:8]       <= rx_frame_data7[7:0];
                duty_cycle_spad[7:0]        <= rx_frame_data8[7:0];
                spad_period[31:24]          <= rx_frame_data9[7:0];
                spad_period[23:16]          <= rx_frame_data10[7:0];
                spad_period[15:8]           <= rx_frame_data11[7:0];
                spad_period[7:0]            <= rx_frame_data12[7:0];
            end
         end
    end
    
    always@(posedge clk)begin
        flag_start_r    <= flag_start;  
        flag_start_r2   <= flag_start_r;
        flag_start_r3   <= flag_start_r2;
    
        if(flag_start21)begin
            flag_start      <= 1'b1;  
        end else if(flag_start_r3)begin
            flag_start  <= 1'b0;    
        end
    end
    
    always@(posedge clk)begin
        flag_start2_r    <= flag_start2;  
        flag_start2_r2   <= flag_start2_r;
        flag_start2_r3   <= flag_start2_r2;
    
        if(flag_start221)begin
            flag_start2      <= 1'b1;  
        end else if(flag_start2_r3)begin
            flag_start2  <= 1'b0;    
        end
    end
    
    always@(posedge clk)begin
        flag_start3_r    <= flag_start3;  
        flag_start3_r2   <= flag_start3_r;
        flag_start3_r3   <= flag_start3_r2;
    
        if(flag_start321)begin
            flag_start3      <= 1'b1;  
        end else if(flag_start3_r3)begin
            flag_start3  <= 1'b0;    
        end
    end
    
    assign flag_scan        = (flag_scan20)?1'b0:1'b1;
    assign flag_control_i   = (flag_control_i20)?1'b0:1'b1;
    assign flag_control_ii  = (flag_control_ii20)?1'b0:1'b1;
    assign flag_gate        = (flag_gate20)?1'b0:1'b1;
    
    wire flag_send;
    wire flag_send2;
    wire flag_send3;
    assign flag_send  = flag_scan&flag_control_i&flag_control_ii&flag_gate&flag_start;
    assign flag_send2 = flag_scan&flag_control_i&flag_control_ii&flag_gate&flag_start2;
    assign flag_send3 = flag_scan&flag_control_i&flag_control_ii&flag_gate&flag_start3;
    
    wire       scan_tx_crc_din_vld;
    wire [7:0] scan_tx_crc_din;
    wire [7:0] scan_tx_crc_dout;
    wire       scan_tx_crc_done;  
    
    wire       control_i_tx_crc_din_vld;
    wire [7:0] control_i_tx_crc_din;
    wire [7:0] control_i_tx_crc_dout;
    wire       control_i_tx_crc_done;      

    wire       control_ii_tx_crc_din_vld;
    wire [7:0] control_ii_tx_crc_din;
    wire [7:0] control_ii_tx_crc_dout;
    wire       control_ii_tx_crc_done;
    
    wire       gate_tx_crc_din_vld;
    wire [7:0] gate_tx_crc_din;
    wire [7:0] gate_tx_crc_dout;
    wire       gate_tx_crc_done;
            
    wire [7:0] wr_data;
    wire [7:0] scan_wr_data;
    wire [7:0] control_i_wr_data;
    wire [7:0] control_ii_wr_data;
    wire [7:0] gate_wr_data;
    
    
    uart_scan_pack uart_scan_pack_inst(
	   .clk                (clk_50m),
	   .enable             (scan_sendback),
	   .reset              (reset),

        //与uart_send交互的信号
        .wr_en             (scan_wr_en),
        .wr_data           (scan_wr_data[7:0]),

	    //.tx_frame_vld      (),    
	    .tx_frame_data0    (nx_pix[15:8]),	
	    .tx_frame_data1    (nx_pix[7:0]),	
	    .tx_frame_data2    (ny_pix[15:8]),	
	    .tx_frame_data3    (ny_pix[7:0]),	
	    .tx_frame_data4    (nx_min[15:8]),	
	    .tx_frame_data5    (nx_min[7:0]),	
	    .tx_frame_data6    (nx_max[15:8]),	
	    .tx_frame_data7    (nx_max[7:0]),
	    .tx_frame_data8    (ny_min[15:8]),
	    .tx_frame_data9    (ny_min[7:0]),
	    .tx_frame_data10   (ny_max[15:8]),
	    .tx_frame_data11   (ny_max[7:0]),
	    .tx_frame_data12   (pixel_time[31:24]),
	    .tx_frame_data13   (pixel_time[23:16]),
	    .tx_frame_data14   (pixel_time[15:8]),
	    .tx_frame_data15   (pixel_time[7:0]),
	    .tx_frame_data16   (8'hf0),	
	    .tx_frame_data17   (8'hf0),
	    .tx_frame_data18   (8'hf0),
	    .tx_frame_data19   (8'hf0),
	    .tx_frame_data20   (8'hf0),
	    .tx_frame_data21   (8'hf0),
	    .tx_frame_data22   (8'hf0),
	    .tx_frame_data23   (8'hf0),
	    .tx_frame_data24   (8'hf0),
	    .tx_frame_data25   (8'hf0),
	    
        //与crc8_d8_tx模块交互信号
	    .tx_crc_din_vld    (scan_tx_crc_din_vld),  //输出待校验的数据有效 
	    .tx_crc_din        (scan_tx_crc_din[7:0]),      //输出待校验的数据 
	    .tx_crc_dout       (scan_tx_crc_dout[7:0]), 	//输入经过CRC模块校验后的数据
	    .tx_crc_done	   (scan_tx_crc_done)//一帧CRC校验完成				
    );
    
    uart_control_i_pack uart_control_i_pack_inst(
	   .clk                (clk_50m),
	   .enable             (control_i_sendback),
	   .reset              (reset),

        //与uart_send交互的信号
        .wr_en             (control_i_wr_en),
        .wr_data           (control_i_wr_data[7:0]),

	    //.tx_frame_vld      (),    
	    .tx_frame_data0    (sig_start_frame[31:24]),	
	    .tx_frame_data1    (sig_start_frame[23:16]),	
	    .tx_frame_data2    (sig_start_frame[15:8] ),	
	    .tx_frame_data3    (sig_start_frame[7:0]  ),	
	    .tx_frame_data4    (duty_cycle_frame[15:8]),	
	    .tx_frame_data5    (duty_cycle_frame[7:0] ),	
	    .tx_frame_data6    (sig_start_pixel[31:24]),	
	    .tx_frame_data7    (sig_start_pixel[23:16]),
	    .tx_frame_data8    (sig_start_pixel[15:8] ),
	    .tx_frame_data9    (sig_start_pixel[7:0]  ),
	    .tx_frame_data10   (duty_cycle_pixel[15:8]),
	    .tx_frame_data11   (duty_cycle_pixel[7:0] ),
	    .tx_frame_data12   (sig_start_laser[31:24]),
	    .tx_frame_data13   (sig_start_laser[23:16]),
	    .tx_frame_data14   (sig_start_laser[15:8] ),
	    .tx_frame_data15   (sig_start_laser[7:0]  ),
	    .tx_frame_data16   (duty_cycle_laser[15:8]),
	    .tx_frame_data17   (duty_cycle_laser[7:0] ),
	    .tx_frame_data18   (8'hf0),
	    .tx_frame_data19   (8'hf0),
	    .tx_frame_data20   (8'hf0),
	    .tx_frame_data21   (8'hf0),
	    .tx_frame_data22   (8'hf0),
	    .tx_frame_data23   (8'hf0),
	    .tx_frame_data24   (8'hf0),
	    .tx_frame_data25   (8'hf0),

        //与crc8_d8_tx模块交互信号
	    .tx_crc_din_vld    (control_i_tx_crc_din_vld),  //输出待校验的数据有效 
	    .tx_crc_din        (control_i_tx_crc_din[7:0]),      //输出待校验的数据 
	    .tx_crc_dout       (control_i_tx_crc_dout[7:0]), 	//输入经过CRC模块校验后的数据
	    .tx_crc_done	   (control_i_tx_crc_done)//一帧CRC校验完成	
	    			
    );
    
    uart_control_ii_pack uart_control_ii_pack_inst(
	   .clk                (clk_50m),
	   .enable             (control_ii_sendback),
	   .reset              (reset),

        //与uart_send交互的信号
        .wr_en             (control_ii_wr_en),
        .wr_data           (control_ii_wr_data[7:0]),

	    //.tx_frame_vld      (),    
	    .tx_frame_data0    (frame_period[63:56]),	
	    .tx_frame_data1    (frame_period[55:48]),	
	    .tx_frame_data2    (frame_period[47:40]),	
	    .tx_frame_data3    (frame_period[39:32]),	
	    .tx_frame_data4    (frame_period[31:24]),	
	    .tx_frame_data5    (frame_period[23:16]),	
	    .tx_frame_data6    (frame_period[15:8] ),	
	    .tx_frame_data7    (frame_period[7:0]  ),
	    .tx_frame_data8    (pixel_period[31:24]),
	    .tx_frame_data9    (pixel_period[23:16]),
	    .tx_frame_data10   (pixel_period[15:8] ),
	    .tx_frame_data11   (pixel_period[7:0]  ),
	    .tx_frame_data12   (laser_period[31:24]),
	    .tx_frame_data13   (laser_period[23:16]),
	    .tx_frame_data14   (laser_period[15:8] ),
	    .tx_frame_data15   (laser_period[7:0]  ),
	    .tx_frame_data16   (frame_nums[7:0]    ),
	    .tx_frame_data17   (pixel_nums[7:0]    ),
	    .tx_frame_data18   (laser_nums[7:0]    ),
	    .tx_frame_data19   (8'hf0),
	    .tx_frame_data20   (8'hf0),
	    .tx_frame_data21   (8'hf0),
	    .tx_frame_data22   (8'hf0),
	    .tx_frame_data23   (8'hf0),
	    .tx_frame_data24   (8'hf0),
	    .tx_frame_data25   (8'hf0),

        //与crc8_d8_tx模块交互信号
	    .tx_crc_din_vld    (control_ii_tx_crc_din_vld),  //输出待校验的数据有效 
	    .tx_crc_din        (control_ii_tx_crc_din[7:0]),      //输出待校验的数据 
	    .tx_crc_dout       (control_ii_tx_crc_dout[7:0]), 	//输入经过CRC模块校验后的数据
	    .tx_crc_done	   (control_ii_tx_crc_done)//一帧CRC校验完成	
    			
    );
    
    uart_gate_pack uart_gate_pack_inst(
	   .clk                (clk_50m),
	   .enable             (gate_sendback),
	   .reset              (reset),

        //与uart_send交互的信号
        .wr_en             (gate_wr_en),
        .wr_data           (gate_wr_data[7:0]),

	    //.tx_frame_vld      (),    
	    .tx_frame_data0    (i_cnt_value[7:0]),	
	    .tx_frame_data1    (i_cnt_value[15:8]),	
	    .tx_frame_data2    (spad_nums[7:0]),	
	    .tx_frame_data3    (sig_start_spad[31:24]),	
	    .tx_frame_data4    (sig_start_spad[23:16]),	
	    .tx_frame_data5    (sig_start_spad[15:8] ),	
	    .tx_frame_data6    (sig_start_spad[7:0]  ),	
	    .tx_frame_data7    (duty_cycle_spad[15:8]),
	    .tx_frame_data8    (duty_cycle_spad[7:0] ),
	    .tx_frame_data9    (spad_period[31:24]   ),
	    .tx_frame_data10   (spad_period[23:16]   ),
	    .tx_frame_data11   (spad_period[15:8]    ),
	    .tx_frame_data12   (spad_period[7:0]     ),
	    .tx_frame_data13   (8'hf0),
	    .tx_frame_data14   (8'hf0),
	    .tx_frame_data15   (8'hf0),
	    .tx_frame_data16   (8'hf0),
	    .tx_frame_data17   (8'hf0),
	    .tx_frame_data18   (8'hf0),
	    .tx_frame_data19   (8'hf0),
	    .tx_frame_data20   (8'hf0),
	    .tx_frame_data21   (8'hf0),
	    .tx_frame_data22   (8'hf0),
	    .tx_frame_data23   (8'hf0),
	    .tx_frame_data24   (8'hf0),
	    .tx_frame_data25   (8'hf0),

        //与crc8_d8_tx模块交互信号
	    .tx_crc_din_vld    (gate_tx_crc_din_vld),  //输出待校验的数据有效 
	    .tx_crc_din        (gate_tx_crc_din[7:0]),      //输出待校验的数据 
	    .tx_crc_dout       (gate_tx_crc_dout[7:0]), 	//输入经过CRC模块校验后的数据
	    .tx_crc_done	   (gate_tx_crc_done)//一帧CRC校验完成	
	    	
    );
        
    top_scan u_top_scan(
        .clk                (clk_50m),
        .clk_100m           (clk),
        .reset              (reset),
        .nx_pix             (nx_pix),
        .ny_pix             (ny_pix),
        .pixel_time         (pixel_time),
        .nx_min             (nx_min),
        .nx_max             (nx_max),
        .ny_min             (ny_min),
        .ny_max             (ny_max),
        .send_en            (flag_send),
        .send_en2           (flag_send2),
        .send_en3           (flag_send3),

        .sendck             (sendck),
        .sync               (sync),
        .chl_x              (chl_x),
        .chl_y              (chl_y),     
        .txdone             (txdone),      
        .xy2_state          (xy2_state),
        .xy2_send           (xy2_send) 
    );
    
    top_signal u_top_signal(
        .sys_clk_100M           (clk),
        .clk_200m               (clk_out_200m),
        .clk_400m               (clk_out_400m),
        .clk_500m               (clk_out_500m),
        .reset                  (reset),
        .laser_trigger          (laser_trigger_out),
        .txdone                 (txdone),
        .frame_nums             (frame_nums),
        .pixel_nums             (pixel_nums),
        .laser_nums             (laser_nums),
        .spad_nums              (spad_nums),
        .i_cnt_value            (i_cnt_value[8:0]),
        .sig_start_frame        (sig_start_frame),
        .duty_cycle_frame       (duty_cycle_frame), 
        .sig_start_pixel        (sig_start_pixel),
        .duty_cycle_pixel       (duty_cycle_pixel),   
        .sig_start_laser        (sig_start_laser),
        .duty_cycle_laser       (duty_cycle_laser),
        .sig_start_spad         (sig_start_spad),
        .duty_cycle_spad        (duty_cycle_spad),
        .frame_period           (frame_period),
        .pixel_period           (pixel_period),
        .laser_period           (laser_period),
        .spad_period            (spad_period),
        
        .frame                  (frame),       
        .pixel                  (pixel),   
        .laser                  (laser),
        .spad                   (spad),
        .spad_fine              (spad_fine)
    );  
    
    assign  u_laser       =  ~laser;
    assign  u_spad        =  ~spad;
    assign  u_spad_fine   =  ~spad_fine;
    
    crc8_d8 crc8_d8_rx
		(
			.clk         (clk_50m),
			.reset       (reset),

			.crc_din_vld (rx_crc_din_vld),
			.crc_din     (rx_crc_din),
			.crc_dout    (rx_crc_dout),
			.crc_done    (rx_crc_done)
		);
		
    crc8_d8 scan_tx
		(
			.clk         (clk_50m),
			.reset       (reset),

			.crc_din_vld (scan_tx_crc_din_vld),
			.crc_din     (scan_tx_crc_din[7:0]),
			.crc_dout    (scan_tx_crc_dout[7:0]),
			.crc_done    (scan_tx_crc_done)
		);	
		
    crc8_d8 control_i_tx
		(
			.clk         (clk_50m),
			.reset       (reset),

			.crc_din_vld (control_i_tx_crc_din_vld),
			.crc_din     (control_i_tx_crc_din[7:0]),
			.crc_dout    (control_i_tx_crc_dout[7:0]),
			.crc_done    (control_i_tx_crc_done)
		);	
		
    crc8_d8 control_ii_tx
		(
			.clk         (clk_50m),
			.reset       (reset),

			.crc_din_vld (control_ii_tx_crc_din_vld),
			.crc_din     (control_ii_tx_crc_din[7:0]),
			.crc_dout    (control_ii_tx_crc_dout[7:0]),
			.crc_done    (control_ii_tx_crc_done)
		);	
		
    crc8_d8 gate_tx
		(
			.clk         (clk_50m),
			.reset       (reset),

			.crc_din_vld (gate_tx_crc_din_vld),
			.crc_din     (gate_tx_crc_din[7:0]),
			.crc_dout    (gate_tx_crc_dout[7:0]),
			.crc_done    (gate_tx_crc_done)
		);				
    
    mux send_mux(
        .clk                    (clk),
        .reset                  (reset),
        .select_scan            (scan_wr_en),
        .select_control_i       (control_i_wr_en),
        .select_control_ii      (control_ii_wr_en),
        .select_gate            (gate_wr_en),
        .scan_wr_en             (scan_wr_en),
        .scan_wr_data           (scan_wr_data[7:0]),
        .control_i_wr_en        (control_i_wr_en),
        .control_i_wr_data      (control_i_wr_data[7:0]),
        .control_ii_wr_en       (control_ii_wr_en),
        .control_ii_wr_data     (control_ii_wr_data[7:0]),
        .gate_wr_en             (gate_wr_en),
        .gate_wr_data           (gate_wr_data[7:0]),
        
        .wr_en                  (wr_en),
		.wr_data                (wr_data[7:0])
    );
    
    uart_send u_uart_send(
		.clk                  (clk_50m),
		.reset                (reset),

		.wr_en                (wr_en),
		.wr_data              (wr_data),

		.uart_tx_en           (uart_tx_en),
		.uart_tx_data         (uart_tx_data[7:0]),
		.uart_tx_busy         (uart_tx_busy)
    );  
    
    
    always @(posedge clk)begin
        frame_r     <= frame;
        frame_r2    <= frame_r;
        
        if(reset)begin
            flag_led    <=  1'b0;
        end else if(frame_r && (!frame_r2))begin
            flag_led    <=  ~flag_led;
        end else begin flag_led <= flag_led; end
    end
    
    ila_0 your_instance_name (
	   .clk(clk), // input wire clk


	   .probe0(start), // input wire [0:0]  probe0  
	   .probe1(flag_send), // input wire [0:0]  probe1 
	   .probe2(u_top_scan.mux_inst.clk), // input wire [0:0]  probe2 
	   .probe3(clk_out_200m), // input wire [0:0]  probe3 
	   .probe4(u_top_scan.mux_inst.send_en_r), // input wire [0:0]  probe4 
	   .probe5(u_top_scan.mux_inst.send_en2_r), // input wire [0:0]  probe5 
	   .probe6(u_top_scan.mux_inst.send_en3_r), // input wire [0:0]  probe6 
	   .probe7(frame), // input wire [0:0]  probe7
	   .probe8(clk), // input wire [7:0]  probe8
	   .probe9(u_top_scan.mux_inst.select),//2
	   .probe10(u_top_scan.mux_inst.send_en),
	   .probe11(u_top_scan.mux_inst.send_en2),
	   .probe12(u_top_scan.mux_inst.send_en3)
    );
      
endmodule
