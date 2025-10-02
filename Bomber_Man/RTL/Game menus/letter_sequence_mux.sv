module letter_sequence_mux (	
	
	input	logic	clk,
	input	logic	resetN,
	
	//Sequence 1
	input	logic	SEQ_1,
	input	logic	[10:0] X_1,
	input	logic	[10:0] Y_1,
	input logic [4:0] letters_1 [15:0],
	//Sequence 2
	input	logic	SEQ_2,
	input	logic	[10:0] X_2,
	input	logic	[10:0] Y_2,
	input logic [4:0] letters_2 [15:0],
	//Sequence 3
	input	logic	SEQ_3,
	input	logic	[10:0] X_3,
	input	logic	[10:0] Y_3,
	input logic [4:0] letters_3 [15:0],
	
	//Outputs
	output logic [10:0] X_OUT,
	output logic [10:0] Y_OUT,
	output logic SEQ_OUT,
	output logic [4:0] letters_out [15:0]
	
);

always_comb
begin
	if(!resetN) begin
			X_OUT = 11'b0;
			Y_OUT = 11'b0;
			letters_out = '{5'd0, 5'd0, 5'd0, 5'd0, 5'd0, 5'd0, 5'd0, 5'd0, 5'd0, 5'd0, 5'd0, 5'd0, 5'd0, 5'd0, 5'd0, 5'd0};
	end
	
	else begin
		if (SEQ_1) begin
			X_OUT = X_1;
			Y_OUT = Y_1;
			letters_out = letters_1;
		end
		else if (SEQ_2) begin
			X_OUT = X_2;
			Y_OUT = Y_2;
			letters_out = letters_2;
		end
		else if (SEQ_3) begin
			X_OUT = X_3;
			Y_OUT = Y_3;
			letters_out = letters_3;
		end
		else begin 
			X_OUT = 11'b0;
			Y_OUT = 11'b0;
			letters_out = '{5'd0, 5'd0, 5'd0, 5'd0, 5'd0, 5'd0, 5'd0, 5'd0, 5'd0, 5'd0, 5'd0, 5'd0, 5'd0, 5'd0, 5'd0, 5'd0};
		end
	end
end
	
assign SEQ_OUT = SEQ_1 || SEQ_2 || SEQ_3;

endmodule