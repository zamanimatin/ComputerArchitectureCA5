`timescale 1ns/1ns
module RAM (input[14:0]Address, input rst, output reg [31:0]Data0, Data1, Data2, Data3);

    wire [14:0] Wire[0:3];

    assign Wire[0] = {Address[14:2], 2'b00};
    assign Wire[1] = {Address[14:2], 2'b01};
    assign Wire[2] = {Address[14:2], 2'b10};
    assign Wire[3] = {Address[14:2], 2'b11};
    
    reg [31:0] RandomAccessMemory [0:32767];

    always @(negedge rst) begin
        $readmemb("RAM.mem", RandomAccessMemory);
        Data0 = RandomAccessMemory[Wire[0]];
        Data1 = RandomAccessMemory[Wire[1]];
        Data2 = RandomAccessMemory[Wire[2]];
        Data3 = RandomAccessMemory[Wire[3]];
    end

    integer i = 0;
    always @(posedge rst, Address) begin
        Data0 = 32'b00000000000000000000000000000000;
        Data1 = 32'b00000000000000000000000000000000;
        Data2 = 32'b00000000000000000000000000000000;
        Data3 = 32'b00000000000000000000000000000000;
        if(rst)
            for( i = 0; i < 1024; i = i + 1) begin
                RandomAccessMemory[i] = 32'b00000000000000000000000000000000;
            end
        Data0 = RandomAccessMemory[Wire[0]];
        Data1 = RandomAccessMemory[Wire[1]];
        Data2 = RandomAccessMemory[Wire[2]];
        Data3 = RandomAccessMemory[Wire[3]];
    end
endmodule