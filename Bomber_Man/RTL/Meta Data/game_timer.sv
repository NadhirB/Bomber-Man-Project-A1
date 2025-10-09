// (c) Technion IIT, Department of Electrical Engineering 2022 
// Written By Liat Schwartz August 2018 
// Updated by Mor Dahan - January 2022

// Implements a BCD down counter 99 down to 0 with several enable inputs and loadN data
// having countL, countH and tc outputs
// by instantiating two one bit down-counters


module game_timer
	(
	input logic clk, 
	input logic resetN, 
	input logic loadN, 
	input logic enable1, 
	input logic enable2, 
	input logic inc_time,
	
	output logic [3:0] countL, 
	output logic [3:0] countH,
	output logic tc
   );

// Parameters defined as external, here with a default value - to be updated
// in the upper hierarchy file with the actial bomb down counting values
// -----------------------------------------------------------
	parameter  logic [3:0] datainL = 4'h9 ; 
	parameter  logic [3:0] datainH = 4'h9 ;
// -----------------------------------------------------------
	
logic  tclow, tchigh; // internal variables terminal count 
logic [3:0] next_countL, next_countH;
logic loadN_internal;

assign loadN_internal = loadN & ~inc_time;

    always_comb begin
        if (inc_time) begin
            int total;
            total = (countH * 10) + countL + 10; // add 10 seconds
            if (total > 99) total = 99;          // saturate at 99
            next_countH = total / 10;
            next_countL = total % 10;
        end
        else begin
            // normal load value (when external loadN is used)
            next_countH = datainH;
            next_countL = datainL;
        end
    end
	
// Low counter instantiation
	down_counter lowc(.clk(clk), 
							.resetN(resetN),
							.loadN(loadN_internal),	
							.enable1(enable1), 
							.enable2(enable2),
							.enable3(1'b1), 	
							.datain(next_countL), 
							.count(countL), 
							.tc(tclow) );
	
// High counter instantiation	
	
	down_counter highc(.clk(clk), 
							.resetN(resetN),
							.loadN(loadN_internal),	
							.enable1(enable1), 
							.enable2(enable2),
							.enable3(tclow), 	
							.datain(next_countH), 
							.count(countH), 
							.tc(tchigh) );
							

 assign tc = tclow*tchigh ;	//  ## initializing a variable to enable compilation, change if needed 

endmodule
