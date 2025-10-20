module	color_changer	(	
					
					input logic	[7:0] RGBin,// offset from top left  position
					input logic enable,
					
					output logic	[7:0] RGBout  //rgb value from the bitmap 

 ) ;



parameter logic [7:0] CHANGE_FROM1 = 8'h00;// RGB value you want to change
parameter logic [7:0] CHANGE_TO1 = 8'h00;// RGB value you want to change to
parameter logic [7:0] CHANGE_FROM2 = 8'h00;// RGB value you want to change
parameter logic [7:0] CHANGE_TO2 = 8'h00;// RGB value you want to change to
parameter logic [7:0] CHANGE_FROM3 = 8'h00;// RGB value you want to change
parameter logic [7:0] CHANGE_TO3 = 8'h00;// RGB value you want to change to


always_comb 
begin
	if (enable && CHANGE_FROM1 == RGBin)
		RGBout = CHANGE_TO1;
	else if (enable && CHANGE_FROM2 == RGBin)
		RGBout = CHANGE_TO2;
	else if (enable && CHANGE_FROM3 == RGBin)
		RGBout = CHANGE_TO3;
	else
		RGBout = RGBin;
end   

endmodule