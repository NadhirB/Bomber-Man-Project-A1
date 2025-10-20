// (c) Technion IIT, Department of Electrical Engineering 2025 
//-- Alex Grinshpun Apr 2017
//-- Dudy Nov 13 2017
// SystemVerilog version Alex Grinshpun May 2018
// coding convention dudy December 2018
// updated Eyal Lev April 2023
// updated to state machine Dudy March 2023 
// update the hit and collision algoritm - Eyal MAR 2024
// good practice code - Dudy MAR 2025

module	player_move	(	
 
					input	logic clk,
					input logic resetN,
					input	logic startOfFrame,       	//short pulse every start of frame 30Hz 
					input	logic up_direction_key,   	//move Up   
					input	logic down_direction_key,  //move Down
					input	logic left_direction_key,  //move Left
					input	logic right_direction_key, //move Right
					input logic column_collision,    //collision if player hits a column or wall?
					input logic [1:0] speed_level,	//Used to set the different speed levels that will changed with powerup	
					input logic [3:0] HitEdgeCode,
					input logic game_on,
					
					output logic signed [10:0] topLeftX, // output the top left corner 
					output logic signed [10:0] topLeftY,  // can be negative , if the object is partliy outside 
					output logic [1:0] current_speed_level
					
);


// a module used to generate the player's movement.  

parameter int INITIAL_X = 15;
parameter int INITIAL_Y = 48;
parameter int Speed_default = 64;


const int	FIXED_POINT_MULTIPLIER = 64; // note it must be 2^n 
// FIXED_POINT_MULTIPLIER is used to enable working with integers in high resolution so that 
// we do all calculations with topLeftX_FixedPoint to get a resolution of 1/64 pixel in calcuatuions,
// we devide at the end by FIXED_POINT_MULTIPLIER which must be 2^n, to return to the initial proportions


// movement limits 
const int   OBJECT_WIDTH_X = 32;
const int   OBJECT_HIGHT_Y = 32;

const int	x_FRAME_LEFT	=	15 * FIXED_POINT_MULTIPLIER; 
const int	x_FRAME_RIGHT	=	(623 - OBJECT_WIDTH_X)* FIXED_POINT_MULTIPLIER; 
const int	y_FRAME_TOP		=	48 * FIXED_POINT_MULTIPLIER;
const int	y_FRAME_BOTTOM	=	(464 - OBJECT_HIGHT_Y ) * FIXED_POINT_MULTIPLIER; //- OBJECT_HIGHT_Y



const logic [3:0] TOP =		 4'b0100; 
const logic [3:0] RIGHT =   4'b0010; 
const logic [3:0] LEFT =	 4'b1000; 
const logic [3:0] BOTTOM =  4'b0001; 


enum  logic [2:0] {IDLE_ST,         	// initial state
						 MOVE_ST, 				// moving no colision
						 START_OF_FRAME_ST, 	// startOfFrame activity-after all data collected 
						 POSITION_CHANGE_ST, // position interpolate 
						 POSITION_LIMITS_ST  // check if inside the frame  
						}  SM_Motion ;


int Xmove;		 //Speed changes before position
int Ymove;
int Xposition ; //position   
int Yposition ;

logic [7:0] Speed;
logic [7:0] speed_levels [0:2] = '{64, 96, 128};


logic [3:0] hit_reg_1 = 4'b0;
logic [3:0] hit_reg_2 = 4'b0;


logic move_flag_up = 0;
logic move_flag_down = 0;
logic move_flag_left = 0;
logic move_flag_right = 0;
logic hit_flag_1 = 0;
logic hit_flag_2 = 0;

logic [3:0] move = 4'b0;
 //---------
 
always_ff @(posedge clk or negedge resetN)
begin : fsm_sync_proc

	if (resetN == 1'b0) begin 
		SM_Motion <= IDLE_ST; 
		Xposition <= 0; 
		Yposition <= 0;
		Xmove <= 0;
		Ymove <= 0;
		hit_reg_1 <= 4'b0;
		hit_reg_2 <= 4'b0;
		move_flag_down <= 0;
		move_flag_up <= 0;
		move_flag_left <= 0;
		move_flag_right <= 0;
		hit_flag_1 <= 0;
		hit_flag_2 <= 0;
		Speed <= Speed_default;
		move <= 0;
	end 	
	
	else begin
	
//		toggle_x_key_D <= toggle_x_key ;  //shift register to detect edge 

	
		case(SM_Motion)
		
		//------------
			IDLE_ST: begin
		//------------
		
				Xposition <= INITIAL_X*FIXED_POINT_MULTIPLIER; 
				Yposition <= INITIAL_Y*FIXED_POINT_MULTIPLIER; 

				if (game_on) 
					SM_Motion <= MOVE_ST ;
 	
			end
	
		//------------
			MOVE_ST:  begin     // moving collecting colisions 
		//------------
		
				
		
		// keys direction change 
				if (up_direction_key && move_flag_up == 0) begin
					move <= TOP;
					Ymove <= - Speed;
					move_flag_up <= 1;
					end
					
				if (down_direction_key && move_flag_down == 0) begin
					move <= BOTTOM;
					Ymove <= Speed;
					move_flag_down <= 1;
					end
					
				if (left_direction_key && move_flag_left == 0) begin
					move <= LEFT;
					Xmove <= - Speed;
					move_flag_left <= 1;
					end
					
				if (right_direction_key && move_flag_right == 0) begin
					move <= RIGHT;
					Xmove <= Speed;
					move_flag_right <= 1;
					end
					
				
	
       // collcting collisions 	
				if (column_collision && hit_flag_1 == 0) begin
					hit_reg_1 <= HitEdgeCode;
					hit_flag_1 <= 1;
				end
				
				if (column_collision && hit_flag_1 && !hit_flag_2 && HitEdgeCode != hit_reg_1) begin
					hit_reg_2 <= HitEdgeCode;
					hit_flag_2 <= 1;
				end

				if (startOfFrame) begin
					move_flag_down <= 0;
					move_flag_up <= 0;
					move_flag_left <= 0;
					move_flag_right <= 0;
					SM_Motion <= START_OF_FRAME_ST ; 
				end
						
		end 
		
		
		//------------
			START_OF_FRAME_ST:  begin      //check if any colisin was detected 
		//------------

				case (hit_reg_1[3:0])  // test sides
				
					TOP + LEFT: 	// collision with top left corner
					begin
						Xposition[10:0] <= 11'b01111000000;
						Yposition[10:0] <= 11'b10000000000;
					end
					TOP + RIGHT:	// collision with top right corner
					begin
						Xposition[10:0] <= 11'b01111000000;
						Yposition[10:0] <= 11'b10000000000;
					end
					BOTTOM + LEFT: // collision with bottom left corner
					begin
						Xposition[10:0] <= 11'b01111000000;
						Yposition[10:0] <= 11'b10000000000;
					end
					BOTTOM + LEFT: // collision with bottom left corner
					begin
						Xposition[10:0] <= 11'b01111000000;
						Yposition[10:0] <= 11'b10000000000;
					end
	
					TOP:  			// collision with top side
					begin
						Yposition[10:0] <= 11'b10000000000;
					end
					BOTTOM: 			// collision with bottom side
					begin
						Yposition[10:0] <= 11'b10000000000;
					end
					RIGHT:   		// collision with right side
					begin
						Xposition[10:0] <= 11'b01111000000;
					end
					LEFT:				// collision with left side
					begin
						Xposition[10:0] <= 11'b01111000000;
					end
					
					default: ; 
	
			  endcase
			  
			  case (hit_reg_2[3:0])  // test sides
				
					TOP + LEFT: 	// collision with top left corner
					begin
						Xposition[10:0] <= 11'b01111000000;
						Yposition[10:0] <= 11'b10000000000;
					end
					TOP + RIGHT:	// collision with top right corner
					begin
						Xposition[10:0] <= 11'b01111000000;
						Yposition[10:0] <= 11'b10000000000;
					end
					BOTTOM + LEFT: // collision with bottom left corner
					begin
						Xposition[10:0] <= 11'b01111000000;
						Yposition[10:0] <= 11'b10000000000;
					end
					BOTTOM + LEFT: // collision with bottom left corner
					begin
						Xposition[10:0] <= 11'b01111000000;
						Yposition[10:0] <= 11'b10000000000;
					end
	
					TOP:  			// collision with top side
					begin
						Yposition[10:0] <= 11'b10000000000;
					end
					BOTTOM: 			// collision with bottom side
					begin
						Yposition[10:0] <= 11'b10000000000;
					end
					RIGHT:   		// collision with right side
					begin
						Xposition[10:0] <= 11'b01111000000;
					end
					LEFT:				// collision with left side
					begin
						Xposition[10:0] <= 11'b01111000000;
					end
					
					default: ; 
	
			  endcase
			  
			hit_reg_1 <= 4'b0;
			hit_flag_1 <= 0;
			hit_reg_2 <= 4'b0;
			hit_flag_2 <= 0;
			SM_Motion <= POSITION_CHANGE_ST ; 
		end 

		//------------------------
			POSITION_CHANGE_ST : begin  // position interpolate 
		//------------------------
				Xposition <= Xposition + Xmove; 
				Yposition <= Yposition + Ymove;
				Xmove <= 0;
				Ymove <= 0;

				Speed <= speed_levels[speed_level];
				
				SM_Motion <= POSITION_LIMITS_ST ; 
			end
		
		//------------------------
			POSITION_LIMITS_ST : begin  //check if still inside the frame 
		//------------------------
		if (Xposition < x_FRAME_LEFT) 
						Xposition <= x_FRAME_LEFT ; 
		if (Xposition > x_FRAME_RIGHT)
						Xposition <= x_FRAME_RIGHT ; 
		if (Yposition < y_FRAME_TOP) 
						Yposition <= y_FRAME_TOP ; 
		if (Yposition > y_FRAME_BOTTOM) 
						Yposition <= y_FRAME_BOTTOM ; 
				
					if (!game_on)
						SM_Motion <= IDLE_ST;
					else
						SM_Motion <= MOVE_ST; 
			
			end
		
		endcase  // case 

		
	end 

end // end fsm_sync


//return from FIXED point trunc back to prame size parameters 
  
assign topLeftX = Xposition / FIXED_POINT_MULTIPLIER ;   // note it must be 2^n 
assign topLeftY = Yposition / FIXED_POINT_MULTIPLIER ; 

	
endmodule	
//---------------
 
