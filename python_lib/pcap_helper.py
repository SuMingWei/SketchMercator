import socket, struct
import os

def ip2long(ip):
    """
    Convert an IP string to long
    """
    packedIP = socket.inet_aton(ip)
    return struct.unpack("!L", packedIP)[0]

def long2ip(long):
    """
    Convert long to an IP string
    """
    return socket.inet_ntoa(struct.pack('!L', long))

def convert_pcap_to_rawip(folder_path, file_path):
    print(folder_path)
    print(file_path)
    
    original_full_path = os.path.join(folder_path, file_path)
    temp_full_path = os.path.join(folder_path, "temp.pcap")

    print("[convert_pcap_to_rawip]")
    cmd = "editcap -T rawip %s %s" % (original_full_path, temp_full_path)
    print(cmd)
    os.system(cmd)

    cmd = "mv %s %s" % (temp_full_path, original_full_path)
    print(cmd)
    os.system(cmd)
