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

    localparam CLK_FRQ = 100_000_000; //100 MHz
    localparam CYCLES_PER_BIT = CLK_FRQ / BAUD;
    localparam HALF_CYLE = CYCLES_PER_BIT >> 1;
    localparam COUNTER_WIDTH = $clog2(CYCLES_PER_BIT);

    localparam START_BIT = 1'b0;
    localparam STOP_BIT = 1'b1;

    localparam IDLE = 0;
    localparam START = 1;
    localparam RECEIVE = 2;
    localparam STOP = 3;

    logic [1:0] state;
    logic [COUNTER_WIDTH - 1:0] count;
    logic [2:0] data_index;

    always_ff @(posedge clk)begin
        if (rst)begin
            state <= IDLE;
            axiov <= 0;
        end else begin
            case (state)
                IDLE: begin
                    // receiving only starts when the receiver sees the 
                    // start bit (0)
                    if (axiid == START_BIT)begin
                        state <= START;
                        count <= 1;
                        data_index <= 0;
                    end
                    axiov <= 0;
                end
                START: begin
                    if (axiid != START_BIT) state <= IDLE;
                    else if (count == CYCLES_PER_BIT)begin
                        state <= RECEIVE;
                        count <= 1;
                    end else count <= count + 1;
                end
                RECEIVE: begin
                    if (count == CYCLES_PER_BIT)begin
                        if (data_index == 3'd7) state <= STOP;
                        else data_index <= data_index + 1;
                        count <= 1;
                    end else count <= count + 1;
                    
                    if (count == HALF_CYLE) axiod[data_index] <= axiid; // sample from middle
                end
                STOP: begin
                    if (axiid != STOP_BIT) state <= IDLE;
                    else if (count == CYCLES_PER_BIT)begin
                        axiov <= 1;
                        state <= IDLE;
                    end else count <= count + 1;
                end
            endcase
        end
    end

endmodule

`default_nettype wire
