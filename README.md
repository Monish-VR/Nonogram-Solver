# Nongram Solver
parallelized nonogram solver on FPGA

# Instructions 
To run this code, run "python3 nonogram.py". You may choose to enter a board manually or use a provided, hardcoded board. 

If opting to manually enter a board, please only enter solvable boards. The code can handle boards up to size 11x11.

# Methodology 

This code functions by transmitting boards to and from the solver using UART. The solver itself functions using a FIFO that stores rows and columns and options that would satisfy each row and each column. Over time, the code shortens the FIFO by eliminating options based on known information. Information is considered "known" when there is only a single option left for a given row or column or if each option for a given line assigns the same value for speicific cell. 

The solver was originally written with a serial implementation but now also includes a parallel implementation that solves rows and columns simaltameously. 

# Analysis


# Prerequisites 

Download pyserial. If you have an FPGA but are unable to build, feel free to simply flash out.bit to your computer to run it

# Nonograms

For more infomation about nonograms, check out this wikipdeia link: https://en.wikipedia.org/wiki/Nonogram

# Future Improvements

There are many future imporvements we could use to expand this project. 

More specifically, we hope to explore using larger boards, further parallelizing my doing multiple rows and columns simaltameously, and being better equipped to handle unsolvable boards. 

# Contributors

This code was written by Nina Gerszberg, Veronica Grant, and Dana Rubin for MIT's 6.111/6.205 course as our final project.

# Acknolwedgemnts 

Special thank you to Professor Joe Steinmeyer, TA's Fischer Moseley and Jay Lang for all the help and support they have provided. 
