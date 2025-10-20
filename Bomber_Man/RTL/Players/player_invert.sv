module	player_invert	(		
					input logic	[7:0] RGBin,// offset from top left  position
					input logic invert_player,
					
					output logic	[7:0] RGBout  //rgb value from the bitmap 
 ) ;



parameter logic [7:0] TRANSPARENT_ENCODING = 8'h00;// RGB value in the bitmap representing a transparent pixel should be the same as in the Bitmap


always_comb 
begin
	
	if (RGBout != TRANSPARENT_ENCODING && invert_player)
		RGBout = 8'hff;
	else
		RGBout = RGBin;
	
end   

endmodule