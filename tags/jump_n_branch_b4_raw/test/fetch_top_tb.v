`timescale 1ns/1ps
module fetch_test;
   reg reset__R; // reset request

   // output channels
   reg         f2d_A;  // f2d ack
   wire [63:0] f2d;    // f2d is 64 bit
   wire        f2d_R;  // f2d req

   // input channels - bit the fetch is active!
   wire        d2f_R;
   reg  [32:0] d2f;
   reg         d2f_A;

   // memory interface
   reg         IM_CLK;
   reg  [31:0] IM_DATA;
   wire [31:0] IM_ADDR;

   // the memory
   reg  [31:0] mem [0:1023] ;
 
   initial begin
      $readmemb("../test/memory.list", mem); // memory_list is memory file
   end

   // module fetch_top(Z_R, Z_A, d2f_R, d2f_A, d2f, f2d_R, f2d, f2d_A, IM_CLK, 
   //                  IM_ADDR, IM_DATA );
   fetch_top f (.Z_R (reset__R), 
	   .d2f_R(d2f_R), .d2f(d2f), .d2f_A(d2f_A), 
	   .f2d_R(f2d_R), .f2d(f2d), .f2d_A(f2d_A),
	   .IM_CLK(IM_CLK), .IM_ADDR(IM_ADDR), .IM_DATA(IM_DATA) );
   
   // simulation duration
   initial
     begin
	$dumpfile("fetch_top.vcd");
	$dumpvars(10, fetch_test); 
	#10000 $stop;
	$finish;
     end
      
   // drive the design clock
   initial
     begin
	// reset operation
	reset__R<=0;
	IM_CLK<=0;
	
	#20 reset__R<=1;

        forever
	  begin
	     #100 IM_CLK<=1;
	     #10 IM_DATA <= mem[IM_ADDR];

	     #100 IM_CLK<=0;
	  end
     end // initial begin

   // channels 
   initial
     begin
	f2d_A<=0;
	#40 forever
	  begin
	     wait (f2d_R); 
	     #10 f2d_A<=1;
	     wait (!f2d_R);
	     #10 f2d_A<=0;
	  end
	
     end // initial begin
   
   // channels 
   initial
     begin
	d2f_A<=0;
	d2f <= 33'b0;
	#40 forever
	  begin
	     wait (d2f_R); 
	     #10 d2f_A<=1;
	     wait (!d2f_R);
	     #10 d2f_A<=0;
	  end
	
     end // initial begin

endmodule

