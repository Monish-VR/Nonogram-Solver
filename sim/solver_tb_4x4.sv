`default_nettype none
`timescale 1ns / 1ps

`define status(OPT, KNOWNS, SOL) \
$display("option: %b \n", OPT); \
$display("knows: \n %b  %b  %b  %b \n", KNOWNS[0][0], KNOWNS[0][1], KNOWNS[0][2], KNOWNS[0][3]); \
$display(" %b  %b  %b  %b \n", KNOWNS[1][0], KNOWNS[1][1], KNOWNS[1][2], KNOWNS[1][3]); \
$display(" %b  %b  %b  %b \n", KNOWNS[2][0], KNOWNS[2][1], KNOWNS[2][2], KNOWNS[2][3]); \
$display(" %b  %b  %b  %b \n", KNOWNS[3][0], KNOWNS[3][1], KNOWNS[3][2], KNOWNS[3][3]); \
$display("sol: \n %b  %b  %b  %b \n", SOL[0][0], SOL[0][1], SOL[0][2],SOL[0][3]); \
$display(" %b  %b  %b  %b \n", SOL[1][0], SOL[1][1], SOL[1][2], SOL[1][3]); \
$display(" %b  %b  %b  %b \n", SOL[2][0], SOL[2][1], SOL[2][2], SOL[2][3]); \
$display(" %b  %b  %b  %b \n", SOL[3][0], SOL[3][1], SOL[3][2], SOL[3][3]); 
// $display(" %b  %b  %b \n", KNOWNS);

// $display("\n");
// $display("option", option);
// $display("\n");

module solver_tb_4x4;

    logic clk;
    logic rst;
    logic started;
    logic [3:0] option;
    logic valid_in;
    logic next;
    logic [7:0] [6:0] old_options_amnt; //[2*SIZE-1:0] [6:0]
    logic [3:0] [3:0] assigned; //[SIZE-1:0]  [SIZE-1:0]
    logic put_back_to_FIFO;  //boolean- do we need to push to fifo
    logic solved;
    logic [3:0] [3:0] known;


    solver uut (
        .clk(clk),
        .rst(rst),
        .started(started),
        .option(option),
        .num_rows(3'd4),
        .num_cols(3'd4),
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
        $dumpfile("solver4.vcd");
        $dumpvars(0, solver_tb_4x4);
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
        // 0 0 1 1
        // 1 1 0 0
        // 1 0 1 0
        // 1 0 1 1

        //row 1: 0011 0110 1100
        //row 2: 0011 0110 1100
        //row 3: 1010 0101 1001
        //row 4: 1011 
        //col 1: 1110 0111
        //col 2: 1000 0100 0010 0001
        //col 3: 1101
        //col 4: 1010 0101 1001




        $display("just started");
        started = 1;
        option = 0 ; //first line index 
        valid_in = 1;
        old_options_amnt[0] = 3; //logic [2*SIZE:0] [6:0]
        old_options_amnt[1] = 3; //logic [2*SIZE:0] [6:0]
        old_options_amnt[2] = 3;
        old_options_amnt[3] = 1;
        old_options_amnt[4] = 2;
        old_options_amnt[5] = 4;
        old_options_amnt[6] =1;
        old_options_amnt[7] =3;
        #10;

        //ROUND 1 :

        `status(option,known,assigned);
        option = 4'b0011; //row 1 opt 1
        valid_in = 1;
        #10;
        `status(option, known,assigned);
        option = 4'b0110; //row 1 opt 2
        valid_in = 1;
        `status(option,known,assigned);
        #10;
        option = 4'b1100; //row 1 opt 3
        valid_in = 1;
        `status(option,known,assigned);
        #10;

        `status(option,known,assigned);
        option = 4'b0001; //row 2 line index
        valid_in = 1;
        #10;
        `status(option,known,assigned);
        option = 4'b0011; //row 2 opt 1
        valid_in = 1;
        #10;
        `status(option, known,assigned);
        option = 4'b0110; //row 2 opt 2
        valid_in = 1;
        `status(option,known,assigned);
        #10;
        option = 4'b1100; //row 2 opt 3
        valid_in = 1;
        `status(option,known,assigned);
        #10;

        //ROW 3 :1010 0101 1001
        option = 4'b0010; //R3 ind
        valid_in = 1;
        `status(option,known,assigned);
        #10;
        option = 4'b1010; //R3 op1
        valid_in = 1;
        `status(option,known,assigned);
        #10;
        option = 4'b1001; //R3 op2
        valid_in = 1;
        `status(option,known,assigned);
        #10;
        option = 4'b0101; //R3 op3
        valid_in = 1;
        `status(option,known,assigned);
        #10;

        //ROW 4 1011
        $display("ROW 4, should assign the row.");
        option = 4'b0011; //R4 ind
        valid_in = 1;
        `status(option,known,assigned);
        #10;
        option = 4'b1011; //R4 op1
        valid_in = 1;
        `status(option,known,assigned);

        //col1
        #10;
        option = 4'b0100; //C1 ind
        valid_in = 1;
        `status(option,known,assigned);
        #10;
        option = 4'b1110; //C1 op1
        valid_in = 1;
        `status(option,known,assigned);
        #10;
        option = 4'b0111; //C1 op2
        valid_in = 1;
        `status(option,known,assigned);

        //col2
        #10;
        option = 4'b0101; //C2 ind
        valid_in = 1;
        `status(option,known,assigned);
        #10;
        option = 4'b1000; //C2 op1
        valid_in = 1;
        `status(option,known,assigned);
        #10;
        option = 4'b0100; //C2 op1
        valid_in = 1;
        `status(option,known,assigned);
        #10;
        option = 4'b0010; //C2 op3
        valid_in = 1;
        `status(option,known,assigned);
        #10;
        option = 4'b0001; //C2 op4
        valid_in = 1;
        `status(option,known,assigned);

        //col3
        #10;
        option = 4'b0110; //C3 ind
        valid_in = 1;
        `status(option,known,assigned);
        #10;
        option = 4'b1101; //C3 op1
        valid_in = 1;
        `status(option,known,assigned);

        //col3
        #10;
        option = 4'b0111; //C4 ind
        valid_in = 1;
        `status(option,known,assigned);
        #10
        option = 4'b1010; //R3 op1
        valid_in = 1;
        `status(option,known,assigned);
        #10;
        option = 4'b1001; //R3 op2
        valid_in = 1;
        `status(option,known,assigned);
        #10;
        option = 4'b0101; //R3 op3
        valid_in = 1;
        `status(option,known,assigned);
        #10
//row 4: 1011 
        //col 4: 1010 0101 1001

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
