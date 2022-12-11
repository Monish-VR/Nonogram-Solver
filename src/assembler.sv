`timescale 1ns / 1ps
`default_nettype none

module assembler#(parameter MAX_ROWS = 11, parameter MAX_COLS = 11)(
        input wire clk,
        input wire rst,
        input wire valid_in,
        input wire transmit_done,
        input wire [(MAX_ROWS * MAX_COLS) - 1:0] solution,
        input wire [$clog2(MAX_ROWS) - 1:0] m,
        input wire [$clog2(MAX_COLS) - 1:0] n,

        output logic send,
        output logic [7:0] byte_out,
        output logic done
    );

    /*
        Assembler:

        Convert solution to PC readable format.
    */
    // states
    localparam IDLE = 0;
    localparam TRANSMIT = 1;
    localparam WAIT = 2;


    localparam START = 0;
    localparam ASSIGN = 1;
    localparam STOP = 2;


    // message flags
    localparam START_BOARD = 3'b111;
    localparam END_BOARD = 3'b000;
    localparam AND = 3'b101;
        
    logic first_start_msg;
    logic [15:0] buffer;
    logic [2:0] flag;
    logic [11:0] assignment_index;
    logic assignment_value;
    logic first_half;

    logic [1:0] state, transmit_stage_state;

    logic [$clog2(MAX_ROWS) - 1:0] row_index;
    logic [$clog2(MAX_COLS) - 1:0] col_index;
    logic [$clog2(MAX_ROWS * MAX_COLS) - 1:0] real_index, relative_index;

    assign buffer = {flag, assignment_index, assignment_value};
    assign byte_out = (first_half)? buffer[7:0] : buffer[15:8];

    always_ff @(posedge clk)begin
        if (rst)begin
            send <= 0;
            first_start_msg <= 0;
            state <= IDLE;
            row_index <= 0;
            col_index <= 0;
            done <= 0;
        end else begin
            case(state)
                IDLE: begin
                    if(valid_in)begin
                        state <= TRANSMIT;
                        transmit_stage_state <= START;
                        row_index <= 0;
                        col_index <= 0;
                        real_index <= 0;
                        relative_index <= 0;
                        send <= 0;
                        first_start_msg <= 0;
                        first_half <= 1;
                    end
                    done <= 0;
                end
                TRANSMIT: begin
                    if (first_half)begin
                        case(transmit_stage_state)
                            START: begin
                                flag <= START_BOARD;
                                assignment_value <= 0;
                                if (first_start_msg) begin
                                    assignment_index <= n;
                                    transmit_stage_state <= ASSIGN;
                                end else begin
                                    assignment_index <= m;
                                    transmit_stage_state <= START;
                                end
                                state <= WAIT;
                                send <= 1;
                                first_start_msg <= ~first_start_msg;
                            end
                            ASSIGN: begin
                                flag <= AND;
                                assignment_index <= relative_index;
                                assignment_value <= solution[real_index];
                                if (col_index < n - 1) begin
                                    col_index <= col_index + 1;
                                    real_index <= real_index + 1;
                                end else begin
                                    col_index <= 0;
                                    if (row_index < m - 1) begin
                                        row_index <= row_index + 1;
                                        real_index <= real_index + 1 + (MAX_COLS - n);
                                    end else transmit_stage_state <= STOP;
                                end
                                relative_index <= relative_index + 1;
                                send <= 1;
                                state <= WAIT;
                            end
                            STOP: begin
                                if (flag == END_BOARD)begin
                                    state <= IDLE;
                                    send <= 0;
                                    done <= 1;
                                end else begin 
                                    flag <= END_BOARD;
                                    assignment_index <= 0;
                                    assignment_value <= 0;
                                    state <= WAIT;
                                    send <= 1;
                                end
                            end
                        endcase
                    end else begin
                        state <= WAIT;
                        send <= 1;
                    end
                    first_half <= ~first_half;
                end
                WAIT: begin
                    state <= (transmit_done)? TRANSMIT: WAIT;
                    send <= 0;
                end
            endcase
        end
    end
endmodule

`default_nettype wire
