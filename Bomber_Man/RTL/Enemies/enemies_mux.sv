

module enemies_mux (	
	
	input	logic	clk,
	input	logic	resetN,
	input logic game_on,
	
	//Enemy 1
	input	logic	enemy1DR,
	input	logic	[7:0] enemy1RGB, 
	input logic enemy1_kill,
	//Enemy 2
	input	logic	enemy2DR,
	input	logic	[7:0] enemy2RGB,
	input logic enemy2_kill,
	//Enemy 2
	input	logic	enemy3DR,
	input	logic	[7:0] enemy3RGB,
	input logic enemy3_kill,
	//Outputs
	output logic enemiesDR,
	output logic [7:0] enemiesRGB,
	output logic [2:0] enemiesDR_BUS
);

logic draw_enemy1;
logic draw_enemy2;
logic draw_enemy3;

logic flag;


// synchronic logic for enemy killikng and enabeling.
always_ff @(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		draw_enemy1 <= 1;
		draw_enemy2 <= 1;
		draw_enemy3 <= 1;
		flag <= 1;
	end

	else begin
		// resets on the start of every level
		if (game_on && flag) begin 
			draw_enemy1 <= 1;
			draw_enemy2 <= 1;
			draw_enemy3 <= 1;
			flag <= 0;
		end
		
		if (!game_on)
			flag <= 1;
		
		if (enemy1_kill)
			draw_enemy1 <= 0;
		
		if (enemy2_kill)
			draw_enemy2 <= 0;
		
		if (enemy3_kill)
			draw_enemy3 <= 0;
	end
		
end


//combinatorical logic for RGB and DR
always_comb
begin
	if(!resetN) begin
		enemiesRGB	= 8'b0;
		enemiesDR_BUS = 3'b0;
	end
	
	else begin
		
		if (enemy1DR * draw_enemy1) begin
			enemiesRGB = enemy1RGB;
			enemiesDR_BUS = 3'b001;
		end
		else if (enemy2DR * draw_enemy2) begin  
			enemiesRGB = enemy2RGB;
			enemiesDR_BUS = 3'b010;
		end
		else if (enemy3DR * draw_enemy3) begin  
			enemiesRGB = enemy3RGB;
			enemiesDR_BUS = 3'b100;
		end
		else begin
			enemiesRGB = 8'b0;
			enemiesDR_BUS = 3'b0;
		end
	end
end
	
assign enemiesDR = enemy1DR * draw_enemy1 || enemy2DR * draw_enemy2 || enemy3DR * draw_enemy3;

endmodule


