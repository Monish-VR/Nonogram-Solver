`default_nettype none
`timescale 1ns / 1ps

module top_level (
        input wire clk_100mhz,
        input wire btnc,
        input wire rx,

        output logic tx,
        output logic [7:0] led
    );
    
    localparam RECEIVE = 0;
    localparam SOLVE = 1;
    localparam TRANSMIT = 2;

    localparam CYCLES = 50_000_000;
    localparam MAX_BYTE = 255;
    localparam COUNTER_WIDTH = $clog2(CYCLES);

    logic rst;
    logic [COUNTER_WIDTH - 1: 0] counter;
    logic [7:0] transmit_data, received_data, display_value;
    logic receive_done, transmit_valid, transmit_done, board_done, line_done, next_line;
    logic [1:0] state;
    logic [15:0] fifo_in, fifo_out;
    logic fifo_empty, fifo_full;
    logic solved;
    logic [3:0] n,m; // HARDCODED for 11x11
    logic [4:0] [6:0] options_per_line; // HARDCODED for 11x11
    logic [10:0] [10:0] solution; // HARDCODED for 11x11

    assign rst = btnc;
    assign led = display_value;

    uart_rx receiver (
        .clk(clk_100mhz),
        .rst(rst),
        .axiid(rx),

        .axiov(receive_done),
        .axiod(received_data)
    );

    parser parse (
        .clk(clk_100mhz),
        .rst(rst),
        .byte_in(received_data),
        .valid_in(receive_done),

        .board_done(board_done), //board is done 
        .write_ready(line_done), //Indication that we need to write to BRAM ,here in top level , we done with one line to the BRAM, ready to get new one
        .line(fifo_in),
        .options_per_line(options_per_line),
        .n(n),
        .m(m)
    );

    fifo_11_by_11 fifo (
        .clk(clk_100mhz),               // input wire clk
        .rst(rst),                      // input wire rst
        .din(fifo_in),                  // input wire [15 : 0] din
        .wr_en(line_done),              // input wire wr_en
        .rd_en(next_line),              // input wire rd_en
        .dout(fifo_out),                // output wire [15 : 0] dout
        .full(fifo_full),               // output wire full
        .empty(fifo_empty),             // output wire empty
        .wr_rst_busy(),                 // output wire wr_rst_busy DON'T NEED?
        .rd_rst_busy()                  // output wire rd_rst_busy DON'T NEED?
    );

    //solver Module
    solver solve (
        //TODO: confirm sizes for everything
        .clk(clk_100mhz),
        .rst(rst),
        .started(board_done), //indicates board has been parsed, ready to solve
        .option(fifo_out),
        .num_rows(m),
        .num_cols(n),
        .valid_op(next_line),
        .old_options_amnt(options_per_line),  //[0:2*SIZE] [6:0]
        //Taken from the BRAM in the top level- how many options for this line

        .new_option(fifo_in),
        .assigned(solution),  
        .put_back_to_FIFO(line_done),  //boolean- do we need to push to fifo
        .solved(solved) // board is 
    );


    assembler assemble (
        .clk(clk_100mhz),
        .rst(rst),
        .valid_in(solved),
        .transmit_busy(~transmit_done),
        .solution(solution),
        .n(n),  //11x11
        .m(m),  //11x11

        .transmit_ready(transmit_valid),
        .byte_out(transmit_data)
    );

    uart_tx transmitter (
        .clk(clk_100mhz),
        .rst(rst),
        .axiiv(transmit_valid),
        .axiid(transmit_data),
        
        .axiod(tx),
        .done(transmit_done)
    );


    always_ff @(posedge clk_100mhz)begin
        if (rst) begin
            byte_data <= 0;
            display_value <= 0;
            counter <= 0;
            state <= RECEIVE;
            next_line <= 0;
        end else begin
            case (state)
                RECEIVE: begin
                    if (board_done) state <= SOLVE;
                end
                SOLVE: begin
                    //find solution. 
                end
                TRANSMIT: begin
                    // transmit solution back to PC
                end
            endcase
        end
    end

endmodule

`default_nettype wire
