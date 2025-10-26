module	player_hit_SM	(	
			input	logic	clk,
			input	logic	resetN,
			input	logic	player_hit,
			input logic turbo_pulse,

			output logic player_invert,
			output logic player_invulnerable

);


enum  logic [1:0] {IDLE_ST,         	// initial state
						 INVERTED_ST, 			// inverted state
						 REGULAR_ST 			// regular state
						}  SM_Player_Hit ;


logic [4:0] count;

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN)
	begin 
	count <=5'b0;
	SM_Player_Hit <= IDLE_ST;
	player_invert <= 0;
	player_invulnerable <= 0;
	end 
	else begin 
	
		case(SM_Player_Hit)
	
		//------------
			IDLE_ST: begin
		//------------
				//stay here until player gets hit 
				if (player_hit) begin
					SM_Player_Hit <= INVERTED_ST;
					player_invert <= 1;
					player_invulnerable <= 1;
					end
			end
	
		//------------
			INVERTED_ST:  begin 
		//------------
			if (turbo_pulse) begin
				SM_Player_Hit <= REGULAR_ST;
				player_invert <= 0;
				end	
			end 
		
		
		//------------
			REGULAR_ST:  begin 
		//------------
				if (count == 10) begin				//Reset after two seconds 
					SM_Player_Hit <= IDLE_ST;
					player_invert <= 0;
					player_invulnerable <= 0;
					count <= 0;
					end
				else if (turbo_pulse) begin		// Alternate between the REGULAR and INVERTED states for two seconds
					SM_Player_Hit <= INVERTED_ST;
					player_invert <= 1;
					count <= count + 1;
					end	
			end
		
		endcase
 
	end 
end

endmodule