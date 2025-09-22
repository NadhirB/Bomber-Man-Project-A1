

module metadata_mux (	
	
	input	logic	clk,
	input	logic	resetN,
	
	//Timer
	input	logic	timerDR,
	input	logic	[7:0] timerRGB, 
	//Lives
	input	logic	livesDR,
	input	logic	[7:0] livesRGB,
	//Bombs
	input	logic	bombsDR,
	input	logic	[7:0] bombsRGB,
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
		else 
			metadataRGB = 8'b0;
		end
	end
	
assign metadataDR = timerDR || livesDR || bombsDR;

endmodule


