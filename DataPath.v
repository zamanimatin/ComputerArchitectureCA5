`timescale 1ns/1ns


module RAM (input[31:0]Address, input rst, output reg [31:0]Data0, Data1, Data2, Data3);

    wire [31:0]next1, next2, next3;

    assign next1 = Address + 32'b00000000000000000000000000000100;
    assign next2 = Address + 32'b00000000000000000000000000001000;
    assign next3 = Address + 32'b00000000000000000000000000001100;
    
    reg [31:0] RandomAccessMemory [0:1024]; // 32*32
    always @(negedge rst) begin
        $readmemb("RAM.mem", RandomAccessMemory);
    end
    integer i = 0;
    always @(posedge rst, Address)begin
        Data0 = 32'b00000000000000000000000000000000;
        Data1 = 32'b00000000000000000000000000000000;
        Data2 = 32'b00000000000000000000000000000000;
        Data3 = 32'b00000000000000000000000000000000;
        if(rst)
            for( i = 0; i < 1024; i = i + 1)begin
                RandomAccessMemory[i] = 32'b00000000000000000000000000000000;
            end
        else
            Data0 = RandomAccessMemory[Address[31:2]];
            Data1 = RandomAccessMemory[next1[31:2]];
            Data2 = RandomAccessMemory[next2[31:2]];
            Data3 = RandomAccessMemory[next3[31:2]];
    end
endmodule


module CacheConnectedToRAM(input [31:0]Address, input rst, output reg [31:0]Data, output reg H_M);

    // Defining Cache
    reg [127:0] CacheFastMemory[0:1024];        // 4 * 32[Four Words] 
    reg [17:0]TagArray[0:1024];                 // 18-bit for Tag
    reg ValidArray[0:1024];                     // Valid Array

    wire[1:0] ByteOffset;
    wire[1:0] WordOffset;
    wire[9:0] AddressIndex;
    wire[17:0] AddressTag;

    assign ByteOffset = Address[1:0];
    assign WordOffset = Address[3:2];
    assign AddressIndex = Address[13:4];
    assign AddressTag = Address[31:14];


    // Wiring cache with RAM
    wire [31:0]DRAMoutput0, DRAMoutput1, DRAMoutput2, DRAMoutput3;
    RAM DRAM(Address, rst, DRAMoutput0, DRAMoutput1, DRAMoutput2, DRAMoutput3);



    // Loading cache if needed
    always @(negedge rst) begin
        $readmemb("Cache.mem", CacheFastMemory);
    end

    integer i;
    always @(posedge rst, Address) begin
        Data = 32'b00000000000000000000000000000000;
        H_M = 1'b0;
        if(rst) begin
            for(i = 0; i < 1024; i = i + 1) begin
                ValidArray[i] = 1'b0;
                TagArray[i] = 18'b000000000000000000;
            end
        end
        else begin
            if (ValidArray[AddressIndex] == 1'b1 && TagArray[AddressIndex] == AddressTag) begin             // Hit happen
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
                H_M = 1'b0;                             // Miss happen
                ValidArray[AddressIndex] = 1'b1;
                TagArray[AddressIndex] = AddressTag;

                // Cause all addresses are a multiplier of 4, we start from that address to put it in cache
                CacheFastMemory[AddressIndex][31:0] = DRAMoutput0;
                CacheFastMemory[AddressIndex][63:32] = DRAMoutput1;
                CacheFastMemory[AddressIndex][95:64] = DRAMoutput2;
                CacheFastMemory[AddressIndex][127:96] = DRAMoutput3;
            end
        end
    end
endmodule
