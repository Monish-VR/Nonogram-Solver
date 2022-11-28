`default_nettype none
`timescale 1ns / 1ps

module FIFO_tb;

    
    logic clk;
    logic rst;
    logic valid_in;
    logic [1:0] SIZE;

    logic [2:0] option;
    logic [2:0] line_ind;
    logic valid_op;
    logic row;
    logic [3:0] option_num;

     logic  [2:0]  [2:0] assigned; 
     logic put_back_to_FIFO;  //boolean- do we need to push to fifo
     logic new_option_num; // for the BRAM gonna either be same as option num or 1 less
     logic valid_out;
    
    fifo_solver  solver (
        .clk(clk),
        .rst(rst),
        .option(option),
        .line_ind(line_ind),
        .valid_op(valid_op),
        .row(row), //is it a row or a column (line indices repeat, once for the row index and once for the column)
        .option_num(option_num),//Taken from the BRAM in the top level- how many options for this line

//outputs
        .assigned(assigned),  
        .put_back_to_FIFO(put_back_to_FIFO),  //boolean- do we need to push to fifo
        .new_option_num(new_option_num), // for the BRAM gonna either be same as option num or 1 less
        .valid_out(valid_out)
    );

    always begin
        #5;
        clk = !clk;
    end
    initial begin
        $dumpfile("fifo_solv.vcd");
        $dumpvars(0, FIFO_tb);
        $display("Starting Sim FIFO Solver");
        clk = 0;
        rst = 0;
        //valid_in = 0;
        //first row in
        #5;
        rst = 1;
        #10;
        rst = 0;
        #10;
        

        //shouldnt do anything, just not contradict:
        option = 3'b100;
        option_num =3;
        line_ind = 0;
        valid_op =1;
        row =1;

        #10;
        #10;
        option = 3'b010;
        option_num =2;
        line_ind = 0;
        valid_op =1;
        row =1;



        #10;
        #10;
        option = 3'b001;
        option_num =1;
        line_ind = 0;
        valid_op =1;
        row =1;

        #10;
        #10;
        //should cotradict :
        option = 3'b100;
        option_num =3;
        line_ind = 3; //first column
        valid_op =1;
        row =0;

$display("assigned %d", assigned);
//shoudnt contradict
        #10;
        #10;
        option = 3'b010;
        option_num =2;
        line_ind = 1;
        valid_op =1;
        row =1;

        #10;
        #10;
        option = 3'b001;
        option_num =1;
        line_ind = 1;
        valid_op =1;
        row =1;

$display("assigned 2 %d", assigned);


        // $display("new options amount %d", new_options_amnt);
        // $display("the assignments made to the board",assigned_board);//ask about how to print out all the assignments
        // $display("new board line is %b" doubt);


        $display("Finishing Sim");
        $finish;
    end

endmodule

`default_nettype wire
