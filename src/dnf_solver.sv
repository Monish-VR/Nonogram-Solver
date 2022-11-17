/* `default_nettype none
`timescale 1ns / 1ps

module dnf_solver(
        input wire clk_100mhz,
        input wire btnc,
        input wire slot_data,
        input wire n,
        input wire m,

        output wire solution, // put 1s for black squares at the correct indices
        output wire solved,
        output wire request_bram_line // do not touch
    );
    

    logic [COUNTER_WIDTH - 1: 0] counter;
    logic [7:0] byte_data, received_data, display_value;
    logic receive_done, valid_in, transmit_done, board_done, slot_done;
    logic [1:0] state;
    logic [12:0] bram_input, bram_output;
    logic [25:0] bram_index;
    logic [11:0] solution;

   

    //BRAM INSTITIATION 
    //  Xilinx Single Port Read First RAM
    xilinx_single_port_ram_read_first #(
        .RAM_WIDTH(13),     //each slot in bram will be 13 bits- 12 bits for location 1 bit for boolean value
                            // UNLESS ITS LINE INDICATOR WHICH WILL BE up to 13 bits of indicating line
        .RAM_DEPTH(33562624),  //Full Calculation is on Dana's Ipad //M + M**2 + N + N**2 / / Specify RAM depth (number of entries) //Calculation is on my Ipad
        .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
    ) possible_options (
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


    always_ff @(posedge clk_100mhz)begin
        if (btnc) begin
            byte_data <= 0;
            display_value <= 0;
            counter <= 0;
            state <= RECEIVE;
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

module option_reader (
        input wire clk_100mhz,
        input wire line_index,
        input wire m,
        input wire n,
        
        output wire line_done,
        output wire line
    );

endmodule

`default_nettype wire
 */