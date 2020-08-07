`timescale 1ns/1ns

module Controller(input HMbar, start, clk, input [14:0]address, output reg read, write, Ready);
    parameter [1:0] Start = 2'b00, ReadCache = 2'b01, CheckAddress = 2'b10, WriteCache = 2'b11;
    
    reg [1:0]ps, ns;
    always @(HMbar, start, ps)begin
        read = 1'b0;
        write = 1'b0;
        Ready = 1'b0;
        ns = Start;

        case (ps)
            Start : begin
                Ready = 1'b1;                   // Check whether it is correct even at the first time for reading the first data
                ns = start ? ReadCache : Start;
            end
            ReadCache : begin
                read = 1'b1;
                Ready = 1'b0;
                ns = HMbar ? CheckAddress : WriteCache;
            end
            CheckAddress : begin
                ns = Start;
            end
            WriteCache : begin
                write = 1'b1;
                ns = CheckAddress;
            end
        endcase
    end
    always @(posedge clk) begin
        ps <= ns;
    end
endmodule 