// HartsMatrixBitMap File 
// A two level bitmap. dosplaying harts on the screen Feb 2025 
//(c) Technion IIT, Department of Electrical Engineering 2025 



module	ColumnsMatrixBitMap	(	
					input	logic	clk,
					input	logic	resetN,
					input logic	[10:0] offsetX,// offset from top left  position 
					input logic	[10:0] offsetY,
					input	logic	InsideRectangle, //input that the pixel is within a bracket 

					output	logic	drawingRequest, //output that the pixel should be dispalyed 
					output	logic	[7:0] RGBout  //rgb value from the bitmap 
 ) ;
 

localparam logic [7:0] TRANSPARENT_ENCODING = 8'hff ;// RGB value in the bitmap representing a transparent pixel 


localparam  int TILE_NUMBER_OF_X_BITS = 5;  // 2^5 = 32  everu object 
localparam  int TILE_NUMBER_OF_Y_BITS = 5;  // 2^5 = 32 

localparam  int MAZE_NUMBER_OF__X_BITS = 5;  // 2^4 = 16 / /the maze of the objects 
localparam  int MAZE_NUMBER_OF__Y_BITS = 4;  // 2^3 = 8 

//-----

localparam  int TILE_WIDTH_X = 1 << TILE_NUMBER_OF_X_BITS ;
localparam  int TILE_HEIGHT_Y = 1 <<  TILE_NUMBER_OF_Y_BITS ;
localparam  int MAZE_WIDTH_X = 1 << MAZE_NUMBER_OF__X_BITS ;
localparam  int MAZE_HEIGHT_Y = 1 << MAZE_NUMBER_OF__Y_BITS ;


 logic [10:0] offsetX_LSB  ;
 logic [10:0] offsetY_LSB  ; 
 logic [10:0] offsetX_MSB ;
 logic [10:0] offsetY_MSB  ;

 assign offsetX_LSB  = offsetX[(TILE_NUMBER_OF_X_BITS-1):0] ; // get lower bits 
 assign offsetY_LSB  = offsetY[(TILE_NUMBER_OF_Y_BITS-1):0] ; // get lower bits 
 assign offsetX_MSB  = offsetX[(TILE_NUMBER_OF_X_BITS + MAZE_NUMBER_OF__X_BITS -1 ):TILE_NUMBER_OF_X_BITS] ; // get higher bits 
 assign offsetY_MSB  = offsetY[(TILE_NUMBER_OF_Y_BITS + MAZE_NUMBER_OF__Y_BITS -1 ):TILE_NUMBER_OF_Y_BITS] ; // get higher bits 
 

 
// the screen is 640*480  or  20 * 15 squares of 32*32  bits ,  we wiil round up to 8 *16 
// this is the bitmap  of the maze , if there is a specific value  the  whole 32*32 rectange will be drawn on the screen
// there are  16 options of differents kinds of 32*32 squares 
// all numbers here are hard coded to simplify the understanding 



// This is a Test:

logic [1:0] MazeBitMapMask [0:10] [0:16];

logic [1:0] MazeDefaultBitMapMask [0:10] [0:16] = 
	'{'{1'b1, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 1'b1},
	  '{1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0},
	  '{1'b1, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 1'b1},
	  '{1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0},
	  '{1'b1, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 1'b1},
	  '{1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0},
	  '{1'b1, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 1'b1},
	  '{1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0},
	  '{1'b1, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 1'b1},
	  '{1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0},
	  '{1'b1, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 1'b1}};
 

logic [0:TILE_HEIGHT_Y-1] [0:TILE_WIDTH_X-1] [7:0] object_colors = {
	{8'h00,8'hfa,8'hfa,8'hfa,8'hd1,8'h00,8'hac,8'hfa,8'hfa,8'hfa,8'hd1,8'h00,8'h00,8'hfa,8'hfa,8'hd1,8'hf5,8'hd1,8'h20,8'h00,8'hf5,8'hf5,8'hf5,8'hf5,8'h84,8'h00,8'hfa,8'hfa,8'hfa,8'hf5,8'h84,8'h00},
	{8'hfa,8'hfa,8'hf5,8'hf5,8'hd1,8'h84,8'hfa,8'hf5,8'hf5,8'hf5,8'hd1,8'h84,8'hd1,8'hfa,8'hf5,8'hf5,8'hf5,8'hf5,8'hac,8'hf5,8'hfa,8'hf5,8'hf5,8'hf5,8'hd1,8'h84,8'hfa,8'hf5,8'hf5,8'hf5,8'hf5,8'h84},
	{8'hfa,8'hf5,8'hf5,8'hf5,8'hd1,8'h84,8'hd1,8'hf5,8'hf5,8'hf5,8'hd1,8'hd1,8'hd1,8'hf5,8'hf5,8'hf5,8'hf5,8'hf5,8'hd1,8'hf5,8'hf5,8'hf5,8'hf5,8'hf5,8'hd1,8'h84,8'hfa,8'hf5,8'hf5,8'hf5,8'hf5,8'hd1},
	{8'hf5,8'hf5,8'hf5,8'hf5,8'hd1,8'hf5,8'hd1,8'hd1,8'hac,8'hd1,8'hd1,8'h84,8'hd1,8'hd1,8'hd1,8'hd1,8'hd1,8'hd1,8'hd1,8'hd1,8'hd1,8'hf5,8'hf5,8'hd1,8'hd1,8'h84,8'hd1,8'hf5,8'hf5,8'hf5,8'hd1,8'hd1},
	{8'hd1,8'hf5,8'hd1,8'hd1,8'h84,8'hac,8'hf5,8'h84,8'h84,8'h84,8'h84,8'hf9,8'hf9,8'h84,8'hd1,8'hd1,8'h84,8'h84,8'hd5,8'hf9,8'hd1,8'hd1,8'hd1,8'hd1,8'hcd,8'hf9,8'hd1,8'hd1,8'hd1,8'hd1,8'hd1,8'hd1},
	{8'h00,8'hd1,8'h84,8'hd5,8'hd1,8'hfa,8'hfa,8'hd1,8'hf9,8'hcd,8'hfa,8'hfa,8'hfa,8'hd1,8'h84,8'hf9,8'hfa,8'hfa,8'hfa,8'hfa,8'hd1,8'h84,8'hf9,8'hf5,8'h84,8'h84,8'hd5,8'hd5,8'hd5,8'h84,8'h64,8'h00},
	{8'h84,8'hd1,8'ha4,8'hf9,8'hfa,8'hf5,8'hf5,8'hd1,8'hf5,8'hfa,8'hf5,8'hf5,8'hf5,8'hf5,8'hd1,8'hac,8'hfa,8'hf5,8'hf5,8'hf5,8'hd1,8'h84,8'hf9,8'hac,8'hfa,8'hfa,8'hd1,8'h84,8'h84,8'hfa,8'hf5,8'h84},
	{8'hfa,8'hfa,8'hf5,8'hf5,8'hfa,8'hf5,8'hf5,8'hd1,8'hf5,8'hd1,8'hf5,8'hf5,8'hf5,8'hd1,8'hd1,8'hac,8'hf5,8'hf5,8'hf5,8'hf5,8'hd1,8'h84,8'h84,8'hfa,8'hcd,8'hf5,8'hd1,8'h64,8'h84,8'hf5,8'hf5,8'hac},
	{8'hfa,8'hf5,8'hd1,8'h84,8'hd1,8'hf5,8'hf5,8'hd1,8'hf9,8'hf1,8'hf5,8'hf5,8'hf5,8'hd1,8'hac,8'hac,8'hf5,8'hf5,8'hf5,8'hf5,8'hd1,8'h84,8'h84,8'hf5,8'hf5,8'hf5,8'hd1,8'h84,8'hd1,8'hf5,8'hf5,8'hd1},
	{8'hf5,8'hf5,8'hd1,8'h84,8'h84,8'hd1,8'hd1,8'h84,8'hf9,8'h84,8'hd1,8'hd1,8'hd1,8'h84,8'hd5,8'hf9,8'hd1,8'hd1,8'hd1,8'hd1,8'hd1,8'hf5,8'hf5,8'hd1,8'hd1,8'hd1,8'hd1,8'hd5,8'hd1,8'hf5,8'hf5,8'hd1},
	{8'hd1,8'hd1,8'hac,8'h84,8'hf9,8'h84,8'h84,8'h84,8'h84,8'hfd,8'h64,8'h84,8'h64,8'h84,8'h64,8'h84,8'h64,8'h64,8'h64,8'h84,8'h84,8'h84,8'h84,8'hf5,8'h84,8'h64,8'hf5,8'hfd,8'h84,8'hd1,8'hd1,8'hac},
	{8'h84,8'hd1,8'h84,8'hf5,8'hd1,8'hfa,8'hfa,8'hf5,8'hcc,8'hd1,8'hfd,8'hfa,8'hfa,8'hf5,8'hf5,8'hf5,8'hd1,8'hd1,8'hd1,8'hfa,8'hfa,8'hf5,8'hd1,8'hd1,8'hfa,8'hfa,8'hd1,8'hf9,8'hf9,8'h84,8'h84,8'hac},
	{8'h00,8'h84,8'h84,8'hd0,8'hd1,8'hf5,8'hf5,8'hf5,8'hf5,8'hd1,8'hf5,8'hfa,8'hf5,8'hf5,8'hf5,8'hf5,8'hf5,8'hd1,8'hd1,8'hf5,8'hf5,8'hf5,8'hf5,8'hd1,8'hfa,8'hf5,8'hd1,8'h64,8'h84,8'hd1,8'hd1,8'h00},
	{8'hac,8'hfa,8'hf5,8'h84,8'hd1,8'hf5,8'hf5,8'hf5,8'hf5,8'hd1,8'hf5,8'hf5,8'hf5,8'hf5,8'hf5,8'hf5,8'hd1,8'hac,8'hd1,8'hf5,8'hf5,8'hf5,8'hd1,8'h84,8'hfa,8'hf5,8'hd1,8'h84,8'hd1,8'hfa,8'hf5,8'hd1},
	{8'hfa,8'hf5,8'hf5,8'hd1,8'hf5,8'hd1,8'hd1,8'hd1,8'hd1,8'hd1,8'hd1,8'h84,8'hd1,8'hac,8'hd1,8'hd1,8'h84,8'hd5,8'hf9,8'h84,8'hcd,8'hd1,8'hd1,8'h84,8'hd1,8'hd1,8'hd1,8'h64,8'hfa,8'hf5,8'hf5,8'hd1},
	{8'hfa,8'hf5,8'hf5,8'hd1,8'hf9,8'h84,8'hd1,8'hd1,8'hd1,8'hd1,8'hf9,8'h84,8'h84,8'h84,8'hf5,8'hb1,8'hd1,8'hd1,8'hd1,8'hd1,8'h84,8'h84,8'h84,8'h84,8'h84,8'hd1,8'h84,8'h84,8'hfa,8'hf5,8'hf5,8'hd1},
	{8'hf5,8'hf5,8'hd1,8'hd1,8'hf5,8'hfd,8'hf5,8'hf5,8'hd5,8'hd5,8'hac,8'hfa,8'hfa,8'hf5,8'h84,8'hf5,8'hfa,8'hf5,8'hf5,8'hf5,8'hcd,8'hfe,8'hfd,8'hac,8'hcd,8'hd1,8'h84,8'h64,8'hf5,8'hf5,8'hf5,8'hd1},
	{8'h84,8'hd1,8'hd1,8'hf5,8'h84,8'hfa,8'hf5,8'hf5,8'hf5,8'h84,8'hfa,8'hf5,8'hf5,8'hf5,8'hd1,8'h8c,8'hf5,8'hcd,8'hf5,8'hf5,8'hd1,8'hb1,8'hfa,8'hfa,8'hf5,8'hf5,8'hd1,8'h84,8'hd1,8'hd1,8'hac,8'h84},
	{8'h00,8'h84,8'hf5,8'hf9,8'hac,8'hf5,8'hf5,8'hd1,8'hd1,8'hd1,8'hf5,8'hf5,8'hf5,8'hf5,8'hd1,8'hac,8'hf5,8'hf5,8'hf5,8'hf5,8'hd1,8'hf9,8'hf5,8'hf5,8'hf5,8'hf5,8'hd1,8'h84,8'h84,8'hd1,8'hd1,8'h00},
	{8'h00,8'hfa,8'hf5,8'h8c,8'hac,8'hf5,8'hf5,8'hf5,8'hd1,8'hd1,8'hd1,8'hf5,8'hf5,8'hf5,8'hd1,8'h84,8'hd1,8'hf5,8'hf5,8'hd1,8'hd1,8'hf5,8'hd1,8'hf5,8'hf5,8'hf5,8'hd1,8'h84,8'hf9,8'h84,8'h84,8'h00},
	{8'hfa,8'hf5,8'hf5,8'hd1,8'h84,8'hd1,8'hd1,8'hd1,8'hd1,8'hf5,8'hd5,8'hd1,8'hac,8'hd1,8'hf5,8'hf9,8'h84,8'h84,8'h84,8'h84,8'hf5,8'hfe,8'h84,8'hac,8'hd1,8'hd1,8'hd1,8'h64,8'hfa,8'hf5,8'hf5,8'hd1},
	{8'hf5,8'hf5,8'hd1,8'hd1,8'h8c,8'h84,8'h64,8'h64,8'hd5,8'hf9,8'h84,8'hd1,8'hd1,8'hd1,8'h84,8'hfd,8'h84,8'hd1,8'hd1,8'hd1,8'hd1,8'h84,8'hfd,8'h84,8'h64,8'h64,8'hd5,8'hfa,8'hf5,8'hf5,8'hf5,8'hd1},
	{8'hf5,8'hf5,8'hd1,8'hd1,8'hd5,8'hd1,8'hd1,8'hf1,8'h84,8'hf9,8'hfa,8'hfa,8'hf5,8'hf5,8'hd1,8'h8c,8'hfa,8'hfa,8'hf5,8'hf5,8'hf5,8'hd1,8'h84,8'hfd,8'hd1,8'hd1,8'hf9,8'hfa,8'hf5,8'hf5,8'hf5,8'hd1},
	{8'hd1,8'hd1,8'hd1,8'h84,8'hcd,8'hf5,8'hf5,8'hf5,8'hd1,8'h64,8'hf5,8'hf5,8'hf5,8'hf5,8'hd1,8'h8c,8'hfa,8'hf5,8'hf5,8'hf5,8'hf5,8'hd1,8'h84,8'hcd,8'hf5,8'hf5,8'h84,8'hd1,8'hd1,8'hf5,8'hd1,8'hd1},
	{8'h00,8'h84,8'h84,8'hd5,8'hd1,8'hf5,8'hf5,8'hf5,8'hd1,8'h64,8'hf5,8'hf5,8'hf5,8'hd1,8'hd1,8'hac,8'hd1,8'hf5,8'hf5,8'hf5,8'hf5,8'hd1,8'h84,8'hd1,8'hf5,8'hf5,8'h84,8'h64,8'hd1,8'hd1,8'hd1,8'h84},
	{8'h00,8'h84,8'h84,8'hfd,8'h84,8'hd1,8'hd1,8'hd1,8'hd1,8'h8c,8'hd1,8'hd1,8'hd1,8'hd1,8'hd1,8'hd1,8'hcd,8'hd1,8'hd1,8'hd1,8'hd1,8'hac,8'h84,8'hd1,8'hd1,8'hcc,8'h84,8'hf9,8'h84,8'h64,8'h64,8'h00},
	{8'hfa,8'hfa,8'hf5,8'hf5,8'hd1,8'h84,8'h84,8'h84,8'h84,8'h84,8'h84,8'h64,8'h84,8'h84,8'hd5,8'hd1,8'hd1,8'hd1,8'hd1,8'hd5,8'hf5,8'hf5,8'hfd,8'hfe,8'h84,8'h84,8'hf5,8'hfa,8'hfa,8'hfa,8'hf5,8'h84},
	{8'hfa,8'hf5,8'hcd,8'hf5,8'hf5,8'h64,8'hf9,8'had,8'hfa,8'hfa,8'hd1,8'h84,8'hf9,8'hf9,8'hfa,8'hf5,8'hf5,8'hf5,8'h84,8'hac,8'h84,8'hfa,8'hfa,8'hfa,8'h84,8'hf9,8'hac,8'hfa,8'hf5,8'hf5,8'hf5,8'hd1},
	{8'hf5,8'hf5,8'hf5,8'hf5,8'hf5,8'hd1,8'h84,8'hfa,8'hf5,8'hf5,8'hf5,8'hd1,8'hd1,8'hf5,8'hfa,8'hf5,8'hf5,8'hf5,8'hd1,8'h64,8'hfa,8'hf5,8'hf5,8'hf5,8'hf5,8'hd1,8'hd1,8'hf9,8'hf5,8'hf5,8'hd1,8'hcd},
	{8'hd1,8'hf5,8'hf5,8'hf5,8'hd1,8'hd1,8'h84,8'hd1,8'hf5,8'hf5,8'hf5,8'hd1,8'hd1,8'hd1,8'hf5,8'hf5,8'hf5,8'hf5,8'hd1,8'h64,8'hf5,8'hf5,8'hf5,8'hf5,8'hf5,8'hd1,8'hd1,8'hf5,8'hf5,8'hf5,8'hac,8'hac},
	{8'h84,8'hd1,8'hd1,8'hd1,8'hac,8'hd1,8'h84,8'hd1,8'hd1,8'hd1,8'hd1,8'hd1,8'hd1,8'hd1,8'hd1,8'hf5,8'hf5,8'hd1,8'hd1,8'h64,8'hd1,8'hd1,8'hd1,8'hd1,8'hd1,8'hd1,8'hd1,8'hd1,8'hd1,8'hd1,8'hd1,8'h84},
	{8'h00,8'h64,8'hd1,8'hd1,8'hd1,8'h00,8'h00,8'h64,8'hd1,8'hd1,8'hd1,8'hcd,8'h00,8'h00,8'hd1,8'hd1,8'hd1,8'hcd,8'h84,8'h00,8'h84,8'hcd,8'hd1,8'hd1,8'hd1,8'h84,8'h00,8'hd1,8'hac,8'hd1,8'h84,8'h00}};

 
//
// pipeline (ff) to get the pixel color from the array 	 

//==----------------------------------------------------------------------------------------------------------------=
always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		RGBout <=	8'h00;
		MazeBitMapMask  <=  MazeDefaultBitMapMask ;  //  copy default tabel 
	end
	else begin
		RGBout <= TRANSPARENT_ENCODING ; // default 
		
		if (InsideRectangle == 1'b1 )	
			begin 
		   	case (MazeBitMapMask[offsetY_MSB][offsetX_MSB])
					 1'b0 : RGBout <= TRANSPARENT_ENCODING ;
					 1'b1 : RGBout <= object_colors[offsetY_LSB][offsetX_LSB];  
				default:  RGBout <= TRANSPARENT_ENCODING ; 
				endcase
			end 

	end 
end

//==----------------------------------------------------------------------------------------------------------------=
// decide if to draw the pixel or not 
assign drawingRequest = (RGBout != TRANSPARENT_ENCODING ) ? 1'b1 : 1'b0 ; // get optional transparent command from the bitmpap   
endmodule

