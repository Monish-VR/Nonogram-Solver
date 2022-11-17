`timescale 1ns / 1ps
`default_nettype none

module parser(
        input wire clk,
        input wire rst,
        input wire [7:0] byte_in,
        input wire valid_in,
        
        output logic board_done,  //signals parser is done
        output logic write_ready, //signals when output to be written to BRAM is done
        output logic [12:0] assignment, // assignment = cell index (max 2^12) + value = 2bits + 1bits = 3 bits

        //********** HARDCODED FOR NOW - DO MATH LATER ************//
        // assuming 2x2 board
        output logic [25:0] bram_index, ///address to write the assignment to in BRAM
        output logic [11:0] n, m
        // size(cell index) is dependent on size of message we 2^12
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

    logic [12:0] line_index; //line index is MAX 2^12 + 1 
    logic [12:0] bram_row, bram_col, num_bram_cols;

    assign flag = buffer[7:5];
    assign num_bram_cols = $max(n,m) + 1;
    assign bram_index = bram_col + bram_row * num_bram_cols;

    always_ff @(posedge clk)begin
        if (rst)begin
            board_done <= 0;
            write_ready <= 0;
            count <= 0;
            bram_row <= 0;
            bram_col <= 0;
            n <= 0;
            m <= 0;
        end else begin
            if (valid_in)begin
                if (!count) buffer <= byte_in;
                else begin
                    case(flag)
                        START_BOARD:begin
                            // handle n,m
                            write_ready <= 0;
                            line_index <= 0;
                            bram_row <= 0;
                            bram_col <= 0;
                            if (count) n <= {buffer[4:0], byte_in[7:1]};
                            else m <= {buffer[4:0], byte_in[7:1]};
                            count <= !count;
                        end
                        END_BOARD: begin
                            board_done <= 1;
                            write_ready <= 0; //send over n and m
                        end
                        START_LINE: begin
                            write_ready <= 1;
                            assignment <= line_index;
                        end
                        END_LINE: begin 
                            line_index <= line_index + 1;
                            write_ready <= 0;
                            //changes bram_index (next row)
                            bram_row <= bram_row + 1;
                            bram_col <= 0;
                        end
                        AND: begin
                            write_ready <= 1;
                            // change bram_index (next col)
                            bram_col <= bram_col + 1;
                            assignment <= {buffer[4:0], byte_in};
                        end
                        OR: begin
                            write_ready <= 0;
                            // change bram_index (next row)
                            bram_row <= bram_row + 1;
                            bram_col <= 0;
                        end
                    endcase
                end
                count <= !count;
            end else write_ready <= 0;
            if (board_done) board_done <= 0;
        end
    end
endmodule

`default_nettype wire
