
`timescale 1ns / 1ps
`default_nettype none
//assuming line index starts at 0

module fifo_solver (
        input wire clk,
        input wire rst,
        input wire [size-1:0] option,
        input wire [size-1:0] line_ind,
        input wire valid_op,
        input wire row, //is it a row or a column (line indices repeat, once for the row index and once for the column)
        input wire [size:0] option_num,//TODO: what size is this

        output logic [size-1:0] assigned_board [size-1:0], 
        output logic put_back_to_FIFO, 
        output logic new_option_num
    );
        parameter size = 4;
        logic [size-1:0] [size-1:0] known;
        logic [size-1:0] [size-1:0] assigned ;
        logic contradict;
        logic simp_valid;

        logic [size-1:0] assi_simp;
        logic [size-1:0] known_simp;

        simplify #(.size(size))simplify_m(
        .clk(clk),
        .rst(rst),
        .valid_in(valid_op),
        .assigned(assi_simp), //[size-1:0]
        .known(known_simp),
        .option(option),
        .valid(simp_valid),
        .contradict(contradict)
        );


    logic [size-1:0] [size-1:0] known_t;
    logic [size-1:0] [size-1:0] assigned_t;

    genvar m;
    genvar n;
    for(m = 0; m < size; m = m + 1) begin
        for(n = 0; n < size; n = n + 1) begin

            assign known_t[n][m] = known[m][n];
            assign assigned_t[n][m] = assigned[m][n];
        end
    end

    //always_ff @(posedge clk) begin
    //    for (int i..)
    //        for (int j...)
    //end

    always_comb begin
        if (row) begin
            assi_simp = assigned[line_ind];
            known_simp = known[line_ind];
        end else begin
            assi_simp = assigned_t[line_ind];
            known_simp = known_t[line_ind];
            //for (int i = 0; i < size; i = i + 1)begin
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
            if (row) begin
                known[line_ind] <= -1; //-1;//this might be wroing '{1}
                assigned[line_ind] <= option;
            end else begin
                //known_t[line_ind] <= 0; //-1;//this might be wroing '{1}
               // assigned_t[line_ind] <= option;
                integer j = 0;
                for(integer i = line_ind; i < size*size; i = i + size)begin
                    known[i] <= 1;
                    assigned[i] <= option[j];
                    j = j + 1;
                end
            end
        end
        
        else if (valid_op) begin       
            if (row) begin
                known[line_ind] = -1;//-1;//this might be wroing '{1}
                assigned[line_ind] <= option;
            end else begin
                //known_t[line_ind] = {1};//-1;//this might be wroing '{1}
                //assigned_t[line_ind] <= option;
                integer j = 0;
                for(integer i = line_ind; i < size*size; i = i + size)begin
                    known[i] <= 1;
                    assigned[i] <= option[j];
                    j = j + 1;
                end
            end

            if (contradict && simp_valid)begin
                put_back_to_FIFO <= 0;
                new_option_num <= option_num - 1;
            end else begin
                put_back_to_FIFO <= 1;
            end
        end
    end

endmodule




/*
module fifo_solver(#(parameter size =11)(
        input wire clk,
        input wire rst,
        input wire [1023:0] read_FIFO,
        input wire [6:0] options_per_line,

        output logic write_to_fifo, //when we simplified a line and want to put it back
        output logic rd_from_fifo, // when we want to read a nw line
        output logic [1023:0] dout, //simplified line out, write to fifo
        output logic [size-1:0] assigned_board [size-1:0], //when we're done we send the board
        output logic solved  //signals solver is done sends assigned board
        output logic option_counter

    );


    reg [size-1:0] known [size-1:0]; // 0 if we dont have assigned bit at this loc 1 if we do
    reg [size-1:0]assigned [size-1:0]; // 0 if the assigned bit is 0 or we don't know it yet, 1 if its 1 and we know its 1
    logic contradict, simp_valid; //outputs from simplify
    logic simplify_now; //1 if we want to call simplify
    logic [size-1:0] assi_simp;
    logic [size-1:0] known_simp;
    logic [size-1:0] opt_simp;
    logic got_a_line; // 1 when we have a line ready in read_FIFO to read from
    logic [1023:0] write_FIFO;
    logic contradict2; //if we put simplify in here
    logic [size:0] option_counter; //can be smaller
    logic [$clog2(1024):0] bit_to_skip;
    logic [size-1:0] col_known;
    logic [size-1:0] col_assigned;

simplify#(.size(11))(
        .clk(clk),
        .rst(rst),
        .valid_in(simplify_now),
        .assigned(assi_simp), //[size-1:0]
        .known(known_simp),
        .option(opt_simp),
        
        .valid(simp_valid),
        .contradict(contradict)
);

always_comb begin
    if (write_to_fifo) begin
        dout = write_FIFO;
    end
end

    always_ff @(posedge clk)begin
        if(rst)begin
            solved <= 0;
            contradict<=0;
            simp_valid<=0;
            simplify_now<=0;
            known <=0;
            assigned<=0;
            assi_simp<=0;
            known_simp<=0;
            opt_simp<=0;
            got_a_line<=0;
            contradict2<=0;
            option_counter<=0;
            bit_to_skip<=0
        end 
        else if (fifo_empty) begin 
            solved <= 1;
            assigned_board <=  assigned;
        end else begin
            //pop off top line of queue
            rd_from_fifo <=1;
            got_a_line <=1;
            option_counter<=0;
            
            if (got_a_line) begin //grab an option from the line and stop read from the fifo
                rd_from_fifo<=0;
                line_index <= read_FIFO[1023 : 1023 - $clog2(size*2) ]; 
                write_FIFO <= {line_index , 0};
                bit_to_skip<=0

                //if its a column we get the column known and assigned data:
                if (line_index >= size) begin
                    for (z = 0  ; z > size  ; z = z + 1) begin
                        col_known <= {col_known, known[line_index-size][z]};
                        col_assigned <= {col_assigned, assigned[line_index-size][z]};
                    end
                end
                for (i = 1023 - $clog2(size*2)   ; i > 0  ; i = i - size) begin
                    //ROW:
                    if (line_index < size) begin
                        //check if it can be simplified using simplify.sv
                        // simplify_now <=1;
                        // assi_simp <= assigned[line_index] ; 
                        // known_simp<= known[line_index] ;
                        opt_simp <= read_FIFO[i : i + size -1 ]; //getting an option
                        if (((assigned[line_index] ^ read_FIFO[i : i + size -1 ]) & known[line_index]) > 0) begin //basically pass if it contradicts
                            contradict2 <= 1;
                            bit_to_skip <= bit_to_skip + size ; //how many bits to skip when writing to WRITE_fIFO
                        end else begin // we need to add this option to what we gonna write to fifo
                            option_counter<=option_counter+1 ; //tells us how many valid option there are for a specific line
                            contradict2 <= 0;
                            write_FIFO[i + bit_to_skip : i + size -1 + bit_to_skip ] <= opt_simp; 
                        end 
                    end

                    //COL
                    else if (line_index >= size) begin
                        opt_simp <= read_FIFO[i : i + size -1 ];
                        if ((( col_assigned ^ read_FIFO[i : i + size -1 ]) & col_known) > 0) begin //basically pass if it contradicts
                            contradict2 <= 1;
                            bit_to_skip <= bit_to_skip + size ; //how many bits to skip when writing to WRITE_fIFO
                        end else begin // we need to add this option to what we gonna write to fifo
                            option_counter<=option_counter+1 ; //tells us how many valid option there are for a specific line
                            contradict2 <= 0;
                            write_FIFO[i + bit_to_skip : i + size -1 + bit_to_skip ] <= opt_simp; 
                        end 
                    end
                    $display ("Current loop#%0d ", i); 
                end
                if (option_counter == 1) begin //then we only have one option per line- so we have to use it
                    //don't return to FIFO
                    write_to_fifo<=0;
                    //add it to assigned and known
                    if (line_index < size) begin
                        known[line_index] <= {size{1'b1}};//check that thats how we fill with 1
                        assigned[line_index] <= write_FIFO[ 1024 - $clog2(size*2) : 1024 - $clog2(size*2) - size];
                    end
                    else begin
                        for (z = 0  ; z > size  ; z = z + 1) begin
                            known[z][line_index-size] <=  1;
                            assigned[z][line_index-size] <=  write_FIFO[ 1024 - $clog2(size*2) - i];
                        end
                    end 
                end else begin
                    write_to_fifo<=1;

                end
                


            //if it contradicts, remove this option from the queue line - I think I did so in the block above by not adding to writeFIFO

            //if it everything is known and it doesnt contradict, dont add the queue line back to the queue - I'm not sure what you mean- like we have 1 option that is good?

            //add the queue line back the qeueue - Done
        end 
    end

endmodule

*/

`default_nettype wire


//IF WE DECIDE TO DO BIGGER BOARDS- BRAM USAGE
    //BRAM INSTITIATION 
    //  Xilinx Single Port Read First RAM
    // xilinx_single_port_ram_read_first #(
    //     .RAM_WIDTH(11),     //
    //     .RAM_DEPTH(11),  //Full Calculation is on Dana's Ipad //M + M**2 + N + N**2 / / Specify RAM depth (number of entries) //Calculation is on my Ipad
    //     .RAM_PERFORMANCE("HIGH_PERFORMANCE") // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
    // ) known (
    //     .addra(bram_index), // Address bus, width determined from RAM_DEPTH //NOT SURE WHAT TO PUT HERE
    //     .dina(bram_input),  // RAM input data, width determined from RAM_WIDTH
    //     .clka(clk_100mhz),  // Clock
    //     .wea(slot_done),    // Write enable
    //     .ena(1),            // RAM Enable, for additional power savings, disable port when not in use
    //     .rsta(rst),        // Output reset (does not affect memory contents)
    //     .regcea(1),         // Output register enable
    //     .douta(bram_output) // RAM output data, width determined from RAM_WIDTH
    // ); 

    //     xilinx_single_port_ram_read_first #(
    //     .RAM_WIDTH(11),     //each slot in bram will be 13 bits- 12 bits for location 1 bit for boolean value
    //                         // UNLESS ITS LINE INDICATOR WHICH WILL BE up to 13 bits of indicating line
    //     .RAM_DEPTH(11),  //Full Calculation is on Dana's Ipad //M + M**2 + N + N**2 / / Specify RAM depth (number of entries) //Calculation is on my Ipad
    //     .RAM_PERFORMANCE("HIGH_PERFORMANCE") // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
    //     ) assigned (
    //     .addra(bram_index), // Address bus, width determined from RAM_DEPTH //NOT SURE WHAT TO PUT HERE
    //     .dina(bram_input),  // RAM input data, width determined from RAM_WIDTH
    //     .clka(clk_100mhz),  // Clock
    //     .wea(slot_done),    // Write enable
    //     .ena(1),            // RAM Enable, for additional power savings, disable port when not in use
    //     .rsta(rst),        // Output reset (does not affect memory contents)
    //     .regcea(1),         // Output register enable
    //     .douta(bram_output) // RAM output data, width determined from RAM_WIDTH
    // ); 
