`default_nettype none
`timescale 1ns / 1ps

module simplify_tb;
    logic clk;
    logic rst;
    logic valid_in;

    logic [2:0] assignment;
    logic [2:0] option;
    logic [2:0] known;


    logic valid;
    logic contradict;

    simplify #(
        .size(3))
        s (
        .clk(clk),
        .rst(rst),
        .valid_in(valid_in),
        .assigned(assignment),  
        .known(known), 
        .option(option),
        .valid(valid),
        .contradict(contradict)
    );



    always begin
        #5;
        clk = !clk;
    end
    initial begin
        $dumpfile("simplify.vcd");
        $dumpvars(0, simplify_tb);
        $display("Starting Sim Simplifier");
        clk = 0;
        rst = 0;
        valid_in = 0;
        #5;
        rst = 1;
        #10;
        rst = 0;

        valid_in = 1;
        assignment = 3'b001;
        option = 3'b111;
        known = 3'b101;
        #10;
        $display("valid out is %b and contradiction is %b", valid, contradict);

        $display("Finishing Sim");
        $finish;
    end

endmodule

`default_nettype wire
