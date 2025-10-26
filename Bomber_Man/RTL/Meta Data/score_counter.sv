
// This module is responsible for counting the score of the player

module score_counter
(
    input logic clk,
    input logic resetN,

    input logic collision_blast_enemy,
    input logic collision_player_jewl,
    input logic collision_blast_wall,
    input logic explosion,      // stays high during explosion
    input logic game_on,
	 input logic score_reset,

    output logic [15:0] score,
    output logic [3:0] digit_thousands,
    output logic [3:0] digit_hundreds,
    output logic [3:0] digit_tens,
    output logic [3:0] digit_ones
);


    logic prev_wall;
    logic wall_rising;
    logic wall_scored;

    always_ff @(posedge clk or negedge resetN) begin
        if (!resetN) begin
            score <= 16'd0;
            prev_wall <= 1'b0;
            wall_scored <= 1'b0;
        end
        else if (game_on) begin			// score can't change when game_on == 0
		  
				// in order to prevent score rising up quick when blast hits unbroken wodden boxes

            wall_rising <= collision_blast_wall & ~prev_wall;
            prev_wall <= collision_blast_wall;


            if (collision_blast_enemy)
                score <= score + 16'd20;
            else if (collision_player_jewl)
                score <= score + 16'd50;
            else if (wall_rising && explosion && !wall_scored) begin
                score <= score + 16'd5;
                wall_scored <= 1'b1;
            end

            if (!explosion)
                wall_scored <= 1'b0;
        end
        else begin
				if (score_reset) 		// reset score on main menu (was added because we wanted to display score on the last screen)
					score <= 16'd0;
				else begin
					score <= score;
					prev_wall <= 1'b0;
					wall_scored <= 1'b0;
				end
        end
    end


	 // using "unefficient" method of deviding by 10 instead of multiples of 2, because other method did not work (we are honest)
	 
    always_comb begin
        int tmp;
        tmp = score;
        digit_thousands = (tmp / 1000) % 10;
        digit_hundreds = (tmp / 100) % 10;
        digit_tens = (tmp / 10) % 10;
        digit_ones = tmp % 10;
    end

endmodule
