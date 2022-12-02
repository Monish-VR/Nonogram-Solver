`default_nettype none
`timescale 1ns / 1ps

`define status(OPT, KNOWNS) \
$display("new board: %b  %b  %b \n", KNOWNS[0][0], KNOWNS[0][1], KNOWNS[0][2]); \
$display(" %b  %b  %b \n", KNOWNS[1][0], KNOWNS[1][1], KNOWNS[1][2]); \
$display(" %b  %b  %b \n", KNOWNS[2][0], KNOWNS[2][1], KNOWNS[2][2]); 
// $display(" %b  %b  %b \n", KNOWNS);

// $display("\n");
// $display("option", option);
// $display("\n");

module fifo_solver_tb;

    logic clk;
    logic rst;
    logic started;
    logic [2:0] option;
    logic valid_in;
    logic [6:0][6:0] old_options_amnt; //[2*SIZE:0] [6:0]
    logic [2:0]  [2:0] assigned; //[SIZE-1:0]  [SIZE-1:0]
     logic put_back_to_FIFO;  //boolean- do we need to push to fifo
     logic solved ;
     logic [0:2]  [2:0] known;


    solver uut (
        .clk(clk),
        .rst(rst),
        .started(started),
        .option(option),
        .valid_op(valid_in),
        .put_back_to_FIFO(put_back_to_FIFO),  
        .assigned(assigned),
        .known(known),
        .solved(solved)
    );

    always begin
        #5;
        clk = !clk;
    end
    initial begin
        $dumpfile("fifo_solver.vcd");
        $dumpvars(0, fifo_solver_tb);
        $display("Starting Sim FIFO Solver");
        clk = 0;
        rst = 0;
        valid_in = 0;
        #10;
        rst = 1;
        #10;
        rst = 0;
        #10;

        //BOARD :
        // 1 1 0
        // 0 1 0
        // 1 0 1

        // row 1 : 110 011
        //row 2: 100 010 001
        //row 3: 101
        //col 1:  101
        //col 2: 110 011
        //col 3: 100 010 001

        $display("just started");
        started = 1;
        option = 0 ; //first line index 
        valid_in = 1;
        old_options_amnt[0] = 2; //logic [2*SIZE:0] [6:0]
        old_options_amnt[1] = 3; //logic [2*SIZE:0] [6:0]
        old_options_amnt[2] = 1;
        old_options_amnt[3] = 1;
        old_options_amnt[4] = 2;
        old_options_amnt[5] = 3;
        `status(option,known);
        #10;

        started = 0;

        option = 3'b110 ; //row 1 first opt
        valid_in = 1;
        `status(option,known);
        #10;
        // $display("put this back in FIFO should be 0, put_back_to_FIFO %b", put_back_to_FIFO);
        option = 3'b011 ; //row 1 2 opt
        valid_in = 1;
        $display("should assign cell [0] [1] to be known");
        `status(option, known);
        #10;
        // should assign cell [0] [1] to be known


        option = 3'b001 ; //row 2 line index
        valid_in = 1;
        `status(option,known);
        #10;
        option = 3'b100 ; //row 2 opt 1
        valid_in = 1;
        `status(option,known);
        #10;
        option = 3'b010  ; //row 2 opt 2
        valid_in = 1;
        `status(option,known);
        #10;
        option = 3'b001  ; //row 2 opt 3
        valid_in = 1;
        `status(option,known);
        #10;

        option = 3'b010  ; //row 3 line ind (==2)
        valid_in = 1;
        `status(option,known);
        #10;
        //SHOULD HAVE ONLY ONE OPTION SO ASSIGN:
        option = 3'b101  ; //row 3 opt 1
        valid_in = 1;
        $display("should assign whole third row to be known");
        `status(option,known);
        #10;
    // SHOULD assign whole third row to be known

        option = 3'b011  ; //col 1 line ind 
        valid_in = 1;
        `status(option,known);
        #10;
        option = 3'b101  ; //col 1 opt 1 
        valid_in = 1;
        $display("should assign cells [1][0] and [2][0] to be known");
        `status(option,known);
        #10;
        // should assign cells [1][0] and [2][0] to be known

        option = 3'b100  ; //col 2 line ind 
        valid_in = 1;
        `status(option,known);
        #10;
        option = 3'b110 ; //col 2 first opt
        valid_in = 1;
        `status(option,known);
        #10;
        option = 3'b011 ; //col 2 2 opt
        valid_in = 1;
        $display("put this back in FIFO should be 0, put_back_to_FIFO %b", put_back_to_FIFO);
        `status(option,known);
        #10;

        // $display("options for col 2 should be 1. opt for col 2: %b", options_amnt); DANA: need to return options if we wanna check that
        option = 3'b101  ; //col 3 line ind 
        valid_in = 1;
        `status(option,known);
        #10;
        option = 3'b100 ; //col 3 opt 1
        $display("put this back in FIFO should be 0, put_back_to_FIFO %b", put_back_to_FIFO);
        valid_in = 1;
        `status(option,known);
        #10;
        option = 3'b010  ; //col 3 opt 2
        valid_in = 1;
        $display("put this back in FIFO should be 0, put_back_to_FIFO %b", put_back_to_FIFO);
        `status(option,known);
        #10;
        option = 3'b001  ; //col 3 opt 3
        valid_in = 1;
        `status(option,known);
        #10;


        // $display("put this back in FIFO should be 0 but we got %b", put_back_to_FIFO);
        $display("the assignments made to the board",assigned);//should not be totally 
        //correct since we havent filled it, but all the spots of 1 should be correct


        //ask about how to print out all the assignments
        // $display("the amount of options left sohuld be 0 but is %b", options_amnt);
        // $display("valid out sohuld be 1 but is %b", valid_out);


        $display("Finishing Sim");
        $finish;
    end

endmodule

`default_nettype wire
