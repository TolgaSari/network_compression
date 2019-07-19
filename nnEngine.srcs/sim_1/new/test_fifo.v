`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/10/2019 01:28:16 PM
// Design Name: 
// Module Name: test_fifo
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


module test_fifo
#(
    parameter DATA_WIDTH = 32,
    parameter BUFFER_DEPTH = 100000,
    parameter LOG_BUFFER_DEPTH = $clog2(BUFFER_DEPTH),
    parameter CLK_PERIOD = 100
)();
    

    
    reg                      clk_i;
    reg                      rstn_i;
    reg                      clr_i;
    
    wire [LOG_BUFFER_DEPTH:0] elements_o;
    wire  [DATA_WIDTH-1 : 0]   data_o;
    wire                       valid_o;
    reg                      ready_i;
    reg                      valid_i;
    reg [DATA_WIDTH-1 : 0]   data_i;
    wire                       ready_o;
    
    io_generic_fifo uut(.clk_i(clk_i),
                        .rstn_i(rstn_i),
                        .clr_i(clr_i),
                        .ready_i(ready_i),
                        .valid_i(valid_i),
                        .data_i(data_i),
                        .elements_o(elements_o),
                        .data_o(data_o),
                        .valid_o(valid_o),
                        .ready_o(ready_o));

    task push;
        input [31:0] data_in;
    begin
        if(~ready_o)
        begin
            @(negedge ready_o);
        end
            data_i = data_in;
            valid_i = 1;
        @(posedge clk_i);
            valid_i = 0;
    end
endtask

    task reset;
    begin
        clr_i = 0;
        ready_i = 0;
        data_i = 0;
        valid_i = 0;
        clk_i = 0;
        rstn_i = 1;
        @(posedge clk_i);
        rstn_i = 0;
        @(posedge clk_i);
        rstn_i = 1;

    end
endtask
    
    task pop;
    begin
    ready_i = 1;
    @(posedge clk_i);
    ready_i = 0;
    end
endtask

    always
    begin
        #(CLK_PERIOD/2) clk_i = ~clk_i;
    end
    initial begin
        reset();
        push(32'h01);
        push(32'h02);
        pop();
        push(32'h03);
        pop();
        push(32'h04);
        pop();
        pop();
    end
endmodule