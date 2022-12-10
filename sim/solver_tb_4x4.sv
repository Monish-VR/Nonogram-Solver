`default_nettype none
`timescale 1ns / 1ps

`define status(OPT, KNOWNS, SOL) \
$display("option: %b \n", OPT); \
$display("knows: \n %b  %b  %b  %b \n", KNOWNS[0], KNOWNS[1], KNOWNS[2], KNOWNS[3]); \
$display(" %b  %b  %b  %b \n", KNOWNS[11], KNOWNS[12], KNOWNS[13], KNOWNS[14]); \
$display(" %b  %b  %b  %b \n", KNOWNS[22], KNOWNS[23], KNOWNS[24], KNOWNS[25]); \
$display(" %b  %b  %b  %b \n", KNOWNS[33], KNOWNS[34], KNOWNS[35], KNOWNS[36]); \
$display("sol: \n %b  %b  %b  %b \n", SOL[0], SOL[1], SOL[2],SOL[3]); \
$display(" %b  %b  %b  %b \n", SOL[11], SOL[12], SOL[13], SOL[14]); \
$display(" %b  %b  %b  %b \n", SOL[22], SOL[23], SOL[24], SOL[25]); \
$display(" %b  %b  %b  %b \n", SOL[33], SOL[34], SOL[35], SOL[36]); 
// $display(" %b  %b  %b \n", KNOWNS);

// $display("\n");
// $display("option", option);
// $display("\n");

module solver_tb_4x4;

    logic clk;
    logic rst;
    logic started;
    logic [3:0] new_op;
    logic [15:0] option;
    logic valid_in;
    logic next;
    logic [21:0] [6:0] old_options_amnt; //[2*SIZE:0] [6:0]
    logic [120:0] assigned; //[SIZE-1:0]  [SIZE-1:0]
    logic put_back_to_FIFO;  //boolean- do we need to push to fifo
    logic solved;
    logic [120:0] known;


    solver uut (
        .clk(clk),
        .rst(rst),
        .started(started),
        .option(option),
        .num_rows(4'd4),
        .num_cols(4'd4),
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
        //row 4: 1101 
        //col 1: 1110 0111
        //col 2: 1000 0100 0010 0001
        //col 3: 1101 
        //col 4: 1010 0101 1001

//ROUND 2:
        //row 1: 0011 0110 1100
        //row 2: 0011 0110 1100
        //row 3: 1010 0101 1001
        //row 4: 
        //col 1: 1110 
        //col 2: 0100 0010 0001
        //col 3: 
        //col 4: 1010  1001

//ROUND 3:
        //row 1: 0110 1100
        //row 2: 0011 
        //row 3: 0101 1001
        //row 4: 
        //col 1: 1110 
        //col 2: 0100 0010 0001
        //col 3: 
        //col 4: 1010  1001

        $display("just started");
        started = 1;
        #10;
        started = 0;

        old_options_amnt[0] = 3; //logic [2*SIZE:0] [6:0]
        old_options_amnt[1] = 3; //logic [2*SIZE:0] [6:0]
        old_options_amnt[2] = 3;
        old_options_amnt[3] = 1;
        old_options_amnt[4] = 2;
        old_options_amnt[5] = 4;
        old_options_amnt[6] = 1;
        old_options_amnt[7] = 3;

//ROUND 1 :
        option = 0 ; //first line index 
        #10;
        `status(option,known,assigned);
        option = 4'b0011; //row 1 opt 1
        `status(option,known,assigned);
        #10;
        option = 4'b0110; //row 1 opt 2
        #10;
        `status(option,known,assigned);
        option = 4'b1100; //row 1 opt 3
        #20;
        `status(option,known,assigned);

        $display("DONE WITH ROW 1 should not know anything");

//ROW 2 ROUND 1:
        option = 4'b0001; //row 2 line index
        #10;
        `status(option,known,assigned);
        
        option = 4'b0011; //row 2 opt 1  
        #10;
        `status(option,known,assigned);
        option = 4'b0110; //row 2 opt 2
        #10;
        `status(option,known,assigned);
        option = 4'b1100; //row 2 opt 3
        #20;
        `status(option,known,assigned);

        $display("DONE WITH ROW 2 should not know anything");
// ROW 3 ROUND 1:
        option = 4'b0010; //R3 ind
        #10;
        `status(option,known,assigned);
        
        option = 4'b1010; //R3 op1
        #10;
        `status(option,known,assigned);
        option = 4'b1001; //R3 op2
        #10;
        `status(option,known,assigned);
        option = 4'b0101; //R3 op3
        #20;
        `status(option,known,assigned);
        $display("DONE WITH ROW 3 should not know anything");

// /ROW 4 ROUND 1:
        option = 4'b0011; //R4 ind
        #10;
        `status(option,known,assigned);
        option = 4'b1101; //R4 op1
        #20;
        `status(option,known,assigned);

        $display("DONE WITH ROW 4 should assign it");

//COL 1 ROUND 1:
        option = 4'b0100; //C1 ind
        #10;
        `status(option,known,assigned);
        option = 4'b1110; //C1 op1
        #10;
        // /*
        `status(option,known,assigned);
        option = 4'b0111; //C1 op2
        #20;
        `status(option,known,assigned);

        $display("DONE WITH COL 1 should assign all knowns in col 1");

//COL 2 ROUND 1:
        option = 4'b0101; //C2 ind
        #10;
        `status(option,known,assigned);
        option = 4'b1000; //C2 op1
        #10;
        `status(option,known,assigned);
        option = 4'b0100; //C2 op1
        #10;
        `status(option,known,assigned);
        option = 4'b0010; //C2 op3
        #10;
        `status(option,known,assigned);
        option = 4'b0001; //C2 op4
        #20;
        `status(option,known,assigned);

        $display("DONE WITH COL 2 should remove to 3 options");
//COL 3 ROUND 1:
        $display("col 3: 1 option");
        option = 4'b0110; //C3 ind
        #10;
        `status(option,known,assigned);
        option = 4'b1101; //C3 op1
        #20;
        `status(option,known,assigned);

        $display("DONE WITH COL 3 should assign!");

//COL 4 round 1:
        option = 4'b0111; //C4 ind
        #10
        `status(option,known,assigned);
        option = 4'b1010; //C4 op1
        #10;
        `status(option,known,assigned);
        option = 4'b1001; //C4 op2
        #10;
        `status(option,known,assigned);
        option = 4'b0101; //C4 op3
        #20;
        `status(option,known,assigned);

        $display("DONE WITH COL 4 should remove to 2 options!");

/*
0 - 1 -
1 - 0 -
1 - 1 0
1 0 1 1
*/
//ROUND 2:
        option = 0 ; //first line index 
        #10;
        `status(option,known,assigned);
        option = 4'b0011; //row 1 opt 1
        `status(option,known,assigned);
        #10;
        option = 4'b0110; //row 1 opt 2
        #10;
        `status(option,known,assigned);
        option = 4'b1100; //row 1 opt 3
        #20;
        `status(option,known,assigned);

        $display("DONE WITH ROW 1 should not know anything");

//ROW 2 ROUND 2:
        option = 4'b0001; //row 2 line index
        #10;
        `status(option,known,assigned);
        
        option = 4'b0011; //row 2 opt 1  
        #10;
        `status(option,known,assigned);
        option = 4'b0110; //row 2 opt 2
        #10;
        `status(option,known,assigned);
        option = 4'b1100; //row 2 opt 3
        #20;
        `status(option,known,assigned);

        $display("DONE WITH ROW 2 should not know anything");
// ROW 3 ROUND 2:
        option = 4'b0010; //R3 ind
        #10;
        `status(option,known,assigned);
        
        option = 4'b1010; //R3 op1
        #10;
        `status(option,known,assigned);
        option = 4'b1001; //R3 op2
        #10;
        `status(option,known,assigned);
        option = 4'b0101; //R3 op3
        #20;
        `status(option,known,assigned);
        $display("DONE WITH ROW 3 should not know anything");

// /ROW 4 ROUND 2:
        option = 4'b0011; //R4 ind

        #20;
        `status(option,known,assigned);

        $display("DONE WITH ROW 4 round 2 should assign it");

//COL 1ROUND 2:
        option = 4'b0100; //C1 ind
        #10;
        `status(option,known,assigned);
        option = 4'b1110; //C1 op1
        #20;
        `status(option,known,assigned);

//COL 2 ROUND 2:
        option = 4'b0101; //C2 ind
        #10;
        `status(option,known,assigned);
        option = 4'b0100; //C2 op1
        #10;
        `status(option,known,assigned);
        option = 4'b0010; //C2 op3
        #10;
        `status(option,known,assigned);
        option = 4'b0001; //C2 op4
        #20;
        `status(option,known,assigned);

        $display("DONE WITH COL 2 , should assign it");

//COL 3 ROUND 2:
        $display("col 3: 1 option");
        option = 4'b0110; //C3 ind

        #20;
        `status(option,known,assigned);
//COL 4 Round 2:
        option = 4'b0111; //C4 ind
        #10
        `status(option,known,assigned);
        option = 4'b1010; //C4 op1
        #10;
        `status(option,known,assigned);
        option = 4'b1001; //C4 op2
        #20;
        `status(option,known,assigned);
        $display("DONE SHOULD ASSIGN EVERYTHING");

//ROUND 3:
//ROW 1 ROUND 3:
        option = 0 ; //first line index 
        #10;
        option = 4'b0110; //row 1 opt 2
        #10;
        `status(option,known,assigned);
        option = 4'b1100; //row 1 opt 3
        #20;
        `status(option,known,assigned);

        $display("DONE WITH ROW 1 should not know anything");

        option = 4'b0001; //row 2 line index
        #10;
        `status(option,known,assigned);
        option = 4'b0011; //row 2 opt 1  
        #20;
        `status(option,known,assigned);

        $display("DONE WITH ROW 2 should not know anything");

// ROW 3 ROUND 3:
        option = 4'b0010; //R3 ind
        #10;
        `status(option,known,assigned);
        option = 4'b0101; //R3 op3
        #20;
        `status(option,known,assigned);
        $display("DONE WITH ROW 3 should not know anything");

// /ROW 4 ROUND 2:
        option = 4'b0011; //R4 ind

        #20;
        `status(option,known,assigned);

        $display("DONE WITH ROW 4 round 2 should assign it");

//COL 1ROUND 3:
        option = 4'b0100; //C3

        #20;
        `status(option,known,assigned);
//COL 2 ROUND 3:
        option = 4'b0101; //C2 ind
        #10;

        `status(option,known,assigned);
        option = 4'b0010; //C2 op3
        #20;
        `status(option,known,assigned);

        $display("DONE WITH COL 2 , should assign it");

//COL 3 ROUND 3:
        $display("col 3: 1 option");
        option = 4'b0110; //C3 ind

        #20;
        `status(option,known,assigned);

//COL 4 Round 3:
        option = 4'b0111; //C4 ind
        #10
        `status(option,known,assigned);
        option = 4'b1001; //C4 op2
        #20;
        `status(option,known,assigned);
        $display("DONE SHOULD ASSIGN EVERYTHING");
#2000
/*

///OLD:
        //ROUND 1 :
        option = 0 ; //first line index 
        #10;
        `status(option,known,assigned);
        option = 4'b0011; //row 1 opt 1
        `status(option,known,assigned);
        #10;
        option = 4'b0110; //row 1 opt 2
        #10;
        `status(option,known,assigned);
        option = 4'b1100; //row 1 opt 3
        #20;
        `status(option,known,assigned);

        $display("DONE WITH ROW 1 should not know anything");

        
        option = 4'b0001; //row 2 line index
        #10;
        `status(option,known,assigned);

        $display("start with row options: option :%b ", option);
        
        option = 4'b0011; //row 2 opt 1  
        #10;
        `status(option,known,assigned);
        option = 4'b0110; //row 2 opt 2
        #10;
        `status(option,known,assigned);
        option = 4'b1100; //row 2 opt 3
        #20;
        `status(option,known,assigned);

        $display("DONE WITH ROW 2 should not know anything");

        //ROW 3 :1010 0101 1001
        option = 4'b0010; //R3 ind
        #10;
        `status(option,known,assigned);
        
        option = 4'b1010; //R3 op1
        #10;
        `status(option,known,assigned);
        option = 4'b1001; //R3 op2
        #10;
        `status(option,known,assigned);
        option = 4'b0101; //R3 op3
        #20;
        `status(option,known,assigned);
        $display("DONE WITH ROW 3 should not know anything");

        //ROW 4 1101
        // $display("ROW 4, should assign the row.");
        // $display("ROW 4, opt amound: %b", old_options_amnt[0011]);
        option = 4'b0011; //R4 ind
        #10;
        `status(option,known,assigned);
        option = 4'b1101; //R4 op1
        #20;
        `status(option,known,assigned);

        $display("DONE WITH ROW 4 should assign it");

        //col1
        option = 4'b0100; //C1 ind
        #10;
        `status(option,known,assigned);
        option = 4'b1110; //C1 op1
        #10;
        // /*
        `status(option,known,assigned);
        option = 4'b0111; //C1 op2
        #20;
        `status(option,known,assigned);

        $display("DONE WITH COL 1 should remove to 1 option");

        //col2
        option = 4'b0101; //C2 ind
        #10;
        `status(option,known,assigned);
        option = 4'b1000; //C2 op1
        #10;
        `status(option,known,assigned);
        option = 4'b0100; //C2 op1
        #10;
        `status(option,known,assigned);
        option = 4'b0010; //C2 op3
        #10;
        `status(option,known,assigned);
        option = 4'b0001; //C2 op4
        #20;
        `status(option,known,assigned);

        $display("DONE WITH COL 2 should remove to 3 options");

        //col3
        $display("col 3: 1 option");
        option = 4'b0110; //C3 ind
        #10;
        `status(option,known,assigned);
        option = 4'b1101; //C3 op1
        #20;
        `status(option,known,assigned);

        $display("DONE WITH COL 3 should assign!");

        //col4
        option = 4'b0111; //C4 ind
        #10
        `status(option,known,assigned);
        option = 4'b1010; //C4 op1
        #10;
        `status(option,known,assigned);
        option = 4'b1001; //C4 op2
        #10;
        `status(option,known,assigned);
        option = 4'b0101; //C4 op3
        #20;
        `status(option,known,assigned);

        $display("DONE WITH COL 4 should remove to 2 options!");
        //row 4: 1011 
        //col 4: 1010 0101 1001

        $display("round 1 is over!");
        $display("is solved? %b",solved);
        //ask about how to print out all the assignments
        // $display("the amount of options left sohuld be 0 but is %b", options_amnt);
        // $display("valid out sohuld be 1 but is %b", valid_out);

//ROUND 2:
        //row 1: 0011 0110 1100
        //row 2: 0011 0110 1100
        //row 3: 1010 0101 1001
        //row 4: 
        //col 1: 1110 
        //col 2: 0100 0010 0001
        //col 3: 
        //col 4: 1010  1001
        
        option = 0 ; //first line index 
        #10;
        `status(option,known,assigned);
        option = 4'b0011; //row 1 opt 1
        `status(option,known,assigned);
        #10;
        option = 4'b0110; //row 1 opt 2
        #10;
        `status(option,known,assigned);
        option = 4'b1100; //row 1 opt 3
        #20;
        `status(option,known,assigned);


        $display("DONE WITH ROW 1 now we have 2 options b0110 b1100");
        //ROW 2
        option = 4'b0001; //row 2 line index
        #10;
        `status(option,known,assigned);

        $display("start with row 2 options: option :%b ", option);
        
        option = 4'b0011; //row 2 opt 1  
        #10;
        `status(option,known,assigned);
        option = 4'b0110; //row 2 opt 2
        #10;
        `status(option,known,assigned);
        option = 4'b1100; //row 2 opt 3
        #20;
        `status(option,known,assigned);

    $display("DONE WITH ROW 2 now we have 1 options b0011");

        //ROW 3 :1010 0101 1001
        option = 4'b0010; //R3 ind
        #10;
        `status(option,known,assigned);
        
        option = 4'b1010; //R3 op1
        #10;
        `status(option,known,assigned);
        option = 4'b1001; //R3 op2
        #10;
        `status(option,known,assigned);
        option = 4'b0101; //R3 op3
        #20;
        `status(option,known,assigned);

$display("DONE WITH ROW 3 now we have 1 options 0101");
        option = 4'b0011; //R4 ind

        #20;
        `status(option,known,assigned);
        $display("DONE WITH ROW 4");

        //col1
        option = 4'b0100; //C1 ind
        #10;
        `status(option,known,assigned);
        option = 4'b1110; //C1 op1
        #20;
        `status(option,known,assigned);
        $display("DONE WITH COL 1 assigned, 0 options");

        //col2
        option = 4'b0101; //C2 ind
        #10;
        `status(option,known,assigned);
        option = 4'b0100; //C2 op1
        #10;
        `status(option,known,assigned);
        option = 4'b0010; //C2 op3
        #10;
        `status(option,known,assigned);
        option = 4'b0001; //C2 op4
        #20;
        `status(option,known,assigned);

        $display("DONE WITH COL 2 ,  1 option - b0100");

        //col3
        $display("col 3: 1 option");
        option = 4'b0110; //C3 ind

        #20;
        `status(option,known,assigned);

        //col4
        option = 4'b0111; //C4 ind
        #10
        `status(option,known,assigned);
        option = 4'b1010; //C4 op1
        #10;
        `status(option,known,assigned);
        option = 4'b1001; //C4 op2
        #20;
        `status(option,known,assigned);
        $display("DONE WITH COL 2 ,  1 option - b1001");

$display("round 2 is over");

        //ROUND 3:
        //row 1: 0110 1100
        //row 2: 0011 
        //row 3: 0101 
        //row 4: 
        //col 1:  
        //col 2: 0100 
        //col 3: 
        //col 4:   1001
        option = 0 ; //first line index 
        #10;
        `status(option,known,assigned);
        option = 4'b0110; //row 1 opt 2
        #10;
        `status(option,known,assigned);
        option = 4'b1100; //row 1 opt 3
        #20;
        `status(option,known,assigned);

        //ROW 2
        option = 4'b0001; //row 2 line index
        #10;
        `status(option,known,assigned);

        $display("start with row 2 options: option :%b ", option);
        
        option = 4'b0011; //row 2 opt 1  
        #20;
        `status(option,known,assigned);


        //ROW 3 :1010 0101 1001
        option = 4'b0010; //R3 ind
        #10;
        // `status(option,known,assigned);
        // option = 4'b1001; //R3 op2
        // #10;
        `status(option,known,assigned);
        option = 4'b0101; //R3 op3
        #20;
        `status(option,known,assigned);

        //col1
        option = 4'b0100; //C1 ind

        #20;
        `status(option,known,assigned);

        //col2
        option = 4'b0101; //C2 ind
        #10;
        `status(option,known,assigned);
        option = 4'b0100; //C2 op1
        #20;
        `status(option,known,assigned);


        //col3
        $display("col 3: 1 option");
        option = 4'b0110; //C3 ind

        #20;
        `status(option,known,assigned);

        //col4
        option = 4'b0111; //C4 ind
        #10
        // `status(option,known,assigned);
        // option = 4'b1010; //C4 op1
        // #10;
        `status(option,known,assigned);
        option = 4'b1001; //C4 op2
        #20;
        `status(option,known,assigned);

        $display("round 3 is over");

// $display("DONE W round 4");

        //ROUND 4:
        //row 1: 0110 1100
        //row 2: 0011 
        //row 3: 0101 1001
        //row 4: 
        //col 1:  
        //col 2: 0100 0010 0001
        //col 3: 
        //col 4: 1010  1001
        option = 0 ; //first line index 
        #10;
        `status(option,known,assigned);
        option = 4'b0011; //row 1 opt 1
        `status(option,known,assigned);
        // #10;
        // option = 4'b0110; //row 1 opt 2
        // #10;
        // `status(option,known,assigned);
        // option = 4'b1100; //row 1 opt 3
        #20;
        `status(option,known,assigned);

        //ROW 2
        option = 4'b0001; //row 2 line index
        // #10;
        // `status(option,known,assigned);

        // $display("start with row 2 options: option :%b ", option);
        
        // option = 4'b0011; //row 2 opt 1  
        #20;
        `status(option,known,assigned);


        //ROW 3 :1010 0101 1001
        option = 4'b0010; //R3 ind
        // #10;
        // // `status(option,known,assigned);
        // // option = 4'b1001; //R3 op2
        // // #10;
        // `status(option,known,assigned);
        // option = 4'b0101; //R3 op3
        #20;
        `status(option,known,assigned);

        //col1
        option = 4'b0100; //C1 ind

        #20;
        `status(option,known,assigned);

        //col2
        option = 4'b0101; //C2 ind
        // #10;
        // `status(option,known,assigned);
        // option = 4'b0100; //C2 op1
        // #10;
        // `status(option,known,assigned);
        // option = 4'b0010; //C2 op3
        // #10;
        // `status(option,known,assigned);
        // option = 4'b0001; //C2 op4
        #20;
        `status(option,known,assigned);


        //col3
        $display("col 3: 1 option");
        option = 4'b0110; //C3 ind

        #20;
        `status(option,known,assigned);

        //col4
        option = 4'b0111; //C4 ind
        #10

        // option = 4'b1010; //C4 op1
        // #10;
        `status(option,known,assigned);
        option = 4'b1001; //C4 op2
        #20;
        `status(option,known,assigned);
// */

        #10
        $display("Finishing Sim");
        $finish;
    end

endmodule

`default_nettype wire
