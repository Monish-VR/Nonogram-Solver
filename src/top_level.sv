`default_nettype none
`timescale 1ns / 1ps

module top_level (
        input wire clk_100mhz,
        input wire btnc,
        input wire rx,

        output logic tx,
        output logic [7:0] led
    );
    
    localparam MAX_ROWS = 11;  // HARDCODED for 11x11
    localparam MAX_COLS = 11;  // HARDCODED for 11x11
    localparam LARGEST_DIM = (MAX_ROWS > MAX_COLS)? MAX_ROWS : MAX_COLS;
    localparam MAX_NUM_OPTIONS = 84; //HARDCODED for 11x11

    localparam RECEIVE = 0;
    localparam SOLVE = 1;
    localparam TRANSMIT = 2;

    localparam CYCLES = 50_000_000;
    localparam MAX_BYTE = 255;
    localparam COUNTER_WIDTH = $clog2(CYCLES);

    logic rst;
    logic [COUNTER_WIDTH - 1: 0] counter;
    logic [7:0] transmit_data, received_data, display_value;
    logic receive_done, transmit_valid, transmit_done, next_line, read_first_line;
    logic fifo_write, parse_write, solve_write, solve_next;
    logic [1:0] state;
    logic [15:0] fifo_in, fifo_out, parse_line, solve_line;
    logic fifo_empty, fifo_full;
    logic parsed, solved, assembled;
    logic [2:0] [$clog2(MAX_ROWS) - 1:0] m;
    logic [2:0] [$clog2(MAX_COLS) - 1:0] n;
    logic [1:0] [MAX_ROWS + MAX_COLS - 1:0] [$clog2(MAX_NUM_OPTIONS) - 1:0] options_per_line;
    logic [1:0] [(MAX_ROWS * MAX_COLS) - 1:0] solution;
    logic clk_50mhz;

    assign rst = btnc;
    assign led = display_value;
    //veronica its beautiful.. ^o^
    assign fifo_write = (state == RECEIVE)? parse_write : solve_write;
    assign fifo_in = (state == RECEIVE)? parse_line : solve_line;
    assign next_line = read_first_line || solve_next;

    /* clk_wiz_50 divider (
        .clk_in1(clk_100mhz),
        .clk_out1(clk_50mhz)
    ); */

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

        .board_done(parsed), //board is done 
        .write_ready(parse_write), //Indication that we need to write to BRAM ,here in top level , we done with one line to the BRAM, ready to get new one
        .first_read(read_first_line),
        .line(parse_line),
        .options_per_line(options_per_line[0]),
        .n(n[0]),
        .m(m[0])
    );

    fifo_11_by_11 fifo (
        .clk(clk_100mhz),               // input wire clk
        .srst(rst),                      // input wire rst
        .din(fifo_in),                  // input wire [15 : 0] din
        .wr_en(fifo_write),              // input wire wr_en
        .rd_en(next_line),              // input wire rd_en
        .dout(fifo_out),                // output wire [15 : 0] dout
        .full(fifo_full),               // output wire full
        .empty(fifo_empty)             // output wire empty
    );

    //solver Module
    solver sol (
        //TODO: confirm sizes for everything
        .clk(clk_100mhz),
        .rst(rst),
        .started(parsed), //indicates board has been parsed, ready to solve
        .option(fifo_out),
        .num_rows(m[1]),
        .num_cols(n[1]),
        .old_options_amnt(options_per_line[1]),  //[0:2*SIZE] [6:0]
        //Taken from the BRAM in the top level- how many options for this line
        .new_line(solve_next),
        .new_option(solve_line),
        .assigned(solution[0]),  
        .put_back_to_FIFO(solve_write),  //boolean- do we need to push to fifo
        .solved(solved) // board is 
    );

    assembler assemble (
        .clk(clk_100mhz),
        .rst(rst),
        .valid_in(solved),
        .transmit_busy(~transmit_done),
        .solution(solution[1]),
        .n(n[2]),  //11x11
        .m(m[2]),  //11x11

        .transmit_ready(transmit_valid),
        .byte_out(transmit_data),
        .done(assembled)
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
            display_value <= 0;
            counter <= 0;
            state <= 0;
        end else begin
            options_per_line[1] <= options_per_line[0];
            solution[1] <= solution[0];
            n[1] <= n[0];
            n[2] <= n[1];
            m[1] <= m[0];
            m[2] <= m[1];
            case(state)
                RECEIVE: state <= (parsed)? SOLVE : RECEIVE;
                SOLVE: state <= (solved)? TRANSMIT : SOLVE;
                TRANSMIT: state <= (assembled)? RECEIVE: TRANSMIT;
            endcase
        end
    end

endmodule

`default_nettype wire
