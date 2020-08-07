module ATB();

    reg clk = 1'b0;
    reg rst = 1'b1;

    always #10 clk = ~clk;

    reg [14:0] Address = 15'b000010000000000;
    reg [14:0] H_MCout = 15'b000000000000000;

    wire H_M;

    reg start;
    wire Ready;

    reg tmp = 1'b0;

    wire [31:0] Data;

    Cache cache(clk, rst, start, Address, Ready, H_M, Data);

    initial begin
        #1 rst = 1'b0;
        repeat(8192) begin
            start = 1'b1;
            #10 H_MCout = H_MCout + H_M;
            #20 start = 1'b0;
            H_MCout = H_MCout + H_M;
            Address = Address + 1;
            #50 tmp = ~tmp;
        end
        $display("Number of Hits: %b", H_MCout);
        $display("All operations: 010000000000000");
        $stop;
    end


endmodule