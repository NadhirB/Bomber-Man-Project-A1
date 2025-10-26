// game controller dudy Febriary 2020
// (c) Technion IIT, Department of Electrical Engineering 2021 
//updated --Eyal Lev 2021


module	game_controller	(	
			input	logic	clk,
			input	logic	resetN,
			input	logic	startOfFrame,  // short pulse every start of frame 30Hz 
			input	logic	drawing_request_player,
			input	logic	drawing_request_player2,
			input	logic	drawing_request_columns,
			input logic drawing_request_wall,
			input	logic	drawing_request_blast,
			input	logic	drawing_request_blast2,
			input logic drawing_request_enemy1,
			input logic drawing_request_enemy2,
			input logic drawing_request_enemy3,
			input logic drawing_request_bomb,
			input logic drawing_request_bomb2,
			input logic drawing_request_doorIdol,
			input logic drawing_request_powerUp,
			input logic player_invulnerable,
			input logic player2_invulnerable,
			input logic drawing_request_spikes,

			output logic player_culomn_wall, // active in case of collision player and columns
			output logic player2_culomn_wall,
			output logic enemy1_column_wall_bomb,
			output logic enemy2_column_wall_bomb,
			output logic enemy3_column_wall_bomb,
			output logic SingleHitPulse_enemies, // critical code, generating A single pulse in a frame 
			output logic collision_blast_wall, // active in case of collision between blast and wall
			output logic player_door_idol,
			output logic collision_player_powerUp,
			output logic player_hit,
			output logic collision_player2_powerUp,
			output logic player2_hit,
			output logic enemy1_kill,
			output logic enemy2_kill,
			output logic enemy3_kill
			

);

// Collisions during the game, based on condition and no need to diffrentiate on how many hits per farme.
assign player_culomn_wall = (drawing_request_player && (drawing_request_columns || drawing_request_wall || drawing_request_bomb2));// any collision --> comment after updating with #4 or #5 
assign player2_culomn_wall = (drawing_request_player2 && (drawing_request_columns || drawing_request_wall || drawing_request_bomb));

//enemy collision
assign enemy1_column_wall_bomb = (drawing_request_enemy1 && (drawing_request_columns || drawing_request_wall || drawing_request_bomb || drawing_request_bomb2));
assign enemy2_column_wall_bomb = (drawing_request_enemy2 && (drawing_request_columns || drawing_request_wall || drawing_request_bomb || drawing_request_bomb2));
assign enemy3_column_wall_bomb = (drawing_request_enemy3 && (drawing_request_columns || drawing_request_wall || drawing_request_bomb || drawing_request_bomb2));


assign collision_blast_wall = ((drawing_request_blast || drawing_request_blast2) && drawing_request_wall && !drawing_request_columns);
assign player_door_idol = (drawing_request_doorIdol && drawing_request_player && !drawing_request_wall);

//player and powerup collisions
assign collision_player_powerUp = (drawing_request_player && drawing_request_powerUp && !drawing_request_wall);
assign collision_player2_powerUp = (drawing_request_player2 && drawing_request_powerUp && !drawing_request_wall);

//player hits
assign player_hit = (drawing_request_player && (drawing_request_blast || drawing_request_blast2 || drawing_request_enemy1 || drawing_request_enemy2 || drawing_request_enemy3 || drawing_request_spikes) && !player_invulnerable);
assign player2_hit = (drawing_request_player2 && (drawing_request_blast || drawing_request_blast2 || drawing_request_enemy1 || drawing_request_enemy2 || drawing_request_enemy3 ||  drawing_request_spikes) && !player2_invulnerable);

//enemy kill.
assign enemy1_kill = ((drawing_request_blast || drawing_request_blast2) && drawing_request_enemy1);
assign enemy2_kill = ((drawing_request_blast || drawing_request_blast2) && drawing_request_enemy2);
assign enemy3_kill = ((drawing_request_blast || drawing_request_blast2) && drawing_request_enemy3);


logic flag ; // a semaphore to set the output only once per frame regardless of number of collisions 
logic collision_enemy_column;


always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN)
	begin 
		flag	<= 1'b0;
		SingleHitPulse_enemies <= 1'b0;
	end 
	else begin 
	
		SingleHitPulse_enemies <= 1'b0 ; // default
		collision_enemy_column <= 1'b0;
		
		//if collision detected on frame 
		if ((drawing_request_enemy1 || drawing_request_enemy2 || drawing_request_enemy3) && (drawing_request_columns || drawing_request_wall || drawing_request_bomb || drawing_request_bomb2))
			collision_enemy_column <= 1'b1;
		
		if(startOfFrame) 
				flag <= 1'b0 ; // reset for next time 
				
if ( collision_enemy_column && (flag == 1'b0)) begin 
			flag	<= 1'b1; // to enter only once 
			SingleHitPulse_enemies <= 1'b1 ; 
		end ; 
 
	end 
end

endmodule
