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
    DNF = []

    for i in range(len(rows)): ##i = which row we're in
        row_or =[]
        r = rows[i]
        solutions = get_sols(len(cols),r)
        for option in solutions:
            row_or.append(format_converter(option, i, len(rows)))
        print('row_or',row_or)
        DNF.append(row_or)
    
    for i in range(len(cols)): ##i = which row we're in
        col_or =[]
        c = cols[i]
        solutions = get_sols(len(rows),c)
        for option in solutions:
            col_or.append(format_converter_cols(option, i,len(cols)))
        print('col_or',col_or)
        DNF.append(col_or)
    
    return DNF 
    
            
def format_converter(option, row_number, num_cols):
    """
    option = [1,0,0]
    list with assigments
    """
    valid_line =[]
    for i in range(len(option)):
        elm = option[i]
        valid_line.append(((row_number*num_cols)+i , elm))
    return valid_line

# print(format_converter([0,1],1))


def format_converter_cols(option, col_number, row_len):
    valid_line =[]
    for i in range(len(option)):
        elm = option[i]
        valid_line.append((col_number+i*row_len , elm))
    return valid_line

# print(format_converter_cols([0,1],1,3))




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
        new_line.append(1)
    remaining = get_sols(spots - 1 - cond, conds[1:])
    if remaining is not None:
        if spots - cond > 0:
            new_line.append(0)
        for sol in remaining:
            all_solutions.append(new_line.copy() + sol)
    remaining = get_sols(spots - 1, conds)     
    if remaining is not None:
        for sol in remaining:
            all_solutions.append([0] + sol)
    return all_solutions

