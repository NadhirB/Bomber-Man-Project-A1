// (c) Technion IIT, Department of Electrical Engineering 2025 
//-- Alex Grinshpun Apr 2017
//-- Dudy Nov 13 2017
// SystemVerilog version Alex Grinshpun May 2018
// coding convention dudy December 2018
// updated Eyal Lev April 2023
// updated to state machine Dudy March 2023 
// update the hit and collision algoritm - Eyal MAR 2024
// good practice code - Dudy MAR 2025

module	enemy	(	
 
					input	 logic clk,
					input	 logic resetN,
					input	 logic startOfFrame,      //short pulse every start of frame 30Hz 
					input	 logic [2:0] random_num,   // if 1 enemy moves down, 2 enemy moves up, 3 enemy moves left, 4 enemy moves right
					input  logic collision,         //collision if enemy hits an object
					input  logic game_on,
					input  logic [3:0] HitEdgeCode,
					input  logic valid_enemy_pos,
					
					
					output logic signed 	[10:0] topLeftX, // output the top left corner 
					output logic signed	[10:0] topLeftY,  // can be negative , if the object is partliy outside
					
					output logic [3:0] direction
					
);


parameter int INITIAL_X = 15;
parameter int INITIAL_Y = 48;
parameter int Speed_default = 64;
parameter logic [3:0] default_start_dir = 4'b0001; //the direction the enemy moves at the start of the game should be like the const logic


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

//edges 
	//------------
	//			 434
	//			 1x2
	//			 404
	//
 
const logic [3:0] TOP =		 4'b0100; 
const logic [3:0] RIGHT =   4'b0010; 
const logic [3:0] LEFT =	 4'b1000; 
const logic [3:0] BOTTOM =  4'b0001; 


enum  logic [2:0] {IDLE_ST,         	// initial state
						 MOVE_ST, 				// moving no colision 
						 START_OF_FRAME_ST, 	          // startOfFrame activity-after all data collected 
						 POSITION_CHANGE_ST, // position interpolate 
						 POSITION_LIMITS_ST  // check if inside the frame  
						}  SM_Motion ;

int Xspeed  ; // speed    
int Yspeed  ; 
int Xposition ; //position   
int Yposition ;
 

logic [3:0] hit_reg = 4'b0;
logic [3:0] move = 4'b0;
logic hit_flag = 0;
 //---------
 
always_ff @(posedge clk or negedge resetN)
begin : fsm_sync_proc

	if (resetN == 1'b0) begin 
		SM_Motion <= IDLE_ST ; 
		Xspeed <= Speed_default   ; 
		Yspeed <= 0  ; 
		Xposition <= 0  ; 
		Yposition <= 0  ; 
		hit_reg <= 4'b0 ;
		move <= default_start_dir;
	end 	
	
	else begin

	
		case(SM_Motion)
		
		//------------
			IDLE_ST: begin
		//------------
				move <= default_start_dir;
				Xposition <= INITIAL_X*FIXED_POINT_MULTIPLIER; 
				Yposition <= INITIAL_Y*FIXED_POINT_MULTIPLIER; 

				if (game_on) 
					SM_Motion <= MOVE_ST ;
 	
			end
	
		//------------
			MOVE_ST:  begin     // moving collecting colisions 
		//------------
				
				if (move == TOP) begin
					Xspeed <= 0;
					Xposition[10:0] <= 11'b01111000000;
					Yspeed <= - Speed_default;
				end
				
				if (move == BOTTOM) begin
					Xspeed <= 0;
					Xposition[10:0] <= 11'b01111000000;
					Yspeed <= Speed_default;
				end
				
				if (move == LEFT) begin
					Xspeed <= - Speed_default;
					Yspeed <= 0;
					Yposition[10:0] <= 11'b10000000000;

				end
				
				if (move == RIGHT) begin
					Xspeed <= Speed_default;
					Yspeed <= 0;
					Yposition[10:0] <= 11'b10000000000;
				end
					
				
				
       // collcting collisions 	
				if (collision && hit_flag == 0) begin
					hit_reg <= HitEdgeCode;
					hit_flag <= 1;
				end
				
				
				
				if (startOfFrame) begin
					SM_Motion <= START_OF_FRAME_ST ; 
				end
		end
		
	
		//------------
			START_OF_FRAME_ST:  begin      //check if any colisin was detected 
		//------------
 
				case (hit_reg[3:0])  // test sides 
	
					RIGHT: 
					begin
						Xposition <= Xposition - Speed_default;
						case (random_num[2:0])
							3'b001 : move <= BOTTOM;
							3'b010 : move <= TOP;
							3'b011 : move <= LEFT;
							3'b100 : move <= LEFT;
						endcase
					end
					
					LEFT: 
					begin
						Xposition <= Xposition + Speed_default;
						case (random_num[2:0])
							3'b001 : move <= BOTTOM;
							3'b010 : move <= TOP;
							3'b011 : move <= RIGHT;
							3'b111 : move <= RIGHT;
						endcase
					end
					
					TOP: 
					begin
						Yposition <= Yposition + Speed_default;
						case (random_num[2:0])
							3'b001 : move <= BOTTOM;
							3'b010 : move <= BOTTOM;
							3'b011 : move <= LEFT;
							3'b111 : move <= RIGHT;
						endcase
					end
					
					BOTTOM: 
					begin
						Yposition <= Yposition - Speed_default;
						case (random_num[2:0])
							3'b001 : move <= TOP;
							3'b010 : move <= TOP;
							3'b011 : move <= LEFT;
							3'b111 : move <= RIGHT;
						endcase
					end
					
					default: ; 
	
			  endcase 
	
			hit_reg <= 4'b0;
			hit_flag <= 0;
			SM_Motion <= POSITION_CHANGE_ST ; 
		end 

		//------------------------
			POSITION_CHANGE_ST : begin  // position interpolate 
		//------------------------
	
				Xposition <= Xposition + Xspeed ; 
				Yposition <= Yposition + Yspeed ;				
				SM_Motion <= POSITION_LIMITS_ST ; 
			end
		
		//------------------------
			POSITION_LIMITS_ST : begin  //check if still inside the frame 
		//------------------------
		if (Xposition < x_FRAME_LEFT) begin
						Xposition <= x_FRAME_LEFT;
						move <= RIGHT;
						case (random_num[2:0])
							3'b001 : move <= BOTTOM;
							3'b010 : move <= TOP;
							3'b011 : move <= RIGHT;
							3'b111 : move <= RIGHT;
						endcase
			end
		if (Xposition > x_FRAME_RIGHT) begin
						Xposition <= x_FRAME_RIGHT;
						move <= LEFT;
						case (random_num[2:0])
							3'b001 : move <= BOTTOM;
							3'b010 : move <= TOP;
							3'b011 : move <= LEFT;
							3'b111 : move <= LEFT;
						endcase
			end
		if (Yposition < y_FRAME_TOP) begin
						Yposition <= y_FRAME_TOP;
						move <= BOTTOM;
						case (random_num[2:0])
							3'b001 : move <= BOTTOM;
							3'b010 : move <= BOTTOM;
							3'b011 : move <= LEFT;
							3'b111 : move <= RIGHT;
						endcase
						
			end
		if (Yposition > y_FRAME_BOTTOM) begin
						Yposition <= y_FRAME_BOTTOM;
						move <= TOP;	
						case (random_num[2:0])
							3'b001 : move <= TOP;
							3'b010 : move <= TOP;
							3'b011 : move <= LEFT;
							3'b111 : move <= RIGHT;
						endcase
						
			end

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
assign direction = move;


endmodule	
//---------------
 
