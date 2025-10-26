
// This module has the heart bitmap 32x32

module	LivesBitMap	(	
					input	logic	clk,
					input	logic	resetN,
					input logic	[10:0] offsetX,// o00set from top left  position 
					input logic	[10:0] offsetY,
					input	logic	InsideRectangle, //input that the pixel is within a bracket

					output logic drawingRequest, //output that the pixel should be dispalyed 
					output logic [7:0] RGBout  //rgb value from the bitmap 
 ) ;
 

localparam logic [7:0] TRANSPARENT_ENCODING = 8'hf0 ;// RGB value in the bitmap representing a transparent pixel 


localparam  int TILE_NUMBER_OF_X_BITS = 5;  // 2^5 = 32  every object 
localparam  int TILE_NUMBER_OF_Y_BITS = 5;  // 2^5 = 32 


localparam  int TILE_WIDTH_X = 1 << TILE_NUMBER_OF_X_BITS ;
localparam  int TILE_HEIGHT_Y = 1 <<  TILE_NUMBER_OF_Y_BITS ;


 logic [10:0] offsetX_LSB  ;
 logic [10:0] offsetY_LSB  ; 

 assign offsetX_LSB  = offsetX[(TILE_NUMBER_OF_X_BITS-1):0] ; // get lower bits 
 assign offsetY_LSB  = offsetY[(TILE_NUMBER_OF_Y_BITS-1):0] ; // get lower bits 



 

 logic [0:(TILE_HEIGHT_Y-1)][0:(TILE_WIDTH_X-1)] [7:0]  object_colors  = {
	{8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0},
	{8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0},
	{8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0},
	{8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0},
	{8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0},
	{8'hf0,8'hf0,8'hf0,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hf0,8'hf0,8'hf0},
	{8'hf0,8'hf0,8'hf0,8'h00,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'h00,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'h00,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'h00,8'hf0,8'hf0,8'hf0},
	{8'hf0,8'h00,8'h00,8'h00,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'h00,8'h00,8'h00,8'hf0,8'hf0,8'h00,8'h00,8'h00,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'h00,8'h00,8'h00,8'hf0},
	{8'hf0,8'h00,8'he0,8'he0,8'hff,8'hff,8'hff,8'hff,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'h00,8'hf0,8'hf0,8'h00,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'h00,8'hf0},
	{8'hf0,8'h00,8'he0,8'he0,8'hff,8'hff,8'hff,8'hff,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'h00,8'h00,8'h00,8'h00,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'h00,8'hf0},
	{8'hf0,8'h00,8'he0,8'he0,8'hff,8'hff,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'h00,8'hf0},
	{8'hf0,8'h00,8'he0,8'he0,8'hff,8'hff,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'h00,8'hf0},
	{8'hf0,8'h00,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'h00,8'hf0},
	{8'hf0,8'h00,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'h00,8'hf0},
	{8'hf0,8'h00,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'h00,8'hf0},
	{8'hf0,8'h00,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'h00,8'hf0},
	{8'hf0,8'h00,8'h00,8'h00,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'h00,8'h00,8'h00,8'hf0},
	{8'hf0,8'hf0,8'hf0,8'h00,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'h00,8'hf0,8'hf0,8'hf0},
	{8'hf0,8'hf0,8'hf0,8'h00,8'h00,8'h00,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'h00,8'h00,8'h00,8'hf0,8'hf0,8'hf0},
	{8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'h00,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'h00,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0},
	{8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'h00,8'h00,8'h00,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'h00,8'h00,8'h00,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0},
	{8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'h00,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'h00,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0},
	{8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'h00,8'h00,8'h00,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'h00,8'h00,8'h00,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0},
	{8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'h00,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'h00,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0},
	{8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'h00,8'h00,8'h00,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'h00,8'h00,8'h00,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0},
	{8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'h00,8'ha0,8'ha0,8'he0,8'he0,8'he0,8'he0,8'ha0,8'ha0,8'h00,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0},
	{8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'h00,8'h00,8'h00,8'he0,8'he0,8'he0,8'he0,8'h00,8'h00,8'h00,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0},
	{8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'h00,8'h80,8'h80,8'h80,8'h80,8'h00,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0},
	{8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0},
	{8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0},
	{8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0},
	{8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0}};
 
//
// pipeline (00) to get the pixel color from the array 	 

//==----------------------------------------------------------------------------------------------------------------=
always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		RGBout <=	8'h00;
	end
	else begin
							
		RGBout <= TRANSPARENT_ENCODING ; // default 
		if (InsideRectangle == 1'b1 )	
			RGBout <= object_colors[offsetY_LSB][offsetX_LSB];
		
		else
			RGBout <= TRANSPARENT_ENCODING ;
		

	end 
end

//==----------------------------------------------------------------------------------------------------------------=
// decide if to draw the pixel or not 
assign drawingRequest = (RGBout != TRANSPARENT_ENCODING ) ? 1'b1 : 1'b0 ; // get optional transparent command from the bitmpap   
endmodule

