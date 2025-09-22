
module	letter_sequence	(	
					input	logic	clk,
					input	logic	resetN,
					
					output [4:0] letters [9:0]
 ) ;

 
parameter int num_of_letters = 10;
parameter logic [4:0] letter_0 = 5'd0;
parameter logic [4:0] letter_1 = 5'd0;
parameter logic [4:0] letter_2 = 5'd0;
parameter logic [4:0] letter_3 = 5'd0;
parameter logic [4:0] letter_4 = 5'd0;
parameter logic [4:0] letter_5 = 5'd0;
parameter logic [4:0] letter_6 = 5'd0;
parameter logic [4:0] letter_7 = 5'd0;
parameter logic [4:0] letter_8 = 5'd0;
parameter logic [4:0] letter_9 = 5'd0;


logic [4:0] letters_out [0: num_of_letters - 1];

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		letters_out <= '{5'd0, 5'd0, 5'd0, 5'd0, 5'd0, 5'd0, 5'd0, 5'd0, 5'd0, 5'd0};
	end

	else begin
		letters_out <= '{letter_0, letter_1, letter_2, letter_3, letter_4, letter_5, letter_6, letter_7, letter_8, letter_9};
	end
		
end

assign letters = letters_out ; 

endmodule