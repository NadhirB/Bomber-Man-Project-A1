

module RGB_mux (	
	
	input	logic	clk,
	input	logic	resetN,
	
	input	logic	[7:0] RGB_object_mux, 
	input logic [7:0] RGB_game_sm,
	input logic game_on,
	output logic [7:0] RGBOut

);

always_comb
begin
	if(!resetN) begin
			RGBOut = 8'b0;
	end
	
	else begin
		//Chooses between game screens and the Game board
		if (game_on)
			RGBOut = RGB_object_mux;
		else 
			RGBOut = RGB_game_sm;
	end
end
	

endmodule


