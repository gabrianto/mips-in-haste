# Introduction #
How to prevent the asynchronous order of the Write Back from reading an un-written RF
entry?

# Problem #

The problem is that we want to get write data and write it before we read.
  1. But when the machine is empty we do not get data from the Write-Back.
  1. When the machine stalls we still need to write the data in.

We need to make sure that if there was supposed to be a returning write-back the write happens before the read.

# Solution #

We can simply count how many data sets were sent down the pipe versus how many write back happened. If there were > 3 sent vs write back we need to wait for write-back.
Implementation is a simple number-of-outstanding counter