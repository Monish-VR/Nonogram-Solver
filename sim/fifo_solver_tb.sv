`default_nettype none
`timescale 1ns / 1ps

module fifo_solv_tb;

    logic clk;
    logic rst;
    logic [2:0] option;
    logic valid_in;
    logic [1023:0] read_FIFO;
    logic [6:0] options_per_line;
    logic [6:0] options_amnt;
    logic write_to_fifo;
    logic [4:0] line_ind;
    logic [2:0] [2:0] assigned_board ;
    logic valid_out;


    fifo_solver solv (
        .clk(clk),
        .rst(rst),
        .valid_op(valid_in),
        .put_back_to_FIFO(write_to_fifo),  
        .new_option_num(options_amnt), 
        .assigned(assigned_board),
        .valid_out(valid_out)
    );

    always begin
        #5;
        clk = !clk;
    end
    initial begin
        $dumpfile("fifo_solv.vcd");
        $dumpvars(0, simplify_tb);
        $display("Starting Sim FIFO Solver");
        clk = 0;
        rst = 0;
        valid_in = 0;
        #5;
        rst = 1;
        #10;
        rst = 0;

        //test the special one case
        valid_in = 1;
        option = 3'b101;
        options_per_line[0] = 1;
        #5;

        $display("put this back in FIFO should be 0 but we got %b", put_back_to_FIFO);
        $display("the assignments made to the board",assigned_board);//ask about how to print out all the assignments
        $display("the amount of options left sohuld be 0 but is %b", options_amnt);
        $display("valid out sohuld be 1 but is %b", valid_out);


        $display("Finishing Sim");
        $finish;
    end

endmodule

`default_nettype wire
