`default_nettype none
`timescale 1ns / 1ps

`define START_N	16'b11100000_00000100
`define START_M 16'b11100000_00000100

`define LINE_1_4 64'b11000000_00000000_10100000_00000001_10100000_00000011_00100000_00000000
`define LINE_2_3 112'b11000000_00000000_10100000_00000001_10100000_00000010_01000000_00000000_10100000_00000000_10100000_00000011_00100000_00000000

`define STOP 16'b00000000_00000000

module parser_tb;

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

    //SHOULD WE ADD M N ROW AND SUCH
    parser parse(
        .clk(clk),
        .rst(rst),
        .byte_in(byte_in),
        .valid_in(valid_in),
        
        .board_done(board_done),  //signals parser is done
        .write_ready(write_ready), //signals when output to be written to BRAM is done
        .line(line), // line = line index (5 bits) + #options + options

        //********** HARDCODED FOR NOW - DO MATH LATER ************//
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
        $dumpfile("parser.vcd");
        $dumpvars(0, parser_tb);
        $display("Starting Sim Parser");
        clk = 0;
        rst = 0;
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
