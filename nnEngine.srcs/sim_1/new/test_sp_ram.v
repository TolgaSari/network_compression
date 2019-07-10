`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/10/2019 10:45:50 PM
// Design Name: 
// Module Name: test_sp_ram
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


module test_sp_ram
 #(
    parameter ADDR_WIDTH = 12,
    parameter DATA_WIDTH = 8,
    parameter NUM_WORDS  = 5
  )();
  
    reg                    clk;
    reg                       en_i;
    reg    [ADDR_WIDTH-1:0]   waddr_i;
    reg    [ADDR_WIDTH-1:0]   raddr_i;
    reg    [DATA_WIDTH-1:0]   wdata_i;
    wire   [DATA_WIDTH-1:0]   rdata_o;
    reg                       we_i;
    reg    [DATA_WIDTH/8-1:0] be_i;
    
    sp_ram  uut(.clk(clk),
                .en_i(en_i),
                .waddr_i(waddr_i),
                .raddr_i(raddr_i),
                .wdata_i(wdata_i),
                .rdata_o(rdata_o),
                .we_i(we_i),
                .be_i(be_i)
                );
    always 
    begin
        #50 clk = ~clk;
    end 
    
    task read;
    input [ADDR_WIDTH-1:0] read_addr;
    begin
        en_i = 1;
        be_i = 1;
        raddr_i = read_addr;
        @(posedge clk);
        @(negedge clk);
        en_i = 0;
        be_i = 0;
        raddr_i = 0;
    end
endtask

    task write;
    input [ADDR_WIDTH-1:0] write_addr;
    input [DATA_WIDTH-1:0] write_data;
    begin
        en_i = 1;
        be_i = 1;
        we_i = 1;
        waddr_i = write_addr;
        wdata_i = write_data;
        @(posedge clk);
        @(negedge clk);
        en_i = 0;
        be_i = 0;
        we_i = 0;
        waddr_i = 0;
        wdata_i = 0;
    end
endtask

    task read_write;
    input [ADDR_WIDTH-1:0] read_addr;
    input [ADDR_WIDTH-1:0] write_addr;
    input [DATA_WIDTH-1:0] write_data;
    begin
        en_i = 1;
        be_i = 1;
        we_i = 1;
        waddr_i = write_addr;
        wdata_i = write_data;
        raddr_i = read_addr;
        @(posedge clk);
        @(negedge clk);
        en_i = 0;
        we_i = 0;
        be_i = 0;
        waddr_i = 0;
        wdata_i = 0;
        raddr_i = 0;
    end
endtask

    initial 
    begin
        clk = 0;
        write(12'h000, 8'h01); #75;
        write(12'h001, 8'h05);
        read(12'h001);
        read_write(12'h000, 12'h002, 8'h0A);
        read(12'h002);
    end
    
endmodule
