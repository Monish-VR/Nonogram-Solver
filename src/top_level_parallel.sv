`default_nettype none
`timescale 1ns / 1ps

module top_level (
        input wire clk_100mhz,
        input wire btnc,
        input wire rx,

        output logic tx,
        output logic [7:0] bits,
        output logic [2:0] stat
    );
    
    localparam MAX_ROWS = 11;  // HARDCODED for 11x11
    localparam MAX_COLS = 11;  // HARDCODED for 11x11
    localparam LARGEST_DIM = (MAX_ROWS > MAX_COLS)? MAX_ROWS : MAX_COLS;
    localparam MAX_NUM_OPTIONS = 84; //HARDCODED for 11x11

    localparam RECEIVE = 0;
    localparam SOLVE = 1;
    localparam TRANSMIT = 2;

    localparam CYCLES = 50_000_000;
    localparam MAX_BYTE = 255;
    localparam COUNTER_WIDTH = $clog2(CYCLES);

    logic rst;
    logic [COUNTER_WIDTH - 1: 0] counter;
    logic [7:0] transmit_data, received_data, display_value;
    logic receive_done, transmit_valid, transmit_done, next_line;
    logic fifo_write, parse_write, solve_write, solve_next;
    logic [1:0] state;
    logic [15:0] fifo_in, fifo_out, parse_line, solve_line;
    logic fifo_empty, fifo_full;
    logic parsed, solved, assembled;
    logic [2:0] [$clog2(MAX_ROWS) - 1:0] m;
    logic [2:0] [$clog2(MAX_COLS) - 1:0] n;
    logic [MAX_ROWS + MAX_COLS - 1:0] [$clog2(MAX_NUM_OPTIONS) - 1:0] options_per_line;
    logic [1:0] [(MAX_ROWS * MAX_COLS) - 1:0] solution;
    logic [(MAX_ROWS * MAX_COLS) - 1:0] knowns;
    logic clk_50mhz;
    logic [2:0] flag;
    logic fifo_rst;

    assign stat = {state, (fifo_empty_r & fifo_empty_c)};
    assign rst = btnc;
    assign fifo_rst = rst || solved;
    assign bits = display_value;



    clk_wiz_50 divider (
        .clk_in1(clk_100mhz),
        .clk_out1(clk_50mhz)
    );

    uart_rx receiver (
        .clk(clk_50mhz),
        .rst(rst),
        .axiid(rx),

        .axiov(receive_done),
        .axiod(received_data)
    );

    parser parse (
        .clk(clk_50mhz),
        .rst(rst),
        .valid_in(receive_done),
        .byte_in(received_data),

        .board_done(parsed), //board is done 
        .write_ready(parse_write), //Indication that we need to write to BRAM ,here in top level , we done with one line to the BRAM, ready to get new one
        .line(parse_line),
        .options_per_line(options_per_line),
        .n(n[0]),
        .m(m[0]),
        .flag(flag)
    );


    /*ila_0 ila (
        .clk(clk_50mhz),
        .probe0(receive_done),
        .probe1(received_data),
        .probe2(parsed),
        .probe3(parse_write),
        .probe4(parse_line),
        .probe5(options_per_line),
        .probe6(m[0]),
        .probe7(n[0]),
        .probe8(stat),
        .probe9(fifo_write),
        .probe10(next_line),
        .probe11(solve_next),
        .probe12(solve_line),
        .probe13(solution[0]),
        .probe14(solve_write),
        .probe15(solved),
        .probe16(rst),
        .probe17(fifo_full),
        .probe18(fifo_empty),
        .probe19(btnc),
        .probe20(m[1]),
        .probe21(n[1]),
        .probe22(m[2]),
        .probe23(n[2])
    );*/



//FOR PARALLEL:

    logic fifo_write_r,fifo_write_c, solve_next_r,solve_next_c;
    logic [15:0] fifo_in_c,fifo_in_r, fifo_out_r,fifo_out_c, solve_line_r, solve_line_c;
    logic fifo_empty_r,fifo_empty_c, fifo_full_r, fifo_full_c;

    fifo_11_by_11 fifo_r (
        .clk(clk_50mhz),               // input wire clk
        .srst(fifo_rst),                    // input wire rst
        .din(fifo_in_r),                 // input wire [15 : 0] din
        .wr_en(fifo_write_r),            // input wire wr_en
        .rd_en(solve_next_r),            // input wire rd_en
        .dout(fifo_out_r),               // output wire [15 : 0] dout
        .full(fifo_full_r),              // output wire full
        .empty(fifo_empty_r)             // output wire empty
    );

        fifo_11_by_11 fifo_c (
        .clk(clk_50mhz),               // input wire clk
        .srst(fifo_rst),                    // input wire rst
        .din(fifo_in_c),                 // input wire [15 : 0] din
        .wr_en(fifo_write_c),            // input wire wr_en
        .rd_en(solve_next_c),            // input wire rd_en
        .dout(fifo_out_c),               // output wire [15 : 0] dout
        .full(fifo_full_c),              // output wire full
        .empty(fifo_empty_c)             // output wire empty
    );

    solver sol (
        //TODO: confirm sizes for everything
        .clk(clk_50mhz),
        .rst(rst),
        .started(parsed), //indicates board has been parsed, ready to solve
        .option_r(fifo_out_r),
        .option_c(fifo_out_c),
        .num_rows(m[1]),
        .num_cols(n[1]),
        //May have to divide this:
        .old_options_amnt(options_per_line),  //[0:2*SIZE] [6:0]
        .read_from_fifo_r(solve_next_r),
        .read_from_fifo_c(solve_next_c),
        .new_option_r(solve_line_r),
        .new_option_c(solve_line_c),
        .assigned(solution[0]),  
        .known(known[0])
        .put_back_to_FIFO_r(solve_write_r),  //boolean- do we need to push to fifo
        .put_back_to_FIFO_r(solve_write_c),
        .solved(solved) // board is 
    );


    assembler assemble (
        .clk(clk_50mhz),
        .rst(rst),
        .valid_in(solved),
        .transmit_done(transmit_done),
        .solution(solution[1]),
        .n(n[2]),  //11x11
        .m(m[2]),  //11x11

        .send(transmit_valid),
        .byte_out(transmit_data),
        .done(assembled)
    );

    uart_tx transmitter (
        .clk(clk_50mhz),
        .rst(rst),
        .axiiv(transmit_valid),
        .axiid(transmit_data),
        
        .axiod(tx),
        .done(transmit_done)
    );

logic fifo_write_r,fifo_write_c, solve_next_r,solve_next_c;
logic [15:0] fifo_in_c,fifo_in_r, fifo_out_r,fifo_out_c, solve_line_r, solve_line_c;
logic fifo_empty_r,fifo_empty_c, fifo_full_r, fifo_full_c;
logic finished_rows; //are we still recieving rows from parser
logic [$clog2(MAX_NUM_OPTIONS * MAX_COLS) - 1:0]row_counter ; 

//////// TO COMPLETE- how to get number of total entries to fifo r- all the rows indices and all the rows options
// and then assign when finished_rows = 1 or 0
//should we do it under parser as an output from parser or count here?
// number_entries = rows + numb_options_for each row

always_comb begin
    if (state == RECEIVE) begin
        if (~finished_rows) begin
            fifo_write_r = parse_write;
            fifo_in_r = parse_line;
            fifo_write_c = 0;
        end else begin
            fifo_write_c = parse_write;
            fifo_in_c = parse_line;
            fifo_write_r = 0;
        end
    end else if (state == SOLVE) begin
        fifo_write_r = solve_write_r;
        fifo_write_c = solve_write_c;
        fifo_in_r = solve_line_r;
        fifo_in_c = solve_line_c;
    end
end

    always_ff @(posedge clk_50mhz)begin
        if (rst) begin
            counter <= 0;
            state <= 0;
            display_value <= 0;
            row_counter<=0;
        end else begin
            if (receive_done) display_value <= received_data;
            else if (transmit_done) display_value <= transmit_data;
            solution[1] <= solution[0];
            n[1] <= n[0];       
            n[2] <= n[1];
            m[1] <= m[0];
            m[2] <= m[1];
            case(state)
                RECEIVE: begin
                    state <= (parsed)? SOLVE : RECEIVE;
                    row_counter <= row_counter +1 ;
                end
                SOLVE: state <= (solved)? TRANSMIT : SOLVE;
                TRANSMIT: state <= (assembled)? RECEIVE: TRANSMIT;
            endcase
        end
    end

endmodule

`default_nettype wire
