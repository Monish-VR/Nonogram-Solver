`default_nettype none
`timescale 1ns / 1ps

module fifo_2_tb();

//3X3 board

    logic [1023:0] data_in;

    logic clk;
    logic rst;
    logic valid_in;

    logic write_to_fifo;
    logic [1023:0] d_out;
    reg [2:0] known [2:0]; // 0 if we dont have assigned bit at this loc 1 if we do
    reg [2:0] assigned [2:0];
    logic [6:0] option_counter;
    logic [6:0] opt;

//SHOULD WE ADD M N ROW AND SUCH

    solver uut (
        .clk(clk),
        .rst(rst),
        .valid_in(valid_in),
        
        .read_FIFO(data_in),
        .options_per_line(opt), 

        .write_to_fifo(write_to_fifo), //when we simplified a line and want to put it back
        //output logic rd_from_fifo, // when we want to read a nw line
        .dout(d_out), //simplified line out, write to fifo
        .assigned_board(assigned), //when we're done we send the board
        // .solved(), //signals solver is done sends assigned board
        .option_counter(option_counter)

    );


    always begin
        #5;
        clk = !clk;
    end
    initial begin
        $dumpfile("fifo_solve_tb.vcd");
        $dumpvars(0, fifo2_tb);
        $display("Starting Sim Parser");
        $display("Middle option should fail");
        clk = 0;
        rst = 0;
        valid_in = 0;
        #5;
        rst = 1;
        #10;
        rst = 0;
        #10;
        valid_in = 1;
        data_in = { 1010'b0 , 10001000100001}; // options 100 010 001 for line 1
        known[0] = 3'b010;
        #10;

        valid_in = 0;
        #1000;
        rst = 1;
        #10;
        rst = 0;
        #10;
        valid_in = 1;
      data_in = { 1010'b0 , 00001000100001}; // options 000 010 001 for line 1
      known[0] = 3'b000;
        #10;

        valid_in = 0;
        #1000;

                rst = 1;
        #10;
        rst = 0;

        $display("Finishing Sim");
        $finish;
    end

endmodule

`default_nettype wire
