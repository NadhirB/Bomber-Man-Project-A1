// System-Verilog 'written by Alex Grinshpun May 2018
// New bitmap dudy February 2025
// (c) Technion IIT, Department of Electrical Engineering 2025 


module DebugLivesBitMap (
    input  logic        clk,
    input  logic        resetN,
    input  logic        sw_inc,     
    input  logic        sw_dec,
		
	 output logic player_died,
    output logic [1:0]  lives       
);

    logic sw_inc_prev, sw_dec_prev;  

    always_ff @(posedge clk or negedge resetN) begin
        if (!resetN) begin
            lives <= 2'b11;   
            sw_inc_prev <= 1'b0;
            sw_dec_prev <= 1'b0;
        end
        else begin

            if (sw_inc && !sw_inc_prev && lives < 2'b11)
                lives <= lives + 1;
            if (sw_dec && !sw_dec_prev && lives > 2'b00)
                lives <= lives - 1;

            sw_inc_prev <= sw_inc;
            sw_dec_prev <= sw_dec;
        end
    end
	 
	 assign player_died = (lives > 1) ? 1'b0 : 1'b1;

endmodule


