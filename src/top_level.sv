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
    logic [7:0] byte_data, received_data, display_value;
    logic receive_done, valid_in, transmit_done, board_done, line_done, next_line;
    logic [1:0] state;
    logic [1023:0] fifo_in, fifo_out;
    logic fifo_empty, fifo_full;
    logic [3:0] n,m; // HARDCODED for 11x11
    logic [4:0] [6:0] options_per_line; // HARDCODED for 11x11

    assign rst = btnc;
    assign led = display_value;

    uart_tx transmitter (
        .clk(clk_100mhz),
        .rst(rst),
        .axiiv(valid_in),
        .axiid(byte_data),
        
        .axiod(tx),
        .done(transmit_done)
    );

    uart_rx receiver (
        .clk(clk_100mhz),
        .rst(rst),
        .axiid(rx),

        .axiov(receive_done),
        .axiod(received_data)
    );
        ///Parser will write to the BRAM
//parser need to output BRAM index 
//for each new line X increases, 
// at y==1 we put the line identifier
// for y>1 we put an assigment for one cell- i.e INDEX OF CELL, VALUE


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

    //BRAM INSTITIATION 
    //  Xilinx Single Port Read First RAM
    /* xilinx_single_port_ram_read_first #(
        .RAM_WIDTH(13),     //each slot in bram will be 13 bits- 12 bits for location 1 bit for boolean value
                            // UNLESS ITS LINE INDICATOR WHICH WILL BE up to 13 bits of indicating line
        .RAM_DEPTH(33562624),  //Full Calculation is on Dana's Ipad //M + M**2 + N + N**2 / / Specify RAM depth (number of entries) //Calculation is on my Ipad
        .RAM_PERFORMANCE("HIGH_PERFORMANCE") // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
    ) possible_options (
        .addra(bram_index), // Address bus, width determined from RAM_DEPTH //NOT SURE WHAT TO PUT HERE
        .dina(bram_input),  // RAM input data, width determined from RAM_WIDTH
        .clka(clk_100mhz),  // Clock
        .wea(slot_done),    // Write enable
        .ena(1),            // RAM Enable, for additional power savings, disable port when not in use
        .rsta(rst),        // Output reset (does not affect memory contents)
        .regcea(1),         // Output register enable
        .douta(bram_output) // RAM output data, width determined from RAM_WIDTH
    ); */

    fifo_11_by_11 fifo (
        .clk(clk_100mhz),                  // input wire clk
        .rst(rst),                      // input wire rst
        .din(fifo_in),                  // input wire [1023 : 0] din
        .wr_en(line_done),              // input wire wr_en
        .rd_en(next_line),              // input wire rd_en
        .dout(fifo_out),                // output wire [1023 : 0] dout
        .full(fifo_full),                    // output wire full
        .empty(fifo_empty),              // output wire empty
        .wr_rst_busy(),  // output wire wr_rst_busy DON'T NEED?
        .rd_rst_busy()  // output wire rd_rst_busy DON'T NEED?
    );

    //solver Module


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
