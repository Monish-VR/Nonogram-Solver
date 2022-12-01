`timescale 1ns / 1ps
`default_nettype none

module assembler(
        input wire clk,
        input wire rst,
        input wire valid_in,
        input wire [10:0] [10:0] solution,

        output logic valid_out,
        output logic [7:0] byte_out,

        //********** HARDCODED FOR NOW - DO MATH LATER ************//
        // assuming 11x11 max board
        input wire [3:0] n, m
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
    logic [3:0] row_index, col_index;
    logic [10:0] row;

    assign buffer = {flag, assignment_index, assignment_value};
    assign byte_out = (count)? buffer[7:0] : buffer[15:8];

    always_ff @(posedge clk)begin
        if (rst)begin
            valid_out <= 0;
            byte_out <= 0;
            buffer <= 0;
            count <= 0;
            state <= IDLE;
            row_index <= 0;
            col_index <= 0;
            row <= 0;
        end else begin
            if (count)begin //second half of message
                count <= 0;
                valid_out <= 1;
            end
            else begin
                case(state)
                    IDLE: begin
                        if (valid_in)begin
                            flag <= START_BOARD;
                            assignment_index <= m;
                            assignment_value <= 0;
                            count <= 1;
                            valid_out <= 1;
                            state <= START;
                        end
                    end
                    START: begin
                        assignment_index <= n;
                        count <= 1;
                        valid_out <= 1;
                        state <= NEW_LINE;
                    end
                    NEW_LINE: begin
                        flag <= START_LINE;
                        assignment_index <= 12'b0;
                        assignment_value <= 0;
                        count <= 1;
                        valid_out <= 1;
                        state <= ASSIGN;
                        row <= solution[row_index];
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
                        valid_out <= 1;
                        if (row_index + 1 < m)begin
                            row_index <= row_index + 1;
                            state <= NEW_LINE;
                        end else state <= STOP;
                    end
                    STOP: begin
                        flag <= END_BOARD;
                        assignment_index <= 12'b0;
                        assignment_value <= 0;
                        state <= IDLE;
                    end
                    default: valid_out <= 0;
                endcase
            end
        end
    end
endmodule

`default_nettype wire
