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

module parallel_tb_4x4;

    logic clk;
    logic rst;
    logic started;
    logic [3:0] new_op;
    logic [15:0] option_r;
    logic [15:0] option_c;
    logic valid_in;
    logic read_from_fifo_r, read_from_fifo_c;
    logic [21:0] [6:0] old_options_amnt; 
    logic [120:0] assigned;
    logic put_back_to_FIFO_r, put_back_to_FIFO_c;  
    logic solved;
    logic [15:0] option_r_back;
    logic [15:0] option_c_back;
    logic [120:0] known;


    parrallel_solver uut (
        .clk(clk),
        .rst(rst),
        .started(started),
        .option_r(option_r),
        .option_c(option_c),
        .num_rows(4'd4),
        .num_cols(4'd4),
        .old_options_amnt(old_options_amnt),

        .read_from_fifo_r(read_from_fifo_r),
        .read_from_fifo_c(read_from_fifo_c),
        
        .assigned(assigned),
        .known(known),
        .new_option_r(option_r_back),
        .new_option_c(option_c_back),
        .put_back_to_FIFO_r(put_back_to_FIFO_r),  
        .put_back_to_FIFO_c(put_back_to_FIFO_c), 
        .solved(solved)
    );

    always begin
        #5;
        clk = !clk;
    end
    initial begin
        $dumpfile("solver4p.vcd");
        $dumpvars(0, parallel_tb_4x4);
        $display("Starting Sim Solver");
        clk = 0;
        rst = 0;
        valid_in = 0;
        #5;
        rst = 1;
        #10;
        rst = 0;
        started = 0;
        old_options_amnt[0] = 3; 
        old_options_amnt[1] = 3; 
        old_options_amnt[2] = 3;
        old_options_amnt[3] = 1;
        old_options_amnt[4] = 2;
        old_options_amnt[5] = 4;
        old_options_amnt[6] = 1;
        old_options_amnt[7] = 3;
        #10;


        //BOARD :
        // 0 0 1 1
        // 1 1 0 0
        // 1 0 1 0
        // 1 0 1 1


        $display("just started");
        started = 1;
        #10;
        started = 0;
        #10;

//ROUND 1 :
//ROW 1 AND COL 1


        option_r = 0 ; //first line index 
        option_c = 4'b0100; //C1 ind

        #10;
        `status(option_r,known,assigned);
        option_r = 4'b0011; //row 1 opt 1
        option_c = 4'b1110; //C1 op1

        #10;
        `status(option_r,known,assigned);
        option_r = 4'b0110; //row 1 opt 2
        option_c = 4'b0111; //C1 op2

        //I should divide here to 2 inputs on different cycle since we're done w col 1 (so need to wait 20) 
        //but still have options for row 1
        #10;
        `status(option_r,known,assigned);
        option_r = 4'b1100; //row 1 opt 3
        #10;
        //COL 2
        `status(option_r,known,assigned);
        $display("col 1 middle 2 cells should be assigned");
        option_c = 4'b0101; //C2 ind
        #10;
        `status(option_r,known,assigned);
        option_r = 4'b0001; //row 2 index
        option_c = 4'b1000; //C2 op1
        #10;
        `status(option_r,known,assigned);
        option_r = 4'b0011; //row 2 op1
        option_c = 4'b0100; //C2 op2
        #10;
        `status(option_r,known,assigned);
        option_r = 4'b0110; //row 2 op2
        option_c = 4'b0010; //C2 op3
        #10;
        `status(option_r,known,assigned);
        option_r = 4'b1100; //row 2 op3
        option_c = 4'b0001; //C2 op4
        #10; // no column or row here since were done with col 2 and row 2
        #10;
        `status(option_r,known,assigned);
        $display("should assign row 2");
        option_r = 4'b0010; //row 3 index
        option_c = 4'b0110; //col 3 index
        #10
        `status(option_r,known,assigned);
        option_r = 4'b1010; //row 3 op1
        option_c = 4'b1101; //col 3 op1
        #10; //no col here since done with col 3
        `status(option_r,known,assigned);
        option_r = 4'b1001; //row 3 op2
        #10; 
        `status(option_r,known,assigned);
        $display("should assign col3");
        option_r = 4'b0101; //row 3 op3
        option_c = 4'b0111; //col 4 index
        #10;// no row here since we're done w r3
        `status(option_r,known,assigned);
        option_c = 4'b1010; //col 4 op1
        #10; 
        `status(option_r,known,assigned);
        option_r = 4'b0011; //row 4 index
        option_c = 4'b1001; //col 4 op2
        #10; 
        `status(option_r,known,assigned);
        option_r = 4'b1101; //row 4 op1
        option_c = 4'b0101; //col 4 op3
        #10;//no row cuz were done w r4 and c4
                //ROUND 2:
        #10;
        $display("should assign row 4 and first cell on col 4");
        `status(option_r,known,assigned);
        option_r = 0 ; //ro1 line index 
        option_c = 4'b0100; //C1 ind
        #10;
        `status(option_r,known,assigned);
        option_r = 4'b0011 ; //ro1 op1 
        option_c = 4'b1110; //C1 op1
        //no col in next 
        #10;
        `status(option_r,known,assigned);
        option_r = 4'b0110 ; //ro1 op2
        option_c = 4'b0111; //C1 op2
        #10; //no col:
        `status(option_r,known,assigned);
        option_r = 4'b1100 ; //ro1 op3
        //no row:
        #10;
        `status(option_r,known,assigned);
        $display("should assign all of col 1");
        option_c = 4'b0101; //C2 ind
        #10;
        `status(option_r,known,assigned);
        $display("should assign all of row 1");
        option_r = 4'b0001 ; //R2 ind
        option_c = 4'b1000; //C2 op1
        #10;
        `status(option_r,known,assigned);
        option_r = 4'b0011 ; //R2 op1
        option_c = 4'b0100; //C2 op2
        //no row
        #10;
        `status(option_r,known,assigned);
        option_c = 4'b0010; //C2 op3
        #10;
        `status(option_r,known,assigned);
        option_r = 4'b0010 ; //R3 index
        option_c = 4'b0001; //C2 op4
        //no col
        #10;
        `status(option_r,known,assigned);
        option_r = 4'b1001 ; //R3 op1
        // no row
        #10;
        `status(option_r,known,assigned);
        option_r = 4'b0101 ; //R3 op2
        option_c = 4'b0110 ; //C3 index
        //no row no col
        #10;
        #10;
        `status(option_r,known,assigned);
        $display("should assign everything");
        option_r = 4'b1010 ; //R4 ind
        option_c = 4'b0111; //C4 ind
        #10;

        #10
        $display("Finishing Sim");
        $finish;
    end

endmodule

`default_nettype wire
