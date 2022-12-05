`timescale 1ns / 1ps
`default_nettype none

module assembler#(parameter MAX_ROWS = 11, parameter MAX_COLS = 11)(
        input wire clk,
        input wire rst,
        input wire valid_in,
        input wire transmit_busy,
        input wire [(MAX_ROWS * MAX_COLS) - 1:0] solution,
        input wire [$clog2(MAX_ROWS) - 1:0] m,
        input wire [$clog2(MAX_COLS) - 1:0] n,

        output logic transmit_ready,
        output logic [7:0] byte_out,
        output logic done
    );

    /*
        Assembler:

        Convert solution to PC readable format.
    */
    // states
    localparam IDLE = 0;
    localparam START = 1;
    localparam NEW_LINE = 2;
    localparam ASSIGN = 3;
    localparam STOP_LINE = 4;
    localparam STOP = 5;

    // message flags
    localparam START_BOARD = 3'b111;
    localparam END_BOARD = 3'b000;
    localparam START_LINE = 3'b110;
    localparam END_LINE = 3'b001;
    localparam AND = 3'b101;
        
    logic count;
    logic first;
    logic [15:0] buffer;
    logic [2:0] flag;
    logic [11:0] assignment_index;
    logic assignment_value;

    logic [2:0] state;

    /////******Hard-coded for now*****//////
    logic [$clog2(MAX_ROWS) - 1:0] row_index;
    logic [$clog2(MAX_COLS) - 1:0] col_index;
    logic [$clog2(MAX_ROWS * (MAX_COLS-1)) - 1:0] real_index;
    logic [MAX_COLS - 1:0] row;

    assign buffer = {flag, assignment_index, assignment_value};
    assign byte_out = (count)? buffer[7:0] : buffer[15:8];

    always_ff @(posedge clk)begin
        if (rst)begin
            transmit_ready <= 0;
            count <= 0;
            state <= IDLE;
            row_index <= 0;
            col_index <= 0;
            row <= 0;
            done <= 1;
        end else begin
            if (transmit_busy) transmit_ready <= 0;
            else begin
                if (count)begin //second half of message
                    count <= 0;
                    transmit_ready <= 1;
                    if(state == IDLE) done <= 1;
                end
                else begin
                    case(state)
                        IDLE: begin
                            if (valid_in)begin
                                flag <= START_BOARD;
                                assignment_index <= m;
                                assignment_value <= 0;
                                count <= 1;
                                transmit_ready <= 1;
                                state <= START;
                                done <= 0;
                                row_index <= 0;
                                real_index <= 0;
                                col_index <= 0;
                            end
                        end
                        START: begin
                            assignment_index <= n;
                            count <= 1;
                            transmit_ready <= 1;
                            state <= NEW_LINE;
                        end
                        NEW_LINE: begin
                            flag <= START_LINE;
                            assignment_index <= 12'b0;
                            assignment_value <= 0;
                            count <= 1;
                            transmit_ready <= 1;
                            state <= ASSIGN;
                            row <= solution[real_index +: MAX_COLS];
                            col_index <= 0;
                        end
                        ASSIGN: begin
                            flag <= AND;
                            assignment_index <= col_index;
                            assignment_value <= row[col_index];
                            count <= 1;
                            if (col_index + 1 < n) col_index <= col_index + 1;
                            else state <= STOP_LINE;
                        end
                        STOP_LINE: begin
                            flag <= END_LINE;
                            assignment_index <= 12'b0;
                            assignment_value <= 0;
                            count <= 1;
                            transmit_ready <= 1;
                            if (row_index + 1 < m)begin
                                row_index <= row_index + 1;
                                real_index <= real_index + MAX_COLS;
                                state <= NEW_LINE;
                            end else state <= STOP;
                        end
                        STOP: begin
                            flag <= END_BOARD;
                            assignment_index <= 12'b0;
                            assignment_value <= 0;
                            state <= IDLE;
                        end
                        default: transmit_ready <= 0;
                    endcase
                end
            end
        end
    end
endmodule

`default_nettype wire
