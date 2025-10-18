

module metadata_mux (	
	
	input	logic	clk,
	input	logic	resetN,
	
	//Timer
	input	logic	timerDR,
	input	logic	[7:0] timerRGB, 
	//Lives
	input	logic	livesDR,
	input	logic	[7:0] livesRGB,
	//Lives player 2
	input	logic	lives2DR,
	input	logic	[7:0] lives2RGB,
	//Bombs
	input	logic	bombsDR,
	input	logic	[7:0] bombsRGB,
	//Bombs player 2
	input	logic	bombs2DR,
	input	logic	[7:0] bombs2RGB,
	//Score
	input	logic	scoreDR,
	input	logic	[7:0] scoreRGB,
	//Level
	input	logic	lvlDR,
	input	logic	[7:0] lvlRGB,
	//Outputs
	output logic metadataDR,
	output logic [7:0] metadataRGB
);

always_comb
begin
	if(!resetN) begin
			metadataRGB	= 8'b0;
	end
	
	else begin
		if (timerDR)
			metadataRGB = timerRGB;
		else if (livesDR)   
			metadataRGB = livesRGB;
		else if (bombsDR)   
			metadataRGB = bombsRGB;
		else if (lives2DR)   
			metadataRGB = lives2RGB;
		else if (bombs2DR)   
			metadataRGB = bombs2RGB;
		else if (scoreDR)   
			metadataRGB = scoreRGB;
		else if (lvlDR)   
			metadataRGB = lvlRGB;
		else 
			metadataRGB = 8'b0;
		end
	end
	
assign metadataDR = timerDR || livesDR || bombsDR || scoreDR || lvlDR || bombs2DR || lives2DR;

endmodule


