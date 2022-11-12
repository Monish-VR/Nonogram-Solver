from hashlib import new
import serial
from serial.tools import list_ports
import struct

PORT_NAME = None
msg_keys = {'start_board' : '111' , 'end_board': '000' , 'start_line' : '110', 'end_line': '001', 'and':'101', 'or':'010'}


#ser = serial.Serial('/dev/cu.usbserial-AQ00J7ZN')

def convert_to_binary_string(number):
    """
    takes an integer and returns a string
    representing this integer in 12 bits
    """
    ret = format(number, '12b')
    full=''
    for i in ret:
        if i=='1':
            full+='1'
        else:
            full+='0'
    return full

#print(convert_to_binary_string(3))

def make_serial(solutions):
    
    generic_end = '0'*13
    start_board = msg_keys['start_board'] +generic_end
    end_board = msg_keys['end_board'] + generic_end
    new_line = msg_keys['start_line'] + generic_end
    end_line = msg_keys['end_line'] + generic_end
    new_or = msg_keys['or'] + generic_end
    
    ans = start_board
    
    for line in solutions:
        ans += new_line
        for ors in line:
            ans += new_or
            for num,val in ors:
                ans += msg_keys['and'] + convert_to_binary_string(num) + str(val)
        ans += end_line

    ans += end_board
    return ans


c = make_serial([[[(0, 1), (1, 1)]], [[(2, 1), (3, 0)], [(2, 0), (3, 1)]], [[(0, 1), (2, 0)], [(0, 0), (2, 1)]], [[(1, 1), (3, 1)]]])
i=0
while i < len(c):
    print(c[i:i+16])
    i = i + 16
    
    #ser.write(ans.decode('bin'))

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
    formula = make_serial(DNF_rows + DNF_cols)
    i=0
    while i < len(formula):
        print(formula[i:i+16])
        i = i + 16
    return DNF_rows + DNF_cols

        
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

        

        

# make_serial([[[[(0, 1), (1, 1)]], [[(2, 1), (3, 0)], [(2, 0), (3, 1)]]], [[[(0, 1), (2, 0)], [(0, 0), (2, 1)]], [[(1, 1), (3, 1)]]]])

