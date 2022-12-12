`default_nettype none
`timescale 1ns / 1ps

`define START_M	16'b11100000_00000100
`define START_N 16'b11100000_00000110

`define LINE_1 80'b11000000_00000000_10100000_00000001_10100000_00000011_10100000_00000101_00100000_00000000
`define LINE_2 80'b11000000_00000000_10100000_00000000_10100000_00000010_10100000_00000100_00100000_00000000
`define LINE_3_to_5 112'b11000000_00000000_10100000_00000001_10100000_00000010_01000000_00000000_10100000_00000000_10100000_00000011_00100000_00000000

`define STOP 16'b00000000_00000000

module parser_tb_2x3;

    logic [7:0] byte_in;

    logic clk;
    logic rst;
    logic valid_in;

    logic board_done;
    logic write_ready;
    logic [15:0] line;

    logic [4:0] [6:0] options_per_line;

    logic [3:0] n,m;

    logic [111:0] serial_bits;

    parser uut (
        .clk(clk),
        .rst(rst),
        .byte_in(byte_in),
        .valid_in(valid_in),
        
        .board_done(board_done),
        .write_ready(write_ready),
        .line(line),

        // assuming 11x11 max board
        .options_per_line(options_per_line),
        .n(n),
        .m(m)
    );


    always begin
        #5;
        clk = !clk;
    end

    initial begin
        $dumpfile("parser_2x3.vcd");
        $dumpvars(0, parser_tb_2x3);
        $display("Starting Sim Parser");
        clk = 0;
        rst = 0;
        valid_in = 0;
        #5;
        rst = 1;
        #10;
        rst = 0;
        #10;

        serial_bits = `START_M;

        for (int i = 15; i>0; i = i - 8)begin
            byte_in = serial_bits[i -: 8];
            valid_in = 1;
            #10;
            valid_in = 0;
            #10;
        end

        #20;

        serial_bits = `START_N;

        for (int i = 15; i>0; i = i - 8)begin
            byte_in = serial_bits[i -: 8];
            valid_in = 1;
            #10;
            valid_in = 0;
            #10;
        end

        #20;

        serial_bits = `LINE_1; //row 1

        for (int i = 79; i>0; i = i - 8)begin
            byte_in = serial_bits[i -: 8];
            valid_in = 1;
            #10;
            valid_in = 0;
            #10;
            $display("output should be (111): %b", line);
        end

        $display("output should be (111): %b", line);
        #20;
        $display("next");

        serial_bits = `LINE_2; //row 2

        for (int i = 79; i>0; i = i - 8)begin
            byte_in = serial_bits[i -: 8];
            valid_in = 1;
            #10;
            valid_in = 0;
            #10;
            $display("output should be (000): %b", line);
        end

        $display("output should be (000): %b", line);
        #20;
        $display("next");

        serial_bits = `LINE_3_to_5; //cols 1 - 3

        for (int j = 0; j < 3; j = j + 1)begin
            for (int i = 111; i>0; i = i - 8)begin
                byte_in = serial_bits[i -: 8];
                valid_in = 1;
                #10;
                valid_in = 0;
                #10;
                $display("output should be (01) and then (10): %b", line);
            end

            $display("output should be (01) and then (10): %b", line);
            #20;
            $display("next");
        end

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
