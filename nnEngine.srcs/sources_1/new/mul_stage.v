`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/19/2019 04:34:00 PM
// Design Name: 
// Module Name: mul_stage
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module mul_stage(
    // To previous stage
    input [35:0] mul_pkt_i,
    
    input valid_i,
    output reg valid_o,
    output ready_o,
    
    // To cntrl
    input clk_i,
    input rstn_i,
    
    output [27:0]acc_pkt_o
    
    
    );
    
    reg [7:0] num1;
    reg [15:0] num2;
    reg [27:0] acc_pkt_reg;
    
    wire [35:0] data_o;
    wire fifo_valid;
    
    io_generic_fifo
    #(  .DATA_WIDTH(36),
        .BUFFER_DEPTH(16)
        //.LOG_BUFFER_DEPTH($clog2(BUFFER_DEPTH))
    ) input_fifo (
    // Input Ports - Single Bit
    .clk_i           (clk_i),        
    .clr_i           (1'b0),        
    .ready_i         (1'b0),      
    .rstn_i          (rstn_i),       
    .valid_i         (valid_i),      
    // Input Ports - Busses
    .data_i    (mul_pkt_i), 
    // Output Ports - Single Bit
    .ready_o         (ready_o),      
    .valid_o         (fifo_valid),      
    // Output Ports - Busses
    .data_o    (data_o)
    //.elements_o ()
    // InOut Ports - Single h
    // InOut Ports - Busses
    );

    multiplier multiplier_inst (
       // Input Ports - Single Bit
       // Input Ports - Busses
       .num1    (num1), 
       .num2    (num2),
       // Output Ports - Single Bit
       // Output Ports - Busses
       .result   (acc_pkt_o[27:12])
    );

always@(posedge clk_i)
begin
    if(ready_o && fifo_valid)
    begin
        num1 <= data_o[35:20];
        num2 <= data_o[19:12];
        acc_pkt_reg <= data_o[11:0];
        valid_o <= 1;
    end
    else
    begin
        num1 <= 0;
        num2 <= 0;
        acc_pkt_reg <= 0;
        valid_o <= 0;
    end
end

endmodule
