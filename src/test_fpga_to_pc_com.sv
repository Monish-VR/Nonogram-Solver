`default_nettype none
`timescale 1ns / 1ps

module fpga_to_pc (
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

    localparam CYCLES = 1_000;
    localparam MAX_BYTE = 255;
    localparam COUNTER_WIDTH = $clog2(CYCLES);

    logic [COUNTER_WIDTH - 1: 0] counter;
    logic [7:0] byte_data, received_data, display_value;
    logic receive_done, valid_in, transmit_done;
    logic [1:0] state;

    assign led = display_value;

    uart_tx transmitter (
        .clk(clk_100mhz),
        .rst(btnc),
        .axiiv(valid_in),
        .axiid(byte_data),
        
        .axiod(tx),
        .done(transmit_done)
    );

    always_ff @(posedge clk_100mhz)begin
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
                    if (transmit_done) state <= WAIT;
                    valid_in <= 0;
                end
                WAIT: begin
                    if (counter == CYCLES) begin
                        counter <= 0;
                        state <= START;
                        byte_data <= byte_data + 1;
                        display_value <= display_value + 1;
                    end
                    else counter <= counter + 1;
                end
            endcase
        end
    end

endmodule

`default_nettype wire
