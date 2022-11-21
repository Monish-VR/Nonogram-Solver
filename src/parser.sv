`timescale 1ns / 1ps
`default_nettype none

module parser(
        input wire clk,
        input wire rst,
        input wire [7:0] byte_in,
        input wire valid_in,
        
        output logic board_done,  //signals parser is done
        output logic write_ready, //signals when output to be written to BRAM is done
        output logic [1023:0] line, // line = line index (5 bits) + #options + options

        //********** HARDCODED FOR NOW - DO MATH LATER ************//
        // assuming 11x11 max board
        output logic [4:0] [6:0] options_per_line,
        output logic [3:0] n, m
    );

    /*
        Parser:

        TODO
    */

    // states
    localparam RECEIVE = 0;
    localparam PARSE = 1;

    // message flags
    localparam START_BOARD = 3'b111;
    localparam END_BOARD = 3'b000;
    localparam START_LINE = 3'b110;
    localparam END_LINE = 3'b001;
    localparam AND = 3'b101;
    localparam OR = 3'b010;
        
    logic count;
    logic [7:0] buffer;
    logic [2:0] flag;

    /////******Hard-coded for now*****//////
    logic [4:0] line_index; //line index is MAX 11 
    //logic [6:0] num_options; //max is 84 (9 choose 3)
    logic [3:0] option_index;
    logic [1023:0] buff_index;
    logic [10:0] curr_option;
    logic [6:0] cell_index;

    assign flag = buffer[7:5];
    assign cell_index = byte_in[7:1]; //hard_coded

    always_ff @(posedge clk)begin
        if (rst)begin
            board_done <= 0;
            write_ready <= 0;
            line <= 0;
            options_per_line <= 0;
            n <= 0;
            m <= 0;

            count <= 0;
            line_index <= 0;
            buff_index <= 0;
            curr_option <= 0;
        end else begin
            if (valid_in)begin
                if (!count) buffer <= byte_in;
                else begin
                    case(flag)
                        START_BOARD:begin
                            // handle n,m - update python
                            write_ready <= 0;
                            line_index <= 0;
                            buff_index <= 0;
                            curr_option <= 0;
                            if (count) n <= byte_in[5:1]; // hard coded
                            else m <= byte_in[5:1]; // hard-coded
                            count <= !count;
                        end
                        END_BOARD: begin
                            board_done <= 1;
                            write_ready <= 0;
                        end
                        START_LINE: begin
                            write_ready <= 0;
                            line[buff_index +: 5] <= line_index;
                            buff_index <= 5;
                        end
                        END_LINE: begin 
                            line_index <= line_index + 1;
                            write_ready <= 1;
                            line[buff_index +: 11] <= curr_option;
                            buff_index <= 0;
                            curr_option <= 0;
                            options_per_line[line_index] <= options_per_line[line_index] + 1;
                        end
                        AND: begin
                            write_ready <= 0;
                            curr_option[option_index] <= byte_in[0];
                        end
                        OR: begin
                            write_ready <= 0;
                            curr_option <= 0;
                            line[buff_index +: 11] <= curr_option;
                            buff_index <= buff_index + 11;
                            options_per_line[line_index] <= options_per_line[line_index] + 1;
                        end
                    endcase
                end
                count <= !count;
            end else write_ready <= 0;
            if (board_done) board_done <= 0;
        end
    end

    always_comb begin
        if (line_index < m)begin //dealing with rows
            option_index = cell_index - n * line_index;
        end else begin
            option_index = cell_index / n;
        end
    end
endmodule

`default_nettype wire
