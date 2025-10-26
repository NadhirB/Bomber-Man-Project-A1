
// Simple filter module to filter certain metadata features that are unnecessary in 2-Player mode

module TwoPlayerMetaDataFilter (	
	
	input	logic	resetN,
	input logic drawingRequestIn,
	input	logic	[7:0] RGBIn, 
	input logic enable,
	
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
		if (enable) begin
			RGBOut = RGBIn;
			drawingRequestOut = drawingRequestIn;
		end
		else begin
			RGBOut = 8'b0;
			drawingRequestOut = 1'b0;
		end
	end
end
	

endmodule


