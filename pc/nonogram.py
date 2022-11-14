from serial_com import get_usb_port
import DNF_board
import serial
import time

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

def bitstring_to_bytes(bit_str):
    bit_int = int(bit_str, 2)
    print(bit_int)
    bit_byte = bit_int.to_bytes(2,'big')
    print(bit_byte)
    return bit_byte


def rx(ser):
    timeToSend = False
    try:
        print("Reading...")
        while not timeToSend:
            data = ser.read(1) #read the buffer (99/100 timeout will hit)
            timeToSend =  data != b''  #if not nothing there.
    except Exception as e:
        print(e)
        ser.close()

    return

def tx(ser, index):
    c = DNF_board.make_serial([[[(0, 1), (1, 1)]], [[(2, 1), (3, 0)], [(2, 0), (3, 1)]], [[(0, 1), (2, 0)], [(0, 0), (2, 1)]], [[(1, 1), (3, 1)]]])
    print(type(c))
    for i in range(0,len(c),16):
        print(c[i:i+16])
        bitstring_to_bytes(c[i:i+16])
        i = i + 16
        time.sleep(.75)
    return

def main():
    print("hello")
    #connection = connect()

    index = 0
    """ while True:
        rx(connection)
        print("time to send") """
    tx(0, index)
    print("board #{} sent, waiting until needed".format(index))
    index += 1

if __name__ == "__main__":
    main() 
