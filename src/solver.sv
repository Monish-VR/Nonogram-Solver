
`timescale 1ns / 1ps
`default_nettype none
//assuming line index starts at 0

//packed arrays give the values the opposite way from what we expect, so array of 3X3, 
//when we call array[0] it will give the last 3 bits

module solver (
        //TODO: confirm sizes for everything
        input wire clk,
        input wire rst,
        input wire started, //indicates board has been parsed, ready to solve
        input wire  [SIZE-1:0] option,
        
        input wire valid_op,
        input wire [(2*SIZE) - 1:0] [6:0] old_options_amnt,  //[0:2*SIZE] [6:0]
        //Taken from the BRAM in the top level- how many options for this line

        output logic  [SIZE*SIZE - 1:0] assigned,  //changed to 1D array for correct indexing
        output logic  [SIZE*SIZE - 1:0] known,      // changed to 1D array for correct indexing
        output logic put_back_to_FIFO,  //boolean- do we need to push to fifo
        output logic solved //1 when solution is good
    );

        parameter SIZE = 3;
        logic [(2*SIZE) - 1:0] [6:0] options_amnt; 
        logic [(2*SIZE)-1:0] line_ind; //was $clog2(SIZE)*2  but I(dana) changed it cuz anyway line index come from option which is in spec size
                                       //(veronica) changed again to match options amount (2*Size) -1
        logic row;
        assign row = line_ind < SIZE;
        // logic  [SIZE-1:0] [SIZE-1:0] known;
        
        logic valid_in_simplify;

        logic [6:0] options_left; //options left to get from the fifo
        logic [6:0] net_valid_opts; //how many valid options we checked

        //logic [SIZE-1:0] last_valid_option; //that is the last valid option we got for this line. we need it for when we transition we want to use it to assign

        logic contradict; //if 1 contradicts and we remove it
        logic simp_valid; //out put valid for simplify

        logic one_option_case;

        logic  [SIZE-1:0] assi_simp; //one line input of assigned input to simplify
        logic [SIZE-1:0] known_simp; //one line input of known input to simplif

        logic [SIZE-1:0] always1;// a and b
        logic [SIZE-1:0] always0;

        simplify #( (SIZE))simplify_m(
        .clk(clk),
        .rst(rst),
        .valid_in(valid_in_simplify),
        .assigned(assi_simp), // SIZE-1:0]
        .known(known_simp),
        .option(option),
        .valid(simp_valid),
        .contradict(contradict)
        );


    logic  [SIZE*SIZE-1:0] known_t; //transpose
    logic  [SIZE*SIZE-1:0] assigned_t; //transpose


    //TRANSPOSING:
    genvar m; //rows
    genvar n; //cols
    for(m = 0; m < SIZE; m = m + 1) begin
        for(n = 0; n < SIZE; n = n + 1) begin
            assign known_t[n*SIZE + m] = known[m*SIZE + n];
            assign assigned_t[n*SIZE + m] = assigned[m*SIZE + n];
        end
    end

//Grab the line from relevant known and assigned blocks
//@NINA - I didn't know how to change this to reflect 1D arrays
    always_comb begin
        if (options_left > 0) begin
            valid_in_simplify = 1;
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
            valid_in_simplify = 0;
        end
    end
    
    always_ff @(posedge clk)begin
        if(rst)begin
            known <= 0;
            assigned <= 0;
            // valid_out <=0;
            net_valid_opts <=0;
            // started <=0;
            one_option_case <= 0;

        end else if (one_option_case && simp_valid) begin
            put_back_to_FIFO <= 0;
            if (row) begin
                known[line_ind*SIZE +: SIZE] <= -1; //-1;//this might be wroing '{1}, suppose to be a whole ist of 1
                assigned[line_ind*SIZE +: SIZE] <= 3'b101;
            end else begin
                for(integer j = 0; j < SIZE; j = j + 1) begin
                    known[j*SIZE + line_ind] <= 1;
                    assigned[j*SIZE + line_ind] <= option[j];
                end
            end
            options_left <= options_left - 1 ;
        //if we have options left to check:
        end else if (options_left > 0 && simp_valid == 1)begin
            if (simp_valid) begin       
                if (contradict)begin
                    put_back_to_FIFO <= 0;
                end else begin
                    //last_valid_option <= option;
                    put_back_to_FIFO <= 1;
                    net_valid_opts <= net_valid_opts + 1;
                    always1 <= always1 & option;
                    always0 <= always0 & ~option;
                end
                // valid_out<=1;
                options_left <= options_left - 1 ;
            end

        //transition to new line, reset some registers
        //first line logic is now also here (avoids repetitive code)
        end else if (options_left == 0 || started == 1) begin
            //TODO: maybe break this into 2 clock cycles, one where we process old values and one where we assign the new ones
            //unsure if thats nessessary
            
            //@Nina I think we need to change the value of started- we get 1 when we need to start the board
            //and its 0 after we got the first sign
            if (started == 0) begin
                options_amnt[line_ind] <= net_valid_opts;
                options_left <= options_amnt[option];
                //@Nina I think here we done with a line, since we dont have options to check
                if (options_amnt[option] == 1) begin
                    one_option_case <= 1;
                end else begin
                    one_option_case <= 0;
                end

            end else begin
                //first round logic
                options_amnt <= old_options_amnt;
                // started <= 1;
                options_left <= old_options_amnt[0];
                if (old_options_amnt[0] == 1)begin
                    one_option_case <= 1;
                end else begin
                    one_option_case <= 0;
                end
            end
            line_ind <= option;
            net_valid_opts <= 0;
            always1 <= -1;
            always0 <= -1;

            //TODO check if specific bits of always1 or always0 are 1, if so assign it to known and assigned accordingly
            if  (row) begin
                for(integer i = 0; i < SIZE; i = i + 1) begin
                    if (always1[i] == 1) begin 
                        known[line_ind * SIZE + i] <= 1; //-1;//this might be wroing '{1}, suppose to be a whole ist of 1
                        assigned[line_ind * SIZE + i] <= 1;
                    end
                    if (always0[i] == 1) begin 
                        known[line_ind * SIZE + i] <= 1; //-1;//this might be wroing '{1}, suppose to be a whole ist of 1
                        assigned[line_ind * SIZE + i] <= 0;
                    end
                end

            end else if (~row) begin

                for(integer j = 0; j < SIZE; j = j + 1) begin
                    // I think the row we indexing into is j
                    //and the column is line index-size
                    if (always1[j] == 1) begin 
                        known[j*SIZE + line_ind] <= 1; //-1;//this might be wroing '{1}, suppose to be a whole ist of 1
                        assigned[j*SIZE + line_ind] <= 1;
                    end
                    if (always0[j] == 1) begin 
                        known[j*SIZE + line_ind] <= 1; //-1;//this might be wroing '{1}, suppose to be a whole ist of 1
                        assigned[j*SIZE + line_ind] <= 0;
                    end
                end
            end
                //right now my only idea is to have a for loop and go through the options and check 
                //but that feels jank so maybe lets ask in office hours first?

            end
        
        end

endmodule

`default_nettype wire
