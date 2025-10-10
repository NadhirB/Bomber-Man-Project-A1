

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
