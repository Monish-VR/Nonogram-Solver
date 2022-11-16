`default_nettype none
`timescale 1ns / 1ps

module top_level (
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
    logic receive_done, valid_in, transmit_done, board_done, slot_done;
    logic [1:0] state;
    logic [12:0] bram_input, bram_output;
    logic [25:0] bram_index;
    logic [11:0] n,m;

    assign led = display_value;

    uart_tx transmitter (
        .clk(clk_100mhz),
        .rst(btnc),
        .axiiv(valid_in),
        .axiid(byte_data),
        
        .axiod(tx),
        .done(transmit_done)
    );

    uart_rx receiver (
        .clk(clk_100mhz),
        .rst(btnc),
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
        .rst(btnc),
        .byte_in(received_data),
        .valid_in(receive_done)

        .board_done(board_done), //board is done 
        .write_ready(slot_done), //Indication that we need to write to BRAM ,here in top level , we done with one line to the BRAM, ready to get new one
        .assignment(bram_output) //number of 
        .write_index(bram_index), ///address to write the assignment to in BRAM
        .n(n),
        .m(m);
    )

    //BRAM INSTITIATION 
    //  Xilinx Single Port Read First RAM
    xilinx_single_port_ram_read_first #(
        .RAM_WIDTH(13),     //each slot in bram will be 13 bits- 12 bits for location 1 bit for boolean value
                            // UNLESS ITS LINE INDICATOR WHICH WILL BE up to 13 bits of indicating line
        .RAM_DEPTH(33562624),  //Full Calculation is on Dana's Ipad //M + M**2 + N + N**2 / / Specify RAM depth (number of entries) //Calculation is on my Ipad
        .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
    ) bram_options (
        .addra(bram_index), // Address bus, width determined from RAM_DEPTH //NOT SURE WHAT TO PUT HERE
        .dina(bram_input),  // RAM input data, width determined from RAM_WIDTH
        .clka(clk_100mhz),  // Clock
        .wea(slot_done),    // Write enable
        .ena(1),            // RAM Enable, for additional power savings, disable port when not in use
        .rsta(btnc),        // Output reset (does not affect memory contents)
        .regcea(1),         // Output register enable
        .douta(bram_output) // RAM output data, width determined from RAM_WIDTH
    );

    //solver Module



    /*always_ff @(posedge clk_100mhz)begin
        if (btnc) begin
            byte_data <= 0;
            display_value <= 0;
            counter <= 0;
            state <= START;
        end else begin
            if (receive_done) display_value <= received_data;
        end
    end*/

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
