// Potentially unused module - comment by Yoav 26/10/25

module bomb_counter (	
	
	input	logic	clk,
	input	logic	resetN,
	input logic Plus_key,
	input logic blast,
	
	output logic Plus_valid,
	output logic [3:0] bombs_left
);


parameter  logic [3:0] starting_bombs = 4'b0010 ; 
logic flag;

always_ff @(posedge clk or negedge resetN) begin
		if (!resetN) begin
			Plus_valid <= 0;
			bombs_left <= starting_bombs;
			flag <= 0;
		end
	
	else begin
		if (Plus_key && bombs_left && !flag) begin
			Plus_valid <= 1;
			bombs_left <= bombs_left - 1;
			flag <= 1;
		
		end else
			Plus_valid <= 0;
			
		if (!Plus_key)
			flag <= 0;
			
		if (blast)
			bombs_left <= bombs_left + 1;

	end
end
	

endmodule


