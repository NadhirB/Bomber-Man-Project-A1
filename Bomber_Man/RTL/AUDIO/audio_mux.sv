

module audio_mux (	
	
	input	logic	clk,
	input	logic	resetN,
	input logic speed_powerUp,
	input logic live_powerUp,
	input logic bomb_powerUp,
	input logic clock_powerUp,
	input logic jewl_powerUp,
	input logic player_objective,
	input logic player_hit,
	input logic game_lost,
	input logic melodyEnded,
	input logic game_on,
	input logic score_reset,
	input logic main_menu,
	
	output logic startMelodyKey,
	output logic [3:0] melody_select
	
);

enum logic [1:0] {s_idle, s_play, s_reset} SM_playNotes;

logic flag;

always_ff @(posedge clk or negedge resetN) begin
	if(!resetN) begin
		SM_playNotes   <= s_idle;
		melody_select  <= 4'd0;
		startMelodyKey <= 1'b0;
		flag <= 1'b1;
	end 
	else begin
		case (SM_playNotes)

			//=================================================
			s_idle: begin
				startMelodyKey <= 1'b0;
			
				if (jewl_powerUp) begin
					SM_playNotes <= s_play;
					melody_select <= 4'd14;
					startMelodyKey <= 1'b1;
				end
				
				else if (live_powerUp || bomb_powerUp || clock_powerUp || speed_powerUp) begin
					SM_playNotes <= s_play;
					melody_select <= 4'd13;
					startMelodyKey <= 1'b1;
				end
				
				else if (player_objective && game_on) begin
					SM_playNotes <= s_play;
					melody_select <= 4'd15;
					startMelodyKey <= 1'b1;
				end
						
				else if (player_hit) begin
					startMelodyKey <= 1'b1;
					SM_playNotes <= s_play;
					melody_select <= 4'd11;
				end
				
				else if (game_lost && flag) begin
					SM_playNotes <= s_play;
					melody_select <= 4'd12;
					startMelodyKey <= 1'b1;
					flag <= 1'b0;
				end
				
				else if (main_menu) begin
					SM_playNotes <= s_play;
					melody_select <= 4'd10;
					startMelodyKey <= 1'b1;
				end
				
			end

			//=================================================
			s_play: begin
				startMelodyKey <= 1'b0;
				
				if (!flag)
					SM_playNotes <= s_reset;

				if (melodyEnded)
					SM_playNotes <= s_idle;
			end
			//=================================================
			
			s_reset: begin
				if (score_reset) begin
					SM_playNotes <= s_idle;
					flag <= 1'b1;
				end
			end
			//=================================================
			
		endcase
	end
end

endmodule
