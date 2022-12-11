`default_nettype none
`timescale 1ns / 1ps

`define START_N	16'b11100000_00000100
`define START_M 16'b11100000_00000100

`define LINE_1_4 64'b11000000_00000000_10100000_00000001_10100000_00000011_00100000_00000000
`define LINE_2_3 112'b11000000_00000000_10100000_00000001_10100000_00000010_01000000_00000000_10100000_00000000_10100000_00000011_00100000_00000000

`define STOP 16'b00000000_00000000

`define SOLUTION 9'b101010011
// 101010011

module assembler_tb;

    logic clk;
    logic rst;
    logic valid_in;
    logic busy;
    //logic [10:0] [10:0] solution;
    logic [8:0] sol;
    //logic [3:0] n,m;

    logic send;
    logic [7:0] byte_out;
    logic done;

    assembler #(.MAX_ROWS(3), .MAX_COLS(3)) uut (
        .clk(clk),
        .rst(rst),
        .valid_in(valid_in),
        .transmit_busy(busy),
        .solution(sol),
        .m(2'd3),
        .n(2'd3),

        .send(send),
        .byte_out(byte_out),
        .done(done)
    );


    always begin
        #5;
        clk = !clk;
    end

    initial begin
        $dumpfile("assembler.vcd");
        $dumpvars(0, assembler_tb);
        $display("Starting Sim Assembler");
        clk = 0;
        rst = 0;
        busy = 1;
        valid_in = 0;
        #5;
        rst = 1;
        #10;
        rst = 0;
        #10;

        sol = `SOLUTION;
        valid_in = 1;
        #10;
        valid_in = 0;
        #20;

        //first message sent - m
        busy = 0;
        #20;
        busy = 1;
        #10;

        busy = 0;
        #20;
        busy = 1;
        #10;

        //2nd message sent - n
        busy = 0;
        #20;
        busy = 1;
        #10;

        busy = 0;
        #20;
        busy = 1;
        #10;

        //next message - 0
        busy = 0;
        #20;
        busy = 1;
        #10;

        busy = 0;
        #20;
        busy = 1;
        #10;

        //next message - 1
        busy = 0;
        #20;
        busy = 1;
        #10;

        busy = 0;
        #20;
        busy = 1;
        #10;

        //next message - 2
        busy = 0;
        #20;
        busy = 1;
        #10;

        busy = 0;
        #20;
        busy = 1;
        #10;

        //next message - 3
        busy = 0;
        #20;
        busy = 1;
        #10;

        busy = 0;
        #20;
        busy = 1;
        #10;

        //next message - 4
        busy = 0;
        #20;
        busy = 1;
        #10;

        busy = 0;
        #20;
        busy = 1;
        #10;

        //next message - 5
        busy = 0;
        #20;
        busy = 1;
        #10;

        busy = 0;
        #20;
        busy = 1;
        #10;

        //next message - 6
        busy = 0;
        #20;
        busy = 1;
        #10;

        busy = 0;
        #20;
        busy = 1;
        #10;

        //next message - 7
        busy = 0;
        #20;
        busy = 1;
        #10;

        busy = 0;
        #20;
        busy = 1;
        #10;

        //next message - 8
        busy = 0;
        #20;
        busy = 1;
        #10;

        busy = 0;
        #20;
        busy = 1;
        #10;

        //next message - 9
        busy = 0;
        #20;
        busy = 1;
        #10;

        busy = 0;
        #20;
        busy = 1;
        #10;

        //stop message
        busy = 0;
        #20;
        busy = 1;
        #10;

        busy = 0;
        #20;
        busy = 1;
        #10;


        //nothing should happen
        busy = 0;
        #20;


        #20;

        $display("Finishing Sim");
        $finish;
    end

endmodule

`default_nettype wire
