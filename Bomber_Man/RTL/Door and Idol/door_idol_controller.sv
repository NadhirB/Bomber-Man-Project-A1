

module	door_idol_controller	(	
//		--------	Clock Input	 	
					input logic	clk,
					input	logic	resetN,
					input logic enter_is_presed,
					input logic [1:0] level_select,
					input	logic	[4:0] random_num1,
					input	logic	[4:0] random_num2,
					input logic reset,
			
		  // Output	   
					output logic [10:0] topLeftX,
					output logic [10:0] topLeftY,
					output logic bitMap_sel
					
			
);

// Logic to hold the numbers that were generated
logic [10:0] topLeftX_1;
logic [10:0] topLeftY_1;
logic [10:0] topLeftX_2;
logic [10:0] topLeftY_2;

logic flag;

enum  logic [2:0] {IDLE_ST,        // initial state
						 FIRST_NUM_ST,   // collect first num
						 SECOND_NUM_ST,  // collect second num 
						 LEVELS_ST		  // set level coordinates  
						}  SM_Controller ;

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
			topLeftX	<= 11'b0;
			topLeftY	<= 11'b0;
			bitMap_sel <= 0;
			flag <= 0;
			SM_Controller <= IDLE_ST;
	end
	
	else begin
		
		case(SM_Controller)
		
		//------------
			IDLE_ST: begin
		//------------
		
			if(!enter_is_presed) //to not jump
				flag <= 0;
			 
			if(enter_is_presed && !flag) begin
				SM_Controller <= FIRST_NUM_ST;
				flag <= 1;
				end
			end
	
		//------------
			FIRST_NUM_ST:  begin     // collecting first random num
		//------------
			
		if(!enter_is_presed) //to not jump
			flag <= 0;
			
			// Choosing 1st coordinates
		if (enter_is_presed && !flag) begin
			flag <= 1;
			topLeftX_1 <= random_num1*64 + 15;
			topLeftY_1 <= random_num2*64 + 48;
			SM_Controller <= SECOND_NUM_ST;
			end
				
						
			end 
		
		//------------
			SECOND_NUM_ST:  begin      // collecting second random num
		//------------
			if(!enter_is_presed) //to not jump
				flag <= 0;
	
		// Choosing 2nd coordinates	
			if (enter_is_presed && !flag) begin
				flag <= 1;
				topLeftX_2 <= random_num1*64 + 15;
				topLeftY_2 <= random_num2*64 + 48;
				SM_Controller <= LEVELS_ST;
			end
			
			
				
			end
		//------------------------
			LEVELS_ST : begin  // outputing numbers based on level
		//------------------------
				if(level_select == 1) begin
					bitMap_sel <= 0;
					topLeftX <= topLeftX_1;
					topLeftY <= topLeftY_1;
				end
				
				if(level_select == 2) begin
					bitMap_sel <= 1;
					topLeftX <= topLeftX_2;
					topLeftY <= topLeftY_2;
				end
				
				if(!enter_is_presed) //to not jump
					flag <= 0;
	
				if(enter_is_presed && reset && !flag) begin
					SM_Controller <= IDLE_ST;
					flag <= 1;
				end
			end

		
		endcase  // case 
		
		end
	end

endmodule