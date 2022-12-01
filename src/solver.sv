
`timescale 1ns / 1ps
`default_nettype none
//assuming line index starts at 0

//packed arrays give the values the opposite way from what we expect, so array of 3X3, 
//when we call array[0] it will give the last 3 bits

module solver (
        //TODO: confirm sizes for everything
        input wire clk,
        input wire rst,
        input wire start_solver, //indicates board has been parsed, ready to solve
        input wire  [SIZE-1:0] option,
        
        input wire valid_op,
        input wire [2*SIZE:0] [6:0] old_options_amnt,  //[0:2*SIZE] [6:0]
        //Taken from the BRAM in the top level- how many options for this line

        output logic  [SIZE-1:0]  [SIZE-1:0] assigned,  
        output logic put_back_to_FIFO,  //boolean- do we need to push to fifo
        output logic [6:0] new_option_num, // for the BRAM gonna either be same as option num or 1 less
        output logic valid_out
    );

        parameter SIZE = 3;
        logic [2*SIZE:0] [6:0] options_amnt; 
        logic [$clog2(SIZE):0] line_ind;
        logic row;
        assign row = line_ind < SIZE;
        logic  [SIZE-1:0] [SIZE-1:0] known;
        
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

        logic started;

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
            valid_out <=0;
            net_valid_opts <=0;
            started <=0;
            one_option_case <= 0;

        end else if (one_option_case && simp_valid) begin
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
         
        //if we have options left to check:
        end else if (options_left > 0 && simp_valid == 1)begin
            if (simp_valid) begin       
                if (contradict)begin
                    put_back_to_FIFO <= 0;
                end else begin
                    //last_valid_option <= option;
                    put_back_to_FIFO <= 1;
                    net_valid_opts <= net_valid_opts + 1;
                    always1 <= always1 && option;
                    always0 <= always0 && ~option;
                end
                valid_out<=1;
                options_left <= options_left - 1 ;
            end

        //transition to new line, reset some registers
        //first line logic is now also here (avoids repetitive code)
        end else if (options_left == 0 || started == 0) begin
            //TODO: maybe break this into 2 clock cycles, one where we process old values and one where we assign the new ones
            //unsure if thats nessessary
            
            //@DANA - what do you think of combining the starter code logic with this code?
            //@Nina - I think it's ok, the thing is that it will only understand that it has one option after a whole iteration over the FIFO
            // thats what I tried to avoid with the code from before, (under transition check if #option==1) 
            //which i agree may have been wrong as it does put it into fifo tho.., but I tried to immidiate 
            //identify when we have only one option when we transition.  

            if (started == 1) begin
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
                started <= 1;
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
                        known[i*SIZE + line_ind] <= 1; //-1;//this might be wroing '{1}, suppose to be a whole ist of 1
                        assigned[i*SIZE + line_ind] <= 1;
                    end
                    if (always0[i] == 1) begin 
                        known[i*SIZE + line_ind] <= 1; //-1;//this might be wroing '{1}, suppose to be a whole ist of 1
                        assigned[i*SIZE + line_ind] <= 0;
                    end
                end
            end else if (~row) begin
                
                for(integer i = 0; i < SIZE; i = i + 1) begin
                    // I think the row we indexing into is i
                    //and the column is line index-size
                    if (always1[i] == 1) begin 
                        known[i*SIZE - line_ind - SIZE] <= 1; //-1;//this might be wroing '{1}, suppose to be a whole ist of 1
                        assigned[i*SIZE - line_ind - SIZE] <= 1;
                    end
                    if (always0[i] == 1) begin 
                        known[i*SIZE - line_ind - SIZE] <= 1; //-1;//this might be wroing '{1}, suppose to be a whole ist of 1
                        assigned[i*SIZE - line_ind - SIZE] <= 0;
                    end
                end
            end
                //right now my only idea is to have a for loop and go through the options and check 
                //but that feels jank so maybe lets ask in office hours first?

            end
        
        end

endmodule

`default_nettype wire
