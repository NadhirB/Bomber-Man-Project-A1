// System-Verilog 'written by Alex Grinshpun May 2018
// New bitmap dudy February 2025
// (c) Technion IIT, Department of Electrical Engineering 2025 



module	enemyBitMap	(	
					input	logic	clk,
					input	logic	resetN,
					input logic	[10:0] offsetX,// offset from top left  position 
					input logic	[10:0] offsetY,
					input	logic	InsideRectangle, //input that the pixel is within a bracket 
					input logic [3:0] direction,

					output logic drawingRequest, //output that the pixel should be dispalyed 
					output logic [7:0] RGBout,  //rgb value from the bitmap 
				   output logic [3:0] HitEdgeCode 
 ) ;

// this is the devider used to acess the right pixel 
localparam  int OBJECT_NUMBER_OF_Y_BITS = 5;  // 2^5 = 32 
localparam  int OBJECT_NUMBER_OF_X_BITS = 5;  // 2^5 = 32


const logic [3:0] TOP =		 4'b0100; 
const logic [3:0] RIGHT =   4'b0010; 
const logic [3:0] LEFT =	 4'b1000; 
const logic [3:0] BOTTOM =  4'b0001; 


logic	[10:0] HitCodeX ;// offset of Hitcode 
logic	[10:0] HitCodeY ;  

// generating a enemy bitmap

localparam logic [7:0] TRANSPARENT_ENCODING = 8'h00;// RGB value in the bitmap representing a transparent pixel 

logic [0:31] [0:31] [7:0] object_colors = {
{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h04,8'h04,8'h04,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h04,8'h04,8'h31,8'h31,8'h31,8'h04,8'h04,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h04,8'h31,8'h31,8'h31,8'h31,8'h31,8'h31,8'h31,8'h04,8'h04,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h04,8'h31,8'h31,8'h04,8'hff,8'h31,8'h31,8'h31,8'h31,8'h31,8'h31,8'h04,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h04,8'h31,8'h31,8'h31,8'h31,8'h31,8'h31,8'h31,8'h31,8'h31,8'h31,8'h04,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'hc0,8'h00,8'h00,8'h04,8'h31,8'h31,8'h31,8'h31,8'h31,8'h31,8'h31,8'h31,8'h31,8'h31,8'h04,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'hc0,8'hc0,8'h00,8'h04,8'h04,8'h04,8'hfe,8'hfe,8'h31,8'h31,8'h31,8'h31,8'h31,8'h04,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'hc0,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h04,8'hfe,8'hfe,8'h31,8'h31,8'h31,8'h31,8'h04,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h04,8'hda,8'h31,8'h31,8'h31,8'h31,8'h04,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h04,8'hfe,8'h31,8'h31,8'h31,8'h31,8'h04,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h04,8'hfe,8'hfe,8'h31,8'h31,8'h31,8'h04,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h04,8'hda,8'hda,8'h31,8'h31,8'h31,8'h04,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h04,8'hfe,8'hfe,8'hfe,8'h31,8'h31,8'h31,8'h04,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h04,8'hfe,8'hfe,8'h31,8'h31,8'h31,8'h04,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h04,8'hda,8'hda,8'hda,8'h31,8'h31,8'h31,8'h04,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h04,8'h04,8'h04,8'h04,8'h04,8'h04,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h04,8'hfe,8'hfe,8'hfe,8'hfe,8'h31,8'h31,8'h31,8'h04,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h04,8'h31,8'h31,8'h31,8'h31,8'h31,8'h31,8'h04,8'h04,8'h00,8'h00},
	{8'h00,8'h00,8'h04,8'h04,8'hfe,8'hfe,8'hfe,8'h31,8'h31,8'h31,8'h04,8'h04,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h04,8'h31,8'h31,8'h31,8'h04,8'h04,8'h04,8'h04,8'h04,8'h04,8'h04,8'h00},
	{8'h00,8'h04,8'hda,8'hda,8'hda,8'hda,8'h31,8'h31,8'h31,8'h04,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h04,8'h31,8'h31,8'h31,8'h04,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h04,8'h04},
	{8'h04,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'h31,8'h31,8'h04,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h04,8'h31,8'h31,8'h04,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h04},
	{8'h04,8'hfe,8'hfe,8'hfe,8'hfe,8'h31,8'h31,8'h31,8'h04,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h04,8'h31,8'h31,8'h04,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h04,8'hda,8'hda,8'hda,8'hda,8'h31,8'h31,8'h31,8'h04,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h04,8'h31,8'h31,8'h04,8'h04,8'h04,8'h04,8'h04,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h04,8'hfe,8'hfe,8'hfe,8'h31,8'h31,8'h31,8'h31,8'h04,8'h04,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h04,8'h31,8'h31,8'h31,8'h31,8'h31,8'h31,8'h04,8'h00,8'h00,8'h00},
	{8'h00,8'h04,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'h31,8'h31,8'h31,8'h31,8'h04,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h04,8'h04,8'h04,8'h04,8'h31,8'h31,8'h31,8'h04,8'h00,8'h00},
	{8'h00,8'h00,8'h04,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'h31,8'h31,8'h31,8'h04,8'h04,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h04,8'h31,8'h31,8'h31,8'h04,8'h00},
	{8'h00,8'h00,8'h00,8'h04,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'h31,8'h31,8'h31,8'h31,8'h04,8'h04,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h04,8'h04,8'h31,8'h31,8'h04},
	{8'h00,8'h00,8'h00,8'h00,8'h04,8'h04,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'h31,8'h31,8'h31,8'h31,8'h31,8'h04,8'h04,8'h04,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h04,8'h04,8'h31,8'h31,8'h31,8'h31,8'h04},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h04,8'hda,8'hda,8'hda,8'hda,8'hda,8'h31,8'h31,8'h31,8'h31,8'h31,8'h31,8'h31,8'h04,8'h04,8'h04,8'h04,8'h04,8'h04,8'h31,8'h31,8'h31,8'h31,8'h31,8'h04,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h04,8'h04,8'hfe,8'hfe,8'hfe,8'hfe,8'h31,8'h31,8'h31,8'h31,8'h31,8'h31,8'h31,8'h31,8'h31,8'h31,8'h31,8'h31,8'h31,8'h31,8'h31,8'h04,8'h04,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h04,8'h04,8'h04,8'hfe,8'hfe,8'h31,8'h31,8'h31,8'h31,8'h31,8'h31,8'h31,8'h31,8'h31,8'h31,8'h31,8'h31,8'h04,8'h04,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h04,8'h04,8'h31,8'h31,8'h31,8'h31,8'h31,8'h31,8'h31,8'h04,8'h04,8'h04,8'h04,8'h04,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h04,8'h04,8'h31,8'h31,8'h31,8'h04,8'h04,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h04,8'h04,8'h04,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00}};

	

//////////--------------------------------------------------------------------------------------------------------------=


logic [0:3] [0:3] [3:0] hit_colors = 
			{16'h8442,
			 16'h8842,
			 16'h8122,
			 16'h1111};
 
 

// pipeline (ff) to get the pixel color from the array 	 

//////////--------------------------------------------------------------------------------------------------------------=
always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		RGBout <=	8'h00;
		HitEdgeCode <= 3'h0;

	end

	else begin
		RGBout <= TRANSPARENT_ENCODING ; // default  
		HitEdgeCode <= 3'h0;

		if (InsideRectangle == 1'b1 ) 
		begin // inside an external bracket
			case(direction)
				LEFT  : RGBout <= object_colors[offsetY][offsetX];
				RIGHT : RGBout <= object_colors[offsetY][31 - offsetX];
				TOP   : RGBout <= object_colors[31 - offsetX][offsetY];
				BOTTOM: RGBout <= object_colors[offsetX][31 - offsetY];
			endcase
			
			HitEdgeCode <= hit_colors[offsetY >> 3][offsetX >> 3];	//get hitting edge code from the colors table  
		
		end  	
	end
		
end

//////////--------------------------------------------------------------------------------------------------------------=
// decide if to draw the pixel or not 
assign drawingRequest = (RGBout != TRANSPARENT_ENCODING ) ? 1'b1 : 1'b0 ; // get optional transparent command from the bitmpap   

endmodule