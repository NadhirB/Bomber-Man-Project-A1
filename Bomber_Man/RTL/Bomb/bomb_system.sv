

module bomb_system (
    input logic clk,
    input logic resetN,
    input logic OneSecPulse,
    input logic startOfFrame,
    input logic drop_bomb_key,
    input logic [10:0] player_topLeftX,
    input logic [10:0] player_topLeftY,
    input logic [10:0] pixelX,
    input logic [10:0] pixelY,
	 input logic [2:0] blast_num,
	 input logic inc_bomb,
	 input logic score_reset,
    
    output logic bomb_DR,
    output logic [7:0] bomb_RGB,
	 output logic blast_DR,
    output logic [7:0] blast_RGB,
    output logic blast,
	 output logic [3:0] bombs_left,
	 output logic explosion
);

logic [2:0] bomb_drop_key_array;		// used to transfer drop bomb key signal to the bottom hierarchy (bomb_block_t) 

parameter  logic [3:0] starting_bombs = 4'b0010 ; 

logic flag;		// drop_bomb_key flag

logic [2:0] bomb_active;		// keeps track which bomb is currently deployed on screen

logic [2:0] blasts_this_cycle;		// counts the blasts in the last cycle to update back to the metadata

logic bomb1_blast;  
logic bomb2_blast;  
logic bomb3_blast;

logic bomb1_DR;  
logic bomb2_DR;  
logic bomb3_DR;

logic [7:0] bomb1_RGB;  
logic [7:0] bomb2_RGB;  
logic [7:0] bomb3_RGB; 

logic blast1_DR;  
logic blast2_DR;  
logic blast3_DR;

logic [7:0] blast1_RGB;  
logic [7:0] blast2_RGB;  
logic [7:0] blast3_RGB;

logic explode1;
logic explode2;
logic explode3;


    always_ff @(posedge clk or negedge resetN) begin
        if (!resetN) begin
            bomb_drop_key_array <= 3'b000;
				bomb_active <= 3'b000;
				blasts_this_cycle <= 3'b000;
				bombs_left <= starting_bombs;
				flag <= 0;
				
        end else begin
            bomb_drop_key_array <= 3'b000;
            
        if (drop_bomb_key && bombs_left && !flag) begin
            flag <= 1;
            
// Uses first match of bomb if available
            
			if (!bomb_active[0]) begin
				bomb_drop_key_array[0] <= 1'b1;
			   bomb_active[0] <= 1'b1;
			end else if (!bomb_active[1]) begin
			   bomb_drop_key_array[1] <= 1'b1;
			   bomb_active[1] <= 1'b1;
			end else if (!bomb_active[2]) begin
			   bomb_drop_key_array[2] <= 1'b1;
			   bomb_active[2] <= 1'b1;
			end
							 
            bombs_left <= bombs_left - 1;  	// after bomb is deployed, decrease bombs_left by 1
        end
				
			if (!drop_bomb_key)
				flag <= 0;
				
			if (bombs_left < 4'b0011 && inc_bomb)		// if powerUp collected, increase bombs_leftg by 1
				bombs_left <= bombs_left + 1;
					
         blasts_this_cycle = (bomb1_blast ? 1 : 0)
                              + (bomb2_blast ? 1 : 0)
                              + (bomb3_blast ? 1 : 0);

          if (blasts_this_cycle > 0) begin		// reset the bomb_active array
                
            if (bomb1_blast) bomb_active[0] <= 1'b0;
            if (bomb2_blast) bomb_active[1] <= 1'b0;
            if (bomb3_blast) bomb_active[2] <= 1'b0;
				bombs_left <= bombs_left + blasts_this_cycle;
          end
			 
			 
			 if (bombs_left > 4'b0011)
				bombs_left <= 4'b0011;

				if (score_reset) begin				// reset status on main menu using score_reset signal
					bomb_drop_key_array <= 3'b000;
					bomb_active <= 3'b000;
					blasts_this_cycle <= 3'b000;
					bombs_left <= starting_bombs;
					flag <= 0;
					
				end 
        end
    end
    
    // Instantiate bomb blocks (these would be your .bdf instances)
Bomb_Block_T Bomb_Block_T_inst1
(
	.clk(clk) ,	// input  clk_sig
	.resetN(resetN) ,	// input  resetN_sig
	.pixelX(pixelX) ,	// input [10:0] pixelX_sig
	.pixelY(pixelY) ,	// input [10:0] pixelY_sig
	.drop_bomb_key(bomb_drop_key_array[0]) ,	// input  drop_bomb_key_sig
	.OneSecPulse(OneSecPulse) ,	// input  OneSecPulse_sig
	.startOfFrame(startOfFrame) ,	// input  startOfFrame_sig
	.player_topLeftX(player_topLeftX) ,	// input [10:0] player_topLeftX_sig
	.player_topLeftY(player_topLeftY) ,	// input [10:0] player_topLeftY_sig
	.blast_num(blast_num) ,	// input [2:0] blast_num_sig
	.bombRGB(bomb1_RGB) ,	// output [7:0] bombRGB_sig
	.bombDR(bomb1_DR) ,	// output  bombDR_sig
	.blastDR(blast1_DR) ,	// output  blastDR_sig
	.blastRGB(blast1_RGB) ,	// output [7:0] blastRGB_sig
	.blast(bomb1_blast), 	// output  blast_sig
	.explode(explode1)
);

Bomb_Block_T Bomb_Block_T_inst2
(
	.clk(clk) ,	// input  clk_sig
	.resetN(resetN) ,	// input  resetN_sig
	.pixelX(pixelX) ,	// input [10:0] pixelX_sig
	.pixelY(pixelY) ,	// input [10:0] pixelY_sig
	.drop_bomb_key(bomb_drop_key_array[1]) ,	// input  drop_bomb_key_sig
	.OneSecPulse(OneSecPulse) ,	// input  OneSecPulse_sig
	.startOfFrame(startOfFrame) ,	// input  startOfFrame_sig
	.player_topLeftX(player_topLeftX) ,	// input [10:0] player_topLeftX_sig
	.player_topLeftY(player_topLeftY) ,	// input [10:0] player_topLeftY_sig
	.blast_num(blast_num) ,	// input [2:0] blast_num_sig
	.bombRGB(bomb2_RGB) ,	// output [7:0] bombRGB_sig
	.bombDR(bomb2_DR) ,	// output  bombDR_sig
	.blastDR(blast2_DR) ,	// output  blastDR_sig
	.blastRGB(blast2_RGB) ,	// output [7:0] blastRGB_sig
	.blast(bomb2_blast), 	// output  blast_sig
	.explode(explode2)
);

Bomb_Block_T Bomb_Block_T_inst3
(
	.clk(clk) ,	// input  clk_sig
	.resetN(resetN) ,	// input  resetN_sig
	.pixelX(pixelX) ,	// input [10:0] pixelX_sig
	.pixelY(pixelY) ,	// input [10:0] pixelY_sig
	.drop_bomb_key(bomb_drop_key_array[2]) ,	// input  drop_bomb_key_sig
	.OneSecPulse(OneSecPulse) ,	// input  OneSecPulse_sig
	.startOfFrame(startOfFrame) ,	// input  startOfFrame_sig
	.player_topLeftX(player_topLeftX) ,	// input [10:0] player_topLeftX_sig
	.player_topLeftY(player_topLeftY) ,	// input [10:0] player_topLeftY_sig
	.blast_num(blast_num) ,	// input [2:0] blast_num_sig
	.bombRGB(bomb3_RGB) ,	// output [7:0] bombRGB_sig
	.bombDR(bomb3_DR) ,	// output  bombDR_sig
	.blastDR(blast3_DR) ,	// output  blastDR_sig
	.blastRGB(blast3_RGB) ,	// output [7:0] blastRGB_sig
	.blast(bomb3_blast), 	// output  blast_sig
	.explode(explode3)
);
    
    
    // collect the DR and RGB outputs from the lower hierarchy (bomb_block_t) 
	 
always_comb begin
    if (bomb1_DR) begin
        bomb_DR = 1'b1;
        bomb_RGB = bomb1_RGB;
        blast_DR = 1'b0;
        blast_RGB = 8'h00;
    end else if (blast1_DR) begin
        bomb_DR = 1'b0;
        bomb_RGB = 8'h00;
        blast_DR = 1'b1;
        blast_RGB = blast1_RGB;
    end else if (bomb2_DR) begin
        bomb_DR = 1'b1;
        bomb_RGB = bomb2_RGB;
        blast_DR = 1'b0;
        blast_RGB = 8'h00;
    end else if (blast2_DR) begin
        bomb_DR = 1'b0;
        bomb_RGB = 8'h00;
        blast_DR = 1'b1;
        blast_RGB = blast2_RGB;
    end else if (bomb3_DR) begin
        bomb_DR = 1'b1;
        bomb_RGB = bomb3_RGB;
        blast_DR = 1'b0;
        blast_RGB = 8'h00;
    end else if (blast3_DR) begin
        bomb_DR = 1'b0;
        bomb_RGB = 8'h00;
        blast_DR = 1'b1;
        blast_RGB = blast3_RGB;
    end else begin
        bomb_DR = 1'b0;
        blast_DR = 1'b0;
        bomb_RGB = 8'h00;
        blast_RGB = 8'h00;
    end
end
    
    // Combine blast signals
	 
    assign blast = bomb1_blast || bomb2_blast || bomb3_blast;
	 assign explosion = explode1 || explode2 || explode3 ;

endmodule