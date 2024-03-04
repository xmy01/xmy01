`timescale 1ns / 1ps

module pack_and_send_signal(
    input  wire u_signal,
    input  wire clk,
    
    output reg signal
    );
    
    reg         signal_r    = 1'b0;  
    reg         start       = 1'b0;
    reg  [31:0] cnt         = 32'b0;
    reg         signal_r2   = 1'b0;
    reg         signal_r3   = 1'b0;
    reg         signal_r4   = 1'b0;
    reg         u_signal_r  = 1'b0;
    reg         u_signal_r2 = 1'b0;
        
    always @(posedge clk)begin
        signal_r2    <= signal_r; 
        signal_r3    <= signal_r2;
        signal_r4    <= signal_r3;
        
        u_signal_r   <= u_signal;
        u_signal_r2  <= u_signal_r;
        
        if(u_signal_r&&(!u_signal_r2))begin
            start    <= 1'b1;    
        end else if(signal_r4)begin
            signal_r <= 1'b0;    
        end else if(start&&(cnt < 32'd300_000))begin
            cnt      <= cnt + 1'b1;  
            signal_r <= 1'b0;  
        end else if(cnt == 32'd300_000)begin
            cnt      <= 32'h0;    
            signal_r <= 1'b1;
            start    <= 1'b0;
        end
    end
    
    always @(posedge clk)begin
        signal  <=  signal_r; 
    end
    
endmodule
