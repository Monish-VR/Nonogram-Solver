`timescale 1ns / 1ps
`default_nettype none

module uart_tx #(parameter BAUD = 'd9600)(
        input wire clk,
        input wire rst,
        input wire axiiv,
        input wire [7:0] axiid,
        
        output logic axiod,
        output logic done
    );

    /*
        UART Transmission protocol:
        10 bits are sent per byte at a transmission rate of x baud (baud = bits per second)
        
        bit 0 - start bit or 0
        bit 1 to 8 - the data byte being transmitted in lsb order (0, 1, ..., 7)
        bit 9 - stop bit or 1

        Each bit must be held for a certain number of cycles depending on clk frequency
        and the baud of the connection.
    */

    localparam CLK_FRQ = 100_000_000; //100 MHz
    localparam CYCLES_PER_BIT = CLK_FRQ / BAUD; //Baud is the bits per second transmission rate
    localparam COUNTER_WIDTH = $clog2(CYCLES_PER_BIT);

    localparam START_BIT = 1'b0;
    localparam STOP_BIT = 1'b1;

    localparam IDLE = 0;
    localparam START = 1;
    localparam TRANSMIT = 2;
    localparam STOP = 3;

    logic [1:0] state;
    logic [COUNTER_WIDTH - 1:0] count;
    logic [2:0] data_index;

    always_ff @(posedge clk)begin
        if (rst)begin
            state <= IDLE;
            done <= 1;
            axiod <= 1;
        end else begin
            case (state)
                IDLE: begin
                    if (axiiv)begin
                        axiod <= START_BIT;
                        state <= START;
                        count <= 1;
                        data_index <= 0;
                        done <= 0;
                    end
                end
                START: begin
                    if (count == CYCLES_PER_BIT)begin
                        state <= TRANSMIT;
                        axiod <= axiid[data_index];
                        count <= 1;
                    end else count <= count + 1;
                end
                TRANSMIT: begin
                    if (count == CYCLES_PER_BIT)begin
                        if (data_index == 3'd7) begin
                            state <= STOP;
                            axiod <= STOP_BIT;
                        end else begin
                            data_index <= data_index + 1;
                            axiod <= axiid[data_index + 1];
                        end
                        count <= 1;
                    end else count <= count + 1;
                end
                STOP: begin
                    if (count == CYCLES_PER_BIT)begin
                        done <= 1;
                        state <= IDLE;
                    end else count <= count + 1;
                end
            endcase
        end
    end

endmodule

`default_nettype wire
