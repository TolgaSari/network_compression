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


module mul_stage
 #(
    parameter ADDR_WIDTH = 12,
    parameter DATA_WIDTH = 16,
    parameter NUM_WORDS  = 5
  )(
    // To previous stage
    input [11:0] col_i,
    input [15:0] value_i,
    input [ 7:0] weight_i, 
    input valid_i,
    output reg valid_o,
    output ready_o,
    
    // To cntrl
    input clk_i,
    input rstn_i,
    
    output [27:0] data_o
    
    );
    
    wire [11:0] col_to;
    wire [15:0] value_to;
    wire [ 7:0] weight_to;
    
    reg [7:0] num1;
    reg [15:0] num2;
    //reg [27:0] acc_pkt_reg;
    reg [11:0]col_o;
    reg ready;
    
    
    wire fifo_valid;
    wire [15:0] result_o;
    
    io_generic_fifo
    #(  .DATA_WIDTH(36),
        .BUFFER_DEPTH(16)
        //.LOG_BUFFER_DEPTH($clog2(BUFFER_DEPTH))
    ) mul_fifo (
    // Input Ports - Single Bit
    .clk_i           (clk_i),        
    .clr_i           (1'b0),        
    .ready_i         (ready),      
    .rstn_i          (rstn_i),       
    .valid_i         (valid_i),      
    // Input Ports - Busses
    .data_i    ({col_i,value_i,weight_i}), 
    // Output Ports - Single Bit
    .ready_o         (ready_o),      
    .valid_o         (fifo_valid),      
    // Output Ports - Busses
    .data_o    ({col_to,value_to,weight_to})
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
       .result   (result_o)
    );

assign data_o = {col_o,result_o};

always@(posedge clk_i)
begin
    if(ready_o && fifo_valid)
    begin
        ready <= 1;
        num1 <= weight_to;
        num2 <= value_to;
        col_o <= col_to;
        valid_o <= 1;
    end
    else
    begin
        ready <= 0;
        num1 <= 0;
        num2 <= 0;
        col_o <= 0;
        valid_o <= 0;
    end
end

endmodule
