// (c) Technion IIT, Department of Electrical Engineering 2022 
// Written By Liat Schwartz August 2018 
// Updated by Mor Dahan - January 2022


module lives_logic
	(
	input logic clk, 
	input logic resetN,  
	input logic player_hit,
	input logic increase_heart,
	
	output logic heart1,
	output logic heart2,
	output logic heart3,
	output logic player_died
   );

logic [1:0] heart_counter;
	
always_ff @(posedge clk or negedge resetN)
   begin
	   
   if ( !resetN ) begin // Asynchronic reset
	
		heart_counter <= 2'b11;
		heart1 <= 1'b1;
		heart2 <= 1'b1;
		heart3 <= 1'b1;
		player_died <= 1'b0;

		end else if (!player_hit) begin case(heart_counter)
		
			2'b11:	begin
						heart3 <= 1'b0;
						heart_counter <= 32'd2;
						end
			2'b10:	begin
						heart2 <= 1'b0;
						heart_counter <= 32'd1;
						end
			2'b01:	begin
						heart3 <= 1'b0;
						heart_counter <= 32'd0;
						player_died <= 1'b1;
						end
			default: ;
		
		endcase
		
		if (!increase_heart) begin case (heart_counter)
		
			2'b11:	begin
						heart_counter <= 32'd3;
						end
			2'b10:	begin
						heart3 <= 1'b1;
						heart_counter <= 32'd3;
						end
			2'b01:	begin
						heart2 <= 1'b1;
						heart_counter <= 32'd2;
						end
			default: ;
		
		endcase
		
		end
		
		end
		
	end		

endmodule
