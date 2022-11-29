
`timescale 1ns / 1ps
`default_nettype none
//assuming line index starts at 0

//packed arrays give the values the opposite way from what we expect, so array of 3X3, 
//when we call array[0] it will give the last 3 bits

module fifo_solver (
        input wire clk,
        input wire rst,
        input wire  [SIZE-1:0] option,
        
        input wire valid_op,
        input wire [2*SIZE:0] [6:0] options_amnt,//Taken from the BRAM in the top level- how many options for this line

        output logic  [SIZE-1:0]  [SIZE-1:0] assigned,  
        output logic put_back_to_FIFO,  //boolean- do we need to push to fifo
        output logic new_option_num, // for the BRAM gonna either be same as option num or 1 less
        output logic valid_out
    );

        logic [SIZE-1] line_ind; //TODO:What size should this be?
        assign row = line_ind < SIZE;
        parameter SIZE = 3;
        logic  [SIZE-1:0] [SIZE-1:0] known;
        
        logic checking_option;

        logic [6:0] options_left; //options left to get from the fifo
        logic [6:0] net_valid_opts; //how many valid options we checked

        logic contradict; //if 1 contradicts and we remove it
        logic simp_valid; //out put valid for simplify

        logic  [SIZE-1:0] assi_simp; //one line input of assigned input to simplify
        logic [SIZE-1:0] known_simp; //one line input of known input to simplif

        logic [SIZE-1:0] always1;// a and b
        logic [SIZE-1:0] always0;

        simplify #( (SIZE))simplify_m(
        .clk(clk),
        .rst(rst),
        .valid_in(checking_option),
        .assigned(assi_simp), // SIZE-1:0]
        .known(known_simp),
        .option(option),
        .valid(simp_valid),
        .contradict(contradict)
        );


    logic  [SIZE-1:0]  [SIZE-1:0] known_t; //transpose
    logic  [SIZE-1:0]  [SIZE-1:0] assigned_t; //transpose


    //TRANSPOSING:
    genvar m;
    genvar n;
    for(m = 0; m < SIZE; m = m + 1) begin
        for(n = 0; n < SIZE; n = n + 1) begin

            assign known_t[n][m] = known[m][n];
            assign assigned_t[n][m] = assigned[m][n];
        end
    end

//Grab the line from relevant known and assigned blocks
    always_comb begin
        if (options_left > 0) begin
            checking_option = 1;
            if (row) begin
                assi_simp = assigned[SIZE - line_ind ];
                known_simp = known[SIZE - line_ind ];

            end else begin
                assi_simp = assigned_t[SIZE - line_ind ];
                known_simp = known_t[SIZE - line_ind ];
            end
        end
        else begin 
            //this is the case where the input to the queue is a line index
            checking_option = 0;
        end
    end
    
    always_ff @(posedge clk)begin
        if(rst)begin
            known <= 0;
            assigned <= 0;
            valid_out <=0;
        end else begin (options_left > 0)begin
            if (simp_valid) begin       
                if (contradict)begin
                    put_back_to_FIFO <= 0;
                    new_option_num <= option_num - 1;

                end else begin
                    put_back_to_FIFO <= 1;
                end
                valid_out<=1;
            end
        end else begin
            //transition to new line 
            options_left <= options_amnt[line_ind];
            net_valid_opts <= 0;
            if (options_amnt[line_ind] == 1) begin
                //only one valid option
                put_back_to_FIFO <= 0;
                if (row) begin
                    known[line_ind] <= -1; //-1;//this might be wroing '{1}, suppose to be a whole ist of 1
                    assigned[line_ind] <= option;
                end else begin
                    for(integer row = 0; row < SIZE; row = row + 1) begin
                            known[row*SIZE + line_ind] <= 1;
                            assigned[row*SIZE + line_ind] <= option[row];
                    end
                end
            end
        end
    end

endmodule

`default_nettype wire
