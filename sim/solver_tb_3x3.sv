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

module solver_tb_3x3;

    logic clk;
    logic rst;
    logic started;
    logic [15:0] new_op;
    logic [15:0] option;
    logic valid_in;
    logic next;
    logic [21:0] [6:0] old_options_amnt; //[2*SIZE:0] [6:0]
    logic [120:0] assigned; //[SIZE-1:0]  [SIZE-1:0]
    logic put_back_to_FIFO;  //boolean- do we need to push to fifo
    logic solved, unsolvable;
    logic [120:0] known;
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
        .new_option(new_op),
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
        $dumpfile("solver_3x3.vcd");
        $dumpvars(0, solver_tb_3x3);
        $display("Starting Sim Solver");
        clk = 0;
        rst = 0;
        valid_in = 0;
        #5;
        rst = 1;
        #10;
        rst = 0;
        started = 0;
        old_options_amnt[0] = 2; 
        old_options_amnt[1] = 3;
        old_options_amnt[2] = 1;
        old_options_amnt[3] = 1;
        old_options_amnt[4] = 2;
        old_options_amnt[5] = 3;
        net_option_amnt = 12;
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

        $display("just started");
        started = 1;
        #10;
        started = 0;
        #10;

        option = 0 ; //first line index 
        valid_in = 1;
        #10;
        `status(option,known,assigned);
        option = 3'b110 ; //row 1 opt 1
        valid_in = 1;
        #10;
        `status(option,known,assigned);
        // $display("put this back in FIFO should be 0, put_back_to_FIFO %b", put_back_to_FIFO);
        option = 3'b011 ; //row 1 opt 2
        valid_in = 1;
        $display("should assign cell [0] [1] to be known");
        #20;
        `status(option, known,assigned);

        option = 3'b001 ; //row 2 line index
        valid_in = 1;
        `status(option,known,assigned);
        #10;
        option = 3'b100 ; //row 2 opt 1
        valid_in = 1;
        `status(option,known,assigned);
        #10;
        option = 3'b010  ; //row 2 opt 2
        valid_in = 1;
        `status(option,known,assigned);
        #10;
        option = 3'b001  ; //row 2 opt 3
        valid_in = 1;
        #20;
        `status(option,known,assigned);

        option = 3'b010  ; //row 3 line ind (==2)
        valid_in = 1;
        `status(option,known,assigned);
        #10;
        //SHOULD HAVE ONLY ONE OPTION SO ASSIGN:
        option = 3'b101  ; //row 3 opt 1
        valid_in = 1;
        $display("should assign whole third row to be known");
        #20;
        `status(option,known,assigned);
        // SHOULD assign whole third row to be known

        option = 3'b011  ; //col 1 line ind 
        valid_in = 1;
        `status(option,known,assigned);
        #10;
        option = 3'b101  ; //col 1 opt 1 
        valid_in = 1;
        $display("should assign cells [1][0] and [2][0] to be known");
        #20;
        `status(option,known,assigned);
        // should assign cells [1][0] and [2][0] to be known

        option = 3'b100  ; //col 2 line ind 
        valid_in = 1;
        `status(option,known,assigned);
        #10;
        option = 3'b110 ; //col 2 first opt
        valid_in = 1;
        `status(option,known,assigned);
        #10;
        option = 3'b011 ; //col 2 2 opt
        valid_in = 1;
        $display("put this back in FIFO should be 0, put_back_to_FIFO %b", put_back_to_FIFO);
        #20;
        `status(option,known,assigned);

        // $display("options for col 2 should be 1. opt for col 2: %b", options_amnt); DANA: need to return options if we wanna check that
        option = 3'b101  ; //col 3 line ind 
        valid_in = 1;
        `status(option,known,assigned);
        #10;
        option = 3'b100 ; //col 3 opt 1
        $display("put this back in FIFO should be 0, put_back_to_FIFO %b", put_back_to_FIFO);
        valid_in = 1;
        `status(option,known,assigned);
        #10;
        option = 3'b010  ; //col 3 opt 2
        valid_in = 1;
        $display("put this back in FIFO should be 0, put_back_to_FIFO %b", put_back_to_FIFO);
        `status(option,known,assigned);
        #10;
        option = 3'b001  ; //col 3 opt 3
        valid_in = 1;
        #20;
        `status(option,known,assigned);


        // $display("put this back in FIFO should be 0 but we got %b", put_back_to_FIFO);
        $display("the assignments made to the board",assigned);//should not be totally 
        //correct since we havent filled it, but all the spots of 1 should be correct

        //round 2:
        //row 1: 110 011
        //row 2: 100 010 001
        //row 3:
        //col 1:
        //col 2: 011
        //col 3: 100

        option = 3'b000  ; //R1
        valid_in = 1;
        `status(option,known,assigned);
        #10;

        option = 3'b110 ; //row 1 opt 1 - put back into FIFO
        valid_in = 1;
        #10;
        `status(option,known,assigned);

        // $display("put this back in FIFO should be 0, put_back_to_FIFO %b", put_back_to_FIFO);
        option = 3'b011 ; //row 1 opt 2 - conflict; remove from FIFO
        valid_in = 1;
        #10;
        `status(option, known,assigned);

        option = 3'b001 ; //row 2 line index
        valid_in = 1;
        `status(option,known,assigned);
        #10;
        option = 3'b100 ; //row 2 opt 1 - conflict; remove from FIFO
        valid_in = 1;
        `status(option,known,assigned);
        #10;
        option = 3'b010  ; //row 2 opt 2 - put back into FIFO
        valid_in = 1;
        `status(option,known,assigned);
        #10;
        option = 3'b001  ; //row 2 opt 3 - conflict; remove from FIFO
        valid_in = 1;
        `status(option,known,assigned);
        #10;

        option = 3'b010 ; //row 3 line index
        valid_in = 1;
        `status(option,known,assigned);
        #10;

        option = 3'b011 ; //col 1 line index
        valid_in = 1;
        `status(option,known,assigned);
        #10;

        option = 3'b100 ; //col 2 line index
        valid_in = 1;
        `status(option,known,assigned);
        #10;
        option = 3'b011 ; //col 2 opt 1 - last option; remove from FIFO
        valid_in = 1;
        #10;
        `status(option,known,assigned);

        option = 3'b101 ; //col 3 line index
        valid_in = 1;
        `status(option,known,assigned);
        #10;
        option = 3'b100 ; //col 3 opt 1 - last option; remove from FIFO; [0][2] and [1][2] should be known (known complete => solved)
        valid_in = 1;
        `status(option,known,assigned);
        #10;
        valid_in = 0;

        $display("is solved? %b",solved);
        #10;
        $display("restarted");
        rst = 1;
        #10;
        rst = 0;
        #10;

        $display("is solved? %b",solved);
        $display("this board cannot be solved %b ", unsolvable);
        #10
        $display("Finishing Sim");
        $finish;
    end

endmodule

`default_nettype wire
