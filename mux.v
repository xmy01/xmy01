`timescale 1ns / 1ps

module mux(
        input   wire        clk                 ,                    
        input   wire        reset               ,                  
        input   wire        select_scan         ,            
        input   wire        select_control_i    ,      
        input   wire        select_control_ii   ,     
        input   wire        select_gate         ,          
        input   wire        scan_wr_en          ,            
        input   wire  [7:0] scan_wr_data        ,         
        input   wire        control_i_wr_en     ,      
        input   wire  [7:0] control_i_wr_data   ,    
        input   wire        control_ii_wr_en    ,  
        input   wire  [7:0] control_ii_wr_data  ,    
        input   wire        gate_wr_en          ,           
        input   wire  [7:0] gate_wr_data        ,         
        
        output  wire        wr_en               ,                
	    output  wire  [7:0] wr_data               
    );

    reg [7:0]   wr_data_r = 8'b0;
    reg         wr_en_r   = 1'b0;
    
    wire [2:0] select;
    assign select = (select_scan)?3'b000:(select_control_i)?3'b001:(select_control_ii)?3'b010:(select_gate)?3'b011:3'b100; 
    
    always @(posedge clk)begin
        case(select) 
            3'b000 :begin
                    wr_data_r  <= scan_wr_data;
                    wr_en_r    <= scan_wr_en;       
                   end
            3'b001 :begin
                    wr_data_r  <= control_i_wr_data;
                    wr_en_r    <= control_i_wr_en;               
                   end
            3'b010 :begin
                    wr_data_r  <= control_ii_wr_data;
                    wr_en_r    <= control_ii_wr_en;               
                   end
            3'b011 :begin
                    wr_data_r  <= gate_wr_data;
                    wr_en_r    <= gate_wr_en;               
                   end
            default:begin
                    wr_data_r  <= 8'h0;
                    wr_en_r    <= 1'b0;        
            end
        endcase
    end

    assign wr_data = wr_data_r;
    assign wr_en   = wr_en_r;

endmodule
