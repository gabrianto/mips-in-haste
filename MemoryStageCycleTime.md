# Problem #
Since the machine is asynch, we need to wait till we have a valid e2m channel-data, then setup the mem addr/ctl, then wait for the read-data to return (negedge of NEXT clock) and then drive the result to m2w pipe.

Option 1: - We could read the next e2m command before ocmpleting the above and save the information till the m-cycle completes. However this will effectivley create another pipeline stage here. COMPLICATED. Is this worth while?

Option 2: do everything in series - which means we do not utilize the memory every cycle (1/2 clk rate at best)

# Solution #