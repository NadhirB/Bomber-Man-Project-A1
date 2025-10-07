module	simple_counter	(	
			input	logic	clk,
			input	logic	resetN,
			input	logic	rise,

			output logic counter_out,
			output logic finished

);

parameter int top = 10;
logic [10:0] counter;


always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN)
	begin 
	counter <= 0;
		
	end 
	else begin 

	if (rise && counter < top) begin
		counter <= counter + 1;
		finished <= 0;
		end
	else if (counter == top) begin
			finished <= 1;
			counter <= 0;
		end
 
	end 
end

assign counter_out = counter;

endmodule