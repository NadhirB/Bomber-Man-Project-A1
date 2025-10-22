// HartsMatrixBitMap File 
// A two level bitmap. dosplaying harts on the screen Feb 2025 
//(c) Technion IIT, Department of Electrical Engineering 2025 



module	PowerUpsBitMap	(	
					input	logic	clk,
					input	logic	resetN,
					input logic	[10:0] offsetX,// offset from top left  position 
					input logic	[10:0] offsetY,
					input	logic	InsideRectangle, //input that the pixel is within a bracket 
					input logic col_player_powerUp,
					input logic col_player2_powerUp,
					input logic [3:0] curr_lives,
					input logic [3:0] curr_bombs,
					input logic [1:0] curr_speed,
					input logic [3:0] curr_lives2,
					input logic [3:0] curr_bombs2,
					input logic [1:0] curr_speed2,
					input logic score_reset,
					input logic mode_sel,
					input logic [3:0] layout_sel,
					input logic game_on,
//					input logic explosion,
//					input logic [10:0] enemy_topLeftX,
//					input logic [10:0] enemy_topLeftY,

					output logic drawingRequest, //output that the pixel should be dispalyed 
					output logic [7:0] RGBout,  //rgb value from the bitmap
					output logic inc_speed,
					output logic inc_bombs,
					output logic inc_lives,
					output logic inc_time,
					output logic inc_score,
					output logic inc_speed2,
					output logic inc_bombs2,
					output logic inc_lives2					
//					output logic enemy_valid_pos
 ) ;
 

localparam logic [7:0] TRANSPARENT_ENCODING = 8'hbc ;// RGB value in the bitmap representing a transparent pixel 


localparam  int TILE_NUMBER_OF_X_BITS = 5;  // 2^5 = 32  everu object 
localparam  int TILE_NUMBER_OF_Y_BITS = 5;  // 2^5 = 32 

localparam  int MAZE_NUMBER_OF__X_BITS = 5;  // 2^4 = 16 / /the maze of the objects 
localparam  int MAZE_NUMBER_OF__Y_BITS = 4;  // 2^3 = 8 

//-----

localparam  int TILE_WIDTH_X = 1 << TILE_NUMBER_OF_X_BITS ;
localparam  int TILE_HEIGHT_Y = 1 <<  TILE_NUMBER_OF_Y_BITS ;
localparam  int MAZE_WIDTH_X = 1 << MAZE_NUMBER_OF__X_BITS ;
localparam  int MAZE_HEIGHT_Y = 1 << MAZE_NUMBER_OF__Y_BITS ;


 logic [10:0] offsetX_LSB ;
 logic [10:0] offsetY_LSB ; 
 logic [10:0] offsetX_MSB ;
 logic [10:0] offsetY_MSB ;
// logic blast_flag; 

 assign offsetX_LSB  = offsetX[(TILE_NUMBER_OF_X_BITS-1):0] ; // get lower bits 
 assign offsetY_LSB  = offsetY[(TILE_NUMBER_OF_Y_BITS-1):0] ; // get lower bits 
 assign offsetX_MSB  = offsetX[(TILE_NUMBER_OF_X_BITS + MAZE_NUMBER_OF__X_BITS -1 ):TILE_NUMBER_OF_X_BITS] ; // get higher bits 
 assign offsetY_MSB  = offsetY[(TILE_NUMBER_OF_Y_BITS + MAZE_NUMBER_OF__Y_BITS -1 ):TILE_NUMBER_OF_Y_BITS] ; // get higher bits 
 
 
 
 // Enemy Valid Position Calc
 
// logic [10:0] offsetX_enemy;
// logic [10:0] offsetY_enemy;
// logic [10:0] offsetX_enemy_width;
// logic [10:0] offsetY_enemy_hight;
// logic maze_object;

// assign offsetX_enemy = enemy_topLeftX - 15;
// assign offsetY_enemy = enemy_topLeftY - 48;
// assign offsetX_enemy_width = offsetX_enemy + TILE_WIDTH_X - 1;
// assign offsetY_enemy_hight = offsetY_enemy + TILE_HEIGHT_Y - 1;

// assign offsetX_enemy_MSB  = offsetX_enemy[(TILE_NUMBER_OF_X_BITS + MAZE_NUMBER_OF__X_BITS -1 ):TILE_NUMBER_OF_X_BITS] ; // get higher bits 
// assign offsetY_enemy_MSB  = offsetY_enemy[(TILE_NUMBER_OF_Y_BITS + MAZE_NUMBER_OF__Y_BITS -1 ):TILE_NUMBER_OF_Y_BITS] ; // get higher bits 
// 
// assign offsetX_enemy_MSB_WIDTH  = offsetX_enemy_MSB + 31;// offsetX_enemy_width[(TILE_NUMBER_OF_X_BITS + MAZE_NUMBER_OF__X_BITS -1 ):TILE_NUMBER_OF_X_BITS] ; // get higher bits 
// assign offsetY_enemy_MSB_HIGHT  = offsetY_enemy_MSB + 31;// offsetY_enemy_hight[(TILE_NUMBER_OF_Y_BITS + MAZE_NUMBER_OF__Y_BITS -1 ):TILE_NUMBER_OF_Y_BITS] ; // get higher bits 
 
 

 
// the screen is 640*480  or  20 * 15 squares of 32*32  bits ,  we wiil round up to 8 *16 
// this is the bitmap  of the maze , if there is a specific value  the  whole 32*32 rectange will be drawn on the screen
// there are  16 options of differents kinds of 32*32 squares 
// all numbers here are hard coded to simplify the understanding 



// This is a Test:

logic [2:0] MazeBitMapMask [0:12] [0:18];
//logic MazeBitMapMask_exploding [0:12] [0:18];

logic [2:0] MazeDefaultBitMapMask [0:4] [0:12] [0:18] = 
	'{'{'{0, 0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0},
	  '{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, //col
	  '{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	  '{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 1, 0, 0, 0, 0}, //col
	  '{0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5},
	  '{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, //col
	  '{0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0},
	  '{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, //col
	  '{0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 0, 0, 1, 0},
	  '{0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, //col
	  '{3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0},
	  '{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, //col
	  '{0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}},
	  
	  '{'{0, 0, 0, 0, 0, 0, 4, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 5},
	  '{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, //col
	  '{0, 0, 0, 0, 3, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 4, 0, 0, 0},
	  '{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, //col
	  '{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	  '{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0}, //col
	  '{0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	  '{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, //col
	  '{0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	  '{0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, //col
	  '{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0},
	  '{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, //col
	  '{0, 0, 0, 1, 0, 0, 0, 0, 0, 4, 0, 0, 0, 1, 0, 0, 0, 0, 0}},
	  
	  
		'{'{0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 3, 0, 0, 0, 4, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0},
		'{0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 5, 0, 0, 0, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3},
		'{3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 4, 0, 0, 2, 0, 0, 0, 0}},
	  
	  
		'{'{0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 4, 3, 0, 0, 0, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3},
		'{0, 0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		'{0, 0, 3, 0, 0, 1, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 5, 0, 0}},
	  
	  
		'{'{0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 0, 2, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 5, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		'{0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3},
		'{0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		'{0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 4, 0, 0, 0, 0, 0, 3, 0}}
	  
	  
	  };

//logic MazeDefaultBitMapMask_exploding [0:12] [0:18] = 
//	'{'{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
//	  '{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, //col
//	  '{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
//	  '{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, //col
//	  '{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
//	  '{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, //col
//	  '{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
//	  '{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, //col
//	  '{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
//	  '{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, //col
//	  '{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
//	  '{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, //col
//	  '{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}};
 
 


logic [0:4] [0:TILE_HEIGHT_Y-1] [0:TILE_WIDTH_X-1] [7:0] object_colors = {
	{{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'he0,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'he4,8'he4,8'he4,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'he4,8'hf0,8'he4,8'hed,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'he4,8'hf8,8'hf8,8'hf4,8'hf0,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'he4,8'hf0,8'hfd,8'hfd,8'hf0,8'he4,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'h00,8'hbf,8'hbf,8'hbf,8'hbf,8'h00,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'h00,8'hd1,8'hd1,8'hf8,8'he4,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'h00,8'hbf,8'hbf,8'hbf,8'hbf,8'h00,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'h00,8'hd1,8'h8c,8'h00,8'he0,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'h00,8'hbf,8'hbf,8'hbf,8'hbf,8'h00,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'h00,8'h8c,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'h00,8'h00,8'h00,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'h00,8'hbf,8'hbf,8'hbf,8'hbf,8'h00,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'h8c,8'h8c,8'hda,8'hbc,8'hbc,8'hbc,8'h00,8'hed,8'he4,8'he4,8'hed,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hbf,8'hbf,8'hbf,8'hbf,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'h00,8'hac,8'h00,8'hed,8'hed,8'h00,8'he4,8'hc4,8'hc4,8'hed,8'hc4,8'h00,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'h00,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hff,8'hd5,8'h8c,8'h00,8'hed,8'hed,8'hed,8'hed,8'hc4,8'he4,8'he4,8'h00,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'h00,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hed,8'hc4,8'hb1,8'h8c,8'h00,8'h00,8'hed,8'hf1,8'h00,8'hc4,8'he4,8'h00,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'h00,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'h00,8'h20,8'hc4,8'h00,8'hd1,8'h00,8'he4,8'hf1,8'hc4,8'h00,8'hc4,8'h00,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'h00,8'hbc},
	{8'hbc,8'hbc,8'h00,8'h00,8'he4,8'hed,8'h00,8'hed,8'h00,8'he4,8'hf1,8'hc4,8'hc4,8'hc4,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hbf,8'hbf,8'hbf,8'hbf,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hbc},
	{8'hbc,8'h00,8'hed,8'hc4,8'hc4,8'hf1,8'hf1,8'he4,8'hf1,8'hc4,8'he4,8'he4,8'he4,8'hc4,8'hc4,8'h00,8'hc4,8'he4,8'he4,8'he4,8'h00,8'hbf,8'hbf,8'hbf,8'hbf,8'h00,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'h00,8'hf1,8'he4,8'hc4,8'hc4,8'hc4,8'h00,8'he4,8'hf1,8'hf1,8'he4,8'he4,8'he4,8'he4,8'hc4,8'hc4,8'h00,8'hc4,8'hc0,8'h00,8'h00,8'hbf,8'hbf,8'hbf,8'hbf,8'h00,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'h00,8'hc4,8'hc4,8'he4,8'he4,8'hc4,8'h00,8'he4,8'hf1,8'hf1,8'he4,8'he4,8'he4,8'he4,8'hc4,8'hc4,8'h00,8'h20,8'h84,8'h00,8'hbf,8'hbf,8'hbf,8'hbf,8'h00,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'h00,8'he4,8'hf1,8'hed,8'he4,8'hc4,8'h00,8'he4,8'hed,8'hf1,8'hed,8'he4,8'he4,8'he4,8'hc4,8'h00,8'hac,8'h00,8'h00,8'hbf,8'hbf,8'hbf,8'hbf,8'h00,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'h00,8'he4,8'hed,8'hf1,8'he4,8'hc4,8'h00,8'he4,8'he4,8'hf1,8'hf1,8'he4,8'h00,8'h8c,8'hd1,8'h20,8'h84,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'h00,8'he4,8'he4,8'hf1,8'he4,8'hc4,8'h00,8'he4,8'he4,8'hf1,8'h00,8'hd1,8'h8c,8'h00,8'hd1,8'h84,8'h00,8'h00,8'hc4,8'he4,8'he4,8'hc4,8'hc4,8'h00,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'h00,8'hc0,8'he4,8'hf1,8'he4,8'hc4,8'h00,8'h00,8'hd1,8'h8c,8'h00,8'hd1,8'h8c,8'h00,8'he4,8'hc4,8'hc4,8'h00,8'hc4,8'he4,8'he4,8'hc4,8'hc4,8'h00,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'h00,8'h00,8'h00,8'h00,8'h00,8'hd1,8'hd1,8'h8c,8'h00,8'h8c,8'h8c,8'h00,8'he4,8'he4,8'he4,8'hc4,8'hc4,8'h00,8'hc4,8'he4,8'he4,8'he4,8'hc4,8'h00,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'h00,8'hd1,8'h8c,8'hd1,8'h8c,8'h00,8'hd1,8'h8c,8'hb0,8'h00,8'hf1,8'hf1,8'he4,8'he4,8'he4,8'he4,8'hc4,8'hc4,8'h00,8'hc4,8'he4,8'he4,8'he4,8'hc4,8'h00,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'h00,8'h00,8'hd1,8'hb0,8'h8c,8'h00,8'h00,8'hc4,8'h00,8'he4,8'hf1,8'hf1,8'he4,8'he4,8'he4,8'he4,8'hc4,8'hc4,8'h00,8'hc4,8'he4,8'he4,8'he4,8'hc4,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'h00,8'h00,8'h00,8'he4,8'hf1,8'he4,8'he4,8'hc4,8'h00,8'he4,8'hf1,8'hf1,8'he4,8'he4,8'he4,8'he4,8'hc4,8'hc4,8'h00,8'hc4,8'hc4,8'hc4,8'h00,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'h00,8'he4,8'hf1,8'hed,8'he4,8'hc4,8'h00,8'he4,8'hf1,8'hf1,8'he4,8'he4,8'he4,8'he4,8'hc4,8'hc4,8'h00,8'h00,8'h24,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'h00,8'he4,8'hf1,8'hf1,8'he4,8'hc4,8'h00,8'he4,8'hed,8'hf1,8'hed,8'he4,8'he4,8'he4,8'hc4,8'hc4,8'ha0,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'h00,8'he4,8'he4,8'hf1,8'he4,8'hc4,8'h00,8'he4,8'he4,8'hf1,8'hf1,8'he4,8'he4,8'he4,8'hc4,8'h00,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'h00,8'he4,8'he4,8'hf1,8'he4,8'hc4,8'h80,8'h60,8'he4,8'hf1,8'hf1,8'he4,8'h60,8'h00,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'h00,8'h20,8'he4,8'hf1,8'he4,8'hc4,8'hc4,8'h00,8'he4,8'he4,8'h00,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'h24,8'h00,8'he4,8'hed,8'h00,8'h00,8'hbc,8'h00,8'h00,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'h00,8'h00,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc}},
	
	{{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'h00,8'hbf,8'hbf,8'hbf,8'hbf,8'h00,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'h00,8'hbf,8'hbf,8'hbf,8'hbf,8'h00,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'h00,8'h00,8'hbf,8'hbf,8'hbf,8'hbf,8'h00,8'h00,8'h00,8'h00,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'h00,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'h00,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'h00,8'h00,8'hbf,8'hbf,8'hbf,8'hbf,8'h00,8'he0,8'he0,8'h00,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'h00,8'h00,8'h00,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hbf,8'hbf,8'hbf,8'hbf,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hbc},
	{8'hbc,8'h00,8'he0,8'he0,8'hff,8'hff,8'hff,8'hff,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'h00,8'h00,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'h00,8'hbc},
	{8'hbc,8'h00,8'he0,8'he0,8'hff,8'hff,8'hff,8'hff,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'h00,8'h00,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'h00,8'hbc},
	{8'hbc,8'h00,8'he0,8'he0,8'hff,8'hff,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'h00,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'h00,8'hbc},
	{8'hbc,8'h00,8'he0,8'he0,8'hff,8'hff,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'h00,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'h00,8'hbc},
	{8'hbc,8'h00,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hbf,8'hbf,8'hbf,8'hbf,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hbc},
	{8'hbc,8'h00,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'h00,8'hbf,8'hbf,8'hbf,8'hbf,8'h00,8'he0,8'he0,8'he0,8'he0,8'h00,8'hbc},
	{8'hbc,8'h00,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'h00,8'hbf,8'hbf,8'hbf,8'hbf,8'h00,8'he0,8'he0,8'he0,8'he0,8'h00,8'hbc},
	{8'hbc,8'h00,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'h00,8'hbf,8'hbf,8'hbf,8'hbf,8'h00,8'he0,8'he0,8'he0,8'he0,8'h00,8'hbc},
	{8'hbc,8'h00,8'h00,8'h00,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'h00,8'hbf,8'hbf,8'hbf,8'hbf,8'h00,8'he0,8'he0,8'h00,8'h00,8'h00,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'h00,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'he0,8'he0,8'h00,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'h00,8'h00,8'h00,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'h00,8'h00,8'h00,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'h00,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'h00,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'h00,8'h00,8'h00,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'h00,8'h00,8'h00,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'h00,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'h00,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'h00,8'h00,8'h00,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'h00,8'h00,8'h00,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'h00,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'h00,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'h00,8'h00,8'h00,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'h00,8'h00,8'h00,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'h00,8'ha0,8'ha0,8'he0,8'he0,8'he0,8'he0,8'ha0,8'ha0,8'h00,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'h00,8'h00,8'h00,8'he0,8'he0,8'he0,8'he0,8'h00,8'h00,8'h00,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'h00,8'h80,8'h80,8'h80,8'h80,8'h00,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc}},
	
	{{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hff,8'h24,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hda,8'hda,8'hda,8'hda,8'h04,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hff,8'hda,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h91,8'hb6,8'h24,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'h00,8'hff,8'h24,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'h00,8'hda,8'hda,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hbf,8'hbf,8'hbf,8'hbf,8'h00,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'h24,8'h91,8'h91,8'h91,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hbf,8'hbf,8'hbf,8'hbf,8'h00,8'h91,8'h24,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'h24,8'hda,8'hda,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hbf,8'hbf,8'hbf,8'hbf,8'h00,8'h6d,8'h00,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'h24,8'hda,8'h00,8'hfd,8'hff,8'hff,8'hfd,8'hf9,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hbf,8'hbf,8'hbf,8'hbf,8'h00,8'hf9,8'h04,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'h00,8'h00,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hf8,8'h00,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hbf,8'hbf,8'hbf,8'hbf,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hbc},
	{8'hbc,8'hbc,8'h20,8'hf4,8'hfd,8'hfd,8'hfd,8'hfd,8'hf4,8'hf8,8'h60,8'h84,8'h84,8'h84,8'hf0,8'h00,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'h00,8'hbc},
	{8'hbc,8'hbc,8'h20,8'hf0,8'hf8,8'hfd,8'hfd,8'hfd,8'hf8,8'h00,8'ha4,8'ha4,8'hec,8'hec,8'hec,8'h00,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'h00,8'hbc},
	{8'hbc,8'hbc,8'h20,8'hf0,8'hf0,8'hf4,8'hf4,8'hf4,8'h64,8'ha4,8'hc4,8'hec,8'hec,8'hec,8'hf5,8'h00,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'h00,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hf9,8'hf0,8'hf0,8'hf8,8'h20,8'ha4,8'hec,8'hec,8'hec,8'hf1,8'hff,8'hff,8'h00,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'h00,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'h24,8'hf4,8'hf4,8'h20,8'ha4,8'hec,8'hec,8'hec,8'hf5,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hbf,8'hbf,8'hbf,8'hbf,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'h84,8'ha4,8'ha4,8'ha4,8'hec,8'hec,8'hec,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h25,8'h25,8'hff,8'hff,8'h00,8'hbf,8'hbf,8'hbf,8'hbf,8'h00,8'hec,8'hec,8'h65,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'h84,8'ha4,8'ha4,8'ha4,8'hec,8'hec,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h25,8'h25,8'hff,8'hff,8'h00,8'hbf,8'hbf,8'hbf,8'hbf,8'h00,8'hec,8'hec,8'h65,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'h20,8'ha4,8'ha4,8'ha4,8'hec,8'hec,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h25,8'h25,8'hff,8'hff,8'h00,8'hbf,8'hbf,8'hbf,8'hbf,8'h00,8'hec,8'hec,8'hcc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'h20,8'ha4,8'ha4,8'ha4,8'hec,8'hec,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h25,8'h25,8'hff,8'hff,8'h00,8'hbf,8'hbf,8'hbf,8'hbf,8'h00,8'hec,8'hec,8'hcc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'h20,8'ha4,8'ha4,8'ha4,8'hec,8'hec,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h25,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hec,8'hec,8'hcc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'h20,8'ha4,8'ha4,8'ha4,8'hec,8'hec,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h25,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'ha4,8'hec,8'hec,8'hcc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'h20,8'ha4,8'ha4,8'ha4,8'hec,8'hec,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h25,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h84,8'hec,8'hec,8'hcc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hdf,8'h84,8'ha4,8'ha4,8'ha4,8'hec,8'hec,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h25,8'h25,8'hff,8'hff,8'hff,8'hff,8'h84,8'hec,8'hec,8'hec,8'h2d,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'h84,8'ha4,8'ha4,8'ha4,8'hec,8'hec,8'hf0,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h24,8'h25,8'hff,8'hff,8'hff,8'hec,8'hec,8'hec,8'hec,8'h6d,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'h24,8'ha4,8'ha4,8'ha4,8'hc0,8'hec,8'hec,8'hec,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hc4,8'hec,8'hec,8'hec,8'h00,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'h20,8'ha4,8'ha4,8'ha4,8'hec,8'hec,8'hec,8'hf1,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h84,8'hec,8'hec,8'hec,8'h20,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'h00,8'h6d,8'h84,8'ha4,8'hec,8'hec,8'hec,8'hec,8'hff,8'hff,8'hff,8'hff,8'hff,8'h84,8'hec,8'hec,8'hec,8'hec,8'h20,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hb6,8'h24,8'h92,8'h00,8'ha4,8'ha4,8'he4,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hac,8'h92,8'h25,8'h92,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'h00,8'h2d,8'hba,8'h00,8'h00,8'ha4,8'ha4,8'ha4,8'ha4,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'h00,8'h00,8'h00,8'h24,8'hb6,8'hb6,8'h00,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'h00,8'h2d,8'hba,8'h96,8'hbc,8'hbc,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'hbc,8'hbc,8'hbc,8'hda,8'h92,8'h96,8'hbb,8'h00,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'h00,8'h00,8'h00,8'h00,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'h00,8'h00,8'h00,8'h00,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc}},
	
	{{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'h00,8'h00,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'h00,8'h6d,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'h00,8'hfb,8'hda,8'h00,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'h00,8'hfb,8'hb6,8'h00,8'h00,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'h00,8'hfb,8'hda,8'h00,8'h00,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'h00,8'h00,8'hfb,8'hfb,8'hfb,8'h00,8'h00,8'h00,8'h00,8'h24,8'hfb,8'hb6,8'h20,8'ha4,8'h00,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'h20,8'hc4,8'had,8'h00,8'h04,8'hfb,8'hda,8'hda,8'hd6,8'hb6,8'hb6,8'hb6,8'h60,8'ha0,8'hc0,8'h00,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'h60,8'he4,8'he4,8'h20,8'h20,8'hfb,8'hfb,8'hfb,8'hda,8'hda,8'hfb,8'hd6,8'h80,8'he0,8'hc0,8'h00,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'h00,8'h00,8'h60,8'he4,8'he0,8'he0,8'ha0,8'h20,8'h00,8'h00,8'h00,8'h00,8'h00,8'h60,8'he0,8'he0,8'hc0,8'h00,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'h00,8'h00,8'h00,8'h20,8'he4,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'ha0,8'h00,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'h00,8'h00,8'h00,8'h00,8'h20,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'ha0,8'h00,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'h00,8'he4,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'ha0,8'h00,8'h00,8'h00,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'h00,8'he4,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'hc0,8'hc0,8'h00,8'h00,8'h00,8'h00,8'hfb,8'hda,8'hda,8'h00,8'hbc},
	{8'hbc,8'hbc,8'h00,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'hc0,8'h80,8'h80,8'h80,8'h80,8'h80,8'h60,8'h60,8'h60,8'h60,8'h60,8'h00,8'h91,8'h91,8'h91,8'hfb,8'hda,8'hda,8'h00,8'hbc},
	{8'hbc,8'hbc,8'h00,8'h80,8'ha0,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h60,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h6d,8'hfb,8'hfb,8'hfb,8'hfb,8'hfb,8'hda,8'h00,8'hbc},
	{8'hbc,8'h00,8'hda,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hfb,8'hfb,8'hfb,8'hfb,8'hfb,8'hfb,8'hfb,8'hfb,8'hfb,8'hfb,8'hfb,8'hfb,8'hfb,8'hfb,8'hfb,8'hfb,8'hda,8'h00,8'hbc},
	{8'hbc,8'h00,8'hfb,8'hfb,8'hfb,8'hfb,8'hfb,8'hfb,8'hfb,8'hfb,8'hfb,8'hfb,8'hfb,8'hfb,8'hfb,8'hda,8'hfb,8'hda,8'hfb,8'hda,8'hfb,8'hda,8'hfb,8'hda,8'hfb,8'hda,8'hfb,8'hda,8'hda,8'hda,8'h00,8'hbc},
	{8'hbc,8'h00,8'hfb,8'hfb,8'hda,8'hfb,8'hda,8'hfb,8'hda,8'hfb,8'hda,8'hfb,8'hda,8'hfb,8'hda,8'hfb,8'hda,8'hfb,8'hb6,8'hda,8'hb6,8'hda,8'hb6,8'hda,8'hb6,8'hda,8'hb6,8'hda,8'hb6,8'hb6,8'h00,8'hbc},
	{8'hbc,8'hbc,8'h00,8'hb6,8'h00,8'h91,8'h00,8'hb6,8'h00,8'h6d,8'h00,8'hb6,8'h00,8'hda,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hb6,8'h00,8'hda,8'h00,8'hb6,8'h00,8'hda,8'h00,8'hb6,8'h00,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc}},
	
	{{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'h16,8'h16,8'h16,8'h16,8'h16,8'h16,8'h16,8'h16,8'h16,8'h16,8'h16,8'h16,8'h16,8'h12,8'h16,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'h16,8'h1f,8'hbf,8'hbf,8'hbf,8'hbf,8'h1f,8'hff,8'hdf,8'h16,8'h16,8'h16,8'h16,8'h16,8'h16,8'h16,8'h16,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'h12,8'hff,8'h1f,8'hdf,8'hbf,8'hbf,8'h1f,8'hff,8'hbf,8'hbf,8'hbf,8'hbf,8'h16,8'h16,8'h16,8'h16,8'h16,8'h1f,8'h16,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'h16,8'hff,8'hff,8'h1f,8'hbf,8'hbf,8'h1f,8'hff,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'h16,8'h16,8'h16,8'h16,8'h1f,8'h1f,8'h16,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'h16,8'hff,8'hff,8'hff,8'hff,8'h1f,8'h1f,8'hff,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'hbf,8'h16,8'h16,8'h1f,8'h1f,8'h1f,8'h16,8'h16,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'h16,8'h16,8'hff,8'hff,8'hff,8'hff,8'h1f,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hdf,8'hdf,8'hff,8'hdf,8'hff,8'h16,8'h1f,8'h1f,8'h1f,8'h1f,8'h16,8'h16,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'h16,8'h16,8'h12,8'h12,8'h12,8'h12,8'h1f,8'h1f,8'h1f,8'h1f,8'h1f,8'h1f,8'h16,8'h16,8'h16,8'h16,8'h16,8'h16,8'h16,8'h16,8'h16,8'h16,8'h16,8'h16,8'h16,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'h16,8'h1f,8'h1f,8'h1f,8'hbf,8'hbf,8'h16,8'h17,8'h16,8'h16,8'h16,8'h1f,8'h1f,8'h1f,8'h1f,8'h1f,8'h1f,8'h1f,8'h12,8'h16,8'h16,8'h16,8'h16,8'h16,8'h16,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'h16,8'h1f,8'h1f,8'h1f,8'hbf,8'h16,8'h16,8'h16,8'h16,8'h16,8'h1f,8'h1f,8'h1f,8'h1f,8'h1f,8'h1f,8'h1f,8'h16,8'h16,8'h16,8'h16,8'h16,8'h16,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'h16,8'h1f,8'h1f,8'hbf,8'h1f,8'h16,8'h16,8'h16,8'h16,8'h1f,8'h1f,8'h9f,8'h9f,8'h1f,8'h1f,8'h16,8'h16,8'h16,8'h16,8'h16,8'h16,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'h16,8'h1f,8'h3f,8'h1f,8'h16,8'h16,8'h16,8'h16,8'h1f,8'h1f,8'h3f,8'h3f,8'h1f,8'h1f,8'h16,8'h16,8'h16,8'h16,8'h16,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'h31,8'h3f,8'h1f,8'h3f,8'h16,8'h16,8'h16,8'h1b,8'h1f,8'h1f,8'h1f,8'h1f,8'h1f,8'h3f,8'h16,8'h16,8'h16,8'h16,8'h31,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'h12,8'h1f,8'hbf,8'h1f,8'h16,8'h16,8'h1f,8'h1f,8'h1f,8'h1f,8'h1f,8'h1f,8'h16,8'h16,8'h16,8'h16,8'h16,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'h12,8'h1f,8'h1f,8'h16,8'h16,8'h1a,8'h1f,8'h1f,8'h1f,8'h1f,8'h3f,8'h16,8'h16,8'h16,8'h32,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'h16,8'h1f,8'h1f,8'h16,8'h1f,8'h16,8'h1f,8'h1f,8'h3f,8'h16,8'h16,8'h1b,8'h16,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'h16,8'h1f,8'h12,8'h1f,8'h1f,8'h1f,8'h1f,8'h3f,8'h16,8'h1b,8'h16,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'h16,8'h1f,8'h16,8'h1f,8'h1f,8'h1b,8'h16,8'h16,8'h12,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'h16,8'h16,8'h1f,8'h1f,8'h16,8'h16,8'h16,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'h16,8'h1f,8'h1f,8'h16,8'h31,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'h12,8'h16,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc},
	{8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc,8'hbc}},
	
	};

 
//
// pipeline (ff) to get the pixel color from the array 	 

//==----------------------------------------------------------------------------------------------------------------=
always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		RGBout <= 8'h00;
		MazeBitMapMask <= MazeDefaultBitMapMask[0] ;  //  copy default tabel
		inc_speed <= 0;
		inc_bombs <= 0;
		inc_lives <= 0;
		inc_time <= 0;
		inc_score <= 0;
		inc_bombs2 <= 0;
		inc_lives2 <= 0;
		inc_speed2 <= 0;
		
//		bombs_left;	
//		MazeBitMapMask_exploding <= MazeDefaultBitMapMask_exploding;
//		blast_flag <= 0;
//		maze_object <= 0;

	end
	else begin
		RGBout <= TRANSPARENT_ENCODING ; // default
		inc_speed <= 0;
		inc_bombs <= 0;
		inc_lives <= 0;
		inc_time <= 0;
		inc_score <= 0;
		inc_bombs2 <= 0;
		inc_lives2 <= 0;
		inc_speed2 <= 0;
		
		if (!game_on) begin
			MazeBitMapMask <= MazeDefaultBitMapMask[layout_sel];
		end
		
		if (col_player_powerUp) begin
			if (MazeBitMapMask[offsetY_MSB][offsetX_MSB] == 3'b001) begin		//bomb
				if (curr_bombs < 4'b0011) begin
					MazeBitMapMask[offsetY_MSB][offsetX_MSB] <= 0;
					inc_bombs <= 1;
				end
			end
			else if (MazeBitMapMask[offsetY_MSB][offsetX_MSB] == 3'b010) begin		//lives
				if (curr_lives < 4'b0011) begin
					MazeBitMapMask[offsetY_MSB][offsetX_MSB] <= 0;
					inc_lives <= 1;
				end
			end
			else if (MazeBitMapMask[offsetY_MSB][offsetX_MSB] == 3'b011) begin		//time
					MazeBitMapMask[offsetY_MSB][offsetX_MSB] <= 0;
					inc_time <= 1;
			end
			else if (MazeBitMapMask[offsetY_MSB][offsetX_MSB] == 3'b100) begin		//speed
				if (curr_speed < 2'b10) begin
					MazeBitMapMask[offsetY_MSB][offsetX_MSB] <= 0;
					inc_speed <= 1;
				end			
			end
			else if (MazeBitMapMask[offsetY_MSB][offsetX_MSB] == 3'b101) begin		//score
				MazeBitMapMask[offsetY_MSB][offsetX_MSB] <= 0;
				inc_score <= 1;

			end
		end
		
		
		if (mode_sel)
			if (col_player2_powerUp) begin
			
			if (MazeBitMapMask[offsetY_MSB][offsetX_MSB] == 3'b001) begin		//bomb
				if (curr_bombs2 < 4'b0011) begin
					MazeBitMapMask[offsetY_MSB][offsetX_MSB] <= 0;
					inc_bombs2 <= 1;
				end
			end
			else if (MazeBitMapMask[offsetY_MSB][offsetX_MSB] == 3'b010) begin		//lives
				if (curr_lives2 < 4'b0011) begin
					MazeBitMapMask[offsetY_MSB][offsetX_MSB] <= 0;
					inc_lives2 <= 1;
				end
			end
			else if (MazeBitMapMask[offsetY_MSB][offsetX_MSB] == 3'b100) begin		//speed
				if (curr_speed2 < 2'b10) begin
					MazeBitMapMask[offsetY_MSB][offsetX_MSB] <= 0;
					inc_speed2 <= 1;
				end			
			end
			
			
			end
	
	
		if (InsideRectangle == 1'b1 )	begin 
		   	case (MazeBitMapMask[offsetY_MSB][offsetX_MSB])
					 3'b000 : RGBout <= TRANSPARENT_ENCODING ;
					 3'b001 : RGBout <= object_colors[0][offsetY_LSB][offsetX_LSB];
					 3'b010 : RGBout <= object_colors[1][offsetY_LSB][offsetX_LSB];
					 3'b011 : begin
										if (!mode_sel)
											RGBout <= object_colors[2][offsetY_LSB][offsetX_LSB];
										else
											RGBout <= TRANSPARENT_ENCODING ;
					 			 end
					 3'b100 : RGBout <= object_colors[3][offsetY_LSB][offsetX_LSB];
					 3'b101 : begin
										if (!mode_sel)
											RGBout <= object_colors[4][offsetY_LSB][offsetX_LSB];
										else
											RGBout <= TRANSPARENT_ENCODING ;
					 			 end 
					 3'b110 : RGBout <= TRANSPARENT_ENCODING; 
					 3'b111 : RGBout <= TRANSPARENT_ENCODING; 
				default:  RGBout <= TRANSPARENT_ENCODING; 
				endcase
				
				
//				if (MazeBitMapMask[offsetY_enemy_MSB][offsetX_enemy_MSB] != 0 || MazeBitMapMask[offsetY_enemy_MSB_HIGHT][offsetX_enemy_MSB] != 0 ||
//					 MazeBitMapMask[offsetY_enemy_MSB][offsetX_enemy_MSB_WIDTH] != 0 || MazeBitMapMask[offsetY_enemy_MSB_HIGHT][offsetX_enemy_MSB_WIDTH] != 0)
//					maze_object <= 1;
//				else
//					maze_object <= 0;
			end
		

	end 
end

//==----------------------------------------------------------------------------------------------------------------=
// decide if to draw the pixel or not 
assign drawingRequest = (RGBout != TRANSPARENT_ENCODING ) ? 1'b1 : 1'b0 ; // get optional transparent command from the bitmpap 
//assign enemy_valid_pos = (maze_object == 0) ? 1 : 0;  
endmodule

