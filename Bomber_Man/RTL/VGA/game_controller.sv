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
			input logic drawing_request_enemy1,
			input logic drawing_request_enemy2,
			input logic drawing_request_bomb,

			output logic player_culomn_wall, // active in case of collision player and columns
			output logic enemy1_column_wall_bomb,
			output logic enemy2_column_wall_bomb,
			output logic SingleHitPulse_enemies, // critical code, generating A single pulse in a frame 
			output logic collision_blast_wall, // active in case of collision between blast and wall
			output logic SingleHitPulse_player

);


assign player_culomn_wall = (drawing_request_player && (drawing_request_columns || drawing_request_wall));// any collision --> comment after updating with #4 or #5 
assign enemy1_column_wall_bomb = (drawing_request_enemy1 && (drawing_request_columns || drawing_request_wall || drawing_request_bomb));
assign enemy2_column_wall_bomb = (drawing_request_enemy2 && (drawing_request_columns || drawing_request_wall || drawing_request_bomb));

assign collision_blast_wall = (drawing_request_blast && drawing_request_wall);



logic flag ; // a semaphore to set the output only once per frame regardless of number of collisions 
logic collision_player_column; // collision between Smiley and number - is not output
logic collision_enemy_column;


always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN)
	begin 
		flag	<= 1'b0;
		SingleHitPulse_enemies <= 1'b0;
		SingleHitPulse_player <= 1'b0;	
		
	end 
	else begin 

		collision_player_column <= 1'b0; // default
		collision_enemy_column <= 1'b0;
		
		if (drawing_request_player && drawing_request_columns)
			collision_player_column <= 1'b1;
		
		if ((drawing_request_enemy1 || drawing_request_enemy2) && (drawing_request_columns || drawing_request_wall || drawing_request_bomb))
			collision_enemy_column <= 1'b1;
		
		SingleHitPulse_enemies <= 1'b0 ; // default
		SingleHitPulse_player <= 1'b0;
		if(startOfFrame) 
				flag <= 1'b0 ; // reset for next time 
				
//	---#7 - change the condition below to collision between Smiley and number ---------

//if ( collision_player_column  && (flag == 1'b0)) begin 
//			flag	<= 1'b1; // to enter only once 
//			SingleHitPulse_player <= 1'b1 ; 
//		end ; 
if ( collision_blast_wall  && (flag == 1'b0)) begin 
			flag	<= 1'b1; // to enter only once 
			SingleHitPulse_player <= 1'b1 ; 
		end ; 
 
	end 
end

endmodule
