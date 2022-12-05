`timescale 1ns / 1ps
`default_nettype none

module parser #(parameter MAX_ROWS = 11, parameter MAX_COLS = 11, MAX_NUM_OPTIONS=84)(
        input wire clk,
        input wire rst,
        input wire [7:0] byte_in,
        input wire valid_in,
        
        output logic board_done,  //signals parser is done
        output logic write_ready, //signals when output to be written to BRAM is done
        output logic first_read,
        output logic [15:0] line, // line = line index (5 bits) + #options + options
        output logic [MAX_ROWS + MAX_COLS - 1:0] [$clog2(MAX_NUM_OPTIONS) - 1:0] options_per_line,
        output logic [$clog2(MAX_ROWS) - 1:0] m,
        output logic [$clog2(MAX_COLS) - 1:0] n
    );

    /*
        Parser:

        TODO
    */

    // message flags
    localparam START_BOARD = 3'b111;
    localparam END_BOARD = 3'b000;
    localparam START_LINE = 3'b110;
    localparam END_LINE = 3'b001;
    localparam AND = 3'b101;
    localparam OR = 3'b010;
        
    logic count;
    logic first;
    logic row;
    logic [7:0] buffer;
    logic [2:0] flag;
    logic fifo_started;

    /////******Hard-coded for now*****//////
    logic [4:0] line_index; //line index is MAX 11 
    //logic [6:0] num_options; //max is 84 (9 choose 3)
    logic [15:0] curr_option;
    logic [3:0] assignment_index;

    assign flag = buffer[7:5];
    assign assignment_index = byte_in[4:1]; //hard_coded

    always_ff @(posedge clk)begin
        if (rst)begin
            board_done <= 0;
            write_ready <= 0;
            line <= 0;
            options_per_line <= 0;
            n <= 0;
            m <= 0;
            first <= 1;
            count <= 0;
            line_index <= 0;
            curr_option <= 0;
            fifo_started <= 0;
        end else begin
            if (fifo_started) first_read <= 0;
            if (valid_in)begin
                if (!count) buffer <= byte_in;
                else begin
                    case(flag)
                        START_BOARD:begin
                            // handle n,m 
                            write_ready <= 0;
                            line_index <= 0;
                            line <= 0;
                            curr_option <= 0;
                            if (first) n <= byte_in[5:1]; // hard coded
                            else m <= byte_in[5:1]; // hard-coded
                            first <= !first;
                        end
                        END_BOARD: begin
                            board_done <= 1;
                            write_ready <= 0;
                            fifo_started <= 0;
                        end
                        START_LINE: begin
                            write_ready <= 1;
                            line <= line_index;
                            curr_option <= 15'b0;
                            options_per_line[line_index] <= 7'b0;
                        end
                        END_LINE: begin 
                            line_index <= line_index + 1;
                            write_ready <= 1;
                            line <= curr_option;
                            curr_option <= 16'b0;
                            options_per_line[line_index] <= options_per_line[line_index] + 1'b1;
                            if (~fifo_started)begin
                                fifo_started <= 1;
                                first_read <= 1;
                            end
                        end
                        AND: begin
                            write_ready <= 0;
                            curr_option[assignment_index] <= byte_in[0];
                        end
                        OR: begin
                            write_ready <= 1;
                            line <= curr_option;
                            curr_option <= 0;
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
            row = 1;
        end else begin  //dealing with cols
            row = 0;
        end
    end
endmodule

`default_nettype wire
