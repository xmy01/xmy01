`timescale 1ns / 1ps

module mux_scan(
        input   wire        clk,   
        input   wire        clk_100m,                 
        input   wire        reset,                  
        input   wire        send_en,            
        input   wire        send_en2,      
        input   wire        send_en3,             
        input   wire        xy2_send_1,            
        input   wire [15:0] x_coord_1,         
        input   wire [15:0] y_coord_1,      
        input   wire        xy2_send_2,    
        input   wire [15:0] x_coord_2,  
        input   wire [15:0] y_coord_2,    
        input   wire        xy2_send_3,           
        input   wire [15:0] x_coord_3, 
        input   wire [15:0] y_coord_3,        
        
        output  wire        xy2_send,                
	    output  wire [15:0] x_coord,
	    output  wire [15:0] y_coord               
    );
    
    reg             xy2_send_r  = 1'b0;
    reg     [15:0]  x_coord_r   = 16'h0000;
    reg     [15:0]  y_coord_r   = 16'h0000;
    reg             send_en_r   = 1'b0;
    reg             send_en2_r  = 1'b0;
    reg             send_en3_r  = 1'b0;
    reg             send_en_r2   = 1'b0;
    reg             send_en2_r2  = 1'b0;
    reg             send_en3_r2  = 1'b0;
    reg     [1:0]   select  = 2'b0;
    
    always @(posedge clk)begin
        send_en_r    <=  send_en;  
        send_en_r2    <=  send_en_r;  
        send_en2_r   <=  send_en2;
        send_en2_r2   <=  send_en2_r;
        send_en3_r   <=  send_en3;
        send_en3_r2   <=  send_en3_r;
    end    
        
    always @(posedge clk)begin
        if(send_en&&(!send_en_r2))begin
            select  <=  2'b01;                                
        end else if(send_en2&&(!send_en2_r2))begin
            select  <=  2'b10;    
        end else if(send_en3&&(!send_en3_r2))begin
            select  <=  2'b11;
        end else begin select  <=  select; end
    end
    
    always @(posedge clk)begin
        case(select) 
            2'b01 :begin
                    xy2_send_r   <= xy2_send_1;
                    x_coord_r    <= x_coord_1;  
                    y_coord_r    <= y_coord_1; 
                   end
            2'b10 :begin
                    xy2_send_r   <= xy2_send_2;
                    x_coord_r    <= x_coord_2;  
                    y_coord_r    <= y_coord_2;                
                   end
            2'b11 :begin
                    xy2_send_r   <= xy2_send_3;
                    x_coord_r    <= x_coord_3;  
                    y_coord_r    <= y_coord_3;                
                   end
            default:begin
                    xy2_send_r   <= 1'b0;
                    x_coord_r    <= 16'h0000;  
                    y_coord_r    <= 16'h0000;          
            end
        endcase        
    end
    
    assign  xy2_send   =   xy2_send_r;
    assign  x_coord    =   x_coord_r; 
    assign  y_coord    =   y_coord_r;
       
endmodule
