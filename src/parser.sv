`timescale 1ns / 1ps
`default_nettype none

module parser #(parameter MAX_ROWS = 11, parameter MAX_COLS = 11, MAX_NUM_OPTIONS=84)(
        input wire clk,
        input wire rst,
        input wire valid_in,
        input wire [7:0] byte_in,
        
        output logic board_done,  //signals parser is done #MVR: goes to the solver to indicate board is done
        output logic write_ready, //signals when output to be written to BRAM is done
        output logic [15:0] line, // line = line index (5 bits) + #options + options #MVR : Goes to FIFO by collecting the two 8 bit data from UART_RX
        output logic [MAX_ROWS + MAX_COLS - 1:0] [$clog2(MAX_NUM_OPTIONS) - 1:0] options_per_line,
        output logic [MAX_ROWS + MAX_COLS - 1:0] [$clog2(MAX_NUM_OPTIONS) - 1:0] options_per_line_cols,
        output logic [$clog2(MAX_ROWS) - 1:0] m,
        output logic [$clog2(MAX_COLS) - 1:0] n,
        output logic [2:0] flag, // #MVR: Indicates board's stage, line's stage n all, check // message flags
        output logic  row
    );

    /*
        Parser:
            gets an input of 8 bits in every clock cycle and parse it out to get output of 16 bits which 
            will be taken into the fifo. (every 2 clock cycles)
             parser will also keep track of the board size and # of options per line
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
    // logic row;
    logic [7:0] buffer;
        logic [$clog2(MAX_ROWS + MAX_COLS) - 1:0] line_index; // #MVR: for 11x11 it's 5 bit wide

    logic [15:0] curr_option; // hardcoded based upon FIFO
    logic [6:0] assignment_index;
    logic assignment_value;

    assign flag = buffer[7:5];
    assign assignment_index = byte_in[7:1];
    assign assignment_value = byte_in[0];
        
    always_ff @(posedge clk)begin
        if (rst)begin
            board_done <= 0;
            write_ready <= 0;
            line <= 0;
            options_per_line <= 0;
            options_per_line_cols<=0;
            n <= 0;
            m <= 0;
            first <= 1;
            count <= 0;
            line_index <= 0;
            curr_option <= 0;
        end else begin
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
                            if (first) m <= {buffer[4:0], assignment_index};
                            else n <= {buffer[4:0], assignment_index};
                            first <= !first;
                        end
                        END_BOARD: begin
                            board_done <= 1;
                            write_ready <= 0;
                        end
                        START_LINE: begin
                            write_ready <= 1;
                            line <= line_index;
                            curr_option <= 0;
                            options_per_line[line_index] <= 0;
                            if (~row) begin
                                options_per_line_cols[line_index] <=0;
                            end
                        end
                        END_LINE: begin 
                            line_index <= line_index + 1;
                            write_ready <= 1;
                            line <= curr_option;
                            curr_option <= 0;
                            options_per_line[line_index] <= options_per_line[line_index] + 1;
                            if (~row) begin
                                options_per_line_cols[line_index] <=options_per_line_cols[line_index]+1;
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
                            if (~row) begin
                                options_per_line_cols[line_index] <=options_per_line_cols[line_index]+1;
                            end
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
