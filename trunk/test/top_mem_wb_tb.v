`timescale 1ns/1ps
module design_test;
reg[31:0] Mem [0:255];
reg[15:0] i;
wire[31:0] wadd, wdata;
wire wr;

reg Z_R,  Clk, rdy;
reg[31:0] rdata;


//e2m channel
wire EMreq;
reg[31:0] EMALUOut, EMWriteData;
reg[4:0] EMWriteReg;
reg EMRegWrite, EMMemtoReg, EMMemWrite, EMAck;

// m2d channel
reg MDAck;
wire MDreq;
wire[31:0] MDALUOut;

// m2e channel
reg MEAck;
wire MEreq;
wire[31:0] MEALUOut;

// w2e channel
reg WEAck;
wire WEreq;
wire[31:0] WEALUOut;
wire[4:0] WEWriteReg;


//w2d channel
wire WDreq;
reg[31:0] WDResult_R;
reg[4:0] WDWriteReg_R;
reg WDRegWrite_R, WDAck;
wire[31:0] WDResult;
wire[4:0] WDWriteReg;
wire WDRegWrite;

top_mem_wb t1 (.Z_R(Z_R), .e2m_R(EMreq), .e2m_A(EMAck), .e2m({EMALUOut, EMWriteData,EMWriteReg,EMRegWrite, EMMemtoReg, EMMemWrite}),.M_CLK(Clk),.M_WE(wr),.M_ADDR(wadd),.M_WR_DATA(wdata),.w2d_R(WDreq),.w2d({WDResult,WDWriteReg,WDRegWrite}),.w2d_A(WDAck),.w2e_R(WEreq),.w2e_A(WEAck),.w2e({WEALUOut, WEWriteReg}),.M_RD_DATA(rdata),.M_RD_VALID(rdy));

//simulation duration
initial 
begin
  $dumpfile("top_mem_wb.vcd");
  $dumpvars(10,design_test);
// run simvision on the vcd
	#50000 $stop;
	$finish;
end

//monitoring the results - start with the RAM then add the writeback pipe
initial 
begin
	#40
	$display("                 Time |Clk |EMreq | EMAck | EMALUout  | EMWriteData | EMWriteReg | EMRegWrite | EMMemtoReg | wadd      | wdata     | wr | rdata      | WDResult   | WDWriteReg | WDRegWrite");
	$display("                -------------------------------------------------------------------------------------------------------------------------------------------------------------");
//	$monitor($time,"  | 0x%x| 0x%x  | 0x%x  |0x%x|0x%x|      0x%x  |         0x%x |       0x%x |      0x%x     | 0x%x| 0x%x| 0x%x | 0x%x| 0x%x |     0x%x     |     0x%x     ",Clk,EMreq, EMAck,EMALUOut,EMWriteData, EMWriteReg,EMRegWrite,EMMemtoReg,wadd,wdata,wr,rdata, WDResult_R,WDWriteReg_R, WDRegWrite_R);
	$monitor($time,"  | 0x%x| 0x%x  | 0x%x   |0x%x |0x%x   |      0x%x  |        0x%x |        0x%x |0x%x |0x%x |0x%x | 0x%x | 0x%x |     0x%x   | 0x%x ",Clk,EMreq, EMAck,EMALUOut,EMWriteData, EMWriteReg,EMRegWrite,EMMemtoReg,wadd,wdata,wr,rdata, WDResult_R,WDWriteReg_R, WDRegWrite_R);
end

// RAM init
initial
begin
	for (i =0; i <256 ; i = i+1) begin
		Mem[i] = i;
	end
end

// clocking..
initial begin
	Z_R = 0;
	Clk = 0;
	#20 Z_R = 1; // end of reset
	
	#20 ;
	forever
	   begin
		Clk = 1;
		#500 Clk = 0;
		#500;
	   end
end


// RAM modeling: only 256 entries; will therefore wrap on address (addr upper bits need visual testing and mod-read/write validation
initial begin
	rdy = 0;
	rdata = 0;
	#20 forever
	  begin
		@(posedge Clk) begin
			rdy = 0;
			if (wr) Mem[(wadd)%256] = wdata;
			else rdata = Mem[(wadd)%256];
			#10 rdy = 1;
			end
	  end

end

// pulling data out of the w2d pipe
initial begin
	WDAck = 0;
	WDResult_R = 0;
	WDWriteReg_R = 0;
	WDRegWrite_R = 0;
	#20 forever begin
		wait(WDreq);
		WDResult_R = WDResult;
		WDWriteReg_R = WDWriteReg;
		WDRegWrite_R = WDRegWrite;
		#10 WDAck = 1;
		wait(!WDreq);
		#10 WDAck = 0;
	end
end

// pulling data out of the w2epipe - just making sure it does not block operation
initial begin
	WEAck = 0;
	#20 forever begin
		wait(WEreq);
		#10 WEAck = 1;
		wait(!WEreq);
		#10 WEAck = 0;
	end
end	

// testing the mem and wb
initial begin
	EMALUOut = 0;
	EMWriteData = 0;
	EMWriteReg = 0;
	EMMemWrite = 0;
	EMRegWrite = 0; // write-back to reg file indication - set on R types and lw
	EMMemtoReg = 0; // mem/~ALU writeback data selector
	EMAck = 0;
	#40;
	// write 0x101 to addr-1
	wait (EMreq);
	#5 EMWriteData = 32'h00000101; 
	EMALUOut = 32'h00000001; 
	EMMemWrite = 1;
	#5 EMAck = 1;
	wait (!EMreq);
	#5 EMAck = 0;	
	// write 0x102 to addr-2
	wait (EMreq);
	#5 EMWriteData = 32'h00000102; 
	EMALUOut = 32'h00000002; 
	EMMemWrite = 1;
	#5 EMAck = 1;
	wait (!EMreq);
	#5 EMAck = 0;
	// write 0x104 to addr-4
	wait (EMreq);
	#5 EMWriteData = 32'h00000104; 
	EMALUOut = 32'h00000004; 
	EMMemWrite = 1;
	#5 EMAck = 1;
	wait (!EMreq);
	#5 EMAck = 0;
	// write 0x108 to addr-8
	wait (EMreq);
	#5 EMWriteData = 32'h00000108; 
	EMALUOut = 32'h00000008; 
	EMMemWrite = 1;
	#5 EMAck = 1;
	wait (!EMreq);
	#5 EMAck = 0;
	// write 0x110 to addr-16
	wait (EMreq);
	#5 EMWriteData = 32'h00000110; 
	EMALUOut = 32'h00000010; 
	EMMemWrite = 1;
	#5 EMAck = 1;
	wait (!EMreq);
	#5 EMAck = 0;
	// write 0x120 to addr-32
	wait (EMreq);
	#5 EMWriteData = 32'h00000120; 
	EMALUOut = 32'h00000020; 
	EMMemWrite = 1;
	#5 EMAck = 1;
	wait (!EMreq);
	#5 EMAck = 0;
	// write 0x140 to addr-64
	wait (EMreq);
	#5 EMWriteData = 32'h00000140; 
	EMALUOut = 32'h00000040; 
	EMMemWrite = 1;
	#5 EMAck = 1;
	wait (!EMreq);
	#5 EMAck = 0;
	// write 0x180 to addr-128
	wait (EMreq);
	#5 EMWriteData = 32'h00000180; 
	EMALUOut = 32'h00000080; 
	EMMemWrite = 1;
	#5 EMAck = 1;
	wait (!EMreq);
	#5 EMAck = 0;
	// read addr-0 to reg 8
	wait (EMreq);
	#5 EMALUOut = 32'h00000000; 
	EMMemWrite = 0;
	EMRegWrite = 1;
	EMMemtoReg = 1;
	EMWriteReg = 8;
	#5 EMAck = 1;
	wait (!EMreq);	
	#5 EMAck = 0;
	// read addr-1 to reg 0
	wait (EMreq);
	#5 EMALUOut = 32'h00000001; 
	EMMemWrite = 0;
	EMRegWrite = 1;
	EMMemtoReg = 1;
	EMWriteReg = 0;
	#5 EMAck = 1;
	wait (!EMreq);	
	#5 EMAck = 0;
	// read addr-2 to reg 1
	wait (EMreq);
	#5 EMALUOut = 32'h00000002; 
	EMMemWrite = 0;
	EMRegWrite = 1;
	EMMemtoReg = 1;
	EMWriteReg = 1;
	#5 EMAck = 1;
	wait (!EMreq);	
	#5 EMAck = 0;
	// read addr-4 to reg 2
	wait (EMreq);
	#5 EMALUOut = 32'h00000004; 
	EMMemWrite = 0;
	EMRegWrite = 1;
	EMMemtoReg = 1;
	EMWriteReg = 2;
	#5 EMAck = 1;
	wait (!EMreq);	
	#5 EMAck = 0;
	// read addr-16 to reg 8
	wait (EMreq);
	#5 EMALUOut = 32'h00000010; 
	EMMemWrite = 0;
	EMRegWrite = 1;
	EMMemtoReg = 1;
	EMWriteReg = 8;
	#5 EMAck = 1;
	wait (!EMreq);	
	#5 EMAck = 0;
	// read addr-32 to reg 16
	wait (EMreq);
	#5 EMALUOut = 32'h00000020; 
	EMMemWrite = 0;
	EMRegWrite = 1;
	EMMemtoReg = 1;
	EMWriteReg = 5'h10;
	#5 EMAck = 1;
	wait (!EMreq);	
	#5 EMAck = 0;
	// read addr-64 to reg 31
	wait (EMreq);
	#5 EMALUOut = 32'h00000040; 
	EMMemWrite = 0;
	EMRegWrite = 1;
	EMMemtoReg = 1;
	EMWriteReg = 5'h1F;
	#5 EMAck = 1;
	wait (!EMreq);	
	#5 EMAck = 0;
	// read addr-128 to reg 9
	wait (EMreq);
	#5 EMALUOut = 32'h00000080; 
	EMMemWrite = 0;
	EMRegWrite = 1;
	EMMemtoReg = 1;
	EMWriteReg = 5'h09;
	#5 EMAck = 1;
	wait (!EMreq);	
	#5 EMAck = 0;
	// write 0xACACACAC to addr-127
	wait (EMreq);
	#5 EMWriteData = 32'hACACACAC; 
	EMALUOut = 32'h0000007F; 
	EMMemWrite = 1;
	#5 EMAck = 1;
	wait (!EMreq);
	#5 EMAck = 0;
	// read addr-63 to reg 10
	wait (EMreq);
	#5 EMALUOut = 32'h0000003F; 
	EMMemWrite = 0;
	EMRegWrite = 1;
	EMMemtoReg = 1;
	EMWriteReg = 5'h0A;
	#5 EMAck = 1;
	wait (!EMreq);
	#5 EMAck = 0;
	// stall inpipe for 200 to see the read completes
	#200;
	
//e2m channel
//wire EMreq;
//reg[31:0] EMALUOut, EMWriteData;
//reg[2:0] EMWriteReg;
//reg EMRegWrite, EMMemtoReg, EMMemWrite, EMAck;
end




endmodule
