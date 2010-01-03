`timescale 1ns/1ps
module decode_test;
   reg reset__R; // reset request

   // input channels
   wire        f2d_R;  // f2d req
   reg  [63:0] f2d;    // f2d is 64 bit
   reg         f2d_A;  // f2d ack

   wire        m2d_R;
   reg  [31:0] m2d;
   reg         m2d_A; 
   
   wire        w2d_R;
   reg  [37:0] w2d;
   reg         w2d_A; 

   // output channels - bit the decode is active!
   wire        d2f_R;
   wire [32:0] d2f;
   reg         d2f_A;

   wire         d2e_R;
   wire [118:0] d2e;
   reg          d2e_A;

   // the commands memory
   reg  [9:0]  addr, next_addr;
   reg  [31:0] mem [0:1023];

   // data from write back
   reg [31:0]  seq_num;
   reg [5:0]   reg_num;
   reg         reg_write;
   
   initial begin
      $readmemb("../test/dec_mem.list", mem); // memory_list is memory file
   end

   decode_top f (.Z_R (reset__R),
             .f2d_top_R(f2d_R), .f2d_top_A(f2d_A), .f2d_top(f2d), 
             .m2d_top_R(m2d_R), .m2d_top_A(m2d_A), .m2d_top(m2d), 
             .w2d_top_R(w2d_R), .w2d_top_A(w2d_A), .w2d_top(w2d), 
             .d2f_R(d2f_R), .d2f(d2f), .d2f_A(d2f_A),
             .d2e_R(d2e_R), .d2e(d2e), .d2e_A(d2e_A) );
   
   // simulation duration
   initial
     begin
	     $dumpfile("decode_top.vcd");
	     $dumpvars(10, decode_test);
        
	     #10000 $stop;
	     $finish;
     end
   
   // monitoring result
   initial
     begin
	#20 $display("              Time   f2d_R/A w2d_R/A m2d_R/A d2f_R/A d2e_R/A ");
	    $display("              ====== ======= ======= ======= ======= ======= ");
	    $monitor($time," 0x%x/0x%x 0x%x/0x%x 0x%x/0x%x 0x%x/0x%x 0x%x/0x%x",
                      f2d_R, f2d_A, w2d_R, w2d_A, m2d_R, m2d_A, d2f_R, d2f_A, d2e_R, d2e_A);
     end

   // drive the design reset and f2d
   initial
     begin
	     // reset operation
	     reset__R<=0;
	     #20 reset__R<=1;
	     seq_num <=0;
        f2d_A <=0;
        addr <= 0;
        
        // drive the f2d with consecutibe inputs from the memory
        forever
	       begin
             wait (f2d_R);
             next_addr <= addr+4;
             #10 f2d <= {mem[addr>>2], 22'b0000000000000000000000, next_addr};
             #10 f2d_A <= 1;
             wait(!f2d_R);
             #10 f2d_A <= 0;
             addr <= next_addr;
             seq_num <= seq_num + 1;
	       end
     end 

   // drive the w2d with result that is a sequence number, 
   // its modulo 32 and random reg write
   // start driving after 2 outputs on d2e only
   initial
     begin
	     // inits
        reg_num <=0;
        reg_write <= 0;
        w2d_A <= 0;
        
        // drive the f2d with consecutibe inputs from the memory
        forever
	       begin
             // do not send anything for 3 turns
             #10 if (seq_num > 2'b10) 
               begin
                  wait(w2d_R);
                  #10 w2d <= {seq_num,reg_num,reg_write};
                  #10 w2d_A <= 1;
                  wait(!w2d_R);
                  #10 w2d_A <= 0;
                  reg_num <= reg_num + 1;
                  reg_write = !reg_write;
               end
	       end
     end 
   
   // read the d2f output channel
   initial
     begin
	     d2f_A<=0;
	     #40 forever
	       begin
	          wait (d2f_R); 
	          #10 d2f_A<=1;
	          wait (!d2f_R);
	          #10 d2f_A<=0;
	       end
	     
     end // initial begin
   
   // read the d2f output channel
   initial
     begin
	     d2e_A<=0;
	     #40 forever
	       begin
	          wait (d2e_R); 
	          #10 d2e_A<=1;
	          wait (!d2e_R);
	          #10 d2e_A<=0;
	       end
	     
     end // initial begin
   
   // no driving of the m2d channel
   initial
     begin
	     m2d_A <=0;
	     #40 forever
	       begin
	          wait (m2d_R); 
             m2d <= 0;
	          #10 m2d_A<=1;
	          wait (!m2d_R);
	          #10 m2d_A<=0;
	       end
	     
     end // initial begin

endmodule

