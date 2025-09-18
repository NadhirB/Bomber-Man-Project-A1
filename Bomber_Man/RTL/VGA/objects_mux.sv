
// (c) Technion IIT, Department of Electrical Engineering 2025 


module	objects_mux	(	
//		--------	Clock Input	 	
					input		logic	clk,
					input		logic	resetN,
		   // player 
					input		logic	playerDR, // two set of inputs per unit
					input		logic	[7:0] playerRGB, 
					     
		  // bomb
					input		logic	bombDR, // two set of inputs per unit
					input		logic	[7:0] bombRGB,  
		  //blast
					input logic blastDR,
					input logic [7:0] blastRGB,
			  
		  // background 
					input    logic columnsDR,
					input		logic	[7:0] columnsRGB,   
					input		logic	[7:0] bordersRGB, 
					input		logic	bordersDR, 
					input		logic	[7:0] RGB_MIF, 
			  
				   output	logic	[7:0] RGBOut,
					
			// enemy
					input logic enemyDR,
					input logic [7:0] enemyRGB
);

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
			RGBOut	<= 8'b0;
	end
	
	else begin
		if (columnsDR) //first priority
			RGBOut <= columnsRGB;
		else if (bordersDR)
				RGBOut <= bordersRGB;
		else if (blastDR) 
			RGBOut <= blastRGB;
		else if (playerDR)   
			RGBOut <= playerRGB;
		else if (enemyDR)
				RGBOut <= enemyRGB;
		else if (bombDR)
				RGBOut <= bombRGB;
		else RGBOut <= RGB_MIF ;// last priority 
		end ; 
	end

endmodule


