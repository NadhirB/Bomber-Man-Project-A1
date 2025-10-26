// System-Verilog 'written by Alex Grinshpun May 2018
// New bitmap dudy February 2025
// (c) Technion IIT, Department of Electrical Engineering 2025 



module	TimerBlockOutputs	(	
					input	logic	clk,
					input	logic	resetN,
					input logic timerOnesDR,
					input logic [7:0] timerOnesRGB,
					input logic timerTensDR,
					input logic [7:0] timerTensRGB,
					input logic letterDR_T,
					input logic [7:0] letterRGB_T,
					input logic letterDR_I,
					input logic [7:0] letterRGB_I,
					input logic letterDR_M,
					input logic [7:0] letterRGB_M,
					input logic letterDR_E,
					input logic [7:0] letterRGB_E,
					
					output	logic	drawingRequest, //output that the pixel should be dispalyed 
					output	logic	[7:0] RGBout  //rgb value from the bitmap 
 ) ;
 
 localparam logic [7:0] TRANSPARENT_ENCODING = 8'hff;// RGB value in the bitmap representing a transparent pixel 

 
 assign drawingRequest = timerOnesDR || timerTensDR || letterDR_E || letterDR_I || letterDR_M|| letterDR_T;
// pipeline (ff) to get the pixel color from the array 	 

//////////--------------------------------------------------------------------------------------------------------------=
always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		RGBout <=	8'h00;
	end

	else begin
		if (timerOnesDR)
			RGBout <= timerOnesRGB;
		else if (timerTensDR)
			RGBout <= timerTensRGB;
		else if (letterDR_E)
			RGBout <= letterRGB_E;
		else if (letterDR_I)
			RGBout <= letterRGB_I;
		else if (letterDR_M)
			RGBout <= letterRGB_M;
		else if (letterDR_T)
			RGBout <= letterRGB_T;
		else
			RGBout <= TRANSPARENT_ENCODING;
	end
		
end

endmodule