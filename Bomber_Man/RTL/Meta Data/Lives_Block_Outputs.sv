// System-Verilog 'written by Alex Grinshpun May 2018
// New bitmap dudy February 2025
// (c) Technion IIT, Department of Electrical Engineering 2025 



module	HeartBlockOutputs	(	
					input	logic	clk,
					input	logic	resetN,
					input logic heart1DR,
					input logic [7:0] heart1RGB,
					input logic heart2DR,
					input logic [7:0] heart2RGB,
					input logic heart3DR,
					input logic [7:0] heart3RGB,
					
					output	logic	drawingRequest, //output that the pixel should be dispalyed 
					output	logic	[7:0] RGBout  //rgb value from the bitmap 
 ) ;
 
 localparam logic [7:0] TRANSPARENT_ENCODING = 8'hff;// RGB value in the bitmap representing a transparent pixel 

 
 assign drawingRequest = heart1DR || heart2DR || heart3DR;
// pipeline (ff) to get the pixel color from the array 	 

//////////--------------------------------------------------------------------------------------------------------------=
always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		RGBout <=	8'h00;
	end

	else begin
		if (heart1DR)
			RGBout <= heart1RGB;
		else if (heart2DR)
			RGBout <= heart2RGB;
		else if (heart3DR)
			RGBout <= heart3RGB;
		else
			RGBout <= TRANSPARENT_ENCODING;
	end
		
end

endmodule