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


    parser parse (.clk(clk_100mhz),
        .rst(btnc),
        .axiid(received_data),
        .axiiv(receive_done)

        .axiov(done_board), //board is done 
        .axiovl(slot_done), //Indication that we need to write to BRAM ,here in top level , we done with one line to the BRAM, ready to get new one
          .axiod(slot_data) //number of 

    )

    //BRAM INSTITIATION 
  //  Xilinx Single Port Read First RAM
  xilinx_single_port_ram_read_first #(
    .RAM_WIDTH(18),                       // Specify RAM data width
    .RAM_DEPTH(1024),                     // Specify RAM depth (number of entries)
    .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
    .INIT_FILE(`FPATH(data.mem))          // Specify name/location of RAM initialization file if using one (leave blank if not)
  ) bram_options (
  .addra(addra),     // Address bus, width determined from RAM_DEPTH //NOT SURE WHAT TO PUT HERE
    .dina(slot_data),       // RAM input data, width determined from RAM_WIDTH
    .clka(clk_100mhz),       // Clock
    .wea(slot_done),         // Write enable
    .ena(ena),         // RAM Enable, for additional power savings, disable port when not in use
    .rsta(btnc),       // Output reset (does not affect memory contents)
    .regcea(regcea),   // Output register enable
    .douta(douta)      // RAM output data, width determined from RAM_WIDTH
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
