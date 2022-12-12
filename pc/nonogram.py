from serial_com import get_usb_port
import DNF_board
import serial
import time

msg_flags = {'start' : '111' , 'end': '000', 'assignment':'101'}


def connect():
    s = get_usb_port()  #grab a port
    print("USB Port: "+str(s)) #print it if you got

    if s:
        ser = serial.Serial(port = s,
            baudrate=9600,
            parity=serial.PARITY_NONE,
            stopbits=serial.STOPBITS_ONE,
            bytesize=serial.EIGHTBITS,
            timeout=0.01) #auto-connects already I guess?
        print("Serial Connected!")
        if ser.isOpen():
            print(ser.name + ' is open...')
    else:
        print("No Serial Device :/ Check USB cable connections/device!")
        exit()

    return ser

def bitstring_to_bytes(input_str,num):
    input_int = int(input_str, 2)
    bit_byte = input_int.to_bytes(num,'big')
    #print(bit_byte.hex())
    return bit_byte

def byte_to_bitstring(input_bytes):
    input_int = int.from_bytes(input_bytes,"big")#int(input_bytes.hex(),16)
    #print(input_int)
    bit_str = format(input_int, '08b')
    #print(bit_str)
    return bit_str

def display_board(board,m,n):
    print("SOLUTION ({}x{}):".format(m,n))
    for y in range(m):
        for x in range(n):
            val = board[y][x]#"#" if (board[y][x] == '1') else " "
            print(val,end="")
        print("")
    return

def rx(ser):
    board_done = False
    board = []
    m = 0
    n = 0
    count = 0
    buffer = ""
    try:
        print("Reading...")
        while not board_done:
            data = ser.read(1) #read the buffer (99/100 timeout will hit)
            if data != b'':  #if not nothing there.
                print("rx: " + byte_to_bitstring(data))
                if not count:
                    buffer = byte_to_bitstring(data)
                else:
                    msg = buffer + byte_to_bitstring(data)
                    flag = msg[:3] #first 3 bits are the flag
                    """ print("msg: " + msg)
                    print("flag: " + flag)
                    print("index: " + msg[3:15])
                    print("value: " + msg[15]) """
                    if flag == msg_flags['start']:
                        if m == 0:
                            m = int(msg[3:15],2)
                        else:
                            n = int(msg[3:15],2)
                            board = [ [ None for y in range(m) ] for x in range(n) ]
                    elif flag == msg_flags['end']:
                        display_board(board,m,n)
                        board_done = True
                    elif flag == msg_flags['assignment']:
                        indx = int(msg[3:15],2)
                        x = indx % n
                        y = indx // n
                        board[y][x] = msg[15]
                        display_board(board,m,n)
                count = not count
                        



    except Exception as e:
        print(e)
        ser.close()
        

    return

def input_board():
    row_amnt = input("how many rows do you have? ")
    col_amnt = input("how many columns do you have? ")
    rows_info = []
    cols_info = []
    print('please input contraints as numbers seperated by commas')
    print('example: if a rows constraints are 1,1, please input 1,1')
    for row in range(int(row_amnt)):
        q = "tell me contraints of row " + str(row) + ": "
        constraints = input(q)
        rows_info.append(constraints.split())
    for col in range(int(col_amnt)):
        q = "tell me contraints of col " + str(col) + ": "
        constraints = input(q)
        cols_info.append(constraints.split())
    return rows_info,cols_info


def tx(ser, index):
    #TODO: comment out the below line if you want a hardcoded board
    r,c = input_board()
    print(r)
    print(c)
    #r = [[2],[1],[1,1]]
    #c = [[1,1],[2],[1]]
    board = DNF_board.make_DNF(r,c)
    #c = DNF_board.make_serial(2,2,[[[(0, 1), (1, 1)]], [[(2, 1), (3, 0)], [(2, 0), (3, 1)]], [[(0, 1), (2, 0)], [(0, 0), (2, 1)]], [[(1, 1), (3, 1)]]])
    try:
        print("Writing...")
        print(board)
        for i in range(0,len(board),8):
            print("tx: " + board[i:i+8])
            v = bitstring_to_bytes(board[i:i+8],1)
            ser.write(v)
            #time.sleep(.01)
        return
    except Exception as e:
        print(e)
        ser.close()

def main():
    print("hello")
    connection = connect()

    index = 0
    tx(connection, index)
    rx(connection)
    """ while True:
        tx(connection, index)
        print("board #{} sent, waiting until needed".format(index))
        rx(connection)
        print("time to send")
        index += 1 """

def test_rx(input):
    board_done = False
    board = []
    m = 0
    n = 0
    count = False
    buffer = ""
    i = 0
    while not board_done:
        data = input[i:i+8]
        #print(data)
        print(count)
        data = int(data, 2)
        data = data.to_bytes(1,'big')
        i += 8
        if data != b'':  #if not nothing there.
            if not count:
                buffer = byte_to_bitstring(data)
            else:
                msg = buffer + byte_to_bitstring(data)
                # print(msg)
                # print(type(msg))
                # print(len(msg))
                # print(msg[:3])
                # print("end")
                flag = msg[:3]
                if flag == msg_flags['start']:
                    if m == 0:
                        m = int(msg[3:15],2)
                    else:
                        n = int(msg[3:15],2)
                        board = [ [ None for y in range(m) ] for x in range(n) ]
                elif flag == msg_flags['end']:
                    display_board(board,m,n)
                    board_done = True
                elif flag == msg_flags['assignment']:
                    indx = int(msg[3:15],2)
                    x = indx % n
                    y = indx // n
                    board[y][x] = msg[15]
            count = not count

if __name__ == "__main__":
    print(input_board())
    #main() 
    
    """ byt = bitstring_to_bytes("1000000000101100")
    print(type(byt))
    string = bytes_to_bitstring(byt) """
    """ r = [[2],[1]]
    c = [[1],[2]]
    d = DNF_board.make_DNF(r,c)
    test_rx(d) """
    #tx(0,0)
    
    
"""
2 by 2 : 
1 0
1 1
r = [[2],[1]]
c = [[1],[2]]
2 by 2 : 
1 0
1 0
r = [[1],[1]]
c = [[2],[]]
2 by 3 : 
1 0 1
1 0 1
r = [[1,1],[1,1]]
c = [[2],[], [2]]
2 by 3 : 
1 1 1
1 0 1
r = [[3],[1,1]]
c = [[2],[1], [2]]
3 by 3 : 
1 1 1
1 0 1
0 1 0
r = [[3],[1,1], [1]]
c = [[2],[1,1], [2]]
3 by 3 : 
0 1 0
1 0 1
0 1 0
r = [[1],[1,1], [1]]
c = [[1],[1,1], [1]]
4 by 4 :
0 1 1 0
1 0 0 1
0 1 1 0
0 0 0 1
r = [[2],[1,1], [2] , [1]]
c = [[1],[1,1], [1,1], [1,1]]
4 by 4 :
0 1 1 0
1 0 0 1
0 1 1 1
0 0 0 1
r = [[2],[1,1], [3] , [1]]
c = [[1],[1,1], [1,1], [3]]
5 by 5 : # D AS DANA
0 1 1 0 0
1 0 0 1 0
1 0 0 1 0
1 0 0 1 0
1 1 1 0 0
r = [[2],[1,1], [1,1] , [1,1], [3]]
c = [[4],[1,1], [1,1], [3],[]]
6 by 6 : 
0 1 1 0 0 0
1 0 0 1 0 0
1 0 0 1 0 1
1 0 0 1 0 1
1 1 1 0 0 1
0 0 0 0 0 1
r = [[2],[1,1], [1,1,1] , [1,1,1], [3,1],[1]]
c = [[4],[1,1], [1,1], [3],[],[4]]
6 by 7 : # <3
0 1 1 0 1 1 0
1 0 0 1 0 0 1
1 0 0 1 0 0 1
0 1 0 0 0 1 0
0 0 1 0 1 0 0
0 0 0 1 0 0 0
r = [[2,2],[1,1,1], [1,1,1] , [1,1], [1,1],[1]]
c = [[2],[1,1], [1,1], [2,1],[1,1],[1,1],[2]]
6 by 7 : # <3
0 1 1 0 1 1 0
1 1 1 0 1 1 1
1 1 1 1 1 1 1
0 1 1 1 1 1 0
0 0 1 1 1 0 0
0 0 0 1 0 0 0
r = [[2,2],[3,3], [7] , [5], [3],[1]]
c = [[2],[4], [5], [4],[5],[4],[2]]
10 by 10 : # boat
0 0 0 0 0 0 1 0 0 0
0 0 0 0 0 1 1 0 0 0
0 0 0 0 1 0 1 0 0 0
0 0 0 1 0 0 1 0 0 0
0 0 1 1 1 1 1 0 0 0
0 0 0 0 0 0 1 0 0 0
1 1 1 1 1 1 1 1 1 0
0 1 1 1 1 1 1 1 1 0
0 0 1 1 1 1 1 1 0 0
0 0 0 1 1 1 1 0 0 0
r = [[1],[2],[1,1],[1,1],[5],[1],[9],[8],[6],[4]]
c = [[1],[2],[1,3],[2,4],[1,1,4],[1,1,4],[10],[3],[2],[]]
10 by 10 : # filled boat
0 0 0 0 0 0 1 0 0 0
0 0 0 0 0 1 1 0 0 0
0 0 0 0 1 1 1 0 0 0
0 0 0 1 1 1 1 0 0 0
0 0 1 1 1 1 1 0 0 0
0 0 0 0 0 0 1 0 0 0
1 1 1 1 1 1 1 1 1 1
0 1 1 1 1 1 1 1 1 0
0 0 1 1 1 1 1 1 0 0
0 0 0 1 1 1 1 0 0 0
r = [[1],[2],[3],[4],[5],[1],[10],[8],[6],[4]]
c = [[1],[2],[1,3],[2,4],[3,4],[4,4],[10],[3],[2],[1]]
11 by 10 : # filled boat
0 0 0 0 0 0 1 0 0 0
0 0 0 0 0 1 1 0 0 0
0 0 0 0 1 1 1 0 0 0
0 0 0 1 1 1 1 0 0 0
0 0 1 1 1 1 1 0 0 0
0 0 0 0 0 0 1 0 0 0
1 1 1 1 1 1 1 1 1 1
0 1 1 1 1 1 1 1 1 0
0 0 1 1 1 1 1 1 0 0
0 0 0 1 1 1 1 0 0 0
0 0 0 0 0 0 1 0 0 0
r = [[1],[2],[3],[4],[5],[1],[10],[8],[6],[4], [1]]
c = [[1],[2],[1,3],[2,4],[3,4],[4,4],[11],[3],[2],[1]]
11 by 11 : # butterfly tried....
1 1 1 0 0 0 0 0 0 0 0
0 1 1 0 0 0 0 0 0 0 0
0 1 1 1 0 0 1 1 1 1 0
0 0 0 1 0 1 0 0 0 1 0
0 0 0 0 1 0 0 0 0 1 0
0 0 0 0 1 0 0 0 1 0 0
0 0 0 0 1 0 0 1 0 0 0
0 0 0 0 1 1 1 0 0 0 0
0 0 0 0 1 0 0 0 0 0 0
0 0 0 0 1 0 0 0 0 0 0
r = [[3],[2],[3,4],[1,1,1],[1,1],[1,1],[1,1],[3],[1],[1]]
c = [[1],[3],[3],[2],[6],[1,1],[1,1],[1,1],[3],[]]
"""