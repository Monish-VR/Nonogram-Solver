'''Automatically find USB Serial Port (jodalyst 8/2019)
'''
import serial.tools.list_ports
import time

def get_usb_port():
    usb_port = list(serial.tools.list_ports.grep("USB"))
    if len(usb_port) == 1:
        print("Automatically found USB-Serial Controller: {}".format(usb_port[0].description))
        return usb_port[0].device
    else:
        ports = list(serial.tools.list_ports.comports())
        port_dict = {i:[ports[i],ports[i].vid] for i in range(len(ports))}
        usb_id=None
        for p in port_dict:
            #print("{}:   {} (Vendor ID: {})".format(p,port_dict[p][0],port_dict[p][1]))
            #print(port_dict[p][0],"UART")
            print("UART" in str(port_dict[p][0]))
            if port_dict[p][1]==1027 and "UART" in str(port_dict[p][0]): #for generic USB Devices
                usb_id = p
        if usb_id== None:
            return False
        else:
            print("Found it")
            print("USB-Serial Controller: Device {}".format(p))
            return port_dict[usb_id][0].device

def test_rx(ser):
    try:
        print("Reading...")
        while True:
            data = ser.read(1) #read the buffer (99/100 timeout will hit)
            if data != b'':  #if not nothing there.
                if data[0]<=127: #if going to be valid ascii...
                    print("ASCII: {}, Value: {}".format(data.decode('ascii'),data[0]))
                else:
                    print("Invalid ASCII, Value: {}".format(data[0]))
    except Exception as e:
        print(e)
        ser.close()

def test_tx(ser):
    try:
        print("Writing...")
        data = 0
        while True:
            ser.write((data).to_bytes(1,'big')) #write the buffer (99/100 timeout will hit)
            print(str(data) + ", " + str(((data).to_bytes(1,'big'))))
            data = (data + 1)%255
            time.sleep(.05)
    except Exception as e:
        print(e)
        ser.close()

def main():
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

    #test_rx(ser)
    test_tx(ser)

if __name__ == "__main__":
    main()
