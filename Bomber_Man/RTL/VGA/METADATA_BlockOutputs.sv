// System-Verilog 'written by Alex Grinshpun May 2018
// New bitmap dudy February 2025
// (c) Technion IIT, Department of Electrical Engineering 2025 



module	METADATA_BlockOutputs	(	
					input	logic	clk,
					input	logic	resetN,
					input logic DR_1,
					input logic [7:0] RGB_1,
					input logic DR_2,
					input logic [7:0] RGB_2,
					input logic DR_3,
					input logic [7:0] RGB_3,
					input logic DR_4,
					input logic [7:0] RGB_4,
					input logic DR_5,
					input logic [7:0] RGB_5,
					input logic DR_6,
					input logic [7:0] RGB_6,
					
					output	logic	drawingRequest, //output that the pixel should be dispalyed 
					output	logic	[7:0] RGBout  //rgb value from the bitmap 
 ) ;
 
 localparam logic [7:0] TRANSPARENT_ENCODING = 8'hff;// RGB value in the bitmap representing a transparent pixel 

 
 assign drawingRequest = DR_1 || DR_2 || DR_3 || DR_4 || DR_5|| DR_6;
// pipeline (ff) to get the pixel color from the array 	 

//////////--------------------------------------------------------------------------------------------------------------=
always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		RGBout <=	8'h00;
	end

	else begin
		if (DR_1)
			RGBout <= RGB_1;
		else if (DR_2)
			RGBout <= RGB_2;
		else if (DR_3)
			RGBout <= RGB_3;
		else if (DR_4)
			RGBout <= RGB_4;
		else if (DR_5)
			RGBout <= RGB_5;
		else if (DR_6)
			RGBout <= RGB_6;
		else
			RGBout <= TRANSPARENT_ENCODING;
	end
		
end

endmodule