`default_nettype none
`timescale 1ns / 1ps

`define START_N	16'b11100000_00000100
`define START_M 16'b11100000_00000100

`define LINE_1_4 64'b11000000_00000000_10100000_00000001_10100000_00000011_00100000_00000000
`define LINE_2_3 112'b11000000_00000000_10100000_00000001_10100000_00000010_01000000_00000000_10100000_00000000_10100000_00000011_00100000_00000000

`define STOP 16'b00000000_00000000

module assembler_tb;

    logic clk;
    logic rst;
    logic valid_in;
    logic busy;
    logic [10:0] [10:0] solution;
    logic [3:0] n,m;

    logic transmit_ready;
    logic [7:0] byte_out;

    assembler uut (
        .clk(clk),
        .rst(rst),
        .valid_in(valid_in),
        .transmit_busy(busy),
        .solution(solution),
        .n(n),  //11x11
        .m(m),  //11x11

        .transmit_ready(transmit_ready),
        .byte_out(byte_out)
    );


    always begin
        #5;
        clk = !clk;
    end

    initial begin
        $dumpfile("assembler.vcd");
        $dumpvars(0, assembler_tb);
        $display("Starting Sim Parser");
        clk = 0;
        rst = 0;
        busy = 1;
        valid_in = 0;
        #5;
        rst = 1;
        #10;
        rst = 0;
        #10;

        serial_bits = `START_N;

        for (int i = 15; i>0; i = i - 8)begin
            byte_in = serial_bits[i -: 8];
            valid_in = 1;
            #10;
            valid_in = 0;
            #10;
        end

        #20;

        serial_bits = `START_M;

        for (int i = 15; i>0; i = i - 8)begin
            byte_in = serial_bits[i -: 8];
            valid_in = 1;
            #10;
            valid_in = 0;
            #10;
        end

        #20;

        serial_bits = `LINE_1_4;

        for (int i = 63; i>0; i = i - 8)begin
            byte_in = serial_bits[i -: 8];
            valid_in = 1;
            #10;
            valid_in = 0;
            #10;
        end

        #20;

        serial_bits = `LINE_2_3;

        for (int i = 111; i>0; i = i - 8)begin
            byte_in = serial_bits[i -: 8];
            valid_in = 1;
            #10;
            valid_in = 0;
            #10;
        end

        #20;

        serial_bits = `LINE_2_3;

        for (int i = 111; i>0; i = i - 8)begin
            byte_in = serial_bits[i -: 8];
            valid_in = 1;
            #10;
            valid_in = 0;
            #10;
        end

        #20;

        serial_bits = `LINE_1_4;

        for (int i = 63; i>0; i = i - 8)begin
            byte_in = serial_bits[i -: 8];
            valid_in = 1;
            #10;
            valid_in = 0;
            #10;
        end

        #20;

        serial_bits = `STOP;

        for (int i = 15; i>0; i = i - 8)begin
            byte_in = serial_bits[i -: 8];
            valid_in = 1;
            #10;
            valid_in = 0;
            #10;
        end

        #100;

        $display("Finishing Sim");
        $finish;
    end

endmodule

`default_nettype wire
