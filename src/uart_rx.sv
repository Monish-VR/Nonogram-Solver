`timescale 1ns / 1ps
`default_nettype none

module uart_rx #(parameter BAUD = 'd9600)(
        input wire clk,
        input wire rst,
        input wire axiid,
        
        output logic axiov,
        output logic [7:0] axiod
    );

    /*
        UART Transmission protocol:
        10 bits are sent per byte at a transmission rate of x baud (baud = bits per second)
        
        bit 0 - start bit or 0
        bit 1 to 8 - the data byte being transmitted in lsb order (0, 1, ..., 7)
        bit 9 - stop bit or 1

        Each bit is held for a certain number of cycles depending on clk frequency
        and the baud of the connection. The bit is sampled halfway through its hold time
        to ensure correctness as much as possible.
    */

    localparam CLK_FRQ = 50_000_000; //50 MHz
    localparam CYCLES_PER_BIT = CLK_FRQ / BAUD;
    localparam COUNTER_WIDTH = $clog2(CYCLES_PER_BIT);

    localparam START_BIT = 1'b0;
    localparam STOP_BIT = 1'b1;

    localparam IDLE = 0;
    localparam START = 1;
    localparam RECEIVE = 2;
    localparam STOP = 3;
    localparam CLEAN = 4;

    logic [2:0] state;
    logic [COUNTER_WIDTH - 1:0] count;
    logic [2:0] data_index;
    logic curr_bit = 1;
    logic next_bit = 1;

    /*
        FIX :)
            ISSUE - metastability issues as reading axiid
            SOLUTION - store axiid in register and read from there
    */
    always_ff @(posedge clk)begin
        next_bit <= axiid;
        curr_bit <= next_bit;
    end

    always_ff @(posedge clk)begin
        case (state)
            IDLE: begin
                // receiving only starts when the receiver sees the 
                // start bit (0)
                if (curr_bit == START_BIT)begin
                    state <= START;
                    count <= 1;
                    data_index <= 0;
                end
                axiod <= 0;
            end
            START: begin
                if (count > (CYCLES_PER_BIT >> 1)) begin
                    if (curr_bit != START_BIT) state <= IDLE;
                    else begin
                        state <= RECEIVE;
                        count <= 1;
                        axiod <= 0;
                    end
                end else count <= count + 1;
            end
            RECEIVE: begin
                if (count >= CYCLES_PER_BIT)begin
                    axiod[data_index] <= curr_bit;
                    if (data_index == 3'd7) state <= STOP;
                    else data_index <= data_index + 1;
                    count <= 1;
                end else count <= count + 1;
            end
            STOP: begin
                if (count >= CYCLES_PER_BIT && curr_bit == STOP_BIT)begin
                    axiov <= 1;
                    state <= CLEAN;
                    count <= 1;
                end else count <= count + 1;
            end
            CLEAN: begin
                state <= IDLE;
                axiov <= 0;
            end
        endcase
    end
endmodule

`default_nettype wire
