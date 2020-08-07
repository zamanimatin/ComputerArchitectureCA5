`timescale 1ns/1ns
module Cache(input clk, rst, start, input [14:0]Address, output Ready, H_M, output [31:0]Data);

    wire [31:0] D1, D2, D3, D4;
    wire read, write;

    CacheDP DP(Address, clk, rst, read, write, D1, D2, D3, D4, Data, H_M);
    RAM mainMemory(Address, rst, D1, D2, D3, D4);
    Controller CU(H_M, start, clk, Address, read, write, Ready);
endmodule