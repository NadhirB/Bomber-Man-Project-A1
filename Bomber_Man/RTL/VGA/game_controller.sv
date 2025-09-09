// game controller dudy Febriary 2020
// (c) Technion IIT, Department of Electrical Engineering 2021 
//updated --Eyal Lev 2021


module	game_controller	(	
			input	logic	clk,
			input	logic	resetN,
			input	logic	startOfFrame,  // short pulse every start of frame 30Hz 
			input	logic	drawing_request_player,
			input	logic	drawing_request_columns,
			input logic drawing_request_wall,
			input	logic	drawing_request_blast,
			input logic drawing_request_enemy,

			output logic player_culomn, // active in case of collision player and columns
			output logic SingleHitPulse, // critical code, generating A single pulse in a frame 
			output logic collision_Smiley_Hart // active in case of collision between Smiley and hart

);

// drawing_request_smiley   -->  smiley
// drawing_request_boarders -->  brackets
// drawing_request_number   -->  number/box 

assign player_culomn = (drawing_request_player && drawing_request_columns);// any collision --> comment after updating with #4 or #5 





logic flag ; // a semaphore to set the output only once per frame regardless of number of collisions 
logic collision_player_column; // collision between Smiley and number - is not output


always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN)
	begin 
		flag	<= 1'b0;
		SingleHitPulse <= 1'b0;	
		
	end 
	else begin 

		collision_player_column <= 1'b0; // default
		if (drawing_request_player && drawing_request_columns)
			collision_player_column <= 1'b1;		
		
		SingleHitPulse <= 1'b0 ; // default 
		if(startOfFrame) 
				flag <= 1'b0 ; // reset for next time 
				
//	---#7 - change the condition below to collision between Smiley and number ---------

if ( collision_player_column  && (flag == 1'b0)) begin 
			flag	<= 1'b1; // to enter only once 
			SingleHitPulse <= 1'b1 ; 
		end ; 
 
	end 
end

endmodule

//// game controller dudy Febriary 2020
//// (c) Technion IIT, Department of Electrical Engineering 2025 
////updated --Eyal Lev 2021
//
//
//module	game_controller	(	
//			input	logic	clk,
//			input	logic	resetN,
//			input	logic	startOfFrame,  // short pulse every start of frame 30Hz 
//			input	logic	drawing_request_smiley,
//			input	logic	drawing_request_boarders,
//			input	logic	drawing_request_number,
//			input	logic	drawing_request_hart,
//       // add the box here 
//			
//			output logic collision, // active in case of collision between two objects
//			
//			output logic SingleHitPulse, // critical code, generating A single pulse in a frame 
//			output logic collision_Smiley_Hart // active in case of collision between two objects
//			
//);
//
//
//logic collision_smiley_number;
//
//assign collision = (( drawing_request_smiley && ( drawing_request_boarders || drawing_request_number )) || 
//						( drawing_request_boarders && drawing_request_number )||( drawing_request_smiley && drawing_request_hart )); 
//						
//						
//assign collision_Smiley_Hart = ( drawing_request_smiley &&  drawing_request_hart ) ;
//assign collision_smiley_number = ( drawing_request_smiley &&  drawing_request_number ); // collision of number and smiley
//
//
//// add colision between number and Smiley
////_______________________________________________________
//
//
//logic flag ; // a semaphore to set the output only once per frame / regardless of the number of collisions 
//
//
//always_ff@(posedge clk or negedge resetN)
//begin
//	if(!resetN)
//	begin 
//		flag	<= 1'b0;
//		SingleHitPulse <= 1'b0 ; 
//	end 
//	else begin 
//			SingleHitPulse <= 1'b0 ; // default 
//			if(startOfFrame) 
//				flag <= 1'b0 ; // reset for next time 
//				
////		change the section below  to collision between number and smiley
//
//
//if ( collision_smiley_number  && (flag == 1'b0)) begin 
//			flag	<= 1'b1; // to enter only once 
//			SingleHitPulse <= 1'b1 ; 
//		end ; 
//
//	end 
//end
//
//endmodule
