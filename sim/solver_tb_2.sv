`default_nettype none
`timescale 1ns / 1ps

`define status(OPT, KNOWNS, SOL) \
$display("option: %b \n", OPT); \
$display("knows: \n %b  %b  %b \n", KNOWNS[0], KNOWNS[1], KNOWNS[2]); \
$display(" %b  %b  %b \n", KNOWNS[11], KNOWNS[12], KNOWNS[13]); \
$display(" %b  %b  %b \n", KNOWNS[22], KNOWNS[23], KNOWNS[24]); \
$display("sol: \n %b  %b  %b \n", SOL[0], SOL[1], SOL[2]); \
$display(" %b  %b  %b \n", SOL[11], SOL[12], SOL[13]); \
$display(" %b  %b  %b \n", SOL[22], SOL[23], SOL[24]); 
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
    logic [21:0] [6:0] old_options_amnt; //[2*SIZE:0] [6:0]
    logic [120:0] assigned,known; //[SIZE-1:0]  [SIZE-1:0]
    logic put_back_to_FIFO;  //boolean- do we need to push to fifo
    logic solved,next;

    solver uut (
        .clk(clk),
        .rst(rst),
        .started(started),
        .option(option),
        .num_rows(2'd3),
        .num_cols(2'd3),
        .old_options_amnt(old_options_amnt),

        .new_line(next),
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
        $dumpfile("solver_2.vcd");
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

        /* Board:
            001
            010
            000
        */

        //row 1: 100 010 001
        //row 2: 100 010 001
        //row 3: 000
        //col 1: 000
        //col 2: 100 010 001
        //col 3: 100 010 001

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
        option = 3'b100 ; //col 2 opt 1 - conflict; kick out of FIFO
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
        option = 3'b100 ; //col 3 opt 1 - conflict; kick out of FIFO
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

        //row 1: 100 010 001
        //row 2: 100 010 001
        //row 3: 
        //col 1: 
        //col 2: 010 001
        //col 3: 010 001

        option = 0 ; //first line index 
        #10;
        started = 0;
        option = 3'b100 ; //row 1 opt 1 - 
        valid_in = 1;
        `status(option,known,assigned);
        #10;
        option = 3'b010  ; //row 1 opt 2 -
        valid_in = 1;
        `status(option,known,assigned);
        #10;
        option = 3'b001  ; //row 1 opt 3 - conflict; kick out of FIFO
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
        option = 3'b001  ; //row 2 opt 3 - conflict; kick out of FIFO
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
        option = 3'b010  ; //col 3 opt 2 -
        valid_in = 1;
        `status(option,known,assigned);
        #10;
        option = 3'b001  ; //col 3 opt 3 - 
        valid_in = 1;
        `status(option,known,assigned);
        #10;

        //THIRD:

        //row 1: 100 010 
        //row 2: 100 010
        //row 3: 
        //col 1: 
        //col 2: 010 001
        //col 3: 010 001

        //NO SOLUTION - ambiguous


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
