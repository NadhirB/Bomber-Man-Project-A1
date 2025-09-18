

module columns_walls_mux (	
	
	input	logic	clk,
	input	logic	resetN,
	
	//Columns
	input	logic	columnsDR,
	input	logic	[7:0] columnsRGB, 
	//Walls
	input	logic	wallsDR,
	input	logic	[7:0] wallsRGB,  
	//Outputs
	output logic col_wal_DR,
	output logic [7:0] col_wal_RGB
);

always_comb
begin
	if(!resetN) begin
			col_wal_RGB	= 8'b0;
	end
	
	else begin
		if (columnsDR)
			col_wal_RGB = columnsRGB;
		else if (wallsDR)   
			col_wal_RGB = wallsRGB;
		else 
			col_wal_RGB = 8'b0;
		end
end
	
assign col_wal_DR = columnsDR || wallsDR;
//assign col_wal_RGB = (wallsDR) ? wallsRGB : columnsRGB;

endmodule


