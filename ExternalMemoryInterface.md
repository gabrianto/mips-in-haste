# Problem #

We had several options in designing the external memory interface.
  1. Use a synchronous external memory (each memory has a clock to sample the rest of the control signals
  1. Assume the clock is driven by our design and have a delay line to mimic the memory clock to output delay
  1. Use an asynchronous memory that has a valid-data output and may have a clock or just CE that serve as a clock

# Solution #

Since we intended to swap in the asynchronous MIPS into existing system we assumed the system has its own clock.

**our assumption is that the clock frequency is such that the memory output data is valid before the fall of the clock**