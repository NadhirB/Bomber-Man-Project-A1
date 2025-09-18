

module columns_walls_mux (	
	
	input	logic	clk,
	input	logic	resetN,
	
	//Enemy 1
	input	logic	columnsDR,
	input	logic	[7:0] columnsRGB, 
	//Enemy 2
	input	logic	wallsDR,
	input	logic	[7:0] wallsRGB,  
	//Outputs
	output logic col_wal_DR,
	output logic [7:0] col_wal_RGB
);

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
			col_wal_RGB	<= 8'b0;
	end
	
	else begin
		if (columnsDR)
			col_wal_RGB <= columnsRGB;
		else if (wallsDR)   
			col_wal_RGB <= wallsRGB;
		end
	end
	
assign col_wal_DR = columnsDR || wallsDR;

endmodule


