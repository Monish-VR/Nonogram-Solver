
`timescale 1ns / 1ps
`default_nettype none
//assuming line index starts at 0

module fifo_solver (
        input wire clk,
        input wire rst,
        input wire  [SIZE-1:0] option,
        input wire  [SIZE-1:0] line_ind,
        input wire valid_op,
        input wire row, //is it a row or a column (line indices repeat, once for the row index and once for the column)
        input wire  [SIZE:0] option_num,//TODO: what SIZE is this

        output logic  [SIZE-1:0] assigned_board  [SIZE-1:0], 
        output logic put_back_to_FIFO, 
        output logic new_option_num
    );
        parameter SIZE = 4;
        logic  [SIZE-1:0]  [SIZE-1:0] known;
        logic  [SIZE-1:0]  [SIZE-1:0] assigned ;
        logic contradict;
        logic simp_valid;

        logic  [SIZE-1:0] assi_simp;
        logic [SIZE-1:0] known_simp;

        simplify #( (SIZE))simplify_m(
        .clk(clk),
        .rst(rst),
        .valid_in(valid_op),
        .assigned(assi_simp), // SIZE-1:0]
        .known(known_simp),
        .option(option),
        .valid(simp_valid),
        .contradict(contradict)
        );


    logic  [SIZE-1:0]  [SIZE-1:0] known_t;
    logic  [SIZE-1:0]  [SIZE-1:0] assigned_t;

    genvar m;
    genvar n;
    for(m = 0; m < SIZE; m = m + 1) begin
        for(n = 0; n < SIZE; n = n + 1) begin

            assign known_t[n][m] = known[m][n];
            assign assigned_t[n][m] = assigned[m][n];
        end
    end
    
    always_comb begin
        if (row) begin
            assi_simp = assigned[line_ind];
            known_simp = known[line_ind];
        end else begin
            assi_simp = assigned_t[line_ind];
            known_simp = known_t[line_ind];
            //for (int i = 0; i < SIZE; i = i + 1)begin
            //    assi_simp[i] = assigned[i][line_ind];
            //    known_simp[i] = known[i][line_ind];
            //end
        end

    end
    
    always_ff @(posedge clk)begin
        if(rst)begin
            known <= 0;
            assigned <= 0;
        end 
        
        else if (option_num == 1) begin
            //this is the only valid option for the line
            put_back_to_FIFO <= 0;
            if (row) begin
                known[line_ind] <= -1; //-1;//this might be wroing '{1}
                assigned[line_ind] <= option;
            end else begin
                //known_t[line_ind] <= 0; //-1;//this might be wroing '{1}
               // assigned_t[line_ind] <= option;
               for(integer row = 0; row < SIZE; row = row + 1) begin
                    known[row*SIZE + line_ind] <= 1;
                    assigned[row*SIZE + line_ind] <= option[row];
               end
            end
        
        end else if (valid_op) begin       
            if (contradict && simp_valid)begin
                put_back_to_FIFO <= 0;
                new_option_num <= option_num - 1;
            end else begin
                put_back_to_FIFO <= 1;
            end
        end
    end

endmodule

`default_nettype wire
