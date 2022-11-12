`default_nettype none
`timescale 1ns / 1ps

module uart_tb;

    logic [7:0] transmit_in;

    logic clk;
    logic rst;
    logic tx_valid;
    logic tx_out;

    logic receive_done;
    logic [7:0] rx_out;
    logic transmit_done;

    uart_tx transmitter (
        .clk(clk),
        .rst(rst),
        .axiiv(tx_valid),
        .axiid(transmit_in),
        
        .axiod(tx_out),
        .done(transmit_done)
    );

    uart_rx uut(
        .clk(clk),
        .rst(rst),
        .axiid(tx_out),
        .axiov(receive_done),
        .axiod(rx_out)
    );

    always begin
        #5;
        clk = !clk;
    end

    initial begin
        $dumpfile("uart.vcd");
        $dumpvars(0, uart_tb);
        $display("Starting Sim");
        clk = 0;
        rst = 0;
        tx_valid = 0;
        #5;
        rst = 1;
        #10;
        rst = 0;

        $display("AXIOV should be zero from the beginning (nothing received)");
        #21000;

        $display("1st transmission");
        transmit_in = 8'h3F;
        #10;
        tx_valid = 1;
        #10;
        tx_valid = 0;
        #1146000;

        $display("2nd transmission");
        transmit_in = 8'hF0;
        #10;
        tx_valid = 1;
        #10;
        tx_valid = 0;
        #1146000;

        $display("Finishing Sim");
        $finish;
    end

endmodule

`default_nettype wire
