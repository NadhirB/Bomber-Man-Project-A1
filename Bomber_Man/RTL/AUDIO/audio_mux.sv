

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
	
	output logic startMelodyKey,
	output logic [3:0] melody_select
	
);

//----------------------------------------------------------
// FSM states
//----------------------------------------------------------
enum logic [1:0] {s_idle, s_play} SM_playNotes;

//----------------------------------------------------------
// Internal registers
//----------------------------------------------------------
logic game_lost_d;           // delayed version of game_lost
logic game_lost_rise;        // rising-edge detection

//----------------------------------------------------------
// Rising edge detection
//----------------------------------------------------------
always_ff @(posedge clk or negedge resetN) begin
	if (!resetN) begin
		game_lost_d <= 1'b0;
	end else begin
		game_lost_d <= game_lost;
	end
end

assign game_lost_rise = game_lost & ~game_lost_d;   // 1-cycle pulse on rising edge

//----------------------------------------------------------
// Main FSM
//----------------------------------------------------------
always_ff @(posedge clk or negedge resetN) begin
	if(!resetN) begin
		SM_playNotes   <= s_idle;
		melody_select  <= 4'd0;
		startMelodyKey <= 1'b0;
	end 
	else begin
		case (SM_playNotes)

			//=================================================
			s_idle: begin
				startMelodyKey <= 1'b0;
			
				if (jewl_powerUp) begin
					SM_playNotes   <= s_play;
					melody_select  <= 4'd14;
					startMelodyKey <= 1'b1;
				end
				
				else if (live_powerUp || bomb_powerUp || clock_powerUp || speed_powerUp) begin
					SM_playNotes   <= s_play;
					melody_select  <= 4'd13;
					startMelodyKey <= 1'b1;
				end
				
				else if (player_objective) begin
					SM_playNotes   <= s_play;
					melody_select  <= 4'd15;
					startMelodyKey <= 1'b1;
				end
						
				else if (player_hit) begin
					SM_playNotes   <= s_play;
					melody_select  <= 4'd11;
					startMelodyKey <= 1'b1;
				end
				
				else if (game_lost_rise) begin   // <== use only rising edge
					SM_playNotes   <= s_play;
					melody_select  <= 4'd12;
					startMelodyKey <= 1'b1;
				end
			end

			//=================================================
			s_play: begin
				startMelodyKey <= 1'b0;

				if (melodyEnded)
					SM_playNotes <= s_idle;
			end
		endcase
	end
end

endmodule
