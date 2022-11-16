# Nongram Solver
parallelized nonogram solver on FPGA



**BRAM Implementation**

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


VG -
for m rows and n cols:
    m rows -> m * n lines (all the ands together)
    n cols -> n * m lines
each line has at most max(m,n) + 1 slots
bringing the depth = 2mn * (max(m,n) + 1)

for a 2x4
c c c c => 4 lines
c c c c => 4 lines
2 2 2 2

16 lines 
each line can have at most 4 + 1 slots
16 * 5 = 80 slots

Parser- 
to keep line index < 2^12 

Questions-
Not sure why we need bram_row, braam_col, BRAM index in parser



