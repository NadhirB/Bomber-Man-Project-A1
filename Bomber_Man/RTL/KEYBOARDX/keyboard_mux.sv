
// (c) Technion IIT, Department of Electrical Engineering 2025 


module	keyboard_mux	(	

					input	logic	clk,
					input	logic	resetN,
					input logic KeyIsPressed[9:0],
					input logic plusKey,
					input logic backKey,
					input logic delKey,
					input logic numKey,
					input logic slashKey,
					input logic starKey,
					input logic mode_sel,
					
					output logic player1_drop_bomb_key,
					output logic player1_up_key,
					output logic player1_down_key,
					output logic player1_left_key,
					output logic player1_right_key,

					output logic player2_drop_bomb_key,
					output logic player2_up_key,
					output logic player2_down_key,
					output logic player2_left_key,
					output logic player2_right_key

					
			
);

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
	
		player1_drop_bomb_key <= 0;
		player1_up_key <= 0;
		player1_down_key <= 0;
		player1_left_key <= 0;
		player1_right_key <= 0;
		player2_drop_bomb_key <= 0;
		player2_up_key <= 0;
		player2_down_key <= 0;
		player2_left_key <= 0;
		player2_right_key <= 0;
		
	end
	
	else if (!mode_sel) begin
	
		player1_drop_bomb_key <= plusKey;
		player1_up_key <= KeyIsPressed[8];
		player1_down_key <= KeyIsPressed[5];
		player1_left_key <= KeyIsPressed[4];
		player1_right_key <= KeyIsPressed[6];
		player2_drop_bomb_key <= 0;
		player2_up_key <= 0;
		player2_down_key <= 0;
		player2_left_key <= 0;
		player2_right_key <= 0;

	end 
	
	else begin
	
		player1_drop_bomb_key <= KeyIsPressed[1];
		player1_up_key <= KeyIsPressed[2];
		player1_down_key <= backKey;
		player1_left_key <= KeyIsPressed[0];
		player1_right_key <= delKey;
		player2_drop_bomb_key <= KeyIsPressed[9];
		player2_up_key <= KeyIsPressed[8];
		player2_down_key <= slashKey;
		player2_left_key <= starKey;
		player2_right_key <= numKey;
	
	end
	
end

endmodule


