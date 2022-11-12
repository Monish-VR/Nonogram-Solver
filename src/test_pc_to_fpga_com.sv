`default_nettype none
`timescale 1ns / 1ps

module pc_to_fpga (
        input wire clk_100mhz,
        input wire btnc,
        input wire btnu,
        input wire rx,

        output logic tx,
        output logic [7:0] led
    );
    
    localparam START = 0;
    localparam TRANSMIT = 1;
    localparam WAIT = 2;

    localparam CYCLES = 50_000_000;
    localparam MAX_BYTE = 255;
    localparam COUNTER_WIDTH = $clog2(CYCLES);

    logic [COUNTER_WIDTH - 1: 0] counter;
    logic [7:0] byte_data, received_data, display_value;
    logic receive_done, valid_in, transmit_done;
    logic [1:0] state;

    assign led = counter;

    uart_rx receiver (
        .clk(clk_100mhz),
        .rst(btnc),
        .axiid(rx),

        .axiov(receive_done),
        .axiod(received_data)
    );

    always_ff @(posedge clk_100mhz)begin
        if (btnc) begin
            byte_data <= 0;
            display_value <= 0;
            counter <= 0;
            state <= START;
        end else begin
            if (receive_done) counter <= counter + 1;
        end
    end

endmodule

`default_nettype wire
