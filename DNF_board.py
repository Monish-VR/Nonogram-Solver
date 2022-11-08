import serial
from serial.tools import list_ports
import struct

PORT_NAME = None

def get_sols(spots, conds):
    all_solutions = []

    new_line = []
    
    if (len(conds) == 0):
        if spots > 0:
            return [[0]*spots]
        else:
            return [[]]
    elif (spots == 0):
        return None

    cond = conds[0]
    if spots < cond:
        return None
    for i in range(cond):
        new_line.append(1) #filling black cells
    
    #we take the solution- fill cells with black
    remaining = get_sols(spots - 1 - cond, conds[1:])
    if remaining is not None: # if theres more to fill we want to make sure we seperate with 0
        if spots - cond > 0:
            new_line.append(0)
        for sol in remaining: # 
            all_solutions.append(new_line.copy() + sol)

    # we don't take solution, skip a cell
    remaining = get_sols(spots - 1, conds)     
    if remaining is not None:
        for sol in remaining:
            all_solutions.append([0] + sol)
    return all_solutions

def make_DNF(rows, cols):
    """
    use get sols to get all solution for each row and each column,
    will return the AND of each of the solutions
    in the format of:
    for a line we will have a list:
        [ [OPTION 1] , [OPTION 2] ...] 
        where option is constructed of tuples : (location, boolean)
        location is 0...mXn
    """
    DNF_rows = generate(rows, cols, False)
    DNF_cols = generate(cols, rows, True)
    return [DNF_rows,DNF_cols] 

        
def format_converter(option, line_number, num_ortho_lines,cols=False):
    """
    option = [1,0,0]
    list with assigments
    line_number is the number of current line we're working on
    num_ortho_lines is the number of orthogonal lines- if we work on cols, # of rows.
    """
    valid_line =[]
    for i in range(len(option)):
        elm = option[i]
        if cols:
            valid_line.append((line_number+i*num_ortho_lines , elm))
        else:
            valid_line.append(((line_number*num_ortho_lines)+i , elm))
    return valid_line




def generate(lines, lines_ortho, cols_bool=False):
    """
    gets lines- either rows or columns, 
    and generate the DNF for them
    lines ortho will be given cols if we work on rows and the other way around.
    """
    DNF_formula =[]
    for i in range(len(lines)): ##i = which row we're in
        line_or =[]
        r = lines[i]
        solutions = get_sols(len(lines_ortho),r)
        for option in solutions:
            line_or.append(format_converter(option, i,len(lines), cols_bool))
        DNF_formula.append(line_or)
    return DNF_formula
    

b = [[2],[1]]
c = [[1],[2]]
print(make_DNF(b,c))
    
  
# print(format_converter([0,1],1))




# print(format_converter_cols([0,1],1,3))

port = list(list_ports.comports())
for p in port:
   print(p.device)


ser = serial.Serial('/dev/cu.usbserial-AQ00J7ZN')
def make_serial(solutions):
   for line in solutions:
      for ors in line:
          for var,val in ors:
               ser.write(val)
               ser.write(struct.pack('<H', var))
          ser.write('\n')
      ser.write('\n')