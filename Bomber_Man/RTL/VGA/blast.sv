

module blast
	(
	input logic clk, 
	input logic resetN,   
	input logic OneSecPulse, 
	input logic startOfFrame,
	input logic blast,
	input logic [1:0] blastRadius,
	input logic [10:0] bomb_topLeftX,
	input logic [10:0] bomb_topLeftY,
	output logic signed 	[10:0] topLeftX, // output the top left corner 
	output logic signed	[10:0] topLeftY,  // can be negative , if the object is partliy outside 
	output logic [1:0] radius,
	output logic explode
   );

//-------------------------------------------------------------------------------------------

// state machine declaration 
   enum logic [2:0] {s_idle, s_explode} SMblast;
//--------------------------------------------------------------------------------------------
//  syncronous code:  executed once every clock to update the current state 
always_ff @(posedge clk or negedge resetN)
   begin
	   
   if ( !resetN ) begin // Asynchronic reset
		SMblast <= s_idle;
		radius <= 2'b1;
		topLeftX <= 640;
		topLeftY <= 480;
		explode <= 0;
		end 

	else begin case (SMblast) // logically defining what is the next state, and the ouptput
		
			//Note: the implementation of the idle state is already given you as an example
//      ======		
			s_idle: begin
//      ======
					topLeftX <= 640;
					topLeftY <= 480;
				if (blast) begin
					topLeftX <= bomb_topLeftX - 64;
					topLeftY <= bomb_topLeftY - 64;
					radius <= blastRadius;
					SMblast <= s_explode;
					explode <= 1;
				end
			end // idle			
	
		
//      ======		
			s_explode: begin
//      ======
				if (OneSecPulse) begin
					SMblast <= s_idle;
					topLeftX <= 640;
					topLeftY <= 480;
					explode <= 0;
				end

			end 	

//  		  =========		
			  default : begin   
//         =========			
					SMblast <= s_idle;  
			 end // default
						
		endcase
		
		end
		
	end // always sync

		
endmodule
