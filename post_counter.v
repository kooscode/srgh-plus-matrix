`timescale 1ns / 1ps
module post_counter(
	 input cpu_reset,
    input postbit1,
    output reg glitch,
	 output reg i2c_send,
	 output led
    );
	 

	// Post D8 (Calculate boot loader Hash) happens at Post pin 1 rise/fall count 10
	`define Post_Zero 4'd0

	// Post D8 (Calculate boot loader Hash) happens at Post pin 1 rise/fall count 10
	`define Post_Slowdown 4'd10

	// Post DA (Validate boot loader Hash) happens at Post pin 1 rise/fall count 11
	`define Post_Glitch 4'd11

	// If There was not RESET at this post count yet, SMC recorded Glitch SUCCESS!
	`define Post_Max 4'd15

	// post counter
	reg [3:0] post_cnt;
	assign led = postbit1;

	// Register Initialization values
	initial 
	begin
		glitch = 0;
		i2c_send = 0;
		post_cnt = 0;
	end
	
	// B_Post is connected to the Post bus Pin 1
	// This will just count posts 
	always @(posedge postbit1 or negedge postbit1)
	begin
		// Only count posts when CPU RESET is HIGH
		if (cpu_reset && (post_cnt < `Post_Max))
		begin
			//count up to max then wait for reset
			if (post_cnt < `Post_Max)
				post_cnt <= post_cnt + 1;
		end				
		// CPU in RESET, start from Post 0
		if (!cpu_reset) 
		begin
			post_cnt <= `Post_Zero;
		end
	end	

	//process posts 
	always @(post_cnt)
	begin		
	
		if (post_cnt[3:0] == `Post_Slowdown)
		begin
			// send slowdown
			glitch <= 0;
			i2c_send <= 1;
		end
		else if (post_cnt[3:0] == `Post_Glitch) 
		begin
			// glitch and send speedup
			glitch <= 1;
			i2c_send <= 0;
		end
		else
		begin
			//reset
			glitch <= 0;
			i2c_send <= 0;
		end
	end
	
	
endmodule
