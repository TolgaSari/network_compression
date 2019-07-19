`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/10/2019 01:04:53 PM
// Design Name: 
// Module Name: top
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


module top(
    input clk_i,
    input rstn_i,
    input mem_mode,
    input [1:0] oper_mode, // input bias, input image, do forward pass
    input [31:0] pkt_in,
    input valid_i,
    
    input [7:0] img_in,
    
    output fifo_ready_o
    );
    
io_generic_fifo input_fifo (
   // Input Ports - Single Bit
   .clk_i           (clk_i),        
   .clr_i           (1'b0),        
   .ready_i         (1'b0),      
   .rstn_i          (rstn_i),       
   .valid_i         (valid_i),      
   // Input Ports - Busses
   .data_i    (pkt_in[31:0]), 
   // Output Ports - Single Bit
   .ready_o         (fifo_ready_o),      
   .valid_o         (valid_o),      
   // Output Ports - Busses
   .data_o    (data_o), 
   .elements_o (elements_o)
   // InOut Ports - Single Bit
   // InOut Ports - Busses
);
    
endmodule
