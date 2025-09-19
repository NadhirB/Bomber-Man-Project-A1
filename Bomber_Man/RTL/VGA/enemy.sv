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
					input	 logic random,   // if 1, then enemy moves vertically, otherwise moves horizonatally      
					input  logic collision,         //collision if enemy hits an object
					input  logic [3:0] HitEdgeCode, 
					output logic signed 	[10:0] topLeftX, // output the top left corner 
					output logic signed	[10:0] topLeftY  // can be negative , if the object is partliy outside 
					
);


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
 //---------
 
always_ff @(posedge clk or negedge resetN)
begin : fsm_sync_proc

	if (resetN == 1'b0) begin 
		SM_Motion <= IDLE_ST ; 
		Xspeed <= Speed_default   ; 
		Yspeed <= 0  ; 
		Xposition <= 0  ; 
		Yposition <= 0   ; 
		hit_reg <= 4'b0 ;	
	
	end 	
	
	else begin

	
		case(SM_Motion)
		
		//------------
			IDLE_ST: begin
		//------------
				move <= BOTTOM;
//				Xspeed  <= Speed_default ; 
//				Yspeed  <= Speed_default ; 
				Xposition <= INITIAL_X*FIXED_POINT_MULTIPLIER; 
				Yposition <= INITIAL_Y*FIXED_POINT_MULTIPLIER; 

				if (startOfFrame) 
					SM_Motion <= MOVE_ST ;
 	
			end
	
		//------------
			MOVE_ST:  begin     // moving collecting colisions 
		//------------
				
				if (move == TOP) begin
					Xspeed <= 0;
					Yspeed <= - Speed_default;
				end
				
				if (move == BOTTOM) begin
					Xspeed <= 0;
					Yspeed <= Speed_default;
				end
				
				if (move == LEFT) begin
					Xspeed <= - Speed_default;
					Yspeed <= 0;
				end
				
				if (move == RIGHT) begin
					Xspeed <= Speed_default;
					Yspeed <= 0;
				end
					
				
				
       // collcting collisions 	
				if (collision) begin
					hit_reg <= HitEdgeCode;
				end
				
				if (startOfFrame )
					SM_Motion <= START_OF_FRAME_ST;
		end 
		
		//------------
			START_OF_FRAME_ST:  begin      //check if any colisin was detected 
		//------------
 
				case (hit_reg[3:0])  // test sides 
	
					RIGHT: 
					begin
						move <= LEFT;
					end
					
					LEFT: 
					begin
						move <= RIGHT;
					end
					
					TOP: 
					begin
						move <= BOTTOM;
					end
					
					BOTTOM: 
					begin
						move <= TOP;
					end
	
					LEFT, RIGHT :
					begin
// by Yoav					
//						if (Xspeed != 0) begin
//							if (random) begin
//								Xspeed <= 0;
//								Yspeed <= Speed_default;
//							end else
//								Xspeed <= !Xspeed;
//						end
//end							if (random)
//								Xspeed <= 0-Xspeed ;
//							 else if (!Yspeed) begin
//								Yspeed <= Speed_default;
//								Xspeed <= 0;
//							 end
					end
	
					TOP, BOTTOM : 
					begin
					
// 					if (Yspeed) begin
//							if (!random) begin
//								Yspeed <= 0;
//								Xspeed <= Speed_default;
//							end else
//								Yspeed <= 0-Yspeed;
//						end
					end
					
					default: ; 
	
			  endcase 
	
			hit_reg <= 5'b00000;						
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
						Xposition <= x_FRAME_LEFT ;
						if (Xspeed) begin
							if (random) begin
								Xspeed <= 0;
								Yspeed <= Speed_default;
							end else
								move <= RIGHT;
						end
			end
		if (Xposition > x_FRAME_RIGHT) begin
						Xposition <= x_FRAME_RIGHT ; 
						if (Xspeed) begin
							if (random) begin
								Xspeed <= 0;
								Yspeed <= Speed_default;
							end else
								move <= LEFT;
						end
			end
		if (Yposition < y_FRAME_TOP) begin
						Yposition <= y_FRAME_TOP ; 
						if (Yspeed) begin
							if (!random) begin
								Yspeed <= 0;
								Xspeed <= Speed_default;
							end else
								move <= BOTTOM;
						end
			end
		if (Yposition > y_FRAME_BOTTOM) begin
						Yposition <= y_FRAME_BOTTOM ; 
						if (Yspeed) begin
							if (!random) begin
								Yspeed <= 0;
								Xspeed <= Speed_default;
							end else
								move <= TOP;
						end
			end

				SM_Motion <= MOVE_ST ; 
			
			end
		
		endcase  // case 

		
	end 

end // end fsm_sync


//return from FIXED point trunc back to prame size parameters 
  
assign 	topLeftX = Xposition / FIXED_POINT_MULTIPLIER ;   // note it must be 2^n 
assign 	topLeftY = Yposition / FIXED_POINT_MULTIPLIER ;    
	

endmodule	
//---------------
 
