`timescale 1ns / 1ps
`default_nettype none

module simplify#(parameter size = 3)(//TODO: change this number
        input wire clk,
        input wire rst,
        input wire valid_in,
        input wire [size-1:0] assigned,
        input wire [size-1:0] known,
        input wire [size-1:0] option,
        
        output logic valid,
        output logic contradict
);
/*
simplify module 
takes in the 3 things about a line: one option, whats known, and the already assigned values
returns if we need to delete an option from the FIFO where the line has all the options.
valid returns if the run was valid

*/

always_comb begin
    if (valid_in) begin
        if (((assigned ^ option) & known) > 0) begin
            contradict = 1;
        end else begin
            contradict = 0;
        end 
        valid = 1;
    end else begin
        valid = 0; 
    end
end

endmodule

`default_nettype wire