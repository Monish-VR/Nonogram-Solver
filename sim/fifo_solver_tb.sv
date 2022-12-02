`default_nettype none
`timescale 1ns / 1ps

`define status
$display(" %b | %b | %b \n", known[0][0], known[0][1], known[0][2]);
$display(" %b | %b | %b \n", known[1][0], known[1][1], known[1][2]);
$display(" %b | %b | %b \n", known[2][0], known[2][1], known[2][2]);
$display("\n");
$display(next_line);
$display("\n");

module fifo_solv_tb;

    logic clk;
    logic rst;
    logic started;
    logic [2:0] option;
    logic valid_in;
    logic [2*SIZE:0] [6:0] old_options_amnt;
    logic [SIZE-1:0]  [SIZE-1:0] assigned;
     logic put_back_to_FIFO;  //boolean- do we need to push to fifo
     logic solved ;


    slover solv (
        .clk(clk),
        .rst(rst),
        .started(started),
        .option(option)
        .valid_op(valid_in),
        .put_back_to_FIFO(put_back_to_FIFO),  
        .assigned(assigned),
        .solved(solved)
    );

    always begin
        #5;
        clk = !clk;
    end
    initial begin
        $dumpfile("fifo_solv.vcd");
        $dumpvars(0, solver_tb);
        $display("Starting Sim FIFO Solver");
        clk = 0;
        rst = 0;
        valid_in = 0;
        #5;
        rst = 1;
        #10;
        rst = 0;
        //@Ninas test commented:
        // //test the special one case
        // valid_in = 1;
        // option = 3'b101;
        // options_per_line[0] = 1;
        // #5;
        #10;
        //create a board which is :
        // 1 1 0
        // 0 1 0
        // 1 0 1
        // row 1 : 110 011
        //row 2: 100 010 001
        //row 3: 101
        //col 1:  101
        //col 2: 110 011
        //col 3: 100 010 001

        $display("put this back in FIFO should be 0 but we got %b", put_back_to_FIFO);
        started = 1;
        option = 0 ; //first line index 
        valid_in = 1;
        old_options_amnt = [[2],[3],[1],[1],[2],[3]]; //logic [2*SIZE:0] [6:0]
        
        status();
        #10;
        option = 3'b110 ; //row 1 first opt
        valid_in = 1;
        status();
        #10;
        option = 3'b011 ; //row 1 2 opt
        valid_in = 1;
        status();
        #10;
        option = 3'b001 ; //row 2 line index
        valid_in = 1;
        status();
        #10;
        option = 3'b100 ; //row 2 opt 1
        valid_in = 1;
        status();
        #10;
        option = 3'b010  ; //row 2 opt 2
        valid_in = 1;
        status();
        #10;
        option = 3'b001  ; //row 2 opt 3
        valid_in = 1;
        status();
        #10;
        option = 3'b010  ; //row 3 line ind (==2)
        valid_in = 1;
        status();
        #10;

        //SHOULD HAVE ONLY ONE OPTION SO ASSIGN:
        option = 3'b101  ; //row 3 opt 1
        valid_in = 1;
        status();
        #10;

        option = 3'b011  ; //col 1 line ind 
        valid_in = 1;
        status();
        #10;
        option = 3'b101  ; //col 1 opt 1 
        valid_in = 1;
        status();
        #10;
        option = 3'b100  ; //col 2 line ind 
        valid_in = 1;
        status();
        #10;
        option = 3'b110 ; //col 2 first opt
        valid_in = 1;
        status();
        #10;
        option = 3'b011 ; //col 2 2 opt
        valid_in = 1;
        status();
        #10;
        option = 3'b101  ; //col 3 line ind 
        valid_in = 1;
        status();
        #10;
        option = 3'b100 ; //col 3 opt 1
        valid_in = 1;
        status();
        #10;
        option = 3'b010  ; //col 3 opt 2
        valid_in = 1;
        status();
        #10;
        option = 3'b001  ; //col 3 opt 3
        valid_in = 1;
        status();
        #10;


        $display("put this back in FIFO should be 0 but we got %b", put_back_to_FIFO);
        $display("the assignments made to the board",assigned_board);//ask about how to print out all the assignments
        $display("the amount of options left sohuld be 0 but is %b", options_amnt);
        $display("valid out sohuld be 1 but is %b", valid_out);


        $display("Finishing Sim");
        $finish;
    end

endmodule

`default_nettype wire
