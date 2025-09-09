
// (c) Technion IIT, Department of Electrical Engineering 2025 
//-- Alex Grinshpun Apr 2017
//-- Dudy Nov 13 2017
// SystemVerilog version Alex Grinshpun May 2018
// coding convention dudy December 2018

//-- Eyal Lev 31 Jan 2021

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
		 
			  
				   output logic	[7:0] RGBOut
);

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
			RGBOut	<= 8'b0;
	end
	
	else begin
		if (top_DR == 1'b1 )   
			RGBOut <= top_RGB;  //first priority 

		else if (left_DR == 1'b1)
				RGBOut <= left_RGB;
		
		else if (right_DR == 1'b1)
				RGBOut <= right_RGB;
				
		else if (bottom_DR == 1'b1)
				RGBOut <= bottom_RGB;		
 		
		else RGBOut <= 8'b0 ;// last priority 
		end ; 
	end

endmodule