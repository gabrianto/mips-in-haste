`timescale 1ns/1ps
module mips_test;
   reg reset__R; // reset request

   // input signals
   reg        CLK;  
   reg [31:0] IM_DATA;    
   reg [31:0] DM_RD_DATA;

   // output signals
   wire [31:0] IM_ADDR;
   wire        DM_WE;
   wire [31:0] DM_ADDR;
   wire [31:0] DM_WR_DATA;

   // instruction and data memories
   reg  [9:0]  addr, next_addr;
   reg  [31:0] inst_mem [0:1023];
   reg  [31:0] data_mem [0:1023];
   
   initial begin
      $readmemb("./inst_mem.list", inst_mem); // the memory file
      $readmemb("../test/data_mem.list", data_mem); // the memory file
   end

   mips mips(.Z_R(reset__R),
             .IM_CLK(CLK), .IM_ADDR(IM_ADDR), .IM_DATA(IM_DATA), 
             .DM_CLK(CLK), .DM_WE(DM_WE), .DM_ADDR(DM_ADDR), .DM_WR_DATA(DM_WR_DATA), 
             .DM_RD_DATA(DM_RD_DATA) );
   
   // simulation duration
   initial
     begin
	     $dumpfile("mips.vcd");
	     $dumpvars(10, mips_test);
        
	     #10000 $stop;
	     $finish;
     end

   // monitoring result
   initial
     begin
	     #20 $display("             Time   | CLK | IM_ADDR    | IM_DATA    | DM_WE | DM_ADDR    | DM_WR_DATA | DM_RD_DATA |");
	         $display("             ====== | === | ========== | ========== | ===== | ========== | ========== |");
        
	     $monitor($time,"| 0x%x | 0x%x | 0x%x |  0x%x  | 0x%x | 0x%x | 0x%x |",
                 CLK, IM_ADDR, IM_DATA, DM_WE, DM_ADDR, DM_WR_DATA, DM_RD_DATA);
     end

   // do your thing
   initial begin
	   // reset operation
	   reset__R<=0;
      CLK <= 0;
	   #100 reset__R<=1;
      
      // drive the f2d with consecutibe inputs from the memory
      forever
	     begin
           #200 CLK <= 1;
           IM_DATA  <= inst_mem[IM_ADDR>>2];
           if (DM_WE)
             begin
                data_mem[DM_ADDR>>2] = DM_WR_DATA;
                #200 CLK <= 0;
             end
           else
             begin 
                #100 if (DM_ADDR > 8'hff)
                  DM_RD_DATA <= 32'hffffffff;
                else
                  DM_RD_DATA <= data_mem[DM_ADDR>>2];
                #200 CLK <= 0;
             end
	     end
   end 
   
endmodule

