
// This is a general module used as a mux to convert multiple letter sequences, drawing requests and RGB inputs in a single output,
// used in higher hierarchy



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
					input logic DR_7,
					input logic [7:0] RGB_7,
					input logic DR_8,
					input logic [7:0] RGB_8,
					
					
					output	logic	drawingRequest, //output that the pixel should be dispalyed 
					output	logic	[7:0] RGBout  //rgb value from the bitmap 
 ) ;
 
 
 assign drawingRequest = DR_1 || DR_2 || DR_3 || DR_4 || DR_5 || DR_6 || DR_7 || DR_8;
// pipeline (ff) to get the pixel color from the array 	 

//////////--------------------------------------------------------------------------------------------------------------=
always_comb
begin
	if(!resetN) begin
		RGBout =	8'h00;
	end

	else begin
		if (DR_1)
			RGBout = RGB_1;
		else if (DR_2)
			RGBout = RGB_2;
		else if (DR_3)
			RGBout = RGB_3;
		else if (DR_4)
			RGBout = RGB_4;
		else if (DR_5)
			RGBout = RGB_5;
		else if (DR_6)
			RGBout = RGB_6;
		else if (DR_7)
			RGBout = RGB_7;
		else if (DR_8)
			RGBout = RGB_8;
		else
			RGBout = 8'h00;
	end
		
end

endmodule