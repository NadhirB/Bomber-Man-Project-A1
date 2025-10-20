
// (c) Technion IIT, Department of Electrical Engineering 2025 


module	game_sm	(	
 	
					input logic	clk,
					input	logic	resetN, 
					input logic enter_key_pressed,
					input logic down_key_pressed,
					input logic up_key_pressed,					
					input logic timer_ended,
					input logic player_died,
					input logic one_sec_pulse,
					input logic next_level,
					input logic game_won,
					
					input logic main_menu_DR,
					input	logic	[7:0] main_menu_RGB,
					input logic mode_selection_DR,
					input	logic	[7:0] mode_selection_RGB,
					input logic controls_screen_DR,
					input	logic	[7:0] controls_screen_RGB,
					input logic game_over_DR,
					input	logic	[7:0] game_over_RGB,					
					input logic game_won_DR,
					input	logic	[7:0] game_won_RGB,
					input logic level_DR,
					input	logic	[7:0] level_RGB,
					input logic game_over_2player_DR,
					input logic [7:0] game_over_2player_RGB,
					input logic [7:0] RGB_MIF,
			     
					output logic [7:0] RGBOut,
					output logic game_on,
					output logic mode_sel,
					output logic game_over_type,
					output logic [1:0] level_sel,
					output logic score_reset,
					output logic lives_reset,
					output logic play_menu_music
					
			
);

enum  logic [3:0] {MAIN_MENU_ST,         	// initial state
						 MODE_SELECTION,				 // moving no colision
						 CONTROLS_ST,
						 GAMEPLAY_ST,
						 GAMEOVER_ST,
						 GAMEOVER_TIME_ST, 	// startOfFrame activity-after all data collected 
						 GAMEOVER_LIVES_ST,
						 GAMEOVER_2PLAYER_ST, // position interpolate  
						 LEVEL_DSP_ST,
						 GAME_WON_ST
						}  SM_Game;
						
						
logic flag;
logic timer_flag;
logic [0:1] three_sec_counter;

always_ff@(posedge clk or negedge resetN)
begin: fsm_sync_proc

	if(!resetN) begin
		SM_Game <= MAIN_MENU_ST;
		RGBOut <= 8'b0;
		game_on <= 0;
		flag <= 1'b0;
		timer_flag <= 1'b0;
		mode_sel <= 0;
		three_sec_counter <= 2'b10;
		game_over_type <= 0;
		level_sel <= 1;
		score_reset <= 0;
		lives_reset <= 0;
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
					SM_Game <= MODE_SELECTION;
					flag <= 1'b1;
					score_reset <= 1;
					lives_reset <= 0;
				end
				
				level_sel <= 1; // Make sure to start on level One
				mode_sel <= 0;
				

			end
			
		//---------
		MODE_SELECTION: begin
		//---------
				if (mode_selection_DR)
					RGBOut <= mode_selection_RGB;
				else RGBOut <= RGB_MIF;
				
				if (!enter_key_pressed)
					flag <= 1'b0;
					
				else if (enter_key_pressed && !flag) begin
					SM_Game <= CONTROLS_ST;
					flag <= 1'b1;
					score_reset <= 0;
				end
				
				if (down_key_pressed && !mode_sel)
					mode_sel <= 1;
				if (up_key_pressed && mode_sel)
					mode_sel <= 0;
				
			end

		//---------
		CONTROLS_ST: begin
		//---------
				if (controls_screen_DR)
					RGBOut <= controls_screen_RGB;
				else RGBOut <= RGB_MIF;
				
				if (!enter_key_pressed)
					flag <= 1'b0;
					
				else if (enter_key_pressed && !flag && !mode_sel) begin
					SM_Game <= LEVEL_DSP_ST;
					flag <= 1'b1;
				end
				
				else if (enter_key_pressed && !flag && mode_sel) begin
					SM_Game <= GAMEPLAY_ST;
					game_on <= 1;
					three_sec_counter <= 2'b10;
					
				end
				
			end
			
		//---------
		LEVEL_DSP_ST: begin
		//---------
				if (level_DR)
					RGBOut <= level_RGB;
				else RGBOut <= RGB_MIF;
				
					
				if (three_sec_counter == 2'b00) begin
					SM_Game <= GAMEPLAY_ST;
					game_on <= 1;
					three_sec_counter <= 2'b10;
				end
				
				else if (one_sec_pulse)
					three_sec_counter <= three_sec_counter - 2'b01;
				
			end

		//---------
		GAMEPLAY_ST: begin
		//---------
				if (player_died) begin
					SM_Game <= GAMEOVER_ST;
				end	
					
				else if (timer_ended && !timer_flag) begin
					SM_Game <= GAMEOVER_ST;	
					timer_flag <= 1'b1;
				end
				
				else if (next_level && level_sel == 1) begin
						level_sel <= 2;
						game_on <= 0;
						SM_Game <= LEVEL_DSP_ST;
					end
				
				else if (game_won && level_sel == 2) begin
					SM_Game <= GAME_WON_ST;
					game_on <= 0;
					end
			end
			
			
		//---------
		GAME_WON_ST: begin
		//---------
				if (game_won_DR)
					RGBOut <= game_won_RGB;
				else RGBOut <= RGB_MIF;
				if (enter_key_pressed) begin
					SM_Game <= MAIN_MENU_ST;
					flag <= 1'b1;
					three_sec_counter <= 2'b10;
					lives_reset <= 1;
				end
				
			end
		//---------
		GAMEOVER_ST: begin
		//---------
				
				if (three_sec_counter == 2'b00) begin
					if (mode_sel) begin
						SM_Game <= GAMEOVER_2PLAYER_ST;
						game_on <= 0;
					end
					
					else if (player_died) begin
						SM_Game <= GAMEOVER_LIVES_ST;
						game_over_type <= 1;
						game_on <= 0;
					end
					else begin
						SM_Game <= GAMEOVER_TIME_ST;
						game_over_type <= 0;
						game_on <= 0;
					end
				end
				
				else if (one_sec_pulse)
					three_sec_counter <= three_sec_counter - 2'b01;
				
			end			

		//---------
		GAMEOVER_TIME_ST: begin
		//---------
				if (game_over_DR)
					RGBOut <= game_over_RGB;
				else RGBOut <= RGB_MIF;
				if (enter_key_pressed) begin
					SM_Game <= MAIN_MENU_ST;
					lives_reset <= 1;
					flag <= 1'b1;
					timer_flag <= 1'b0;
					three_sec_counter <= 2'b10;
				end
				
			end			

		//---------
		GAMEOVER_LIVES_ST: begin
		//---------
				if (game_over_DR)
					RGBOut <= game_over_RGB;
				else RGBOut <= RGB_MIF;
				if (enter_key_pressed) begin
					SM_Game <= MAIN_MENU_ST;
					lives_reset <= 1;
					flag <= 1'b1;
					timer_flag <= 1'b0; ////maybe delete
					three_sec_counter <= 2'b10;
				end
				
			end
			
		//---------
		GAMEOVER_2PLAYER_ST: begin
		//---------
				if (game_over_2player_DR)
					RGBOut <= game_over_2player_RGB;
				else RGBOut <= RGB_MIF;
				if (enter_key_pressed) begin
					SM_Game <= MAIN_MENU_ST;
					lives_reset <= 1;
					flag <= 1'b1;
					timer_flag <= 1'b0;////maybe delete
					three_sec_counter <= 2'b10;
				end
		
		end
	
	
		endcase
	
	end 
end

assign play_menu_music = (SM_Game == MAIN_MENU_ST || SM_Game == MODE_SELECTION || SM_Game == CONTROLS_ST) ? 1 : 0;

endmodule


