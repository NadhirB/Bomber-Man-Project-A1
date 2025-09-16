

module bomb
	(
	input logic clk, 
	input logic resetN,   
	input logic OneSecPulse, 
	input logic startOfFrame,
	input logic drop_bomb_key,
	input logic [10:0] player_topLeftX,
	input logic [10:0] player_topLeftY,
	output logic signed 	[10:0] topLeftX, // output the top left corner 
	output logic signed	[10:0] topLeftY,  // can be negative , if the object is partliy outside 
	output logic blast
   );

//-------------------------------------------------------------------------------------------

// state machine declaration 
   enum logic [2:0] {s_idle, s_run, s_explode} SMbomb;
	logic [2:0] timer = 3;
	logic bomb_flag = 0;
 	
//--------------------------------------------------------------------------------------------
//  syncronous code:  executed once every clock to update the current state 
always_ff @(posedge clk or negedge resetN)
   begin
	   
   if ( !resetN ) begin // Asynchronic reset
		SMbomb <= s_idle;
		bomb_flag <= 0;
		timer <= 3;
		blast <= 0;
		end 

	else begin case (SMbomb) // logically defining what is the next state, and the ouptput
		
			//Note: the implementation of the idle state is already given you as an example
//      ======		
			s_idle: begin
//      ======		
				if (drop_bomb_key && !bomb_flag) begin
					topLeftX <= player_topLeftX;
					topLeftY <= player_topLeftY;
					bomb_flag <= 1;
					SMbomb <= s_run; 
				end
			end // idle			
	
//      ======		
			s_run: begin
//      ======

				if (!timer) begin
					timer <= 3;
					SMbomb <= s_explode;
					end
				else if (OneSecPulse)
					timer <= timer - 1; 
			end // run
		
//      ======		
			s_explode: begin
//      ======
				blast <= 1;
				bomb_flag <= 0;
				SMbomb <= s_idle;
				topLeftX <= 640;
				topLeftY <= 480;
			end // lampOff		

//--------------------------------------------------------------------------------------------------------------------
// &&&&&&&&&&&&&&  end of paste SM to the report #1 
//--------------------------------------------------------------------------------------------------------------------			

//  		  =========		
			  default : begin   
//         =========			
					SMbomb <= s_idle;  
			 end // default
						
		endcase
		
		end
		
	end // always sync
	
		
endmodule
