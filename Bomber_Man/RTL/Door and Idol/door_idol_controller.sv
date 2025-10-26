

module	door_idol_controller	(	
//		--------	Clock Input	 	
					input logic	clk,
					input	logic	resetN,
					input logic enter_is_presed,
					input logic [1:0] level_select,
					input	logic	[4:0] randum_num1,
					input	logic	[4:0] randum_num2,
			
		  // Output	   
					output logic [10:0] topLeftX,
					output logic [10:0] topLeftY,
					output logic bitMap_sel
					
			
);

// Logic to hold the numbers that were generated
logic [10:0] topLeftX_1;
logic [10:0] topLeftY_1;
logic [10:0] topLeftX_2;
logic [10:0] topLeftY_2;

logic flag;
logic random_sel;

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
			topLeftX	<= 11'b0;
			topLeftY	<= 11'b0;
			bitMap_sel <= 0;
			random_sel <= 0;
			flag <= 0;
	end
	
	else begin
		if(!enter_is_presed) //to not jump
			flag <= 0;
	
		// Choosing 1st coordinates
		if (enter_is_presed && !random_sel && !flag) begin
			flag <= 1;
			random_sel <= 1;
			topLeftX_1 <= randum_num1*64 + 15;
			topLeftY_1 <= randum_num2*64 + 48;
			end
		// Choosing 2nd coordinates	
		if (enter_is_presed && random_sel && !flag) begin
			flag <= 1;
			topLeftX_2 <= randum_num1*64 + 15;
			topLeftY_2 <= randum_num2*64 + 48;
			end
		
		//chooses the coordinates based on the level 
		if(level_select == 1) begin
			bitMap_sel <= 0;
			topLeftX <= topLeftX_1;
			topLeftY <= topLeftY_1;
			end
		
		if(level_select == 2) begin
			bitMap_sel <= 1;
			random_sel <= 0;
			topLeftX <= topLeftX_2;
			topLeftY <= topLeftY_2;
			end
		
		end
	end

endmodule