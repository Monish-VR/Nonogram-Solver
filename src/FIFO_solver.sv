
`timescale 1ns / 1ps
`default_nettype none

module fifo_solver(
        input wire clk,
        input wire rst,
        //TODO: specify remaining inputs and outputs

        
        output logic solved,  //signals solver is done
);

logic contradict;

if(rst)begin

end else if (len(FIFO) == 0) begin //TODO: Fix this
    solved <= 1;
    //done return info
end else begin
    //pop off top line of queue

    //check if it can be simplified using simplify.sv

    //if it contradicts, remove this option from the queue line

    //if it everything is known and it doesnt contradict, dont add the queue line back to the queue

    //add the queue line back the qeueue
end

endmodule



`default_nettype wire
