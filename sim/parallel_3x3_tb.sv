`default_nettype none
`timescale 1ns / 1ps

`define status(OPT1, OPT2, KNOWNS, SOL) \
$display("option1: %b \n", OPT1); \
$display("option2: %b \n", OPT2); \
$display("knows: \n %b  %b  %b \n", KNOWNS[0], KNOWNS[1], KNOWNS[2]); \
$display(" %b  %b  %b \n", KNOWNS[11], KNOWNS[12], KNOWNS[13]); \
$display(" %b  %b  %b \n", KNOWNS[22], KNOWNS[23], KNOWNS[24]); \
$display("sol: \n %b  %b  %b \n", SOL[0], SOL[1], SOL[2]); \
$display(" %b  %b  %b \n", SOL[11], SOL[12], SOL[13]); \
$display(" %b  %b  %b \n", SOL[22], SOL[23], SOL[24]); 


module parallel_3x3_tb;

    logic clk;
    logic rst;
    logic started;
    logic [15:0] new_op1;
    logic [15:0] new_op2;
    logic [15:0] option1;
    logic [15:0] option2;
    logic valid_in;
    logic next;
    logic [21:0] [6:0] old_options_amnt; //[2*SIZE:0] [6:0]
    logic [120:0] assigned; //[SIZE-1:0]  [SIZE-1:0]
    logic put_back_to_FIFO;  //boolean- do we need to push to fifo
    logic solved;
    logic [120:0] known;

    logic read_from_fifo1;
    logic read_from_fifo2;
    logic back_to_fifo1;
    logic back_to_fifo2;

    parrallel_solver uut (
        .clk(clk),
        .rst(rst),
        .started(started),
        .option_r(option1),
        .option_c(option2),
        .num_rows(4'd3),
        .num_cols(4'd3),
        .old_options_amnt(old_options_amnt),

        .read_from_fifo_r(read_from_fifo1),
        .read_from_fifo_c(read_from_fifo2),
        
        .assigned(assigned),
        .known(known),
        .new_option_r(new_op1),
        .new_option_c(new_op2),
        .put_back_to_FIFO_r(back_to_fifo1),  
        .put_back_to_FIFO_c(back_to_fifo2), 
        .solved(solved)
    );

    always begin
        #5;
        clk = !clk;
    end
    initial begin
        $dumpfile("parallel_3x3.vcd");
        //$dumpvars(0, parallel_3x3.vcd);
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

        option1 = 0; //first line index 
        option2 = 3;
        valid_in = 1;
        #10;
        `status(option1, option2, known, assigned);
        
        option1 = 3'b110; //row 1 opt 1
        option2 = 3'b101;
        valid_in = 1;
        #10;
        `status(option1, option2, known, assigned);

        option1 = 3'b011 ; //row 1 opt 2
        valid_in = 1;
        #10;
        `status(option1, option2, known, assigned);
        
        option2 = 4;
        valid_in = 1;
        #10;
        `status(option1, option2, known, assigned);

        option1 = 1;
        option2 = 3'b110;
        valid_in = 1;
        #10;
        `status(option1, option2, known, assigned);

        option1 = 3'b100;
        option2 = 3'b011;
        valid_in = 1;
        #10;
        `status(option1, option2, known, assigned);

        option1 = 3'b010;
        valid_in = 1;
        #10;
        `status(option1, option2, known, assigned);

        option1 = 3'b001;
        option2 = 5;
        valid_in = 1;
        #10;
        `status(option1, option2, known, assigned);

        option2 = 3'b100;
        valid_in = 1;
        #10;
        `status(option1, option2, known, assigned);

        option1 = 2;
        option2 = 3'b010;
        valid_in = 1;
        #10;
        `status(option1, option2, known, assigned);

        option1 = 3'b101;
        option2 = 3'b001;
        valid_in = 1;
        #10;
        `status(option1, option2, known, assigned);

        #10;
        
        //ROUND 2

        //row 1: 110 011
        //row 2: 100 010 001
        //row 3:
        //col 1:
        //col 2: 011
        //col 3: 100

        option1 = 0;
        option2 = 4;
        valid_in = 1;
        #10;
        `status(option1, option2, known, assigned);

        option1 = 3'b110;
        option2 = 3'b011;
        valid_in = 1;
        #10;
        `status(option1, option2, known, assigned);

        option1 = 3'b011;
        valid_in = 1;
        #10;
        `status(option1, option2, known, assigned);

        option2 = 5;
        valid_in = 1;
        #10;
        `status(option1, option2, known, assigned);

        option1 = 1;
        option2 = 3'b100;
        valid_in = 1;
        #10;
        `status(option1, option2, known, assigned);

        option1 = 3'b100;
        valid_in = 1;
        #10;
        `status(option1, option2, known, assigned);

        option1 = 3'b010;
        valid_in = 1;
        #10;
        `status(option1, option2, known, assigned);

        option1 = 3'b001;
        valid_in = 1;
        #10;
        `status(option1, option2, known, assigned);

        $display("is solved? %b",solved);
        #10;
        $display("restarted");
        rst = 1;
        #10;
        rst = 0;
        #10;

        $display("is solved? %b",solved);

        #10
        $display("Finishing Sim");
        $finish;
    end

endmodule

`default_nettype wire
