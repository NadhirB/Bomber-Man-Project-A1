
module	borders_mux	(	
//		--------	Clock Input	 	
					input	logic	clk,
					input	logic	resetN,
		   // Top 
					input	logic	top_DR, 
					input	logic	[7:0] top_RGB,
					     
		  // Left
					input	logic	left_DR,
					input	logic	[7:0] left_RGB,

		  // Right
					input	logic	right_DR,
					input	logic	[7:0] right_RGB,

		  // Bottom
					input	logic	bottom_DR,
					input	logic	[7:0] bottom_RGB,					
		 
		  // Outputs 
				   output logic	[7:0] RGBOut,
					output logic frame_DR
);

always_comb
begin
	if(!resetN) begin
			RGBOut = 8'b0;
	end
	
	else begin
		if (top_DR)   
			RGBOut = top_RGB;  //first priority 

		else if (left_DR)
				RGBOut = left_RGB;
		
		else if (right_DR)
				RGBOut = right_RGB;
				
		else if (bottom_DR)
				RGBOut = bottom_RGB;		
 		
		else RGBOut = 8'b0 ;// last priority 
		end ; 
	end

assign frame_DR = (left_DR || right_DR || bottom_DR || top_DR);
	
endmodule