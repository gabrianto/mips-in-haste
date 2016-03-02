# Problem #

Consider the program:
  1. lw $s1 10($s0)
  1. add $s2 $s1 $s3

There are 2 cycles to stall (assuming the RF is write then read).
# Solution #

Using similar approach to RAW the Exe can compare to previous cycles to see the lw happened on a relevant register. When this happens the Exe need to stall until the relevant result is provided from the Write-Back.

Since we may get two successive lw we will enhance the Write-Reg with an extra bit modulo 2.
When we receive the result from the Write-Back it will include that bit to compare with.

Need to make sure we can track matching on both registers !
So need to track received data of each of them.