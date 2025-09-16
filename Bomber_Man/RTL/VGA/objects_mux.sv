
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
			  
		  // background 
					input    logic columnsDR,
					input		logic	[7:0] columnsRGB,   
					input		logic	[7:0] bordersRGB, 
					input		logic	bordersDR, 
					input		logic	[7:0] RGB_MIF, 
			  
				   output	logic	[7:0] RGBOut
);

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
			RGBOut	<= 8'b0;
	end
	
	else begin
		if (playerDR == 1'b1 )   
			RGBOut <= playerRGB;  //first priority 
		else if (bombDR == 1'b1)
				RGBOut <= bombRGB;	
 		else if (columnsDR == 1'b1)
				RGBOut <= columnsRGB;
		else if (bordersDR == 1'b1)
				RGBOut <= bordersRGB;
		else RGBOut <= RGB_MIF ;// last priority 
		end ; 
	end

endmodule


