module flag_counter(
    input  wire        start,          
    input  wire [31:0] sig_period,
    input  wire        clk,
    
    output wire        ref_signal      
    );
    
    reg            reset   =  1'b0; 
    reg          reset_r   =  1'b0;     
    reg   [31:0]     cnt   =  32'd0;
    reg          start_r   =  1'b0;
    reg       flag_start   =  1'b0;
    reg     ref_signal_r   =  1'b0;
    reg     ref_signal_r2  =  1'b0;
    
    always@(posedge clk)begin
        start_r <= start;
        if(reset)begin
            flag_start <= 1'b0; 
        end if(!start_r && start)begin
            flag_start <= 1'b1;
        end else begin end
    end
    
    
    always@(posedge clk)begin
        ref_signal_r2 <= ref_signal_r;

        if(reset)begin
            cnt          <= 0;
        end else if(ref_signal_r2)begin
            ref_signal_r <= 1'b0;
        end else if(flag_start && (cnt==1'b0)) begin
            cnt          <= sig_period;
        end else if(flag_start && (cnt==3'd4)) begin
            cnt          <= cnt - 1;
            ref_signal_r <= 1'b1;
        end else if(flag_start && (cnt==1'b1)) begin
            cnt          <= cnt - 1;
        end else if(flag_start) begin
            cnt <= cnt - 1;
        end else cnt <= cnt;   
    end
    
    always@(posedge clk)begin
        reset_r <= reset;

        if(reset_r)begin
            reset <= 1'b0;
        end else if(flag_start && (cnt==2'd2)) begin
            reset <= 1'b1;
        end else begin

        end
    end

    assign  ref_signal     = ref_signal_r;
    
endmodule