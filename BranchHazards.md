# Problem #

When a branch command is provided it poses 2 problems:
  1. The branch decision may be dependent on register values that are being calculated in exe, mem or wb
  1. The fetcher may not continue new instructions until the resolution about the branch is made

# Solution #

The first problem may be handled by tracking target registers that will be updated in future wb's. There are 3 pipe stages after decode so the decode needs to store the 3 possible registers that pending an update. Zero means that there is no update.
When a branch command is decoded the registers involved can be compared (in parallel) to all the pending updates. This comparison has now to happen after every write-back and once cleared the result of the branch can be computed

The second problem is already handled by the feedback required from decode to fetch.
On every fetch the decode has to respond with branch flag and next pc address before the next fetch happens. This means that the machine will stall if there is a branch hazard