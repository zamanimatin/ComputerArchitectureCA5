`timescale 1ns/1ns
module CacheDP(input [14:0]Address, input clk, rst, read, write, input [31:0]D1, D2, D3, D4, output reg [31:0]Data, output reg H_M);

    // Defining Cache
    reg [127:0] CacheFastMemory[0:1023];        // 4 * 32[Four Words] 
    reg [2:0] TagArray[0:1023];                 // 18-bit for Tag
    reg ValidArray[0:1023];                     // Valid Array

    wire[1:0] WordOffset;
    wire[9:0] AddressIndex;
    wire[2:0] AddressTag;

    assign WordOffset = Address[1:0];
    assign AddressIndex = Address[11:2];
    assign AddressTag = Address[14:12];

    integer i;
    always @(posedge clk, posedge rst) begin
        if(rst) begin
            for(i = 0; i < 1024; i = i + 1) begin
                ValidArray[i] = 1'b0;
                TagArray[i] = 18'b000000000000000000;
                CacheFastMemory[i] = 128'b0;
            end
        end
        else if(write) begin
            ValidArray[AddressIndex] = 1'b1;
            TagArray[AddressIndex] = AddressTag;
            CacheFastMemory[AddressIndex] = {D4, D3, D2, D1};
        end
    end

    always @(read, Address) begin
        Data = 32'b00000000000000000000000000000000;
        H_M = 1'b0;
        if(read) begin
            if(ValidArray[AddressIndex] == 1'b1 && TagArray[AddressIndex] == AddressTag) begin
                H_M = 1'b1;
                case (WordOffset)
                    2'b00:
                        Data = CacheFastMemory[AddressIndex][31:0];
                    2'b01:
                        Data = CacheFastMemory[AddressIndex][63:32];
                    2'b10:
                        Data = CacheFastMemory[AddressIndex][95:64];
                    2'b11:
                        Data = CacheFastMemory[AddressIndex][127:96];
                endcase
            end
            else begin
                H_M = 1'b0;
            end
        end
    end
endmodule