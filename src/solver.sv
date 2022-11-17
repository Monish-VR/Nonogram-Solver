`timescale 1ns / 1ps
`default_nettype none

module solver(
        input wire clk,
        input wire rst,
        input wire [12:0] bram_read, //bits read from the BRAM slot
        input wire valid_in,
        input wire [11:0] n,
        input wire [11:0] m, //max value of line indicator :  m+n 
        
        output logic solved,  //signals solver is done
        output logic read_ready, //signals when we want to read from BRAM

        //
        output logic [11:0] n, m
        // size(cell index) is dependent on size of message we 2^12
    );

    logic [] line1, line2 ; //registers that will hold the content of line 1 and line 2
    logic [] id1, id2 ; //identifiers for which lines are currently in the registers
    logic [] lines_assigned ; //COUNTER for how many lines we assigned valid solutions to
    logic [] counter_line2,counter_line1 ; //counters to know when we filled the registers with the lines
    logic load_to_reg1,load_to_reg2; //boolean to know when to load where
    logic false_assigment; //when iterating over the assigmnets, if 2 lines contradict we set false = 1
    logic [] length_of_line ; //number of bits in a line of assigments

    always_ff @(posedge clk_100mhz)begin
        if (rst) begin
            id1 <= 0;
            id2 <= 0;
            load_to_reg1<=0;
            load_to_reg2<=0;
            counter_line2<=0;
            counter_line1<=0;
            false_assigment<=0;

        end
        else if (valid_in) begin
            if (id1==0) begin //start to write into first register
                id1 <= bram_read[12:0]; //set to line identifier.
                load_to_reg1 <=1; 
            end
            else if (load_to_reg1 && counter_line1 < max(m,n)) begin //write into line1
                line1 <= {X_BITS ,bram_read } //shift in bram read
                counter_line1 <= counter_line1 + 1 //
            end
            else if (counter_line1 == max(m,n)) begin //time to stop and start load to line 2
                id2 <= bram_read[12:0]; //set to line identifier.
                load_to_reg2 <=1; 
                load_to_reg1 <=0; 
            end
            else if (load_to_reg2 && counter_line2 < max(m,n)) begin //write into line2
                line1 <= {X_BITS ,bram_read } //shift in bram read
                counter_line2 <= counter_line2 + 1 //
            end
            ////BIG MONEY:
            else if (counter_line2 == max(m,n)) begin //CHECK ASSIGNMENTS!!!!
                counter_line2 <=0; //not sure about this one
                for (integer i = 0 , i < length_of_line , i<= i +13) begin
                    cell_1 <= line1[i+11 , i]; //cell
                    bool_cell_1 <= line1[12] ;//value
                    cell_2 <= line2[i+11 , i] ;//cell
                    bool_cell_2 <= line2[12] ;//value
                    if (cell_1 ==cell_2) && (bool_cell_1 != bool_cell_2 ) begin //false!
                        false_assigment <=1;
                    end
                if (~false_assigment) begin
                        // we need to try another option with line ID2
                    load_to_reg2 <=1;
                    
                end
                end
            end



            



endmodule

`default_nettype wire
