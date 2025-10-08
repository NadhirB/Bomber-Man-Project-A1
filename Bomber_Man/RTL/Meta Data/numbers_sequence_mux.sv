module numbers_sequence_mux (	
	
	input	logic	clk,
	input	logic	resetN,
	
	//Number 1
	input	logic	SEQ_1,
	input	logic	[10:0] X_1,
	input	logic	[10:0] Y_1,
	input logic [3:0] num_1,
	//Number 2
	input	logic	SEQ_2,
	input	logic	[10:0] X_2,
	input	logic	[10:0] Y_2,
	input logic [3:0] num_2,
	//Number 3
	input	logic	SEQ_3,
	input	logic	[10:0] X_3,
	input	logic	[10:0] Y_3,
	input logic [3:0] num_3,
	//Number 4
	input	logic	SEQ_4,
	input	logic	[10:0] X_4,
	input	logic	[10:0] Y_4,
	input logic [3:0] num_4,
	
	//Outputs
	output logic [10:0] X_OUT,
	output logic [10:0] Y_OUT,
	output logic SEQ_OUT,
	output logic [3:0] num_out
	
);

always_comb
begin
	if(!resetN) begin
			X_OUT = 11'b0;
			Y_OUT = 11'b0;
			num_out = 4'b0;
	end
	
	else begin
		if (SEQ_1) begin
			X_OUT = X_1;
			Y_OUT = Y_1;
			num_out = num_1;
		end
		else if (SEQ_2) begin
			X_OUT = X_2;
			Y_OUT = Y_2;
			num_out = num_2;
		end
		else if (SEQ_3) begin
			X_OUT = X_3;
			Y_OUT = Y_3;
			num_out = num_3;
		end
		else if (SEQ_4) begin
			X_OUT = X_4;
			Y_OUT = Y_4;
			num_out = num_4;
		end
		else begin 
			X_OUT = 11'b0;
			Y_OUT = 11'b0;
			num_out = 4'b0;
		end
	end
end
	
assign SEQ_OUT = SEQ_1 || SEQ_2 || SEQ_3 || SEQ_4;

endmodule