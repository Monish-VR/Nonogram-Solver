
`timescale 1ns / 1ps
`default_nettype none
//assuming line index starts at 0

//packed arrays give the values the opposite way from what we expect, so array of 3X3, 
//when we call array[0] it will give the last 3 bits

module solver #(parameter MAX_ROWS = 11, parameter MAX_COLS = 11, parameter MAX_NUM_OPTIONS=84)(
        //TODO: confirm sizes for everything
        input wire clk,
        input wire rst,
        input wire started, //indicates board has been parsed, ready to solve
        input wire [15:0] option1,//TOOD: size larger than nessessary
        input wire [15:0] option2,
        input wire [$clog2(MAX_ROWS) - 1:0] num_rows,
        input wire [$clog2(MAX_COLS) - 1:0] num_cols,
        input wire [MAX_ROWS + MAX_COLS - 1:0] [$clog2(MAX_NUM_OPTIONS)-1:0] old_options_amnt,  //[0:2*SIZE] [6:0]
        //Taken from the BRAM in the top level- how many options for this line
        output logic new_line,
        output logic [15:0] new_option1,
        output logic [15:0] new_option2,
        output logic [(MAX_ROWS * MAX_COLS) - 1:0] assigned,  //changed to 1D array for correct indexing
        output logic [(MAX_ROWS * MAX_COLS) - 1:0] known,      // changed to 1D array for correct indexing
        output logic put_back_to_FIFO1,  //boolean- do we need to push to fifo
        output logic put_back_to_FIFO2,  //boolean- do we need to push to fifo

        output logic solved //1 when solution is good
    );
    localparam IDLE = 0;
    localparam NEXT_LINE_INDEX = 1;
    localparam ONE_OPTION = 2;
    localparam MULTIPLE_OPTIONS = 3;
    localparam WRITE = 4;

    logic [2:0] state1, state_prev1;
    logic [2:0] state2, state_prev2;

    localparam LARGEST_DIM = (MAX_ROWS > MAX_COLS)? MAX_ROWS : MAX_COLS;
    logic [MAX_ROWS + MAX_COLS - 1:0] [6:0] options_amnt; 
    logic [2:0][$clog2(MAX_ROWS + MAX_COLS) - 1:0] line_index1, new_index1;
    logic [2:0][$clog2(MAX_ROWS + MAX_COLS) - 1:0] line_index2, new_index2;
    logic [$clog2(MAX_ROWS * MAX_COLS) - 1:0]  base_index, sol_index;
    logic row1, row2,first;
    assign row1 = line_index1[0] < num_rows;
    assign row2 = line_index2[0] < num_rows;
    logic valid_in_simplify;

    logic [$clog2(MAX_NUM_OPTIONS) - 1:0] options_left1; //options left to get from the fifo
    logic [$clog2(MAX_NUM_OPTIONS) - 1:0] net_valid_opts1; //how many valid options we checked
    logic [$clog2(MAX_NUM_OPTIONS) - 1:0] options_left2; //options left to get from the fifo
    logic [$clog2(MAX_NUM_OPTIONS) - 1:0] net_valid_opts2; //how many valid options we checked

    logic simp_valid; //out put valid for simplify

    logic one_option_case1;
    logic one_option_case2;

    logic [LARGEST_DIM-1:0] curr_assign1; //one line input of assigned input to simplify
    logic [LARGEST_DIM-1:0] curr_known1; //one line input of known input to simplif
    logic [LARGEST_DIM-1:0] curr_assign2; //one line input of assigned input to simplify
    logic [LARGEST_DIM-1:0] curr_known2; //one line input of known input to simplif



    logic [LARGEST_DIM-1:0] always1_1;// a and b
    logic [LARGEST_DIM-1:0] always0_1;
    logic [LARGEST_DIM-1:0] always1_2;// a and b
    logic [LARGEST_DIM-1:0] always0_2;
    logic [MAX_COLS-1:0] cols_all_known;
    logic [$clog2(MAX_COLS) - 1:0] num_known_cols;

    logic  [(MAX_ROWS * MAX_COLS) - 1:0] known_t; //transpose
    logic  [(MAX_ROWS * MAX_COLS) - 1:0] assigned_t; //transpose


    //TRANSPOSING:
    genvar m; //rows
    genvar n; //cols
    for(m = 0; m < MAX_ROWS; m = m + 1) begin
        for(n = 0; n < MAX_COLS; n = n + 1) begin
            assign known_t[n*MAX_ROWS + m] = known[m*MAX_COLS + n];
            assign assigned_t[n*MAX_ROWS + m] = assigned[m*MAX_COLS + n];
        end
    end

//Grab the line from relevant known and assigned blocks
    always_comb begin
        //gets relevant line from assigned and known
        if (row1) begin
            curr_assign1 = assigned[MAX_COLS*new_index +: MAX_COLS];
            curr_known1 = known[MAX_COLS*new_index +: MAX_COLS];
        end else begin
            curr_assign1 = assigned_t[MAX_ROWS*(new_index - num_rows) +: MAX_ROWS];
            curr_known1 = known_t[MAX_ROWS*(new_index - num_rows) +: MAX_ROWS];
        end
        if (row2) begin
            curr_assign2 = assigned[MAX_COLS*new_index +: MAX_COLS];
            curr_known2 = known[MAX_COLS*new_index +: MAX_COLS];
        end else begin
            curr_assign2 = assigned_t[MAX_ROWS*(new_index - num_rows) +: MAX_ROWS];
            curr_known2 = known_t[MAX_ROWS*(new_index - num_rows) +: MAX_ROWS];
        end
        
        cols_all_known = '1;
        num_known_cols = 0;
        sol_index = 0;
        for (integer i = 0; i < MAX_ROWS; i = i + 1)begin
            if (i < num_rows)begin
                cols_all_known = cols_all_known & known[sol_index +: MAX_COLS];
                sol_index = sol_index + MAX_COLS;
            end
        end
        for (integer j = 0; j < MAX_COLS; j = j + 1)begin
            if(cols_all_known[j] && j < num_cols) num_known_cols = num_known_cols + 1;
        end
    end
    
    always_ff @(posedge clk)begin
        if(rst)begin
            known <= 0;
            assigned <= 0;
            net_valid_opts <=0;
            solved <= 0;
            state <= IDLE;
            first <= 1;
            new_index <= '0;
            options_amnt <= '0;
            line_index <= '0;
            base_index<= '0;
            new_line<= '0;
            new_option1<= '0;
            new_option2<= '0;
            put_back_to_FIFO<=0;  //boolean- do we need to push to fifo
        end else begin
            case(state)
                IDLE: begin
                    if (started)begin
                        new_line <= 1;
                        state <= NEXT_LINE_INDEX;
                    end
                    solved <= 0;
                    first <= 1;
                end
                NEXT_LINE_INDEX: begin
                    if (num_known_cols == num_cols)begin
                        //victory check
                        solved <= 1;
                        state <= IDLE;
                        new_line <= 0;
                    end else begin
                        if(first)begin
                            options_amnt <= old_options_amnt;
                            options_left <= old_options_amnt[option];
                            state <= (old_options_amnt[option] == 1)? ONE_OPTION : MULTIPLE_OPTIONS;
                            first <= 0;
                        end else begin
                            options_amnt[line_index[2]] <= net_valid_opts;
                            options_left <= options_amnt[option];
                            state <= (options_amnt[option] == 1)? ONE_OPTION : MULTIPLE_OPTIONS;
                        end
                        //begin new line
                        new_index <= option;
                        line_index[0] <= option;
                        put_back_to_FIFO <= 1;
                        new_option <= option;
                        net_valid_opts <= 0;
                        always1 <= '1;
                        always0 <= '1;
                        put_back_to_FIFO <= 1;
                    end
                end
                MULTIPLE_OPTIONS: begin
                    //check to see if it contradicts known info
                    if (((curr_assign1 ^ option1) & curr_known1) > 0) put_back_to_FIFO1 <= 0;
                    else begin
                        //if it doesn't contradict, update values accordingly
                        new_option <= option;
                        net_valid_opts1 <= net_valid_opts1 + 1;
                        always1_1 <= always1_1 & option1;
                        always0_1 <= always0_1 & ~option1;
                        put_back_to_FIFO <= 1;
                    end
                    options_left1 <= options_left1 - 1;
                    state1 <= (options_left1 - 1 == 0)? WRITE : MULTIPLE_OPTIONS;
                    new_line1 <= (options_left1 > 1);
                    if (((curr_assign2 ^ option2) & curr_known2) > 0) put_back_to_FIFO2 <= 0;
                    else begin
                        //if it doesn't contradict, update values accordingly
                        new_option2 <= option2;
                        net_valid_opts2 <= net_valid_opts2 + 1;
                        always1_2 <= always1_2 & option2;
                        always0_2 <= always0_2 & ~option2;
                        put_back_to_FIFO2 <= 1;
                    end
                    options_left2 <= options_left2 - 1;
                    state2 <= (options_left2 - 1 == 0)? WRITE : MULTIPLE_OPTIONS;
                    new_line2 <= (options_left2 > 1);
                end
                ONE_OPTION: begin
                    //if there is only one option, it must be that this is the correct option
                    put_back_to_FIFO <= 0;
                    net_valid_opts <= 0;
                    always1 <= always1 & option;//TODO: I think this unessessary
                    always0 <= always0 & ~option;
                    options_left <= 0;
                    state <= WRITE;//TODO: I think this may be overkill
                    new_line <= 0;

                    put_back_to_FIFO2 <= 0;
                    net_valid_opts2 <= 0;
                    always1_2 <= always1_2 & option2;//TODO: I think this unessessary
                    always0_2 <= always0_2 & ~option2;
                    options_left2 <= 0;
                    state2 <= WRITE;//TODO: I think this may be overkill
                    new_line2 <= 0;
                end
                WRITE: begin
                    new_line <= 1;
                    // check if specific bits of always1 or always0 are 1, if so assign it to known and assigned accordingly
                    if (row2) begin
                        base_index = MAX_COLS*line_index[1];
                        for(integer i = 0; i < MAX_COLS; i = i + 1) begin
                            if(i < num_cols) begin
                                if (always1_2[i] == 1) begin 
                                    known[base_index + i] <= 1;
                                    assigned[base_index+ i] <= 1;
                                end
                                if (always0_2[i] == 1) begin 
                                    known[base_index + i] <= 1; 
                                    assigned[base_index + i] <= 0;
                                end
                            end
                        end
                    end else begin
                        base_index = (line_index2[1] - num_rows);
                        for(integer j = 0; j < MAX_ROWS; j = j + 1) begin
                            // I think the row we indexing into is j
                            //and the column is line index-size
                            if(j < num_rows) begin
                                if (always1_2[j]) begin 
                                    known[base_index] <= 1; 
                                    assigned[base_index] <= 1;
                                end
                                if (always0_2[j]) begin 
                                    known[base_index] <= 1; 
                                    assigned[base_index] <= 0;
                                end
                            end
                            base_index += MAX_COLS;
                        end
                    end
                    if (row1) begin
                        base_index = MAX_COLS*line_index[1];
                        for(integer i = 0; i < MAX_COLS; i = i + 1) begin
                            if(i < num_cols) begin
                                if (always1_1[i] == 1) begin 
                                    known[base_index + i] <= 1;
                                    assigned[base_index+ i] <= 1;
                                end
                                if (always0_1[i] == 1) begin 
                                    known[base_index + i] <= 1; 
                                    assigned[base_index + i] <= 0;
                                end
                            end
                        end
                    end else begin
                        base_index = (line_index1[1] - num_rows);
                        for(integer j = 0; j < MAX_ROWS; j = j + 1) begin
                            // I think the row we indexing into is j
                            //and the column is line index-size
                            if(j < num_rows) begin
                                if (always1_1[j]) begin 
                                    known[base_index] <= 1; 
                                    assigned[base_index] <= 1;
                                end
                                if (always0[j]) begin 
                                    known[base_index] <= 1; 
                                    assigned[base_index] <= 0;
                                end
                            end
                            base_index += MAX_COLS;
                        end
                    end
                    state <= NEXT_LINE_INDEX;
                    put_back_to_FIFO <= 0;
                end
            endcase
        end
        //pipelining
        state_prev1 <= state1;
        if(state_prev1 != state1)begin
            line_index1[1] <= line_index1[0];
            line_index1[2] <= line_index1[1];
        end
        state_prev2 <= state2;
        if(state_prev2 != state2)begin
            line_index2[1] <= line_index2[0];
            line_index2[2] <= line_index2[1];
        end
    end

endmodule

`default_nettype wire
