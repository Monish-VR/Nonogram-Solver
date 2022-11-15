# Nongram Solver
parallelized nonogram solver on FPGA



# BRAM Implementation-
BRAM width will be size of 13.
Each slot in the BRAM will have Cell Number, Boolean Value.
We aim to have up to 2^12 nanogram cells (represented by 12 bits) and 1 bit for Bool.

Bram Depth-
Let's say we have m rows and n cols.
The maximum # of possible solutions for each row is n for when there's only one cell to color in black-
So for the maximum amount of slots for representing rows we need n * ( n + 1 ) 
(Max_options * ( amount of slots per option ) )
WLOG same applies to cols.
The maximum amount of lines we can have is in case we have 2^x cells is 2^x + 1 (where the board is very tall and narrow)
Therefore, BRAM depth should be 
(2^12 + 1 ) * 2^12 = **2^24 + 2^13 + 2^12 + 2**



