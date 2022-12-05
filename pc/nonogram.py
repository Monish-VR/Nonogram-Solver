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

def bitstring_to_bytes(input_str):
    input_int = int(input_str, 2)
    bit_byte = input_int.to_bytes(2,'big')
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
            val = "#" if (board[y][x] == '1') else " "
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
                if not count:
                    buffer = byte_to_bitstring(data)
                else:
                    msg = buffer + byte_to_bitstring(data)
                    flag = msg[:3] #first 3 bits are the flag
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
                        



    except Exception as e:
        print(e)
        ser.close()
        

    return

def tx(ser, index):
    r = [[2],[1],[1,1]]
    c = [[1,1],[2],[1]]
    board = DNF_board.make_DNF(r,c)
    #c = DNF_board.make_serial(2,2,[[[(0, 1), (1, 1)]], [[(2, 1), (3, 0)], [(2, 0), (3, 1)]], [[(0, 1), (2, 0)], [(0, 0), (2, 1)]], [[(1, 1), (3, 1)]]])
    try:
        print("Writing...")
        for i in range(0,len(board),16):
           ser.write(bitstring_to_bytes(board[i:i+16]))
           time.sleep(.25)
        return
    except Exception as e:
        print(e)
        ser.close()

def main():
    print("hello")
    connection = connect()

    index = 0
    while True:
        tx(connection, index)
        print("board #{} sent, waiting until needed".format(index))
        rx(connection)
        print("time to send")
        index += 1

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
    main() 
    
    """ byt = bitstring_to_bytes("1000000000101100")
    print(type(byt))
    string = bytes_to_bitstring(byt) """
    """ r = [[2],[1]]
    c = [[1],[2]]
    d = DNF_board.make_DNF(r,c)
    test_rx(d) """
    #tx(0,0)
