`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/11/2019 12:25:47 PM
// Design Name: 
// Module Name: test_multiplier
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


module test_multiplier
#( 
   parameter FIXED_IN1  = 6,
   parameter FIXED_IN2  = 12,
   parameter FIXED_OUT = 12,
   parameter DATA_WIDTH_IN_1 = 8,
   parameter DATA_WIDTH_IN_2 = 16,
   parameter DATA_WIDTH_OUT = 16
  )();
  
  reg [DATA_WIDTH_IN_1 - 1: 0] input1;
  reg [DATA_WIDTH_IN_2 - 1: 0] input2;
  wire [DATA_WIDTH_OUT - 1: 0] output1;
  
  localparam PERIOD = 125;
  
  multiplier uut(.num1(input1),
                 .num2(input2),
                 .result(output1));
  initial
  begin
    input1 = 8'b00_100000; input2 = 16'b0001_000000_000000; #PERIOD;
    input1 = 8'b00_010000; input2 = 16'b0001_000000_000000; #PERIOD;
    input1 = 8'b11_100000; input2 = 16'b0101_000000_000000; #PERIOD;
    input1 = 8'b11_110000; input2 = 16'b0101_000000_000000; #PERIOD;
    input1 = 8'b11_100000; input2 = 16'b1001_000000_000000; #PERIOD;
    input1 = 8'b00_110000; input2 = 16'b0011_000000_000000; #PERIOD;
    input1 = 8'b11_111100; input2 = 16'b1101_000000_111111; #PERIOD;
    input1 = 8'b11_110000; input2 = 16'b1101_111011_110111; #PERIOD;
  end
endmodule
