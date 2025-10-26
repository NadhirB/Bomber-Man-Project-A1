
// This module is to determine the winner of the 2-Player mode, based on the lives left.

module TwoPlayerWinScreen (
    input logic clk,
    input logic resetN,
	 input logic [3:0] lives,
	 input logic [3:0] lives2,
	 input logic DR_1,
	 input logic [7:0] RGB_1,
	 input logic DR_2,
	 input logic [7:0] RGB_2,
	 input logic DR_3,
	 input logic [7:0] RGB_3,
		
    output logic DR_winner,
	 output logic [7:0] RGB_winner
);


    always_ff @(posedge clk or negedge resetN) begin
        if (!resetN) begin
            DR_winner <= 1'b0;   
				RGB_winner <= 8'b0;
        end
        else begin
				if (lives2 > lives) begin
					DR_winner <= DR_1;
					RGB_winner <= RGB_1;
				end
				else if (lives > lives2) begin
					DR_winner <= DR_2;
					RGB_winner <= RGB_2;
				end
				else begin
					DR_winner <= DR_3;
					RGB_winner <= RGB_3;
				
				end
        end
    end
	 

endmodule


