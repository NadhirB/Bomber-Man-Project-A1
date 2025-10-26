
// This module is a filter module that takes the drawing request from the controls screen of the 1-Player mode and 2-Player mode and selects the
// correct outputs based on the mode_sel input

module TwoPlayerControlsFilter (	
	
	input	logic	resetN,
	input logic drawingRequestIn_1,
	input	logic	[7:0] RGBIn_1,
	input logic drawingRequestIn_2,
	input	logic	[7:0] RGBIn_2, 
	input logic mode_sel,
	
	output logic drawingRequestOut,
	output logic [7:0] RGBOut


);

always_comb
begin
	if(!resetN) begin
			RGBOut = 8'b0;
			drawingRequestOut = 1'b0;
	end
	
	else begin
		if (mode_sel) begin
			RGBOut = RGBIn_2;
			drawingRequestOut = drawingRequestIn_2;
		end
		else begin
			RGBOut = RGBIn_1;
			drawingRequestOut = drawingRequestIn_1;
		end
	end
end
	

endmodule


