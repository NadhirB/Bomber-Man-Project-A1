// System-Verilog 'written by Alex Grinshpun May 2018
// New bitmap dudy February 2025
// (c) Technion IIT, Department of Electrical Engineering 2025 



module	bombBitMap	(	
					input	logic	clk,
					input	logic	resetN,
					input logic	[10:0] offsetX,// offset from top left  position 
					input logic	[10:0] offsetY,
					input	logic	InsideRectangle, //input that the pixel is within a bracket 

					output	logic	drawingRequest, //output that the pixel should be dispalyed 
					output	logic	[7:0] RGBout  //rgb value from the bitmap 
 ) ;

// this is the devider used to acess the right pixel 
localparam  int OBJECT_NUMBER_OF_Y_BITS = 5;  // 2^5 = 32 
localparam  int OBJECT_NUMBER_OF_X_BITS = 5;  // 2^6 = 64 



// generating a smiley bitmap

localparam logic [7:0] TRANSPARENT_ENCODING = 8'hff;// RGB value in the bitmap representing a transparent pixel 

logic [0:31] [0:31] [7:0] object_colors = {
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'he0,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'he4,8'he4,8'he4,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'he4,8'hf0,8'he4,8'hed,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'he4,8'hf8,8'hf8,8'hf4,8'hf0,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'he4,8'hf0,8'hfd,8'hfd,8'hf0,8'he4,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hd1,8'hd1,8'hf8,8'he4,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'h00,8'hd1,8'h8c,8'h00,8'he0,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'h00,8'h8c,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'h8c,8'h8c,8'hda,8'hff,8'hff,8'hff,8'h00,8'hed,8'he4,8'he4,8'hed,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'h00,8'hac,8'h00,8'hed,8'hed,8'h00,8'he4,8'hc4,8'hc4,8'hed,8'hc4,8'hc4,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hd5,8'h8c,8'h00,8'hed,8'hed,8'hed,8'hed,8'hc4,8'he4,8'he4,8'hc4,8'hc4,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hed,8'hc4,8'hb1,8'h8c,8'h00,8'h00,8'hed,8'hf1,8'h00,8'hc4,8'he4,8'he4,8'hc4,8'hc4,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'h00,8'h20,8'hc4,8'h00,8'hd1,8'h00,8'he4,8'hf1,8'hc4,8'h00,8'hc4,8'he4,8'he4,8'hc4,8'hc4,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'h00,8'h00,8'he4,8'hed,8'h00,8'hed,8'h00,8'he4,8'hf1,8'hc4,8'hc4,8'hc4,8'h00,8'hc4,8'he4,8'he4,8'he4,8'hc4,8'h00,8'h00,8'h24,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'h00,8'hed,8'hc4,8'hc4,8'hf1,8'hf1,8'he4,8'hf1,8'hc4,8'he4,8'he4,8'he4,8'hc4,8'hc4,8'h00,8'hc4,8'he4,8'he4,8'he4,8'h64,8'hac,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'h00,8'hf1,8'he4,8'hc4,8'hc4,8'hc4,8'h00,8'he4,8'hf1,8'hf1,8'he4,8'he4,8'he4,8'he4,8'hc4,8'hc4,8'h00,8'hc4,8'hc0,8'h00,8'hac,8'h64,8'h8c,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'h00,8'hc4,8'hc4,8'he4,8'he4,8'hc4,8'h00,8'he4,8'hf1,8'hf1,8'he4,8'he4,8'he4,8'he4,8'hc4,8'hc4,8'h00,8'h20,8'h84,8'h00,8'h84,8'hac,8'h80,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'h00,8'he4,8'hf1,8'hed,8'he4,8'hc4,8'h00,8'he4,8'hed,8'hf1,8'hed,8'he4,8'he4,8'he4,8'hc4,8'h00,8'hac,8'h00,8'h84,8'hac,8'hc0,8'hc0,8'hc4,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'h00,8'he4,8'hed,8'hf1,8'he4,8'hc4,8'h00,8'he4,8'he4,8'hf1,8'hf1,8'he4,8'h00,8'h8c,8'hd1,8'h20,8'h84,8'hb0,8'h00,8'he4,8'he4,8'hc4,8'hc4,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'h00,8'he4,8'he4,8'hf1,8'he4,8'hc4,8'h00,8'he4,8'he4,8'hf1,8'h00,8'hd1,8'h8c,8'h00,8'hd1,8'h84,8'h00,8'h00,8'hc4,8'he4,8'he4,8'hc4,8'hc4,8'h00,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hc0,8'he4,8'hf1,8'he4,8'hc4,8'h00,8'h00,8'hd1,8'h8c,8'h00,8'hd1,8'h8c,8'h00,8'he4,8'hc4,8'hc4,8'h00,8'hc4,8'he4,8'he4,8'hc4,8'hc4,8'h00,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'hd1,8'hd1,8'h8c,8'h00,8'h8c,8'h8c,8'h00,8'he4,8'he4,8'he4,8'hc4,8'hc4,8'h00,8'hc4,8'he4,8'he4,8'he4,8'hc4,8'h00,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hd1,8'h8c,8'hd1,8'h8c,8'h00,8'hd1,8'h8c,8'hb0,8'h00,8'hf1,8'hf1,8'he4,8'he4,8'he4,8'he4,8'hc4,8'hc4,8'h00,8'hc4,8'he4,8'he4,8'he4,8'hc4,8'h00,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'hd1,8'hb0,8'h8c,8'h00,8'h00,8'hc4,8'h00,8'he4,8'hf1,8'hf1,8'he4,8'he4,8'he4,8'he4,8'hc4,8'hc4,8'h00,8'hc4,8'he4,8'he4,8'he4,8'hc4,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'he4,8'hf1,8'he4,8'he4,8'hc4,8'h00,8'he4,8'hf1,8'hf1,8'he4,8'he4,8'he4,8'he4,8'hc4,8'hc4,8'h00,8'hc4,8'hc4,8'hc4,8'h00,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'he4,8'hf1,8'hed,8'he4,8'hc4,8'h00,8'he4,8'hf1,8'hf1,8'he4,8'he4,8'he4,8'he4,8'hc4,8'hc4,8'h00,8'h00,8'h24,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'he4,8'hf1,8'hf1,8'he4,8'hc4,8'h00,8'he4,8'hed,8'hf1,8'hed,8'he4,8'he4,8'he4,8'hc4,8'hc4,8'ha0,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'he4,8'he4,8'hf1,8'he4,8'hc4,8'h00,8'he4,8'he4,8'hf1,8'hf1,8'he4,8'he4,8'he4,8'hc4,8'h00,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'he4,8'he4,8'hf1,8'he4,8'hc4,8'h80,8'h60,8'he4,8'hf1,8'hf1,8'he4,8'h60,8'h00,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h20,8'he4,8'hf1,8'he4,8'hc4,8'hc4,8'h00,8'he4,8'he4,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h24,8'h00,8'he4,8'hed,8'h00,8'h00,8'hff,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff}};


//////////--------------------------------------------------------------------------------------------------------------=

 
 
// pipeline (ff) to get the pixel color from the array 	 

//////////--------------------------------------------------------------------------------------------------------------=
always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		RGBout <=	8'h00;

	end

	else begin
		RGBout <= TRANSPARENT_ENCODING ; // default  

		if (InsideRectangle == 1'b1 ) 
		begin // inside an external bracket 
			RGBout <= object_colors[offsetY][offsetX];
			
		end  	
	end
		
end

//////////--------------------------------------------------------------------------------------------------------------=
// decide if to draw the pixel or not 
assign drawingRequest = (RGBout != TRANSPARENT_ENCODING ) ? 1'b1 : 1'b0 ; // get optional transparent command from the bitmpap   

endmodule