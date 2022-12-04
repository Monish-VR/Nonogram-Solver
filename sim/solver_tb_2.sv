`default_nettype none
`timescale 1ns / 1ps

`define status(OPT, KNOWNS, SOL) \
$display("option: %b \n", OPT); \
$display("knows: \n %b  %b  %b \n", KNOWNS[0][0], KNOWNS[0][1], KNOWNS[0][2]); \
$display(" %b  %b  %b \n", KNOWNS[1][0], KNOWNS[1][1], KNOWNS[1][2]); \
$display(" %b  %b  %b \n", KNOWNS[2][0], KNOWNS[2][1], KNOWNS[2][2]); \
$display("sol: \n %b  %b  %b \n", SOL[0][0], SOL[0][1], SOL[0][2]); \
$display(" %b  %b  %b \n", SOL[1][0], SOL[1][1], SOL[1][2]); \
$display(" %b  %b  %b \n", SOL[2][0], SOL[2][1], SOL[2][2]); 
// $display(" %b  %b  %b \n", KNOWNS);

// $display("\n");
// $display("option", option);
// $display("\n");

module solver_tb_2;

    logic clk;
    logic rst;
    logic started;
    logic [2:0] option;
    logic valid_in;
    logic [5:0] [6:0] old_options_amnt; //[2*SIZE:0] [6:0]
    logic [2:0] [2:0] assigned; //[SIZE-1:0]  [SIZE-1:0]
    logic put_back_to_FIFO;  //boolean- do we need to push to fifo
    logic solved;
    logic [2:0] [2:0] known;


    solver uut (
        .clk(clk),
        .rst(rst),
        .started(started),
        .option(option),
        .num_rows(4'd3),
        .num_cols(4'd3),
        .valid_op(valid_in),
        .old_options_amnt(old_options_amnt),
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
        $dumpfile("solver2.vcd");
        $dumpvars(0, solver_tb_2);
        $display("Starting Sim Solver");
        clk = 0;
        rst = 0;
        valid_in = 0;
        #5;
        rst = 1;
        #10;
        rst = 0;
        #10;

        //BOARD :
        // 1 1 0
        // 0 1 0
        // 1 0 1

        //row 1: 110 011
        //row 2: 100 010 001
        //row 3: 101
        //col 1: 101
        //col 2: 110 011
        //col 3: 100 010 001


/* Board:
    001
    010
    000
*/


        $display("just started");
        started = 1;
        option = 0 ; //first line index 
        valid_in = 1;
        old_options_amnt[0] = 3; //logic [2*SIZE:0] [6:0]
        old_options_amnt[1] = 3; //logic [2*SIZE:0] [6:0]
        old_options_amnt[2] = 1;
        old_options_amnt[3] = 1;
        old_options_amnt[4] = 3;
        old_options_amnt[5] = 3;
        #10;
        `status(option,known,assigned);
        started = 0;
        option = 3'b100 ; //row 1 opt 1
        valid_in = 1;
        `status(option,known,assigned);
        #10;


        #10;
        option = 3'b010  ; //row 1 opt 2 - put back into FIFO
        valid_in = 1;
        `status(option,known,assigned);
        #10;
        option = 3'b001  ; //row 1 opt 3 - 
        valid_in = 1;
        `status(option,known,assigned);
        #10;
        option = 3'b001 ; //row 2 line index
        valid_in = 1;
        `status(option,known,assigned);
        #10;
        option = 3'b100 ; //row 2 opt 1 -
        valid_in = 1;
        `status(option,known,assigned);
        #10;
        option = 3'b010  ; //row 2 opt 2 -
        valid_in = 1;
        `status(option,known,assigned);
        #10;
        option = 3'b001  ; //row 2 opt 3 - 
        valid_in = 1;
        `status(option,known,assigned);
        #10;

        //row 3:
        option = 3'b010  ; //row 3-lined ind 
        valid_in = 1;
        `status(option,known,assigned);
        #10;
        option = 3'b000  ; //row 3-opt 1
        valid_in = 1;
        $display("row 3 should be known");
        `status(option,known,assigned);
        #10;
        //col 1
        option = 3'b011  ; //col 1 
        valid_in = 1;
        `status(option,known,assigned);
        #10;
        option = 3'b000  ; //col 1 oppt 1 
        valid_in = 1;
        `status(option,known,assigned);
        #10;

        option = 3'b100  ; //col 2
        valid_in = 1;
        `status(option,known,assigned);
        #10;
        option = 3'b100 ; //col 2 opt 1 -
        valid_in = 1;
        `status(option,known,assigned);
        #10;
        option = 3'b010  ; //col 2 opt 2 -
        valid_in = 1;
        `status(option,known,assigned);
        #10;
        option = 3'b001  ; //col 2 opt 3 - 
        valid_in = 1;
        `status(option,known,assigned);
        #10;


        option = 3'b101  ; //col 3
        valid_in = 1;
        `status(option,known,assigned);
        #10;
        option = 3'b100 ; //col 3 opt 1 -
        valid_in = 1;
        `status(option,known,assigned);
        #10;
        option = 3'b010  ; //col 3 opt 2 -
        valid_in = 1;
        `status(option,known,assigned);
        #10;
        option = 3'b001  ; //col 3 opt 3 - 
        valid_in = 1;
        `status(option,known,assigned);
        #10;

        //SECOND:
        option = 0 ; //first line index 
        #10;
        started = 0;
        option = 3'b100 ; //row 1 opt 1 - conflict; remove from FIFO
        valid_in = 1;
        `status(option,known,assigned);
        #10;
        option = 3'b010  ; //row 1 opt 2 - put back into FIFO
        valid_in = 1;
        `status(option,known,assigned);
        #10;
        option = 3'b001  ; //row 1 opt 3 - 
        valid_in = 1;
        `status(option,known,assigned);
        #10;
        option = 3'b001 ; //row 2 line index
        valid_in = 1;
        `status(option,known,assigned);
        #10;
        option = 3'b100 ; //row 2 opt 1 -
        valid_in = 1;
        `status(option,known,assigned);
        #10;
        option = 3'b010  ; //row 2 opt 2 -
        valid_in = 1;
        `status(option,known,assigned);
        #10;
        option = 3'b001  ; //row 2 opt 3 - 
        valid_in = 1;
        `status(option,known,assigned);
        #10;

        //row 3:
        option = 3'b010  ; //row 3-lined ind 
        valid_in = 1;
        
        `status(option,known,assigned);
        #10;

        //col 1
        option = 3'b011  ; //col 1 
        valid_in = 1;
        `status(option,known,assigned);


        option = 3'b100  ; //col 2
        valid_in = 1;
        `status(option,known,assigned);
        #10;
        // option = 3'b100 ; //col 2 opt 1 -
        // valid_in = 1;
        // `status(option,known,assigned);
        // #10;
        option = 3'b010  ; //col 2 opt 2 -
        valid_in = 1;
        `status(option,known,assigned);
        #10;
        option = 3'b001  ; //col 2 opt 3 - 
        valid_in = 1;
        `status(option,known,assigned);
        #10;
        option = 3'b101  ; //col 3
        valid_in = 1;
        `status(option,known,assigned);
        #10;
        // option = 3'b100 ; //col 3 opt 1 -
        // valid_in = 1;
        // `status(option,known,assigned);
        // #10;
        option = 3'b010  ; //col 3 opt 2 -
        valid_in = 1;
        `status(option,known,assigned);
        #10;
        option = 3'b001  ; //col 3 opt 3 - 
        valid_in = 1;
        `status(option,known,assigned);
        #10;



        $display("is solved? %b",solved);
        //ask about how to print out all the assignments
        // $display("the amount of options left sohuld be 0 but is %b", options_amnt);
        // $display("valid out sohuld be 1 but is %b", valid_out);

        #10
        $display("Finishing Sim");
        $finish;
    end

endmodule

`default_nettype wire
