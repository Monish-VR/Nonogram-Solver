`default_nettype none
`timescale 1ns / 1ps

module fpga_to_pc (
        input wire clk_100mhz,
        input wire btnc,
        input wire rx,

        output logic tx,
        output logic [7:0] bits,
        output logic [2:0] stat
    );

    //assign stat = {1, state};
    
    localparam START = 0;
    localparam TRANSMIT = 1;
    localparam WAIT = 2;
    localparam TIME = 3;

    localparam CYCLES = 1_000;
    localparam MAX_BYTE = 255;
    localparam COUNTER_WIDTH = $clog2(CYCLES);

    logic [COUNTER_WIDTH - 1: 0] counter;
    logic [7:0] byte_data, received_data, display_value;
    logic receive_done, valid_in, transmit_done;
    logic [1:0] state;
    logic clk_50mhz;
    assign bits = display_value;

    uart_tx transmitter (
        .clk(clk_50mhz),
        .rst(btnc),
        .axiiv(valid_in),
        .axiid(display_value),
        
        .axiod(tx),
        .done(transmit_done),
        .state(stat)
    );

    clk_wiz_50 divider (
        .clk_in1(clk_100mhz),
        .clk_out1(clk_50mhz)
    );

    always_ff @(posedge clk_50mhz)begin
        if (btnc) begin
            byte_data <= 0;
            display_value <= 0;
            counter <= 0;
            state <= START;
        end else begin
            case (state)
                START: begin
                    state <= TRANSMIT;
                    valid_in <= 1;
                end
                TRANSMIT: begin
                    state <= WAIT;
                    valid_in <= 1;
                    display_value <= display_value + 1;
                end
                WAIT: begin
                    if (transmit_done) state <= TRANSMIT;
                    valid_in <= 0;
                end
                /* TIME: begin
                    
                end */
            endcase
        end
    end

endmodule

`default_nettype wire
