// System-Verilog 'written by Alex Grinshpun May 2018
// New bitmap dudy February 2025
// (c) Technion IIT, Department of Electrical Engineering 2025 



module	FancyLettersBitMap	(	
					input	logic	clk,
					input	logic	resetN,
					input logic	[10:0] offsetX,// offset from top left  position 
					input logic	[10:0] offsetY,
					input	logic	InsideRectangle, //input that the pixel is within a bracket

					output	logic	drawingRequest, //output that the pixel should be dispalyed 
					output	logic	[7:0] RGBout  //rgb value from the bitmap 
 ) ;

 
 parameter int letter = 0;
 
// this is the devider used to acess the right pixel 
localparam  int OBJECT_NUMBER_OF_Y_BITS =15;  
localparam  int OBJECT_NUMBER_OF_X_BITS =15; 	 

// generating a smiley bitmap

localparam logic [7:0] TRANSPARENT_ENCODING = 8'hff;// RGB value in the bitmap representing a transparent pixel 

logic [0:9] [0:OBJECT_NUMBER_OF_Y_BITS] [0:OBJECT_NUMBER_OF_X_BITS] [7:0] object_colors1 = {
	{	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff},
	{8'hff,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'he4,8'he4,8'he4,8'he4,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'h00,8'h00,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'he4,8'he4,8'he4,8'he4,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'h00,8'h00,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff,8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff,8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'he4,8'he4,8'he4,8'he4,8'h00,8'hff,8'hff,8'h00,8'he4,8'he4,8'he4,8'he4,8'h00,8'hff},
	{8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff}},
		
	{{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff},
	{8'hff,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'he4,8'he4,8'he4,8'he4,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'h00,8'h00,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'he4,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'he4,8'he4,8'he4,8'he4,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'h00,8'h00,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'he4,8'h00,8'hff},
	{8'hff,8'h00,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'h00,8'h00,8'hff},
	{8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff}},
	
	{{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff},
	{8'hff,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'he4,8'he4,8'he4,8'he4,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'h00,8'h00,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff,8'hff,8'h00,8'he4,8'he4,8'he4,8'he4,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff,8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'h00,8'h00,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'he4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'he4,8'h00,8'hff},
	{8'hff,8'h00,8'h00,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'h00,8'h00,8'hff},
	{8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff}},
	
	{{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff},
	{8'hff,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'hff,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'he4,8'he4,8'he4,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'h00,8'h00,8'he4,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff,8'h00,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff,8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff,8'h00,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'h00,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'he4,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'he4,8'h00,8'h00,8'hff},
	{8'hff,8'h00,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'h00,8'h00,8'hff,8'hff},
	{8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff}},
	
	{{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff},
	{8'hff,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'he4,8'he4,8'he4,8'he4,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'he4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'h00,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'h00,8'hff},
	{8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff}},
	
	{{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff},
	{8'hff,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'he4,8'he4,8'he4,8'he4,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'h00,8'he4,8'he4,8'he4,8'he4,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff}},
	
	{{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff},
	{8'hff,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'he4,8'he4,8'he4,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'h00,8'h00,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'he4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'he4,8'h00,8'hff},
	{8'hff,8'h00,8'h00,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'h00,8'h00,8'hff},
	{8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff}},
	
	{{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff},
	{8'hff,8'h00,8'hff,8'hff,8'hff,8'hff,8'h00,8'hff,8'hff,8'h00,8'hff,8'hff,8'hff,8'hff,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff,8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff,8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'h00,8'h00,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'he4,8'he4,8'he4,8'he4,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'h00,8'h00,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff,8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff,8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'he4,8'he4,8'he4,8'he4,8'h00,8'hff,8'hff,8'h00,8'he4,8'he4,8'he4,8'he4,8'h00,8'hff},
	{8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff}},
	
	{{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff},
	{8'hff,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'h00,8'he4,8'he4,8'he4,8'he4,8'hfc,8'hfc,8'hfc,8'hfc,8'he4,8'he4,8'he4,8'he4,8'h00,8'hff},
	{8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'h00,8'hff},
	{8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff}},
	
	{{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hff,8'hff,8'hff,8'hff,8'h00,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff,8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'h00,8'h00,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'he4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'he4,8'h00,8'hff},
	{8'hff,8'h00,8'h00,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'h00,8'h00,8'hff},
	{8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff}}};
	

logic [0:9] [0:OBJECT_NUMBER_OF_Y_BITS] [0:OBJECT_NUMBER_OF_X_BITS] [7:0] object_colors2 = {	
	
	{{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'hff,8'h00,8'hff,8'hff,8'hff,8'hff,8'h00,8'hff,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'he4,8'h00},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'he4,8'h00,8'h00},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'he4,8'h00,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'h00,8'hff,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'h00,8'hff,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'he4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'h00},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'he4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'h00},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'h00,8'he4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'h00},
	{8'hff,8'h00,8'he4,8'he4,8'he4,8'he4,8'h00,8'hff,8'h00,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'h00},
	{8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
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
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'h00,8'hff},
	{8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff}},
	
	{{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'hff,8'h00,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'hff,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'h00},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'h00,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'he4,8'hf4,8'hf4,8'hf4,8'he4,8'hf4,8'hf4,8'hf4,8'hf4,8'h00},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'he4,8'hf4,8'he4,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'h00,8'he4,8'h00,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff,8'h00,8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff,8'hff,8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00},
	{8'hff,8'h00,8'he4,8'he4,8'he4,8'he4,8'h00,8'hff,8'hff,8'hff,8'h00,8'he4,8'he4,8'he4,8'he4,8'h00},
	{8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff}},
	
	{{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff},
	{8'hff,8'h00,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'hff,8'h00,8'hff,8'hff,8'hff,8'hff,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'h00,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'he4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'he4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'h00,8'he4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'h00,8'h00,8'he4,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff,8'h00,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'he4,8'he4,8'he4,8'he4,8'h00,8'hff,8'hff,8'h00,8'he4,8'he4,8'he4,8'he4,8'h00,8'hff},
	{8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff}},
	
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
	{8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff},
	{8'hff,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'he4,8'he4,8'he4,8'he4,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'h00,8'h00,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'he4,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'h00,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'h00,8'he4,8'he4,8'he4,8'he4,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff}},
	
	{{8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff},
	{8'hff,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'he4,8'he4,8'he4,8'he4,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'h00,8'h00,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff,8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff,8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff,8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff,8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'h00,8'h00,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'he4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'he4,8'h00,8'hff},
	{8'hff,8'h00,8'h00,8'he4,8'he4,8'he4,8'hf4,8'hf4,8'hf4,8'hf4,8'he4,8'he4,8'he4,8'h00,8'h00,8'hff},
	{8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'he4,8'he4,8'he4,8'he4,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff}},
	
	{{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff},
	{8'hff,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'he4,8'he4,8'he4,8'he4,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'h00,8'h00,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'he4,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'he4,8'he4,8'he4,8'he4,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'h00,8'h00,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff,8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff,8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'he4,8'he4,8'he4,8'he4,8'h00,8'hff,8'hff,8'h00,8'he4,8'he4,8'he4,8'he4,8'h00,8'hff},
	{8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff}},
	
	{{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff},
	{8'hff,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hff},
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
	{8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff},
	{8'hff,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'h00,8'he4,8'he4,8'he4,8'he4,8'hfc,8'hfc,8'hfc,8'hfc,8'he4,8'he4,8'he4,8'he4,8'h00,8'hff},
	{8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'he4,8'he4,8'he4,8'he4,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff}}};
	
	
logic [0:9] [0:OBJECT_NUMBER_OF_Y_BITS] [0:OBJECT_NUMBER_OF_X_BITS] [7:0] object_colors3 = {
	
	{{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff},
	{8'hff,8'h00,8'hff,8'hff,8'hff,8'hff,8'h00,8'hff,8'hff,8'h00,8'hff,8'hff,8'hff,8'hff,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff,8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff,8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff,8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
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
	{8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff},
	{8'hff,8'h00,8'hff,8'hff,8'hff,8'hff,8'h00,8'hff,8'hff,8'h00,8'hff,8'hff,8'hff,8'hff,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff,8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff,8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff,8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'he4,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'he4,8'h00,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'he4,8'h00,8'h00,8'hff,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'he4,8'h00,8'h00,8'hff,8'hff,8'hff},
	{8'hff,8'h00,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff}},
	
	{{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'hff,8'h00,8'hff,8'hff,8'hff,8'hff,8'h00,8'hff,8'hff,8'hff,8'h00,8'hff,8'hff,8'hff,8'hff,8'h00},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff,8'hff,8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'h00,8'h00,8'h00,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'h00,8'hfc,8'h00,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hfc,8'hfc,8'hfc,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'h00},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'h00},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'he4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'h00},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'he4,8'h00,8'he4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'h00},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'he4,8'h00,8'h00,8'h00,8'he4,8'hf4,8'hf4,8'hf4,8'hf4,8'h00},
	{8'hff,8'h00,8'he4,8'he4,8'he4,8'he4,8'h00,8'h00,8'hff,8'h00,8'h00,8'he4,8'he4,8'he4,8'he4,8'h00},
	{8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff}},
	
	{{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff},
	{8'hff,8'h00,8'hff,8'hff,8'hff,8'h00,8'h00,8'hff,8'hff,8'h00,8'h00,8'hff,8'hff,8'hff,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'h00,8'h00,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'h00,8'he4,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'he4,8'h00,8'hff},
	{8'hff,8'h91,8'h00,8'he4,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'he4,8'h00,8'h91,8'hff},
	{8'hff,8'hff,8'h00,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'h00,8'hff,8'hff},
	{8'hff,8'h00,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'he4,8'he4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'he4,8'h00,8'h00,8'he4,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'he4,8'h00,8'h00,8'h00,8'h00,8'he4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'he4,8'he4,8'he4,8'h00,8'h00,8'hff,8'hff,8'h00,8'h00,8'he4,8'he4,8'he4,8'h00,8'hff},
	{8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff}},
	
	{{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff},
	{8'hff,8'h00,8'hff,8'hff,8'hff,8'hff,8'h00,8'hff,8'hff,8'h00,8'hff,8'hff,8'hff,8'hff,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff,8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'h00,8'h00,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'h00,8'he4,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'he4,8'h00,8'hff},
	{8'hff,8'h00,8'h00,8'he4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'he4,8'h00,8'h00,8'hff},
	{8'hff,8'hff,8'h00,8'h00,8'he4,8'he4,8'hf4,8'hf4,8'hf4,8'hf4,8'he4,8'he4,8'h00,8'h00,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'he4,8'he4,8'he4,8'he4,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff}},
	
	{{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff},
	{8'hff,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'h00,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'he4,8'h00,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'he4,8'h00,8'h00,8'hff},
	{8'hff,8'hff,8'hff,8'h00,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'he4,8'h00,8'h00,8'hff,8'hff},
	{8'hff,8'hff,8'h00,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'he4,8'h00,8'h00,8'hff,8'hff,8'hff},
	{8'hff,8'h00,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'he4,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'h00,8'hff},
	{8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff}},
	
	{{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},	// !
	{8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'h00,8'hff,8'hff,8'hff,8'hff,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'h00,8'he4,8'he4,8'he4,8'he4,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'h00,8'he4,8'he4,8'he4,8'he4,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff}},
	
	{{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff},
	{8'hff,8'h00,8'hff,8'hff,8'hff,8'hff,8'h00,8'hff,8'hff,8'h00,8'hff,8'hff,8'hff,8'hff,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff,8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff,8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'h00,8'h00,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'he4,8'he4,8'he4,8'he4,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'h00,8'h00,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff,8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff,8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'he4,8'he4,8'he4,8'he4,8'h00,8'hff,8'hff,8'h00,8'he4,8'he4,8'he4,8'he4,8'h00,8'hff},
	{8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff}},
	
	{{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff},
	{8'hff,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hff,8'hff},
	{8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff,8'hff},
	{8'hff,8'h00,8'he4,8'he4,8'he4,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'he4,8'he4,8'he4,8'h00,8'hff,8'hff},
	{8'hff,8'h00,8'h00,8'h00,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'h00,8'h00,8'h00,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff,8'hff},
	{8'hff,8'h00,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'h00,8'hff,8'hff},
	{8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff}},
	
	{{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},	// J
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hff,8'hff,8'hff,8'hff,8'h00,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hff},
	{8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff,8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'h00,8'h00,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'hff},
	{8'hff,8'h00,8'he4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'he4,8'h00,8'hff},
	{8'hff,8'h00,8'h00,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'h00,8'h00,8'hff},
	{8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff}},
	
	
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
				case (letter)
					 32'd0 : RGBout <= object_colors1[0][offsetY][offsetX];
					 32'd1 : RGBout <= object_colors1[1][offsetY][offsetX]; 
					 32'd2 : RGBout <= object_colors1[2][offsetY][offsetX];
					 32'd3 : RGBout <= object_colors1[3][offsetY][offsetX];
					 32'd4 : RGBout <= object_colors1[4][offsetY][offsetX];
					 32'd5 : RGBout <= object_colors1[5][offsetY][offsetX];
					 32'd6 : RGBout <= object_colors1[6][offsetY][offsetX];
					 32'd7 : RGBout <= object_colors1[7][offsetY][offsetX]; 
					 32'd8 : RGBout <= object_colors1[8][offsetY][offsetX];
					 32'd9 : RGBout <= object_colors1[9][offsetY][offsetX];
					 32'd10 : RGBout <= object_colors2[0][offsetY][offsetX];
					 32'd11 : RGBout <= object_colors2[1][offsetY][offsetX]; 
					 32'd12 : RGBout <= object_colors2[2][offsetY][offsetX];
					 32'd13 : RGBout <= object_colors2[3][offsetY][offsetX];
					 32'd14 : RGBout <= object_colors2[4][offsetY][offsetX];
					 32'd15 : RGBout <= object_colors2[5][offsetY][offsetX];
					 32'd16 : RGBout <= object_colors2[6][offsetY][offsetX];
					 32'd17 : RGBout <= object_colors2[7][offsetY][offsetX]; 
					 32'd18 : RGBout <= object_colors2[8][offsetY][offsetX];
					 32'd19 : RGBout <= object_colors2[9][offsetY][offsetX];
					 32'd20 : RGBout <= object_colors3[0][offsetY][offsetX];
					 32'd21 : RGBout <= object_colors3[1][offsetY][offsetX]; 
					 32'd22 : RGBout <= object_colors3[2][offsetY][offsetX];
					 32'd23 : RGBout <= object_colors3[3][offsetY][offsetX];
					 32'd24 : RGBout <= object_colors3[4][offsetY][offsetX];
					 32'd25 : RGBout <= object_colors3[5][offsetY][offsetX];
					 32'd26 : RGBout <= object_colors3[6][offsetY][offsetX];
				default:  RGBout <= TRANSPARENT_ENCODING ; 
				endcase	
		end  	
	end
		
end

//////////--------------------------------------------------------------------------------------------------------------=
// decide if to draw the pixel or not 
assign drawingRequest = (RGBout != TRANSPARENT_ENCODING ) ? 1'b1 : 1'b0 ; // get optional transparent command from the bitmpap   

endmodule