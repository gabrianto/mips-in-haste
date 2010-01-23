`timescale 1ns/1ps
module design_test;

reg Z_R;


//e2m channel
wire EMreq;
wire[31:0] EMALUOut, EMWriteData;
wire[4:0] EMWriteReg;
wire EMRegWrite, EMMemtoReg, EMMemWrite;
reg[31:0] EMALUOut_R, EMWriteData_R;
reg[4:0] EMWriteReg_R;
reg EMRegWrite_R, EMMemtoReg_R, EMMemWrite_R, EMAck;


//d2e channel
wire DEreq;
reg[31:0] DESrcA, DESrcB, DESignImm;
reg[4:0] DERs, DERt, DERd;
reg DERegWrite, DEMemtoReg, DEMemWrite, DEAck, DEALUSrc, DERegDst;
reg[2:0] DEALUCtrl;

top_exec t1 (.Z_R(Z_R), .d2e_top_R(DEreq), .d2e_top_A(DEAck),.d2e_top({DESrcA,DESrcB,DERs,DERt,DERd,DESignImm,DERegWrite,DEMemtoReg,DEMemWrite,DEALUCtrl,DEALUSrc,DERegDst}),.e2m_R(EMreq), .e2m_A(EMAck), .e2m({EMALUOut, EMWriteData,EMWriteReg,EMRegWrite, EMMemtoReg, EMMemWrite}));

//simulation duration
initial 
begin
  $dumpfile("top_exec.vcd");
  $dumpvars(10,design_test);
// run simvision on the vcd
	#50000 $stop;
	$finish;
end

//monitoring the results - start with the RAM then add the writeback pipe
initial 
begin
	#40
	$display("               Time | DEreq | DEAck |  DESrcA   |  DESrcB    |  DERs| DERt|DERd|  DESignImm| DEregWrite |DEMemtoReg |DEMemWrite |DEALUCtrl|DEALUSrc|DERegDst |EMreq| EMAck | EMALUout |EMWriteData | EMMemWrite| EMWriteReg |EMRegWrite| EMMemtoReg");
	$display("--------------------|-------|-------|-----------|------------|------|-----|----|-----------|------------|-----------|-----------|---------|--------|-------- |-----|-------|----------|------------|-----------|------------|----------|-----------");
	$monitor($time,"    0x%x |  0x%x | 0x%x | 0x%x |  0x%x| 0x%x|0x%x| 0x%x|       0x%x  |    0x%x    |      0x%x  |     0x%x |    0x%x |   0x%x   | 0x%x |   0x%x |0x%x| 0x%x |  0x%x      |   0x%x     |   0x%x    |    0x%x  ",DEreq,DEAck,DESrcA,DESrcB,DERs,DERt,DERd,DESignImm,DERegWrite,DEMemtoReg,DEMemWrite,DEALUCtrl,DEALUSrc,DERegDst,EMreq,EMAck,EMALUOut,EMWriteData,EMMemWrite,EMWriteReg,EMRegWrite,EMMemtoReg);
end

// clocking..
initial begin
	Z_R = 0;
	#20 Z_R = 1; // end of reset
end


// pulling data out of the e2m pipe
initial begin
	EMAck = 0;
	EMALUOut_R = 0;
	EMWriteData_R = 0;
	EMWriteReg_R = 0;
	EMRegWrite_R =0;
	EMMemtoReg_R = 0;
	EMMemWrite_R = 0;
	#20 forever begin
		wait(EMreq);
		EMALUOut_R = EMALUOut;
		EMWriteData_R = EMWriteData;
		EMWriteReg_R = EMWriteReg;
		EMRegWrite_R = EMRegWrite;
		EMMemtoReg_R = EMMemtoReg;
		EMMemWrite_R = EMMemWrite;
		#10 EMAck = 1;
		wait(!EMreq);
		#10 EMAck = 0;
	end
end	

// testing the execute
initial begin
	DESrcA = 0;
	DESrcB = 0;
	DESignImm = 0;
	DERs = 0;
	DERt = 0;
	DERd = 0;
	DERegWrite = 0;
	DEMemtoReg = 0;
	DEMemWrite = 0;
	DEAck = 0;
	DEALUSrc = 0;
	DERegDst = 0;
	DEALUCtrl = 0;

	#40;
// add SrcA + SrcB  result into Rd (A5A5A5A5 + 5A5A5A5A ; Rt = 5, Rd = a)
	wait (DEreq);
	#5 DEALUCtrl = 3'b010;
	DESrcA = 32'hA5A5A5A5;
	DESrcB = 32'h5A5A5A5A;
	DERt = 5;
	DERd = 5'h0a;
	DERegDst = 1;  //Rd/Rt#
	DEALUSrc = 0; // reg#/Imm
	DERegWrite = 1; // writeback of the reg
	#5 DEAck = 1;
	wait (!DEreq);
	#5 DEAck = 0;	
// add SrcA + Imm   result into Rt
	wait (DEreq);
	#5 DEALUCtrl = 3'b010;
	DESrcA = 32'hA5A5A5A5;
	DESrcB = 32'h11111111;
	DESignImm = 32'h25252525;
	DERt = 5;
	DERd = 5'h0a;
	DERegDst = 0;  //Rd/Rt#
	DEALUSrc = 1; // reg#/Imm
	DERegWrite = 1; // writeback of the reg
	#5 DEAck = 1;
	wait (!DEreq);
	#5 DEAck = 0;	
// sub SrcA - SrcB  result into Rd
	wait (DEreq);
	#5 DEALUCtrl = 3'b110;
	DESrcA = 32'hA5A5A5A5;
	DESrcB = 32'h5A5A5A5A;
	DERt = 3;
	DERd = 5'h11;
	DERegDst = 1;  //Rd/Rt#
	DEALUSrc = 0; // reg#/Imm
	DERegWrite = 1; // writeback of the reg
	#5 DEAck = 1;
	wait (!DEreq);
	#5 DEAck = 0;	
// and SrcA * SrcB into Rd
	wait (DEreq);
	#5 DEALUCtrl = 3'b000;
	DESrcA = 32'hA5A5A5A5;
	DESrcB = 32'h5AFF5AFF;
	DERt = 3;
	DERd = 5'h1F;
	DERegDst = 1;  //Rd/Rt#
	DEALUSrc = 0; // reg#/Imm
	DERegWrite = 1; // writeback of the reg
	#5 DEAck = 1;
	wait (!DEreq);
	#5 DEAck = 0;	
// or  SrcA + SrcB into Rd
	wait (DEreq);
	#5 DEALUCtrl = 3'b001;
	DESrcA = 32'hA5A5A5A5;
	DESrcB = 32'h5A005A00;
	DERt = 3;
	DERd = 5'h5;
	DERegDst = 1;  //Rd/Rt#
	DEALUSrc = 0; // reg#/Imm
	DERegWrite = 1; // writeback of the reg
	#5 DEAck = 1;
	wait (!DEreq);
	#5 DEAck = 0;	
// slt  SrcA < SrcB  into Rd bit(0): TRUE
	wait (DEreq);
	#5 DEALUCtrl = 3'b111;
	DESrcA = 32'h05A5A5A5;
	DESrcB = 32'h5A005A00;
	DERt = 3;
	DERd = 5'h5;
	DERegDst = 1;  //Rd/Rt#
	DEALUSrc = 0; // reg#/Imm
	DERegWrite = 1; // writeback of the reg
	#5 DEAck = 1;
	wait (!DEreq);
	#5 DEAck = 0;	
// slt  SrcA < SrcB  into Rd bit(0): FALSE
	wait (DEreq);
	#5 DEALUCtrl = 3'b111;
	DESrcA = 32'h05A5A5A5;
	DESrcB = 32'h05A5A5A5;
	DERt = 3;
	DERd = 5'h5;
	DERegDst = 1;  //Rd/Rt#
	DEALUSrc = 0; // reg#/Imm
	DERegWrite = 1; // writeback of the reg
	#5 DEAck = 1;
	wait (!DEreq);
	#5 DEAck = 0;	
	
		

end




endmodule
