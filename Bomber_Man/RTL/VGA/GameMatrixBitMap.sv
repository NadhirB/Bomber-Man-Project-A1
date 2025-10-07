// HartsMatrixBitMap File 
// A two level bitmap. dosplaying harts on the screen Feb 2025 
//(c) Technion IIT, Department of Electrical Engineering 2025 



module	GameMatrixBitMap	(	
					input	logic	clk,
					input	logic	resetN,
					input logic	[10:0] offsetX,// offset from top left  position 
					input logic	[10:0] offsetY,
					input	logic	InsideRectangle, //input that the pixel is within a bracket
					input logic [10:0] player_topLeftX,
					input logic [10:0] player_topLeftY,
					input logic bomb_placed,

					output logic valid_player_position //output that the pixel should be dispalyed 
 ) ;
 

localparam logic [7:0] TRANSPARENT_ENCODING = 8'hFF ;// RGB value in the bitmap representing a transparent pixel 


localparam  int TILE_NUMBER_OF_X_BITS = 5;  // 2^5 = 32  every object 
localparam  int TILE_NUMBER_OF_Y_BITS = 5;  // 2^5 = 32 

localparam  int MAZE_NUMBER_OF__X_BITS = 4;  // 2^4 = 16 / /the maze of the objects 
localparam  int MAZE_NUMBER_OF__Y_BITS = 3;  // 2^3 = 8 

//-----

localparam  int TILE_WIDTH_X = 1 << TILE_NUMBER_OF_X_BITS ;
localparam  int TILE_HIGHT_Y = 1 <<  TILE_NUMBER_OF_Y_BITS ;
localparam  int MAZE_WIDTH_X = 1 << MAZE_NUMBER_OF__X_BITS ;
localparam  int MAZE_HEIGHT_Y = 1 << MAZE_NUMBER_OF__Y_BITS ;


// logic [10:0] offsetX_LSB ;
// logic [10:0] offsetY_LSB ; 
 logic [10:0] offsetX_MSB ;
 logic [10:0] offsetY_MSB ;
 logic [10:0] offsetX_MSB_WIDTH ;
 logic [10:0] offsetY_MSB_HIGHT ;
 
 logic [10:0] offsetX_player;
 logic [10:0] offsetY_player;
 logic [10:0] offsetX_player_width;
 logic [10:0] offsetY_player_hight;
 logic [3:0] maze_object ;

 assign offsetX_player = player_topLeftX - 15;
 assign offsetY_player = player_topLeftY - 48;
 assign offsetX_player_width = offsetX_player + TILE_WIDTH_X - 1;
 assign offsetY_player_hight = offsetY_player + TILE_HIGHT_Y - 1;

 assign offsetX_MSB  = offsetX_player[(TILE_NUMBER_OF_X_BITS + MAZE_NUMBER_OF__X_BITS -1 ):TILE_NUMBER_OF_X_BITS] ; // get higher bits 
 assign offsetY_MSB  = offsetY_player[(TILE_NUMBER_OF_Y_BITS + MAZE_NUMBER_OF__Y_BITS -1 ):TILE_NUMBER_OF_Y_BITS] ; // get higher bits 
 
 assign offsetX_MSB_WIDTH  = offsetX_player_width[(TILE_NUMBER_OF_X_BITS + MAZE_NUMBER_OF__X_BITS -1 ):TILE_NUMBER_OF_X_BITS] ; // get higher bits 
 assign offsetY_MSB_HIGHT  = offsetY_player_hight[(TILE_NUMBER_OF_Y_BITS + MAZE_NUMBER_OF__Y_BITS -1 ):TILE_NUMBER_OF_Y_BITS] ; // get higher bits 
 
 
// the screen is 640*480  or  20 * 15 squares of 32*32  bits ,  we wiil round up to 8 *16 
// this is the bitmap  of the maze , if there is a specific value  the  whole 32*32 rectange will be drawn on the screen
// there are  16 options of differents kinds of 32*32 squares 
// all numbers here are hard coded to simplify the understanding 




logic [1:0] MazeBitMapMask [0:12] [0:18];

logic [1:0] MazeDefaultBitMapMask [0:12] [0:18] = 
	'{'{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	  '{0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0},
	  '{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	  '{0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0},
	  '{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	  '{0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0},
	  '{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	  '{0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0},
	  '{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	  '{0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0},
	  '{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	  '{0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0},
	  '{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}};
 



// pipeline (ff) to get the pixel color from the array 	 

//==----------------------------------------------------------------------------------------------------------------=
always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		MazeBitMapMask  <=  MazeDefaultBitMapMask ;  //  copy default tabel 
		maze_object <= 0;
	end
	else begin 
		
		if (InsideRectangle == 1'b1 )	
			begin 
		   	if (MazeBitMapMask[offsetY_MSB][offsetX_MSB] == 1 || MazeBitMapMask[offsetY_MSB_HIGHT][offsetX_MSB] == 1 ||
					 MazeBitMapMask[offsetY_MSB][offsetX_MSB_WIDTH] == 1 || MazeBitMapMask[offsetY_MSB_HIGHT][offsetX_MSB_WIDTH] == 1)
					maze_object <= 1;
				else
					maze_object <= 0;
			end

	end
end

//==----------------------------------------------------------------------------------------------------------------=
// decide if to player can go there
assign valid_player_position = (maze_object == 0) ? 1 : 0;  
endmodule

