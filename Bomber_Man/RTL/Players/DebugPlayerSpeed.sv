// System-Verilog 'written by Alex Grinshpun May 2018
// New bitmap dudy February 2025
// (c) Technion IIT, Department of Electrical Engineering 2025 


module DebugPlayerSpeed (
    input logic clk,
    input logic resetN,
    input logic sw_inc,     
    input logic sw_dec,
	 input logic powerUp_inc,
	 input logic score_reset,
		
    output logic [1:0] speed_level       
);

	 logic flag_inc = 0;
	 logic flag_dec = 0;

    always_ff @(posedge clk or negedge resetN) begin
        if (!resetN) begin
            speed_level <= 2'b00;   
				flag_inc <= 0;
				flag_dec <= 0;
        end
        else begin
				//Used for debuging with the physical switches during work on the project
            if (sw_inc && speed_level < 2'b10 && flag_inc == 0) begin
                speed_level <= speed_level + 1;
					 flag_inc <= 1;
				end
            if (sw_dec && speed_level > 2'b00 && flag_dec == 0) begin
                speed_level <= speed_level - 1;
					 flag_dec <= 1;
				end
				
				if (!sw_inc)
					flag_inc <= 0;
				if (!sw_dec)
					flag_dec <= 0;
				
				//Increases Speed level if collected the right power up 
				if (powerUp_inc && speed_level < 2'b10)
					speed_level <= speed_level + 1;
					
				//resets the speed level only when finished the game so the speed level is saved between levels
				if (score_reset) begin
					speed_level <= 2'b00;   
					flag_inc <= 0;
					flag_dec <= 0;
				end
        end
    end
	 

endmodule


