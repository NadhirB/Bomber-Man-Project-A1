
module startMelodyKey_mux (
    input  logic clk,
    input  logic resetN,
    input  logic player_objective,
    input  logic powerUp,
    input  logic player_hit,
    input  logic game_lost,
    input  logic game_on,
    output logic startMelodyKey
);

logic start_req;        // combinational request
logic start_req_d;      // registered delay

always_comb begin
    // create a single combinational request
    start_req = (player_objective || powerUp || player_hit || game_lost) && game_on;
end

always_ff @(posedge clk or negedge resetN) begin
    if (!resetN) begin
        start_req_d <= 1'b0;
        startMelodyKey <= 1'b0;
    end else begin
        // register the request one cycle before driving startMelodyKey
        start_req_d <= start_req;
        startMelodyKey <= start_req_d;
    end
end

endmodule

//module startMelodyKey_mux (	
//	
//	input	logic	clk,
//	input	logic	resetN,
//	input logic player_objective,
//	input logic powerUp,
//	input logic player_hit,
//	input logic game_lost,
//	input logic game_on,
////	input logic melody_ended,
//	
//	output logic startMelodyKey
//);
//
////logic game_lost_flag;
//
//always_ff @(posedge clk or negedge resetN) begin
//	if(!resetN) begin
//		startMelodyKey <= 1'b0;
////		game_lost_flag <= 1'b0;
//	end
//	else if (game_on) begin
//		if (player_objective || powerUp || player_hit)
//			startMelodyKey <= 1'b1;
//		else if (game_lost && !startMelodyKey) begin
//			startMelodyKey <= 1'b1;
////			game_lost_flag <= 1'b1;
//		end
//		else
//			startMelodyKey <= 1'b0;
//	end
//	else begin
//		startMelodyKey <= 1'b0;
////		game_lost_flag <= 1'b0;
//	end
//
//end
//
//	
//
//endmodule


