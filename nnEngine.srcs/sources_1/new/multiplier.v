`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/11/2019 02:45:16 AM
// Design Name: 
// Module Name: multiplier
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
// 00.100000 = 0.5       => 0000.100000_000000
// 11.100000 = - 0.5     => 1111.100000_111111 => 0000.011111_000001

`define GREEDY_QUANTIZATION

module multiplier
#( 
   parameter FIXED_IN1  = 6,
   parameter FIXED_IN2  = 12,
   parameter FIXED_OUT = 12,
   parameter DATA_WIDTH_IN_1 = 8,
   parameter DATA_WIDTH_IN_2 = 16,
   parameter DATA_WIDTH_OUT = 16
  )
 (
    input signed [DATA_WIDTH_IN_1-1:0] num1,
    input signed [DATA_WIDTH_IN_2-1:0] num2,
    output signed [DATA_WIDTH_OUT-1:0] result
 );
    wire signed [DATA_WIDTH_IN_2-1:0] extended_num1;
    wire signed [2*DATA_WIDTH_IN_2-1:0] temp;
    
    `ifdef GREEDY_QUANTIZATION
    assign extended_num1 = ({{5{num1[6]}}, num1[6:0], {4{1'b0}}});
    `else
    assign extended_num1 = {{3{num1[6]}}, num1[6:0], {6{1'b0}}};
    `endif
    localparam temp_hi = DATA_WIDTH_OUT + FIXED_OUT - 1;
    localparam temp_low = FIXED_OUT;
    
    assign temp = extended_num1 * num2;
    
    //assign result = {temp[DATA_WIDTH_OUT-1],temp[temp_hi: temp_low]};
    assign result = temp[27:FIXED_OUT];
endmodule
