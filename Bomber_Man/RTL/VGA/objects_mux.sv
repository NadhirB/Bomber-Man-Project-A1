
// (c) Technion IIT, Department of Electrical Engineering 2025 


module	objects_mux	(	
//		--------	Clock Input	 	
					input		logic	clk,
					input		logic	resetN,
		   // player 
					input		logic	playerDR, // two set of inputs per unit
					input		logic	[7:0] playerRGB, 
					
			// player 2
					input		logic	player2DR, // two set of inputs per unit
					input		logic	[7:0] player2RGB, 	
					     
		  // bomb
					input		logic	bombDR, // two set of inputs per unit
					input		logic	[7:0] bombRGB,  
					
		  // bomb2
					input		logic	bomb2DR, // two set of inputs per unit
					input		logic	[7:0] bomb2RGB,  
		  // blast
					input logic blastDR,
					input logic [7:0] blastRGB,	
			//blast2
					input logic blast2DR,
					input logic [7:0] blast2RGB,		
			// enemy
					input logic enemyDR,
					input logic [7:0] enemyRGB,
			// metadata
					input logic metadataDR,
					input logic [7:0] metadataRGB,
			  
		  // background 
					input    logic columnsDR,
					input		logic	[7:0] columnsRGB,   
					input		logic	[7:0] bordersRGB, 
					input		logic	bordersDR, 
					input		logic	[7:0] RGB_MIF,
			//game over title
					input		logic	game_over_DR, 
					input		logic	[7:0] game_over_RGB,	
	
			//Door and Idol
					input logic Door_Idol_DR,
					input logic [7:0] Door_Idol_RGB,
					
			//Power Ups
					input logic PowerUp_DR,
					input logic [7:0] PowerUp_RGB,
					
			//Spikes
					input logic spikes_DR,
					input logic [7:0] spikes_RGB,
			  
		  // Output	   
					output	logic	[7:0] RGBOut
					
			
);

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
			RGBOut	<= 8'b0;
	end
	
	else begin
		if (game_over_DR)					//first priority
			RGBOut <= game_over_RGB;
		else if (columnsDR) 
			RGBOut <= columnsRGB;
		else if (metadataDR)
				RGBOut <= metadataRGB;
		else if (bordersDR)
				RGBOut <= bordersRGB;
		else if (blastDR) 
			RGBOut <= blastRGB;
		else if (blast2DR) 
			RGBOut <= blast2RGB;
		else if (playerDR)   
			RGBOut <= playerRGB;
		else if (player2DR)   
			RGBOut <= player2RGB;
		else if (enemyDR)
				RGBOut <= enemyRGB;
		else if (bombDR)
				RGBOut <= bombRGB;
		else if (bomb2DR)
				RGBOut <= bomb2RGB;
		else if (Door_Idol_DR)
				RGBOut <= Door_Idol_RGB;
		else if (PowerUp_DR)
				RGBOut <= PowerUp_RGB;
		else if (spikes_DR)
				RGBOut <= spikes_RGB;
		else RGBOut <= RGB_MIF ;// last priority 
		end ; 
	end

endmodule


