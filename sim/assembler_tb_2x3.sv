`default_nettype none
`timescale 1ns / 1ps

`define SOLUTION 22'b0000000000000000000111

module assembler_tb_2x3;

    logic clk;
    logic rst;
    logic valid_in;
    logic done;
    //logic [10:0] [10:0] solution;
    logic [120:0] sol;
    //logic [3:0] n,m;

    logic send;
    logic [7:0] byte_out;
    logic assemble_done;

    assembler uut (
        .clk(clk),
        .rst(rst),
        .valid_in(valid_in),
        .transmit_done(done),
        .solution(sol),
        .m(4'd2),
        .n(4'd3),

        .send(send),
        .byte_out(byte_out),
        .done(assemble_done)
    );


    always begin
        #5;
        clk = !clk;
    end

    initial begin
        $dumpfile("assembler_2x3.vcd");
        $dumpvars(0, assembler_tb_2x3);
        $display("Starting Sim Assembler");
        clk = 0;
        rst = 0;
        done = 0;
        valid_in = 0;
        #5;
        rst = 1;
        #10;
        rst = 0;
        #10;

        sol = {99'b0,`SOLUTION};
        valid_in = 1;
        #10;
        valid_in = 0;
        #20;

        //first message sent - m
        done = 1;
        #20;
        done = 0;
        #10;

        done = 1;
        #20;
        done = 0;
        #10;

        //2nd message sent - n
        done = 1;
        #20;
        done = 0;
        #10;

        done = 1;
        #20;
        done = 0;
        #10;

        //next message - 0
        done = 1;
        #20;
        done = 0;
        #10;

        done = 1;
        #20;
        done = 0;
        #10;

        //next message - 1
        done = 1;
        #20;
        done = 0;
        #10;

        done = 1;
        #20;
        done = 0;
        #10;

        //next message - 2
        done = 1;
        #20;
        done = 0;
        #10;

        done = 1;
        #20;
        done = 0;
        #10;

        //next message - 3
        done = 1;
        #20;
        done = 0;
        #10;

        done = 1;
        #20;
        done = 0;
        #10;

        //next message - 4
        done = 1;
        #20;
        done = 0;
        #10;

        done = 1;
        #20;
        done = 0;
        #10;

        //next message - 5
        done = 1;
        #20;
        done = 0;
        #10;

        done = 1;
        #20;
        done = 0;
        #10;

        //stop message
        done = 1;
        #20;
        done = 0;
        #10;

        done = 1;
        #20;
        done = 0;
        #10;


        //nothing should happen
        done = 1;
        #20;


        #20;

        $display("Finishing Sim");
        $finish;
    end

endmodule

`default_nettype wire
