# Problem #

When register is to be loaded from memory the next
commands depending on that register may start before the register is written back.

# Solution #

It is better to handle this in the Exe to avoid the Decode stall for 3 cycles.
So the exe will need to hold yet another pipe for outstanding MemToRegs

It will have 2 slots for MemToReg in the pipe.
When sending push into that fifo.
When receiving from back from Mem can pop that pipe and store last result and reg

On each command check if need to stall or use the last register if matching