`timescale 1ns / 1ps



module top_scan(
    input   wire            clk,
    input   wire            clk_100m,
    input   wire            reset,
    input   wire   [15:0]   nx_pix,
    input   wire   [15:0]   ny_pix,
    input   wire   [31:0]   pixel_time,
    input   wire   [15:0]   nx_min,
    input   wire   [15:0]   nx_max,
    input   wire   [15:0]   ny_min,
    input   wire   [15:0]   ny_max,
    input   wire            send_en,
    input   wire            send_en2,
    input   wire            send_en3,

    output  wire            sendck,
    output  wire            sync,
    output  wire            chl_x,
    output  wire            chl_y,
    output  wire            txdone,
    output  wire            xy2_state,
    output  wire            xy2_send
    );
    

    wire [15:0] x_coord;
    wire [15:0] y_coord;
    
    wire [15:0] x_coord_1;
    wire [15:0] y_coord_1;
    wire       xy2_send_1;       
    wire [15:0] x_coord_2;
    wire [15:0] y_coord_2;
    wire       xy2_send_2;
    wire [15:0] x_coord_3;
    wire [15:0] y_coord_3;
    wire       xy2_send_3;
    
    
    
    
    
    xy2_100 u_xy2_100(
    //port list
        .rst_n                  (~reset),
        .clk50m                 (clk),
        .send_en                (xy2_send),
        .x_data                 (x_coord),
        .y_data                 (y_coord),
        
 
        .sendck                 (sendck),
        .sync                   (sync),
        .chl_x                  (chl_x),
        .chl_y                  (chl_y),
        .txdone                 (txdone),
        .xy2_state              (xy2_state)
    ); 
    
    scan   scan_inst(
        .clk                    (clk),                 
        .reset                  (reset),             
        .start_scan             (send_en),         
        .nx_pix                 (nx_pix),    
        .ny_pix                 (ny_pix),    
        .nx_min                 (nx_min),
        .nx_max                 (nx_max),
        .ny_min                 (ny_min),
        .ny_max                 (ny_max),
        .flag_duration          (pixel_time), 
        .x_coord                (x_coord_1),   
        .y_coord                (y_coord_1),    
        .xy2_send               (xy2_send_1)
    );    
    
    scan2   scan2_inst(
        .clk                    (clk),                 
        .reset                  (reset),             
        .start_scan             (send_en2),         
        .nx_pix                 (nx_pix),    
        .ny_pix                 (ny_pix),    
        .nx_min                 (nx_min),
        .nx_max                 (nx_max),
        .ny_min                 (ny_min),
        .ny_max                 (ny_max),
        .flag_duration          (pixel_time), 
        .x_coord                (x_coord_2),   
        .y_coord                (y_coord_2),    
        .xy2_send               (xy2_send_2)
    );
    
    scan3   scan3_inst(
        .clk                    (clk),                 
        .reset                  (reset),             
        .start_scan             (send_en3),         
        .nx_pix                 (nx_pix),    
        .ny_pix                 (ny_pix),    
        .nx_min                 (nx_min),
        .nx_max                 (nx_max),
        .ny_min                 (ny_min),
        .ny_max                 (ny_max),
        .flag_duration          (pixel_time), 
        .x_coord                (x_coord_3),   
        .y_coord                (y_coord_3),    
        .xy2_send               (xy2_send_3)
    );
    
    mux_scan     mux_inst(
        .clk                    (clk),
        .clk_100m               (clk_100m),
        .reset                  (reset), 
        .send_en                (send_en),
        .send_en2               (send_en2),
        .send_en3               (send_en3),
        .x_coord_1              (x_coord_1),
        .y_coord_1              (y_coord_1),
        .xy2_send_1             (xy2_send_1),
        .x_coord_2              (x_coord_2),
        .y_coord_2              (y_coord_2),
        .xy2_send_2             (xy2_send_2),
        .x_coord_3              (x_coord_3),
        .y_coord_3              (y_coord_3),
        .xy2_send_3             (xy2_send_3),
        
        .x_coord                (x_coord),
        .y_coord                (y_coord),
        .xy2_send               (xy2_send)
    );   
    
    
    
endmodule


