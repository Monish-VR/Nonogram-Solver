`default_nettype none
`timescale 1ns / 1ps

`define status(OPT, KNOWNS, SOL, UNSLVBLE) \
$display("this board cannot be solved %b" ,UNSLVBLE); \
$display("option: %b \n", OPT); \
$display("knows: \n %b  %b  %b \n", KNOWNS[0], KNOWNS[1], KNOWNS[2]); \
$display(" %b  %b  %b \n", KNOWNS[11], KNOWNS[12], KNOWNS[13]); \
$display(" %b  %b  %b \n", KNOWNS[22], KNOWNS[23], KNOWNS[24]); \
$display("sol: \n %b  %b  %b \n", SOL[0], SOL[1], SOL[2]); \
$display(" %b  %b  %b \n", SOL[11], SOL[12], SOL[13]); \
$display(" %b  %b  %b \n", SOL[22], SOL[23], SOL[24]); 

module solver_tb_2;

    logic clk;
    logic rst;
    logic started;
    logic [15:0] option;
    logic valid_in;
    logic [21:0] [6:0] old_options_amnt;
    logic [120:0] assigned,known;
    logic put_back_to_FIFO;  
    logic solved,next, unsolvable;
    logic [6:0] net_option_amnt;

    solver uut (
        .clk(clk),
        .rst(rst),
        .started(started),
        .option(option),
        .num_rows(4'd3),
        .num_cols(4'd3),
        .old_options_amnt(old_options_amnt),
        .all_options_remaining(net_option_amnt),

        .new_line(next),
        .put_back_to_FIFO(put_back_to_FIFO),  
        .assigned(assigned),
        .known(known),
        .solved(solved),
        .unsolvable(unsolvable)
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
        valid_in = 1;
        old_options_amnt[0] = 3; 
        old_options_amnt[1] = 3; 
        old_options_amnt[2] = 1;
        old_options_amnt[3] = 1;
        old_options_amnt[4] = 3;
        old_options_amnt[5] = 3;
        net_option_amnt = 14;
        #10;

        `status(option,known,assigned, unsolvable);
        started = 0;
        #10;
        option = 0 ; //first line index 
        #10;
        option = 3'b100 ; //row 1 opt 1
        valid_in = 1;
        `status(option,known,assigned, unsolvable);
        #10;
        option = 3'b010  ; //row 1 opt 2 - put back into FIFO
        valid_in = 1;
        `status(option,known,assigned, unsolvable);
        #10;
        option = 3'b001  ; //row 1 opt 3 - 
        valid_in = 1;
        `status(option,known,assigned, unsolvable);
        #10;

        option = 3'b001 ; //row 2 line index
        valid_in = 1;
        `status(option,known,assigned, unsolvable);
        #10;
        option = 3'b100 ; //row 2 opt 1 -
        valid_in = 1;
        `status(option,known,assigned, unsolvable);
        #10;
        option = 3'b010  ; //row 2 opt 2 -
        valid_in = 1;
        `status(option,known,assigned, unsolvable);
        #10;
        option = 3'b001  ; //row 2 opt 3 - 
        valid_in = 1;
        `status(option,known,assigned, unsolvable);
        #10;

        //row 3:
        option = 3'b010  ; //row 3-lined ind 
        valid_in = 1;
        `status(option,known,assigned, unsolvable);
        #10;
        option = 3'b000  ; //row 3-opt 1
        valid_in = 1;
        $display("row 3 should be known");
        `status(option,known,assigned, unsolvable);
        #10;

        //col 1
        option = 3'b011  ; //col 1 
        valid_in = 1;
        `status(option,known,assigned, unsolvable);
        #10;
        option = 3'b000  ; //col 1 oppt 1 
        valid_in = 1;
        `status(option,known,assigned, unsolvable);
        #10;

        option = 3'b100  ; //col 2
        valid_in = 1;
        `status(option,known,assigned, unsolvable);
        #10;
        option = 3'b100 ; //col 2 opt 1 - conflict; kick out of FIFO
        valid_in = 1;
        `status(option,known,assigned, unsolvable);
        #10;
        option = 3'b010  ; //col 2 opt 2 -
        valid_in = 1;
        `status(option,known,assigned, unsolvable);
        #10;
        option = 3'b001  ; //col 2 opt 3 -
        valid_in = 1;
        `status(option,known,assigned, unsolvable);
        #10;
        option = 3'b101  ; //col 3
        valid_in = 1;
        `status(option,known,assigned, unsolvable);
        #10;
        option = 3'b100 ; //col 3 opt 1 - conflict; kick out of FIFO
        valid_in = 1;
        `status(option,known,assigned, unsolvable);
        #10;
        option = 3'b010  ; //col 3 opt 2 -
        valid_in = 1;
        `status(option,known,assigned, unsolvable);
        #10;
        option = 3'b001  ; //col 3 opt 3 -
        valid_in = 1;
        `status(option,known,assigned, unsolvable);
        #10;

        //SECOND ROUND:

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
        `status(option,known,assigned, unsolvable);
        #10;
        option = 3'b010  ; //row 1 opt 2 -
        valid_in = 1;
        `status(option,known,assigned, unsolvable);
        #10;
        option = 3'b001  ; //row 1 opt 3 - conflict; kick out of FIFO
        valid_in = 1;
        `status(option,known,assigned, unsolvable);
        #10;
        option = 3'b001 ; //row 2 line index
        valid_in = 1;
        `status(option,known,assigned, unsolvable);
        #10;
        option = 3'b100 ; //row 2 opt 1 -
        valid_in = 1;
        `status(option,known,assigned, unsolvable);
        #10;
        option = 3'b010  ; //row 2 opt 2 -
        valid_in = 1;
        `status(option,known,assigned, unsolvable);
        #10;
        option = 3'b001  ; //row 2 opt 3 - conflict; kick out of FIFO
        valid_in = 1;
        `status(option,known,assigned, unsolvable);
        #10;

        //row 3:
        option = 3'b010  ; //row 3-lined ind 
        valid_in = 1;
        
        `status(option,known,assigned, unsolvable);
        #10;

        //col 1
        option = 3'b011  ; //col 1 
        valid_in = 1;
        `status(option,known,assigned, unsolvable);


        option = 3'b100  ; //col 2
        valid_in = 1;
        `status(option,known,assigned, unsolvable);
        #10;
        option = 3'b010  ; //col 2 opt 2 -
        valid_in = 1;
        `status(option,known,assigned, unsolvable);
        #10;
        option = 3'b001  ; //col 2 opt 3 - 
        valid_in = 1;
        `status(option,known,assigned, unsolvable);
        #10;

        option = 3'b101  ; //col 3
        valid_in = 1;
        `status(option,known,assigned, unsolvable);
        #10;
        option = 3'b010  ; //col 3 opt 2 -
        valid_in = 1;
        `status(option,known,assigned, unsolvable);
        #10;
        option = 3'b001  ; //col 3 opt 3 - 
        valid_in = 1;
        `status(option,known,assigned, unsolvable);
        #10;

        //THIRD:

        //row 1:  010 001
        //row 2:  010 001
        //row 3: 
        //col 1: 
        //col 2: 010 001
        //col 3: 010 001


        //NO SOLUTION - ambiguous


        $display("is solved? %b",solved);

        #10
        $display("Finishing Sim");
        $finish;
    end

endmodule

`default_nettype wire
