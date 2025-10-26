

module	SpikesMatrixBitMap	(	
					input	logic	clk,
					input	logic	resetN,
					input logic	[10:0] offsetX,// offset from top left  position 
					input logic	[10:0] offsetY,
					input	logic	InsideRectangle, //input that the pixel is within a bracket 
					input logic game_on,
					input logic [3:0] layout_sel,

					output	logic	drawingRequest, //output that the pixel should be dispalyed 
					output	logic	[7:0] RGBout    //rgb value from the bitmap
 ) ;
 

parameter int default_layout = 0;

localparam logic [7:0] TRANSPARENT_ENCODING = 8'hff ;// RGB value in the bitmap representing a transparent pixel 


localparam  int TILE_NUMBER_OF_X_BITS = 5;  // 2^5 = 32  every object 
localparam  int TILE_NUMBER_OF_Y_BITS = 5;  // 2^5 = 32 

localparam  int MAZE_NUMBER_OF__X_BITS = 5;  // 2^5 = 32 / /the maze of the objects 
localparam  int MAZE_NUMBER_OF__Y_BITS = 4;  // 2^4 = 16

//-----

localparam  int TILE_WIDTH_X = 1 << TILE_NUMBER_OF_X_BITS ;
localparam  int TILE_HEIGHT_Y = 1 <<  TILE_NUMBER_OF_Y_BITS ;
localparam  int MAZE_WIDTH_X = 1 << MAZE_NUMBER_OF__X_BITS ;
localparam  int MAZE_HEIGHT_Y = 1 << MAZE_NUMBER_OF__Y_BITS ;


 logic [10:0] offsetX_LSB ;
 logic [10:0] offsetY_LSB ; 
 logic [10:0] offsetX_MSB ;
 logic [10:0] offsetY_MSB ;

 assign offsetX_LSB  = offsetX[(TILE_NUMBER_OF_X_BITS-1):0] ; // get lower bits 
 assign offsetY_LSB  = offsetY[(TILE_NUMBER_OF_Y_BITS-1):0] ; // get lower bits 
 assign offsetX_MSB  = offsetX[(TILE_NUMBER_OF_X_BITS + MAZE_NUMBER_OF__X_BITS -1 ):TILE_NUMBER_OF_X_BITS] ; // get higher bits 
 assign offsetY_MSB  = offsetY[(TILE_NUMBER_OF_Y_BITS + MAZE_NUMBER_OF__Y_BITS -1 ):TILE_NUMBER_OF_Y_BITS] ; // get higher bits 



logic [1:0] MazeBitMapMask [0:12] [0:18];


// Five different layouts for sudo randomnes.
logic [1:0] MazeDefaultBitMapMask [0:4] [0:12] [0:18] = 
		'{'{'{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	  '{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, //col
	  '{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	  '{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, //col
	  '{0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	  '{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, //col
	  '{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	  '{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, //col
	  '{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	  '{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, //col
	  '{0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0},
	  '{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, //col
	  '{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}},
	  
		'{'{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		'{0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}},
		
		'{'{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		'{0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}},
		
		'{'{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		'{0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		'{1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}},
		
		
		'{'{0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		'{1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}}
	  
	  };
 


logic [0:TILE_HEIGHT_Y-1] [0:TILE_WIDTH_X-1] [7:0] object_colors = {
	{8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'h00,8'hb6,8'hb6,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hb6,8'hb6,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hb6,8'hb6,8'h00,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'h00,8'hb6,8'hb6,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hb6,8'hb6,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hb6,8'hb6,8'h00,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'h00,8'hb6,8'hb6,8'hb6,8'hb6,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hb6,8'hb6,8'hb6,8'hb6,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hb6,8'hb6,8'hb6,8'hb6,8'h00,8'hff,8'hff},
	{8'hff,8'hff,8'h00,8'hb6,8'hb6,8'hb6,8'hb6,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hb6,8'hb6,8'hb6,8'hb6,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hb6,8'hb6,8'hb6,8'hb6,8'h00,8'hff,8'hff},
	{8'hff,8'h00,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'h00,8'hff,8'hff,8'hff,8'h00,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'h00,8'hff,8'hff,8'hff,8'h00,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'h00,8'hff},
	{8'hff,8'h00,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'h00,8'hff,8'hff,8'hff,8'h00,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'h00,8'hff,8'hff,8'hff,8'h00,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'h00,8'hff},
	{8'h00,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'h00,8'hff,8'h00,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'h00,8'hff,8'h00,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'h00},
	{8'hff,8'h00,8'h00,8'hb6,8'hb6,8'hb6,8'hb6,8'h00,8'h00,8'hff,8'hff,8'hff,8'h00,8'h00,8'hb6,8'hb6,8'hb6,8'hb6,8'h00,8'h00,8'hff,8'hff,8'hff,8'h00,8'h00,8'hb6,8'hb6,8'hb6,8'hb6,8'h00,8'h00,8'hff},
	{8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'h00,8'hb6,8'hb6,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hb6,8'hb6,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hb6,8'hb6,8'h00,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'h00,8'hb6,8'hb6,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hb6,8'hb6,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hb6,8'hb6,8'h00,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'h00,8'hb6,8'hb6,8'hb6,8'hb6,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hb6,8'hb6,8'hb6,8'hb6,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hb6,8'hb6,8'hb6,8'hb6,8'h00,8'hff,8'hff},
	{8'hff,8'hff,8'h00,8'hb6,8'hb6,8'hb6,8'hb6,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hb6,8'hb6,8'hb6,8'hb6,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hb6,8'hb6,8'hb6,8'hb6,8'h00,8'hff,8'hff},
	{8'hff,8'h00,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'h00,8'hff,8'hff,8'hff,8'h00,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'h00,8'hff,8'hff,8'hff,8'h00,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'h00,8'hff},
	{8'hff,8'h00,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'h00,8'hff,8'hff,8'hff,8'h00,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'h00,8'hff,8'hff,8'hff,8'h00,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'h00,8'hff},
	{8'h00,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'h00,8'hff,8'h00,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'h00,8'hff,8'h00,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'h00},
	{8'hff,8'h00,8'h00,8'hb6,8'hb6,8'hb6,8'hb6,8'h00,8'h00,8'hff,8'hff,8'hff,8'h00,8'h00,8'hb6,8'hb6,8'hb6,8'hb6,8'h00,8'h00,8'hff,8'hff,8'hff,8'h00,8'h00,8'hb6,8'hb6,8'hb6,8'hb6,8'h00,8'h00,8'hff},
	{8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'h00,8'hb6,8'hb6,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hb6,8'hb6,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hb6,8'hb6,8'h00,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'h00,8'hb6,8'hb6,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hb6,8'hb6,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hb6,8'hb6,8'h00,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'h00,8'hb6,8'hb6,8'hb6,8'hb6,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hb6,8'hb6,8'hb6,8'hb6,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hb6,8'hb6,8'hb6,8'hb6,8'h00,8'hff,8'hff},
	{8'hff,8'hff,8'h00,8'hb6,8'hb6,8'hb6,8'hb6,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hb6,8'hb6,8'hb6,8'hb6,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hb6,8'hb6,8'hb6,8'hb6,8'h00,8'hff,8'hff},
	{8'hff,8'h00,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'h00,8'hff,8'hff,8'hff,8'h00,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'h00,8'hff,8'hff,8'hff,8'h00,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'h00,8'hff},
	{8'hff,8'h00,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'h00,8'hff,8'hff,8'hff,8'h00,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'h00,8'hff,8'hff,8'hff,8'h00,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'h00,8'hff},
	{8'h00,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'h00,8'hff,8'h00,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'h00,8'hff,8'h00,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'h00},
	{8'hff,8'h00,8'h00,8'hb6,8'hb6,8'hb6,8'hb6,8'h00,8'h00,8'hff,8'hff,8'hff,8'h00,8'h00,8'hb6,8'hb6,8'hb6,8'hb6,8'h00,8'h00,8'hff,8'hff,8'hff,8'h00,8'h00,8'hb6,8'hb6,8'hb6,8'hb6,8'h00,8'h00,8'hff},
	{8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff}
	};

 
//
// pipeline (ff) to get the pixel color from the array 	 

//==----------------------------------------------------------------------------------------------------------------=
always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		RGBout <=	8'h00;
		MazeBitMapMask  <=  MazeDefaultBitMapMask[default_layout] ;  //  copy default tabel
	end
	else begin
		RGBout <= TRANSPARENT_ENCODING ; // default
		if (!game_on) begin
			MazeBitMapMask <= MazeDefaultBitMapMask[layout_sel];
			end
		
		if (InsideRectangle == 1'b1 )	begin 
			if (MazeBitMapMask[offsetY_MSB][offsetX_MSB])
				RGBout <= object_colors[offsetY_LSB][offsetX_LSB];
			else
				RGBout <= TRANSPARENT_ENCODING ; 
			end
		

	end 
end

//==----------------------------------------------------------------------------------------------------------------=
// decide if to draw the pixel or not 
assign drawingRequest = (RGBout != TRANSPARENT_ENCODING ) ? 1'b1 : 1'b0 ; // get optional transparent command from the bitmpap 
endmodule

