

module enemies_mux (	
	
	input	logic	clk,
	input	logic	resetN,
	
	//Enemy 1
	input	logic	enemy1DR,
	input	logic	[7:0] enemy1RGB, 
	//Enemy 2
	input	logic	enemy2DR,
	input	logic	[7:0] enemy2RGB,  
	//Outputs
	output logic enemiesDR,
	output logic [7:0] enemiesRGB
);

always_comb
begin
	if(!resetN) begin
			enemiesRGB	= 8'b0;
	end
	
	else begin
		if (enemy1DR)
			enemiesRGB = enemy1RGB;
		else if (enemy2DR)   
			enemiesRGB = enemy2RGB;
		else
			enemiesRGB = 8'b0;
		end
	end
	
assign enemiesDR = enemy1DR || enemy2DR;

endmodule


