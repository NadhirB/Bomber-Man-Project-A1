// System-Verilog 'written by Alex Grinshpun May 2018
// New bitmap dudy February 2025
// (c) Technion IIT, Department of Electrical Engineering 2025 



module	FancyDigitsBitMap	(	
					input	logic	clk,
					input	logic	resetN,
					input logic	[10:0] offsetX,// offset from top left  position 
					input logic	[10:0] offsetY,
					input	logic	InsideRectangle, //input that the pixel is within a bracket
					input logic [3:0] digits,

					output	logic	drawingRequest, //output that the pixel should be dispalyed 
					output	logic	[7:0] RGBout  //rgb value from the bitmap 
 ) ;

// this is the devider used to acess the right pixel 
localparam  int OBJECT_NUMBER_OF_Y_BITS =15;  
localparam  int OBJECT_NUMBER_OF_X_BITS =15; 	 

// generating a smiley bitmap

localparam logic [7:0] TRANSPARENT_ENCODING = 8'hff;// RGB value in the bitmap representing a transparent pixel 

logic [0:9] [0:OBJECT_NUMBER_OF_Y_BITS] [0:OBJECT_NUMBER_OF_X_BITS] [7:0] object_colors = {
	{{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff},
	{8'hff,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'he4,8'he4,8'he4,8'he4,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'h00,8'h00,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff,8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff,8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff,8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'h00,8'h00,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'he4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'he4,8'h00,8'hff},
	{8'hff,8'h00,8'h00,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'h00,8'h00,8'hff},
	{8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff}},
		
	{{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'h00,8'hff,8'hff,8'hff,8'hff,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'h00,8'he4,8'he4,8'he4,8'he4,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff}},
	
	{{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff},
	{8'hff,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'h00,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'h00,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'he4,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'h00,8'hff,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'h00,8'hff},
	{8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff}},
	
	{{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff},
	{8'hff,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'h00,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'he4,8'h00,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'h00,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'he4,8'he4,8'he4,8'he4,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'he4,8'h00,8'hff},
	{8'hff,8'h00,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'h00,8'h00,8'hff},
	{8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff}},
	
	{{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff},
	{8'hff,8'h00,8'hff,8'hff,8'hff,8'hff,8'h00,8'hff,8'hff,8'h00,8'hff,8'hff,8'hff,8'hff,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff,8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff,8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'h00,8'h00,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'h00,8'he4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'h00,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'he4,8'he4,8'he4,8'he4,8'h00,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff}},
	
	{{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff},
	{8'hff,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'h00,8'hff},
	{8'hff,8'h00,8'he4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'h00,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'he4,8'h00,8'hff},
	{8'hff,8'h00,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'h00,8'h00,8'hff},
	{8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff}},
	
	{{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff},
	{8'hff,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'he4,8'he4,8'he4,8'he4,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'h00,8'h00,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'he4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'he4,8'h00,8'hff},
	{8'hff,8'h00,8'h00,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'h00,8'h00,8'hff},
	{8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff}},
	
	{{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff},
	{8'hff,8'hff,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hff},
	{8'hff,8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'hff,8'h00,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'he4,8'h00,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'he4,8'h00,8'h00,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'he4,8'h00,8'h00,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'h00,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'he4,8'h00,8'h00,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'h00,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'he4,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'he4,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'he4,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'h00,8'he4,8'he4,8'he4,8'he4,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff}},
	
	{{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff},
	{8'hff,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'he4,8'he4,8'he4,8'he4,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'h00,8'h00,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'h00,8'he4,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'he4,8'h00,8'hff},
	{8'hff,8'h00,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'he4,8'he4,8'he4,8'he4,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'h00,8'h00,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'he4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'he4,8'h00,8'hff},
	{8'hff,8'h00,8'h00,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'h00,8'h00,8'hff},
	{8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff}},
	
	{{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff},
	{8'hff,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'he4,8'he4,8'he4,8'he4,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'h00,8'h00,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'h00,8'he4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'h00,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'he4,8'he4,8'he4,8'he4,8'h00,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff}}
	
	
	};
 
 
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
			case (digits)
					 4'b0000 : RGBout <= object_colors[0][offsetY][offsetX];
					 4'b0001 : RGBout <= object_colors[1][offsetY][offsetX]; 
					 4'b0010 : RGBout <= object_colors[2][offsetY][offsetX];
					 4'b0011 : RGBout <= object_colors[3][offsetY][offsetX];
					 4'b0100 : RGBout <= object_colors[4][offsetY][offsetX];
					 4'b0101 : RGBout <= object_colors[5][offsetY][offsetX];
					 4'b0110 : RGBout <= object_colors[6][offsetY][offsetX];
					 4'b0111 : RGBout <= object_colors[7][offsetY][offsetX]; 
					 4'b1000 : RGBout <= object_colors[8][offsetY][offsetX];
					 4'b1001 : RGBout <= object_colors[9][offsetY][offsetX];
				default:  RGBout <= TRANSPARENT_ENCODING ; 
				endcase
			
		
		end  	
	end
		
end

//////////--------------------------------------------------------------------------------------------------------------=
// decide if to draw the pixel or not 
assign drawingRequest = (RGBout != TRANSPARENT_ENCODING ) ? 1'b1 : 1'b0 ; // get optional transparent command from the bitmpap   

endmodule