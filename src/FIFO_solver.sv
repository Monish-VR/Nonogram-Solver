
`timescale 1ns / 1ps
`default_nettype none

module fifo_solver(
        input wire clk,
        input wire rst,
        //TODO: specify remaining inputs and outputs

        
        output logic solved,  //signals solver is done
);

if(rst)begin

end else if (len(FIFO) == 0) begin //TODO: Fix this
    solved <= 1;
end else begin


end

endmodule



`default_nettype wire
