
// (c) Technion IIT, Department of Electrical Engineering 2025 


module	game_sm	(	
 	
					input logic	clk,
					input	logic	resetN, 
					input logic enter_key_pressed,
					input logic down_key_pressed,
					input logic up_key_pressed,					
					input logic timer_ended,
					input logic player_died,
					
					input logic main_menu_DR,
					input	logic	[7:0] main_menu_RGB,
					input logic mode_selection_story_DR,
					input	logic	[7:0] mode_selection_story_RGB,
					input logic mode_selection_versus_DR,
					input	logic	[7:0] mode_selection_versus_RGB,
					input logic controls_screen_DR,
					input	logic	[7:0] controls_screen_RGB,						
					input logic game_over_time_DR,
					input	logic	[7:0] game_over_time_RGB,
					input logic game_over_lives_DR,
					input	logic	[7:0] game_over_lives_RGB,
					input logic [7:0] RGB_MIF,
			     
					output logic [7:0] RGBOut,
					output logic game_on
					
			
);

enum  logic [3:0] {MAIN_MENU_ST,         	// initial state
						 MODE_SELECTION_STORY_ST,
						 MODE_SELECTION_VERSUS_ST,				 // moving no colision
						 CONTROLS_ST,
						 GAMEPLAY_ST,
						 GAMEOVER_TIME_ST, 	// startOfFrame activity-after all data collected 
						 GAMEOVER_LIVES_ST // position interpolate  
						}  SM_Game;
						
						
logic flag;
logic timer_flag;

always_ff@(posedge clk or negedge resetN)
begin: fsm_sync_proc

	if(!resetN) begin
		SM_Game <= MAIN_MENU_ST;
		RGBOut <= 8'b0;
		game_on <= 1'b0;
		flag <= 1'b0;
		timer_flag <= 1'b0;
	end
	
	else begin
		case (SM_Game)
		
		//---------
		MAIN_MENU_ST: begin
		//---------
				if (main_menu_DR)
					RGBOut <= main_menu_RGB;
				else RGBOut <= RGB_MIF;
				
				if (!enter_key_pressed)
					flag <= 1'b0;
					
				else if (enter_key_pressed && !flag) begin
					SM_Game <= MODE_SELECTION_STORY_ST;
					flag <= 1'b1;
				end

			end
			
		//---------
		MODE_SELECTION_STORY_ST: begin
		//---------
				if (mode_selection_story_DR)
					RGBOut <= mode_selection_story_RGB;
				else RGBOut <= RGB_MIF;
				
				if (!enter_key_pressed)
					flag <= 1'b0;
					
				else if (enter_key_pressed && !flag) begin
					SM_Game <= CONTROLS_ST;
					flag <= 1'b1;
				end
				
				if (down_key_pressed)
					SM_Game <= MODE_SELECTION_VERSUS_ST;
				
			end

		//---------
		MODE_SELECTION_VERSUS_ST: begin
		//---------
				if (mode_selection_versus_DR)
					RGBOut <= mode_selection_versus_RGB;
				else RGBOut <= RGB_MIF;
				
				if (!enter_key_pressed)
					flag <= 1'b0;
					
//				else if (enter_key_pressed && !flag) begin
//					SM_Game <= CONTROLS_ST;
//					flag <= 1'b1;
//				end
				
				if (up_key_pressed)
					SM_Game <= MODE_SELECTION_STORY_ST;
				
			end
			
		//---------
		CONTROLS_ST: begin
		//---------
				if (controls_screen_DR)
					RGBOut <= controls_screen_RGB;
				else RGBOut <= RGB_MIF;
				
				if (!enter_key_pressed)
					flag <= 1'b0;
					
				else if (enter_key_pressed && !flag) begin
					SM_Game <= GAMEPLAY_ST;
					game_on <= 1'b1;
					flag <= 1'b1;
				end
				
			end

		//---------
		GAMEPLAY_ST: begin
		//---------
				if (player_died) begin
					SM_Game <= GAMEOVER_LIVES_ST;
					game_on <= 1'b0;
				end	
					
				else if (timer_ended && !timer_flag) begin
					SM_Game <= GAMEOVER_TIME_ST;	
					game_on <= 1'b0;	
					timer_flag <= 1'b1;
				end
			end
			
		//---------
		GAMEOVER_TIME_ST: begin
		//---------
				if (game_over_time_DR)
					RGBOut <= game_over_time_RGB;
				else RGBOut <= RGB_MIF;
				if (enter_key_pressed) begin
					SM_Game <= MAIN_MENU_ST;
					flag <= 1'b1;
					timer_flag <= 1'b0;
				end
				
			end			

		//---------
		GAMEOVER_LIVES_ST: begin
		//---------
				if (game_over_lives_DR)
					RGBOut <= game_over_lives_RGB;
				else RGBOut <= RGB_MIF;
				if (enter_key_pressed) begin
					SM_Game <= MAIN_MENU_ST;
					flag <= 1'b1;
				end
				
			end	
		endcase
	
	end 
end

endmodule


