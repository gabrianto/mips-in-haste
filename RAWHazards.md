# Problem #

When an R-Type command involving result from previous 2 commands the result is not
available yet in the RF (since Write-Back did not happen yet).
We need to stall or forward the known result to the exe to avoid stalling

# Solution #

All changes are in execute

Added State:

Add 2 levels of memory pipe registers holding two previous cycles data:
  * RegWrite - the control telling they result of that cycle will be written to Reg
  * WriteReg[4:0] - the register to be written
  * ALUOut - the result that would be written into that Reg

Added Logic:

For each of the two levels:
If stored RegWrite and Rs || Rt == Compare stored WriteReg
Take the result from the relevant matching.