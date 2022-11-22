`default_nettype none
`timescale 1ns / 1ps

module fifo_solv_tb;

    
    logic clk;
    logic rst;
    logic valid_in;
    logic [1023:0] read_FIFO;
    logic [6:0] options_per_line;
    logic [size-1:0]assigned [size-1:0];
    logic [6:0] new_options_amnt;
    logic write_to_fifo;
    logic [1023:0] dout;
    logic [4:0] line_ind;
    logic [11:0] assigned_board [size-1:0]
    
    fifo_solver solv (
        .clk(clk),
        .rst(rst),
        .read_FIFO(read_FIFO),
        .options_per_line(options_per_line),  
        .new_options_amnt(new_options_amnt), 
        .assigned(assigned_board),
        .doubt(doubt),
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
        //valid_in = 0;
        #5;
        rst = 1;
        #10;
        rst = 0;

        line_ind = 4'b0;
        options = 00000000101;
        options = 000000000010000000001000000000100;//ask aobut how to combine options
        read_FIFO = 1;
        options_per_line = 3;

        $display("new options amount %d", new_options_amnt);
        $display("the assignments made to the board",assigned_board);//ask about how to print out all the assignments
        $display("new board line is %b" doubt);


        $display("Finishing Sim");
        $finish;
    end

endmodule

`default_nettype wire
