
// a simple module that takes as an input the score and calculates the digits again.

// Note - why not use the digits as input from the score_block in the metadata section? because there was a thought of adding score based on level reached
// so we decided to take the score calcualted at the end of the game and perhaps adding to it. The idea never saw the light of day, but the preperation was present.

module final_score
(

    input logic [15:0] score,
	 
    output logic [3:0] digit_thousands,
    output logic [3:0] digit_hundreds,
    output logic [3:0] digit_tens,
    output logic [3:0] digit_ones
);


    always_comb begin
        int tmp;
        tmp = score;
        digit_thousands = (tmp / 1000) % 10;
        digit_hundreds = (tmp / 100) % 10;
        digit_tens = (tmp / 10) % 10;
        digit_ones = tmp % 10;
    end

endmodule
