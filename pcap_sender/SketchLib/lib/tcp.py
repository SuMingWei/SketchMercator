import socket
import traceback

def execute(msg, HOST, PORT):
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.connect((HOST, PORT))
        s.sendall(str.encode(msg))
        s.close()

    except Exception as e:
        print("except")
        s.close()
        traceback.print_exc()

def tcp_execute(msg, tofino_str, api):
    if api == "cpp":
        PORT = 10001
    elif api == "python":
        PORT = 10002

    if tofino_str == 'tofino1':
        HOST = '10.81.1.30'
    elif tofino_str == 'tofino2':
        HOST = '10.81.1.32'
        # HOST = "128.134.233.253" # ss
    
    execute(msg, HOST, PORT)
