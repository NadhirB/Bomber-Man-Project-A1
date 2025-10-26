
// This module is used to control and calcualte the player's lives.
// It takes both powerUp increases, player_hit and switch increase/decrease for debugging purposes. 

module DebugLivesBitMap (
    input logic clk,
    input logic resetN,
    input logic sw_inc,     
    input logic sw_dec,
	 input logic powerUp_inc,
	 input logic player_hit,
	 input logic lives_reset,
		
	 output logic player_died,
    output logic [3:0] lives
);

	 logic flag_inc = 0;
	 logic flag_dec = 0;


    always_ff @(posedge clk or negedge resetN) begin
        if (!resetN) begin
            lives <= 2'b11;   
				flag_inc <= 0;
				flag_dec <= 0;
        end
        else begin
				
            if (sw_inc && lives < 2'b11 && flag_inc == 0) begin
                lives <= lives + 1;
					 flag_inc <= 1;
				end
            if (sw_dec && lives > 2'b00 && flag_dec == 0) begin
                lives <= lives - 1;
					 flag_dec <= 1;
				end
				
				if (!sw_inc)
					flag_inc <= 0;
				if (!sw_dec)
					flag_dec <= 0;
					
				if (powerUp_inc && lives < 2'b11)
					lives <= lives + 1;
					
				if (player_hit && lives > 2'b00)
					lives <= lives - 1;
					
				if (lives_reset) begin
					lives <= 2'b11;   
					flag_inc <= 0;
					flag_dec <= 0;
				end
				
        end
    end
	 
	 assign player_died = (lives == 0) ? 1'b1 : 1'b0;

endmodule


