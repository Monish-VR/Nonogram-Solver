`default_nettype none
`timescale 1ns / 1ps

module uart_tx_tb;

    logic clk;
    logic rst;
    logic axiiv;
    logic [7:0] axiid;
    
    logic axiod;
    logic done;

    uart_tx uut(
        .clk(clk),
        .rst(rst),
        .axiiv(axiiv),
        .axiid(axiid),
        .axiod(axiod),
        .done(done)
    );

    always begin
        #5;
        clk = !clk;
    end

    initial begin
        $dumpfile("uart_tx.vcd");
        $dumpvars(0, uart_tx_tb);
        $display("Starting Sim");
        clk = 0;
        rst = 0;
        axiiv = 0;
        #5;
        rst = 1;
        #10;
        rst = 0;

        $display("DONE should be zero from the beginning (not transmitting)");
        #21000;

        $display("1st transmission");
        axiid = 8'b10101010;
        #10;
        axiiv = 1;
        #20;
        axiiv = 0;
        #1146000;

        $display("2nd transmission");
        axiid = 8'b11001100;
        #10;
        axiiv = 1;
        #20;
        axiiv = 0;
        #1146000;

        $display("Finishing Sim");
        $finish;
    end

endmodule

`default_nettype wire
