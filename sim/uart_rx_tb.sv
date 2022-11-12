`default_nettype none
`timescale 1ns / 1ps

module uart_rx_tb;

    logic [9:0] total_transmission;

    logic clk;
    logic rst;
    logic axiid;

    logic axiov;
    logic [7:0] axiod;

    uart_rx uut(
        .clk(clk),
        .rst(rst),
        .axiid(axiid),
        .axiov(axiov),
        .axiod(axiod)
    );

    always begin
        #5;
        clk = !clk;
    end

    initial begin
        $dumpfile("uart_rx.vcd");
        $dumpvars(0, uart_rx_tb);
        $display("Starting Sim");
        clk = 0;
        rst = 0;
        axiid = 1;
        #5;
        rst = 1;
        #10;
        rst = 0;

        $display("AXIOV should be zero from the beginning (nothing received)");
        #21000;

        $display("1st transmission");
        total_transmission = 10'b1101010100;
        #10;
        for (int i = 0; i < 10; i = i+1)begin
            axiid = total_transmission[i];
            #104166;
        end
        axiid = 1;
        #42000;

        $display("2nd transmission");
        total_transmission = 10'b1110011000;
        #10;
        for (int i = 0; i < 10; i = i+1)begin
            axiid = total_transmission[i];
            #104166;
        end
        #20;
        axiid = 1;
        #42000;

        $display("Finishing Sim");
        $finish;
    end

endmodule

`default_nettype wire
